import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../l10n.dart';
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
  bool _speaking = false;
  String _readResult = '';
  bool _glassesConnected = true;
  late final AnimationController _scannerAnim = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2200),
  )..repeat(reverse: true);

  @override
  void initState() {
    super.initState();
    if (widget.initialAction != null) {
      openCamera(widget.initialAction!);
    }
  }

  Timer? _speechTimer;

  @override
  void dispose() {
    _speechTimer?.cancel();
    _scannerAnim.dispose();
    super.dispose();
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
    _speak(_readResult);
  }

  void backToHome() {
    setState(() {
      _mode = EyeMode.home;
    });
    stopSpeaking();
  }

  void _speak(String text) {
    _speechTimer?.cancel();
    setState(() => _speaking = true);
    // Audio synthesis feedback hook (survives offline or online)
    _speechTimer = Timer(const Duration(seconds: 4), () {
      if (mounted) setState(() => _speaking = false);
    });
  }

  void stopSpeaking() {
    _speechTimer?.cancel();
    setState(() => _speaking = false);
  }

  void triggerScan() {
    final t = L10nScope.of(context);
    setState(() {
      if (_cameraAction == EyeCameraAction.soma) {
        _readResult = t.language == 'sw'
            ? "'Karakana ya Miwani ya Optsam: Lenzi za tiba zenye kinga ya mwanga wa kompyuta (Blue-Cut UV400). Pata punguzo la 10% wiki hii.'"
            : "'Optsam Eye Care Workshop: Anti-reflective Blue-Cut computer prescription lenses. 10% discount this week.'";
      } else if (_cameraAction == EyeCameraAction.elezea) {
        _readResult = t.language == 'sw'
            ? 'Mbele yako kuna korido yenye mwanga mzuri. Upande wa kulia kuna mlango ulio wazi wenye bango la Optometrist Room.'
            : 'In front of you is a well-lit hallway. On your right is an open door with the Optometrist Room sign.';
      } else {
        _readResult = t.language == 'sw'
            ? 'Hizi ni dawa za kulainisha macho (Artificial Tears). Zitumie kwa matone mawili kila asubuhi na jioni.'
            : 'These are lubricating eye drops (Artificial Tears). Apply two drops every morning and evening.';
      }
    });
    _speak(_readResult);
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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isDark ? const Color(0xFF2E6BFF) : brandBlue,
                width: 2,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.volume_up_rounded,
                  size: 22,
                  color: isDark ? const Color(0xFF2E6BFF) : brandBlue,
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    t.get('eyeVoiceActive'),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : brandBlue,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Acha Kusema (Stop Speaking) Button
          OutlinedButton.icon(
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
                // Viewfinder with Dashed Border (Exact as screenshot)
                Container(
                  height: 240,
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
                        // Dashed frame
                        CustomPaint(
                          size: const Size(double.infinity, 240),
                          painter: _DashedRectPainter(),
                        ),
                        // Animated Scanning Line
                        AnimatedBuilder(
                          animation: _scannerAnim,
                          builder: (context, _) {
                            return Positioned(
                              top: 20 + _scannerAnim.value * 190,
                              left: 20,
                              right: 20,
                              child: Container(
                                height: 2,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF00E5FF),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Color(0xFF00E5FF),
                                      blurRadius: 8,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                        // Center blue pill: "Elekeza kamera kwenye maandishi"
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: brandBlue,
                            borderRadius: BorderRadius.circular(18),
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x66000000),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                          child: Text(
                            t.get('eyeCameraBanner'),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
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
                          if (_speaking)
                            const Icon(
                              Icons.graphic_eq_rounded,
                              color: Color(0xFF1F9D61),
                              size: 20,
                            ),
                        ],
                      ),
                      const SizedBox(height: 6),
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

                // Blue Action Button: "Soma maandishi"
                ElevatedButton.icon(
                  onPressed: triggerScan,
                  icon: const Icon(Icons.notes_rounded, size: 22),
                  label: Text(
                    t.get('eyeReadAction'),
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

  void _showEyeSettingsDialog(BuildContext context, Strings t, bool isDark) {
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
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Lugha & Sauti:',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
            ),
            const SizedBox(height: 4),
            Text(
              'Msaidizi wa maono kwa Kiswahili na Kiingereza. Imeunganishwa na OptSam Smart Glasses.',
              style: TextStyle(
                fontSize: 12,
                color: isDark ? AppColors.darkMuted : AppColors.muted,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'Toleo: Eye 0.3.3 (AskOptSam Unified v2.4.0)',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: isDark ? const Color(0xFF2E6BFF) : const Color(0xFF0A3896),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Sawa', style: TextStyle(fontWeight: FontWeight.w700)),
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
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(26),
      elevation: 3,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(26),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          child: Row(
            children: [
              Icon(icon, size: 36, color: Colors.white),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFFD6E3FF),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DashedRectPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.85)
      ..strokeWidth = 2.2
      ..style = PaintingStyle.stroke;

    const dashWidth = 8.0;
    const dashSpace = 6.0;
    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(12, 12, size.width - 24, size.height - 24),
      const Radius.circular(20),
    );
    final path = Path()..addRRect(rrect);

    for (final metric in path.computeMetrics()) {
      double distance = 0.0;
      while (distance < metric.length) {
        final next = distance + dashWidth;
        final extract = metric.extractPath(distance, math.min(next, metric.length));
        canvas.drawPath(extract, paint);
        distance = next + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
