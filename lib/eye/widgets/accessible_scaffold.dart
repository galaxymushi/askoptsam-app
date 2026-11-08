import 'package:flutter/material.dart';

import '../l10n/strings.dart';
import '../services/speech_service.dart';
import 'eye_ui.dart';
import 'semantic_control.dart';

/// Bottom control that silences the voice from anywhere in the app.
class SpeechActivityBar extends StatelessWidget {
  const SpeechActivityBar({super.key});

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final theme = Theme.of(context);
    return Container(
      color: theme.scaffoldBackgroundColor,
      child: SafeArea(
        top: false,
        minimum: const EdgeInsets.fromLTRB(20, 6, 20, 10),
        child: SemanticControl(
          label: s.stopSpeaking,
          hint: s.silenceHint,
          onTap: SpeechService.instance.stop,
          child: SizedBox(
            height: 60,
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: SpeechService.instance.stop,
              icon: const Icon(Icons.volume_off, size: 26),
              label: Text(s.stopSpeaking),
            ),
          ),
        ),
      ),
    );
  }
}

/// Blue header with a white back pill, matching the Eye mockup.
class EyeScaffold extends StatelessWidget {
  const EyeScaffold({
    super.key,
    this.title = '',
    required this.child,
    this.actions,
    this.bottomBar,
    this.showBack,
    this.appBar,
  });

  final String title;
  final Widget child;
  final List<Widget>? actions;
  final Widget? bottomBar;
  final bool? showBack;
  final PreferredSizeWidget? appBar;

  @override
  Widget build(BuildContext context) {
    final canPop = showBack ?? Navigator.of(context).canPop();
    return Scaffold(
      appBar: appBar ??
          AppBar(
            leadingWidth: canPop ? 150 : 16,
            leading: canPop
                ? const Padding(
                    padding: EdgeInsets.fromLTRB(16, 12, 0, 12),
                    child: RudiPill(),
                  )
                : null,
            title: Text(title),
            actions: actions,
          ),
      body: SafeArea(top: false, child: child),
      bottomNavigationBar: bottomBar ?? const SpeechActivityBar(),
    );
  }
}

/// Backwards-compatible name used by the feature screens.
class AccessibleScaffold extends StatelessWidget {
  const AccessibleScaffold({
    super.key,
    this.title = '',
    required this.child,
    this.actions,
    this.bottomBar,
    this.showBack,
    this.appBar,
  });

  final String title;
  final Widget child;
  final List<Widget>? actions;
  final Widget? bottomBar;
  final bool? showBack;
  final PreferredSizeWidget? appBar;

  @override
  Widget build(BuildContext context) {
    return EyeScaffold(
      title: title,
      actions: actions,
      bottomBar: bottomBar,
      showBack: showBack,
      appBar: appBar,
      child: child,
    );
  }
}

/// Rounded white card used as the body panel of the feature screens.
class FeaturePanel extends StatelessWidget {
  const FeaturePanel({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      top: false,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: theme.scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
        child: child,
      ),
    );
  }
}

/// Small label used above grouped settings.
class EyeSectionLabel extends StatelessWidget {
  const EyeSectionLabel(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text.toUpperCase(),
        style: theme.textTheme.labelMedium?.copyWith(
          fontSize: 14,
          letterSpacing: 1.4,
          fontWeight: FontWeight.w700,
          color: theme.colorScheme.primary,
        ),
      ),
    );
  }
}
