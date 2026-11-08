import 'dart:convert';

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
  static const supportEmail = String.fromEnvironment(
    'SUPPORT_EMAIL',
    defaultValue: 'optsamtz@gmail.com',
  );

  static const releasesApiUrl = String.fromEnvironment(
    'RELEASES_API_URL',
    defaultValue:
        'https://api.github.com/repos/galaxymushi/askoptsam-eye/releases/latest',
  );
  static const latestApkDownloadUrl = String.fromEnvironment(
    'LATEST_APK_URL',
    defaultValue:
        'https://github.com/galaxymushi/askoptsam-eye/releases/latest/download/app-release.apk',
  );
  static const releasesPageUrl = String.fromEnvironment(
    'RELEASES_PAGE_URL',
    defaultValue:
        'https://github.com/galaxymushi/askoptsam-eye/releases/latest',
  );

  // Encoded default Firebase Web/Android API key for project `askoptsam-eye`
  static const _defaultFbKeyB64 =
      'QUl6YVN5QXFvMEV6WmR6WTRsb0EzLUhUeWVyN1hGY1hVZlJiWFFr';

  static const _envFbApiKey = String.fromEnvironment('FIREBASE_API_KEY');
  static String get fbApiKey => _envFbApiKey.isNotEmpty
      ? _envFbApiKey
      : utf8.decode(base64Decode(_defaultFbKeyB64));

  static const fbAppId = String.fromEnvironment(
    'FIREBASE_APP_ID',
    defaultValue: '1:854595963075:android:48d4c23df5c784816dfa76',
  );
  static const fbMessagingSenderId = String.fromEnvironment(
    'FIREBASE_SENDER_ID',
    defaultValue: '854595963075',
  );
  static const fbProjectId = String.fromEnvironment(
    'FIREBASE_PROJECT_ID',
    defaultValue: 'askoptsam-eye',
  );
  static const fbStorageBucket = String.fromEnvironment(
    'FIREBASE_STORAGE_BUCKET',
    defaultValue: 'askoptsam-eye.firebasestorage.app',
  );

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
