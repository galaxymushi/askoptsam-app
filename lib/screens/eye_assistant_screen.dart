import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import '../l10n.dart';
import '../services/eye_vision_service.dart';
import '../theme.dart';

enum EyeMode { home, camera }

enum EyeCameraAction { soma, uliza, elezea }

class EyeAssistantScreen extends StatefulWidget {
  const EyeAssistantScreen({super.key, this.initialAction});

  final EyeCameraAction? initialAction;

  @override
  State<EyeAssistantScreen> createState() => EyeAssistantScreenState();
}

class EyeAssistantScreenState extends State<EyeAssistantScreen>
    with SingleTickerProviderStateMixin {
  EyeMode _mode = EyeMode.home;
  EyeCameraAction _cameraAction = EyeCameraAction.soma;
  String _readResult = '';
  bool _glassesConnected = true;
  bool _isAnalyzing = false;

  CameraController? _cameraController;
  List<CameraDescription> _availableCameras = [];
  bool _cameraInitializing = false;
  bool _cameraReady = false;

  late final AnimationController _scannerAnim = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2200),
  )..repeat(reverse: true);

  @override
  void initState() {
    super.initState();
    EyeVisionService.instance.initTts();
    if (widget.initialAction != null) {
      openCamera(widget.initialAction!);
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    EyeVisionService.instance.stopSpeaking();
    _scannerAnim.dispose();
    super.dispose();
  }

  Future<void> _initCamera() async {
    if (_cameraReady && _cameraController != null) return;
    setState(() => _cameraInitializing = true);
    try {
      _availableCameras = await availableCameras();
      if (_availableCameras.isNotEmpty) {
        final cam = _availableCameras.firstWhere(
          (c) => c.lensDirection == CameraLensDirection.back,
          orElse: () => _availableCameras.first,
        );
        final controller = CameraController(
          cam,
          ResolutionPreset.medium,
          enableAudio: false,
        );
        await controller.initialize();
        if (mounted) {
          setState(() {
            _cameraController = controller;
            _cameraReady = true;
            _cameraInitializing = false;
          });
        }
      } else {
        if (mounted) setState(() => _cameraInitializing = false);
      }
    } catch (e) {
      debugPrint('Camera init exception: $e');
      if (mounted) {
        setState(() {
          _cameraInitializing = false;
          _cameraReady = false;
        });
      }
    }
  }

  void openCamera(EyeCameraAction action) {
    setState(() {
      _cameraAction = action;
      _mode = EyeMode.camera;
      if (action == EyeCameraAction.soma) {
        _readResult =
            'Shikilia simu utulivu, weka maandishi ndani ya mraba. Tumia tochi kwenye sehemu yenye giza.';
      } else if (action == EyeCameraAction.elezea) {
        _readResult =
            'Mbele yako kuna meza ndogo ya kliniki ya Optsam yenye boksi la miwani na dawa ya macho.';
      } else {
        _readResult =
            'Uliza swali lolote kuhusu unachokiona kupitia kamera au miwani janja.';
      }
    });
    _initCamera();
    try {
      final t = L10nScope.of(context);
      EyeVisionService.instance.speak(_readResult, lang: t.language);
    } catch (_) {
      EyeVisionService.instance.speak(_readResult, lang: 'sw');
    }
  }

  void backToHome() {
    setState(() {
      _mode = EyeMode.home;
    });
    stopSpeaking();
  }

  void stopSpeaking() {
    EyeVisionService.instance.stopSpeaking();
  }

  Future<void> triggerScan() async {
    final t = L10nScope.of(context);
    setState(() => _isAnalyzing = true);
    Uint8List? imageBytes;

    if (_cameraController != null && _cameraController!.value.isInitialized) {
      try {
        final xfile = await _cameraController!.takePicture();
        imageBytes = await xfile.readAsBytes();
      } catch (e) {
        debugPrint('Camera frame capture fallback: $e');
      }
    }

    imageBytes ??= Uint8List.fromList([
      0xFF, 0xD8, 0xFF, 0xE0, 0x00, 0x10, 0x4A, 0x46, 0x49, 0x46, 0x00, 0x01,
      0x01, 0x01, 0x00, 0x48, 0x00, 0x48, 0x00, 0x00, 0xFF, 0xDB, 0x00, 0x43
    ]);

    final actionKey = _cameraAction == EyeCameraAction.soma
        ? 'soma'
        : (_cameraAction == EyeCameraAction.elezea ? 'elezea' : 'uliza');

    final result = await EyeVisionService.instance.analyzeImage(
      imageBytes: imageBytes,
      action: actionKey,
      language: t.language,
    );

    if (mounted) {
      setState(() {
        _readResult = result;
        _isAnalyzing = false;
      });
      EyeVisionService.instance.speak(result, lang: t.language);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = L10nScope.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkPage : Colors.white,
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 240),
          child: _mode == EyeMode.home
              ? _buildHome(context, t, isDark)
              : _buildCamera(context, t, isDark),
        ),
      ),
    );
  }

  Widget _buildHome(BuildContext context, Strings t, bool isDark) {
    const brandBlue = Color(0xFF0A3896);

    return SingleChildScrollView(
      key: const ValueKey('eye_home'),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header: Logo Box with Pure Eye Logo + Title + Subtitle + Settings
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: brandBlue, width: 2.2),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x120A3896),
                      blurRadius: 8,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Image.asset(
                  'assets/branding/eye_logo.png',
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t.get('eyeTitle').isEmpty ? 'Eye' : 'Eye',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        color: isDark ? Colors.white : brandBlue,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      t.get('eyeSubtitle'),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.darkMuted : const Color(0xFF0B1229),
                      ),
                    ),
                  ],
                ),
              ),
              // Settings Circle Button
              IconButton(
                onPressed: () => _showEyeSettingsDialog(context, t, isDark),
                icon: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isDark ? const Color(0xFF2E6BFF) : brandBlue,
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    Icons.settings,
                    color: isDark ? const Color(0xFF2E6BFF) : brandBlue,
                    size: 22,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Smart Glasses Hardware Connection Strip
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF102050) : const Color(0xFFEFF5FF),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isDark ? const Color(0xFF1E2C55) : const Color(0xFFDDE8FB),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.visibility_rounded,
                  size: 20,
                  color: isDark ? const Color(0xFF2E6BFF) : brandBlue,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            t.get('smartGlasses'),
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                              color: isDark ? Colors.white : const Color(0xFF0B1229),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            width: 7,
                            height: 7,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _glassesConnected
                                  ? const Color(0xFF1F9D61)
                                  : Colors.orange,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        _glassesConnected
                            ? t.get('smartGlassesConnected')
                            : 'Bluetooth Offline',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: isDark ? AppColors.darkMuted : AppColors.muted,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: _glassesConnected,
                  onChanged: (v) => setState(() => _glassesConnected = v),
                  activeThumbColor: brandBlue,
                ),
              ],
            ),
          ),

          const SizedBox(height: 18),

          // 1. Soma Button (Read)
          _BigEyeActionCard(
            title: t.get('eyeSoma'),
            subtitle: t.get('eyeSomaSub'),
            icon: Icons.notes_rounded,
            color: brandBlue,
            onTap: () => openCamera(EyeCameraAction.soma),
          ),

          const SizedBox(height: 14),

          // 2. Uliza Button (Ask)
          _BigEyeActionCard(
            title: t.get('eyeUliza'),
            subtitle: t.get('eyeUlizaSub'),
            icon: Icons.mic_rounded,
            color: brandBlue,
            onTap: () => openCamera(EyeCameraAction.uliza),
          ),

          const SizedBox(height: 14),

          // 3. Elezea Button (Describe)
          _BigEyeActionCard(
            title: t.get('eyeElezea'),
            subtitle: t.get('eyeElezeaSub'),
            icon: Icons.volume_up_rounded,
            color: brandBlue,
            onTap: () => openCamera(EyeCameraAction.elezea),
          ),

          const SizedBox(height: 18),

          // Voice Active Status Card
          ValueListenableBuilder<bool>(
            valueListenable: EyeVisionService.instance.isSpeaking,
            builder: (context, speaking, _) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: speaking
                      ? (isDark ? const Color(0xFF0F3260) : const Color(0xFFEBF3FF))
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: speaking
                        ? const Color(0xFF1F9D61)
                        : (isDark ? const Color(0xFF2E6BFF) : brandBlue),
                    width: 2,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      speaking ? Icons.graphic_eq_rounded : Icons.volume_up_rounded,
                      size: 22,
                      color: speaking
                          ? const Color(0xFF1F9D61)
                          : (isDark ? const Color(0xFF2E6BFF) : brandBlue),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        speaking
                            ? (t.language == 'sw' ? 'Inasoma kwa sauti...' : 'Speaking aloud...')
                            : t.get('eyeVoiceActive'),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: speaking
                              ? const Color(0xFF1F9D61)
                              : (isDark ? Colors.white : brandBlue),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          const SizedBox(height: 14),

          // Acha Kusema (Stop Speaking) Button
          OutlinedButton.icon(
            key: const ValueKey('eye_stop_home'),
            onPressed: stopSpeaking,
            icon: Icon(
              Icons.volume_off_rounded,
              color: isDark ? Colors.white : brandBlue,
              size: 22,
            ),
            label: Text(
              t.get('eyeStopSpeaking'),
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w900,
                color: isDark ? Colors.white : brandBlue,
              ),
            ),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: BorderSide(
                color: isDark ? const Color(0xFF2E6BFF) : brandBlue,
                width: 2,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCamera(BuildContext context, Strings t, bool isDark) {
    const brandBlue = Color(0xFF0A3896);
    final title = _cameraAction == EyeCameraAction.soma
        ? t.get('eyeSoma')
        : (_cameraAction == EyeCameraAction.uliza
            ? t.get('eyeUliza')
            : t.get('eyeElezea'));

    return Column(
      key: const ValueKey('eye_camera'),
      children: [
        // Top Blue Bar with "< Rudi" and Mode Title
        Container(
          color: brandBlue,
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
          child: Row(
            children: [
              TextButton.icon(
                onPressed: backToHome,
                style: TextButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: brandBlue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                ),
                icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 16),
                label: Text(
                  t.get('backToSignIn').contains('Rudi') ? 'Rudi' : 'Back',
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),

        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Real Camera Viewfinder / Preview with Laser Scan
                Container(
                  height: 250,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0B1426),
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: brandBlue, width: 3.5),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Live Camera feed if available
                        if (_cameraReady &&
                            _cameraController != null &&
                            _cameraController!.value.isInitialized)
                          SizedBox.expand(
                            child: FittedBox(
                              fit: BoxFit.cover,
                              child: SizedBox(
                                width: _cameraController!.value.previewSize?.height ?? 300,
                                height: _cameraController!.value.previewSize?.width ?? 400,
                                child: CameraPreview(_cameraController!),
                              ),
                            ),
                          )
                        else if (_cameraInitializing)
                          Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const CircularProgressIndicator(
                                  color: Color(0xFF00E5FF),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  t.language == 'sw'
                                      ? 'Inawasha kamera...'
                                      : 'Starting camera...',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),

                        // Dashed frame
                        CustomPaint(
                          size: const Size(double.infinity, 250),
                          painter: _DashedRectPainter(),
                        ),

                        // Animated Scanning Laser Bar
                        AnimatedBuilder(
                          animation: _scannerAnim,
                          builder: (context, _) {
                            return Positioned(
                              top: 20 + _scannerAnim.value * 200,
                              left: 20,
                              right: 20,
                              child: Container(
                                height: 2.5,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF00E5FF),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Color(0xFF00E5FF),
                                      blurRadius: 10,
                                      spreadRadius: 1,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),

                        // Center banner indicator
                        Positioned(
                          bottom: 16,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: brandBlue.withValues(alpha: 0.90),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x66000000),
                                  blurRadius: 10,
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.auto_awesome,
                                  color: Color(0xFF00E5FF),
                                  size: 16,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  t.get('eyeCameraBanner'),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Nimesoma: Result Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurface : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isDark ? const Color(0xFF2E6BFF) : brandBlue,
                      width: 2,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            t.get('eyeReadResultTitle'),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: isDark ? const Color(0xFF2E6BFF) : brandBlue,
                            ),
                          ),
                          ValueListenableBuilder<bool>(
                            valueListenable: EyeVisionService.instance.isSpeaking,
                            builder: (context, speaking, _) {
                              if (!speaking) return const SizedBox.shrink();
                              return const Icon(
                                Icons.graphic_eq_rounded,
                                color: Color(0xFF1F9D61),
                                size: 22,
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (_isAnalyzing)
                        Row(
                          children: [
                            const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.2,
                                color: Color(0xFF0A3896),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              t.language == 'sw'
                                  ? 'Eye Vision AI inachambua picha...'
                                  : 'Eye Vision AI analyzing image...',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF0A3896),
                              ),
                            ),
                          ],
                        )
                      else
                        Text(
                          _readResult,
                          style: TextStyle(
                            fontSize: 14,
                            height: 1.45,
                            fontWeight: FontWeight.w500,
                            color: isDark ? Colors.white : const Color(0xFF0B1229),
                          ),
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Blue Action Button: "Soma maandishi" / Trigger Scan
                ElevatedButton.icon(
                  onPressed: _isAnalyzing ? null : triggerScan,
                  icon: const Icon(Icons.camera_alt_rounded, size: 22),
                  label: Text(
                    _isAnalyzing
                        ? (t.language == 'sw' ? 'Inachambua...' : 'Analyzing...')
                        : t.get('eyeReadAction'),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: brandBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 3,
                  ),
                ),

                const SizedBox(height: 12),

                // Bottom: "Acha kusema"
                OutlinedButton.icon(
                  key: const ValueKey('eye_stop_camera'),
                  onPressed: stopSpeaking,
                  icon: Icon(
                    Icons.volume_off_rounded,
                    color: isDark ? Colors.white : brandBlue,
                    size: 20,
                  ),
                  label: Text(
                    t.get('eyeStopSpeaking'),
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: isDark ? Colors.white : brandBlue,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: BorderSide(
                      color: isDark ? const Color(0xFF2E6BFF) : brandBlue,
                      width: 2,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _showEyeSettingsDialog(BuildContext context, Strings t, bool isDark) async {
    final currentKey = await EyeVisionService.instance.getSavedGeminiKey() ?? '';
    final keyController = TextEditingController(text: currentKey);

    if (!context.mounted) return;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AppColors.darkPage : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            Image.asset('assets/branding/eye_logo.png', width: 28, height: 28),
            const SizedBox(width: 10),
            Text(
              'Eye Mipangilio',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                color: isDark ? Colors.white : const Color(0xFF0A3896),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Lugha & Sauti:',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
              ),
              const SizedBox(height: 4),
              Text(
                'Mfumo wa sauti (Voice Model) unaotumia Flutter TTS kwa Kiswahili na Kiingereza, pamoja na miundombinu ya miwani ya kidijitali (Smart Glasses BLE).',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? AppColors.darkMuted : AppColors.muted,
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'Google Gemini Vision API Key:',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: keyController,
                decoration: InputDecoration(
                  hintText: 'Weka Google Gemini API Key hapa...',
                  hintStyle: const TextStyle(fontSize: 12),
                  filled: true,
                  fillColor: isDark ? AppColors.darkSurface : const Color(0xFFF2F4F8),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                style: const TextStyle(fontSize: 13),
              ),
              const SizedBox(height: 6),
              Text(
                'Ukiweka Gemini API Key, uchambuzi wa picha unafanywa moja kwa moja na Google Gemini 1.5 Flash Vision AI.',
                style: TextStyle(
                  fontSize: 11,
                  color: isDark ? AppColors.darkMuted : AppColors.muted,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(t.get('cancel')),
          ),
          ElevatedButton(
            onPressed: () async {
              await EyeVisionService.instance.saveGeminiKey(keyController.text);
              if (ctx.mounted) Navigator.of(ctx).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0A3896),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Hifadhi'),
          ),
        ],
      ),
    );
  }
}

class _BigEyeActionCard extends StatelessWidget {
  const _BigEyeActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(22),
          boxShadow: const [
            BoxShadow(
              color: Color(0x240A3896),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.16),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.white, size: 26),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: Color(0xD9FFFFFF),
                      fontSize: 12.5,
                      fontWeight: FontWeight.w500,
                      height: 1.25,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              color: Colors.white,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}

class _DashedRectPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xCC00E5FF)
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    const dashWidth = 8.0;
    const dashSpace = 6.0;
    final r = RRect.fromRectAndRadius(
      Rect.fromLTWH(18, 18, size.width - 36, size.height - 36),
      const Radius.circular(20),
    );

    final path = Path()..addRRect(r);
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final next = math.min(distance + dashWidth, metric.length);
        final extract = metric.extractPath(distance, next);
        canvas.drawPath(extract, paint);
        distance += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
