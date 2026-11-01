import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

/// Build-time configuration. Values are injected with `--dart-define`.
class AppConfig {
  AppConfig._();

  /// `askoptsam` talks to the hosted AskOptsam assistant (same brain, persona
  /// and sources as the web app). `openai` talks to any OpenAI-compatible API.
  static const aiProtocol = String.fromEnvironment(
    'AI_PROTOCOL',
    defaultValue: 'askoptsam',
  );
  static const aiBaseUrl = String.fromEnvironment(
    'AI_BASE_URL',
    defaultValue: 'https://askoptsam-ai-assistant.vercel.app',
  );
  static const aiApiKey = String.fromEnvironment('AI_API_KEY');
  static const aiModel = String.fromEnvironment('AI_MODEL');
  static const aiSystemPrompt = String.fromEnvironment(
    'AI_SYSTEM_PROMPT',
    defaultValue:
        'You are AskOptSam, a friendly assistant. Answer clearly and concisely. '
        'Reply in the language the user writes in (English or Kiswahili).',
  );

  static const supportUrl = String.fromEnvironment('SUPPORT_URL');
  static const supportEmail = String.fromEnvironment('SUPPORT_EMAIL');

  // Payment details (Tanzania). These are the receiving numbers the operator
  // owns; overriding them at build time replaces the defaults.
  static const payAccountName = String.fromEnvironment(
    'PAY_ACCOUNT_NAME',
    defaultValue: 'AskOptSam',
  );
  static const payAirtel = String.fromEnvironment(
    'PAY_AIRTEL',
    defaultValue: '0698383923',
  );
  static const payMpesa = String.fromEnvironment(
    'PAY_MPESA',
    defaultValue: '0726460872',
  );

  static const fbApiKey = String.fromEnvironment('FIREBASE_API_KEY');
  static const fbAppId = String.fromEnvironment('FIREBASE_APP_ID');
  static const fbMessagingSenderId = String.fromEnvironment('FIREBASE_SENDER_ID');
  static const fbProjectId = String.fromEnvironment('FIREBASE_PROJECT_ID');
  static const fbStorageBucket = String.fromEnvironment('FIREBASE_STORAGE_BUCKET');

  static bool get aiConfigured => aiProtocol == 'askoptsam'
      ? aiBaseUrl.isNotEmpty
      : aiBaseUrl.isNotEmpty && aiApiKey.isNotEmpty && aiModel.isNotEmpty;

  static bool get firebaseConfigured =>
      fbApiKey.isNotEmpty &&
      fbAppId.isNotEmpty &&
      fbMessagingSenderId.isNotEmpty &&
      fbProjectId.isNotEmpty;

  static FirebaseOptions? get firebaseOptions {
    if (!firebaseConfigured) return null;
    return FirebaseOptions(
      apiKey: fbApiKey,
      appId: fbAppId,
      messagingSenderId: fbMessagingSenderId,
      projectId: fbProjectId,
      storageBucket: fbStorageBucket.isEmpty ? null : fbStorageBucket,
    );
  }

  static void logMode() {
    debugPrint(
      'AskOptSam config: ai=${aiConfigured ? AppConfig.aiProtocol : 'off'}, '
      'cloud=${firebaseConfigured ? 'on' : 'off'}',
    );
  }
}
