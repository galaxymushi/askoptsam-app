import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../l10n/strings.dart';
import '../services/app_settings.dart';
import '../services/gemini_service.dart';
import '../services/gemini_voice.dart';
import '../services/speech_service.dart';
import '../theme.dart';
import '../widgets/accessible_scaffold.dart';
import '../widgets/eye_ui.dart';
import '../widgets/semantic_control.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final AppSettings _settings = AppSettings.instance;
  late double _speechRate;
  late double _textScale;
  late bool _autoSpeak;
  late String _geminiVoice;

  bool _testingVoice = false;
  String? _voiceMessage;
  bool _voicePassed = false;

  @override
  void initState() {
    super.initState();
    _speechRate = _settings.speechRate;
    _textScale = _settings.textScale;
    _autoSpeak = _settings.autoSpeak;
    _geminiVoice = _settings.geminiVoice;
  }

  Future<void> _setLanguage(AppLanguage language) async {
    await _settings.setLanguage(language);
    await SpeechService.instance.setLanguage(language);
    if (!mounted) return;
    final s = S.of(context);
    setState(() => _voiceMessage = null);
    SpeechService.instance.speak(
      '${s.languageTitle}: '
      '${language == AppLanguage.sw ? s.swahili : s.english}',
      force: true,
      urgent: true,
    );
  }

  Future<void> _testVoice() async {
    final s = S.of(context);
    setState(() {
      _testingVoice = true;
      _voiceMessage = null;
    });
    final started = await GeminiVoice.instance.speak(s.voiceTestLine);
    if (!mounted) return;
    setState(() {
      _testingVoice = false;
      _voicePassed = started;
      _voiceMessage = started ? s.voiceOk(_geminiVoice) : s.voiceFail;
    });
    if (!started) {
      SpeechService.instance.speak(_voiceMessage!, force: true, urgent: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final theme = Theme.of(context);
    final muted = theme.textTheme.bodyMedium?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );
    return AccessibleScaffold(
      title: s.settingsTitle,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        children: [
          SectionTitle(s.languageTitle, number: '01'),
          Text(s.languageNote, style: muted),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _LanguageOption(
                  label: s.swahili,
                  selected: _settings.language == AppLanguage.sw,
                  onTap: () => _setLanguage(AppLanguage.sw),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _LanguageOption(
                  label: s.english,
                  selected: _settings.language == AppLanguage.en,
                  onTap: () => _setLanguage(AppLanguage.en),
                ),
              ),
            ],
          ),
          const SizedBox(height: 26),
          SectionTitle(s.voiceTitle, number: '02'),
          Text(
            '${s.speechSpeed}: ${s.percent((50 + _speechRate * 100).round())}',
            style: theme.textTheme.bodyLarge,
          ),
          Slider(
            value: _speechRate,
            min: 0.25,
            max: 0.8,
            divisions: 11,
            label: '${(50 + _speechRate * 100).round()}%',
            onChanged: (value) => setState(() => _speechRate = value),
            onChangeEnd: (value) async {
              await _settings.setSpeechRate(value);
              await SpeechService.instance.setRate(value);
              await SpeechService.instance.speak(
                s.pick(
                  'Hivi ndivyo nitakavyosema.',
                  'This is how fast I will speak.',
                ),
                force: true,
                urgent: true,
              );
            },
          ),
          Text(s.speedHelp, style: muted),
          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            value: _autoSpeak,
            title: Text(s.autoSpeak, style: theme.textTheme.bodyLarge),
            subtitle: Text(s.autoSpeakHelp, style: muted),
            onChanged: (value) {
              setState(() => _autoSpeak = value);
              _settings.setAutoSpeak(value);
            },
          ),
          const SizedBox(height: 8),
          Text(s.voiceSelectLabel, style: theme.textTheme.bodyLarge),
          const SizedBox(height: 4),
          Text(s.voiceSelectHelp, style: muted),
          const SizedBox(height: 10),
          DropdownMenu<String>(
            initialSelection: _geminiVoice,
            expandedInsets: EdgeInsets.zero,
            label: Text(s.voiceSelectLabel),
            textStyle: theme.textTheme.bodyLarge,
            dropdownMenuEntries: [
              for (final voice in GeminiVoice.voices)
                DropdownMenuEntry(value: voice, label: voice),
            ],
            onSelected: (value) {
              if (value == null) return;
              setState(() => _geminiVoice = value);
              _settings.setGeminiVoice(value);
            },
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: (_testingVoice || !_settings.isConfigured)
                ? null
                : _testVoice,
            icon: _testingVoice
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 3),
                  )
                : const Icon(Icons.graphic_eq),
            label: Text(_testingVoice ? s.testing : s.testVoice),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(66),
            ),
          ),
          if (_voiceMessage != null) ...[
            const SizedBox(height: 10),
            Semantics(
              liveRegion: !AppSettings.instance.autoSpeak,
              child: Text(
                _voiceMessage!,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: _voicePassed
                      ? theme.colorScheme.primary
                      : theme.colorScheme.error,
                ),
              ),
            ),
          ],
          const SizedBox(height: 26),
          SectionTitle(s.textTitle, number: '03'),
          Text(
            '${s.textSize}: ${s.percent((_textScale * 100).round())}',
            style: theme.textTheme.bodyLarge,
          ),
          Slider(
            value: _textScale,
            min: 1.0,
            max: 2.0,
            divisions: 10,
            label: '${(_textScale * 100).round()}%',
            onChanged: (value) => setState(() => _textScale = value),
            onChangeEnd: (value) async {
              await _settings.setTextScale(value);
              if (!mounted) return;
              SpeechService.instance.speak(
                '${s.textSize}: ${s.percent((value * 100).round())}',
                force: true,
              );
            },
          ),
          const SizedBox(height: 26),
          SectionTitle(s.themeTitle, number: '04'),
          const SizedBox(height: 6),
          for (final mode in AppThemeMode.values) ...[
            _ThemeOption(
              mode: mode,
              selected: _settings.themeMode == mode,
              onTap: () => _settings.setThemeMode(mode),
            ),
            const SizedBox(height: 10),
          ],
          const SizedBox(height: 26),
          SectionTitle(
            s.pick('Ufunguo wa Gemini AI', 'Gemini AI API Key'),
            number: '05',
          ),
          const SizedBox(height: 6),
          _ApiKeyCard(
            apiKey: _settings.apiKey,
            onSave: (key) async {
              await _settings.setApiKey(key);
              setState(() {});
            },
          ),
          const SizedBox(height: 26),
          SectionTitle(s.aboutTitle, number: '06'),
          Text(
            s.aboutText,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 10),
          Text(s.aboutCredits, style: theme.textTheme.bodySmall),
        ],
      ),
    );
  }
}

class _ApiKeyCard extends StatefulWidget {
  const _ApiKeyCard({
    required this.apiKey,
    required this.onSave,
  });

  final String apiKey;
  final ValueChanged<String> onSave;

  @override
  State<_ApiKeyCard> createState() => _ApiKeyCardState();
}

class _ApiKeyCardState extends State<_ApiKeyCard> {
  bool _testing = false;
  String? _testStatus;
  bool _testPassed = false;

  Future<void> _showEditDialog() async {
    final s = S.of(context);
    final controller = TextEditingController(text: widget.apiKey);
    final key = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: Text(s.pick('Weka Ufunguo wa Gemini', 'Enter Gemini API Key')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              s.pick(
                'Pata ufunguo wa bure kutoka Google AI Studio (aistudio.google.com) kisha ubandike hapa:',
                'Get a free API key from Google AI Studio (aistudio.google.com) and paste it below:',
              ),
              style: const TextStyle(fontSize: 13.5, height: 1.4),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: controller,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'AIzaSy...',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.paste_rounded),
                  onPressed: () async {
                    final data = await Clipboard.getData(Clipboard.kTextPlain);
                    if (data?.text != null) {
                      controller.text = data!.text!.trim();
                    }
                  },
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(s.pick('Ghairi', 'Cancel')),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(controller.text.trim()),
            child: Text(s.pick('Hifadhi', 'Save')),
          ),
        ],
      ),
    );
    if (key != null) {
      widget.onSave(key);
      setState(() => _testStatus = null);
    }
  }

  Future<void> _testKey() async {
    final s = S.of(context);
    setState(() {
      _testing = true;
      _testStatus = null;
    });
    final res = await GeminiService.testKey(
      widget.apiKey,
      AppSettings.instance.model,
    );
    if (!mounted) return;
    setState(() {
      _testing = false;
      _testPassed = res.isOk;
      _testStatus = res.isOk
          ? s.pick('Ufunguo unafanya kazi kikamilifu! (OK)',
              'API Key is active and working! (OK)')
          : s.pick(
              'Hitilafu ya ufunguo: ${res.errorCode ?? 'Haijaunganishwa'}. Weka ufunguo kutoka aistudio.google.com',
              'Key error: ${res.errorCode ?? 'Failed'}. Check key on aistudio.google.com');
    });
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final theme = Theme.of(context);
    final masked = widget.apiKey.length > 10
        ? '${widget.apiKey.substring(0, 6)}...${widget.apiKey.substring(widget.apiKey.length - 4)}'
        : (widget.apiKey.isNotEmpty ? 'Imehifadhiwa' : 'Haijawekwa');

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.colorScheme.outline, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.vpn_key_outlined, size: 24),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  masked,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                onPressed: _showEditDialog,
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            s.pick(
              'aEye inahitaji ufunguo wa bure wa Gemini API ili kusoma maandishi, kuelezea mazingira, na kujibu maswali ya picha.',
              'aEye requires a free Gemini API key to transcribe text, describe scenes, and answer vision questions.',
            ),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontSize: 13.5,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _testing ? null : _testKey,
                  icon: _testing
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2.5),
                        )
                      : const Icon(Icons.network_check_rounded, size: 18),
                  label: Text(s.pick('Pima Ufunguo', 'Test Key')),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton.icon(
                  onPressed: _showEditDialog,
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: Text(s.pick('Badilisha', 'Change Key')),
                ),
              ),
            ],
          ),
          if (_testStatus != null) ...[
            const SizedBox(height: 10),
            Text(
              _testStatus!,
              style: TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: _testPassed
                    ? theme.colorScheme.primary
                    : theme.colorScheme.error,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _LanguageOption extends StatelessWidget {
  const _LanguageOption({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SemanticControl(
      label: label,
      selected: selected,
      onTap: onTap,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 64,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? theme.colorScheme.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: theme.colorScheme.primary, width: 2.5),
          ),
          child: Text(
            label,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontSize: 21,
              fontWeight: FontWeight.w700,
              color: selected
                  ? theme.colorScheme.onPrimary
                  : theme.colorScheme.primary,
            ),
          ),
        ),
      ),
    );
  }
}

class _ThemeOption extends StatelessWidget {
  const _ThemeOption({
    required this.mode,
    required this.selected,
    required this.onTap,
  });

  final AppThemeMode mode;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final theme = Theme.of(context);
    final previewTheme = AppTheme.build(mode);
    final name = s.themeName(mode);
    final description = s.themeDescription(mode);
    return SemanticControl(
      label: name,
      hint: description,
      selected: selected,
      onTap: onTap,
      child: Material(
        color: previewTheme.scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: selected
                    ? previewTheme.colorScheme.primary
                    : theme.colorScheme.outline,
                width: selected ? 3 : 1.5,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: previewTheme.colorScheme.primary,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: previewTheme.colorScheme.secondary,
                      width: 4,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: previewTheme.textTheme.titleMedium?.copyWith(
                          fontSize: 24,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        description,
                        style: previewTheme.textTheme.bodyMedium?.copyWith(
                          fontSize: 16,
                          color: previewTheme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                if (selected)
                  Icon(
                    Icons.check_circle,
                    size: 34,
                    color: previewTheme.colorScheme.primary,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
