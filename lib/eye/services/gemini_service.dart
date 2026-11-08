import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../l10n/strings.dart';
import 'app_settings.dart';
import 'gemini_http.dart';

class AiResult {
  const AiResult.ok(this.text) : errorCode = null;
  const AiResult.fail(this.errorCode) : text = null;

  final String? text;
  final String? errorCode;

  bool get isOk => text != null;
}

class GeminiService {
  GeminiService._();

  static const String describePrompt =
      'You are Eye, a calm vision assistant for a blind or low-vision person. '
      'Describe the scene in front of the camera in two to four short '
      'sentences. Prioritize anything that affects walking: obstacles in the '
      'path, stairs, curbs, vehicles, cyclists, people, doorways, and readable '
      'signs. Use clock directions where the person is facing twelve o\'clock. '
      'If the path ahead is clear, say so. Do not use lists, markdown, or '
      'emoji.';

  static const String readPrompt =
      'Transcribe every piece of text visible in this image exactly as it '
      'appears. Keep line breaks between separate lines, signs, or paragraphs. '
      'Do not describe the image, do not add commentary, and do not use '
      'markdown. If there is no readable text, reply exactly: No text found.';

  static const String askPrompt =
      'You are Eye, a vision assistant for a blind or low-vision person. '
      'Answer the question using only what is visible in the image. Be brief '
      'and concrete: two to four short sentences, spoken aloud. Name positions '
      'with clock directions when useful. Do not use lists, markdown, or emoji. '
      'If the image does not show the answer, say so plainly.';

  static const List<String> models = [
    'gemini-2.5-flash',
    'gemini-3.5-flash',
    'gemini-3-flash-preview',
  ];

  static String get _languageRule {
    switch (AppSettings.instance.language) {
      case AppLanguage.sw:
        return ' Reply in Kiswahili.';
      case AppLanguage.en:
        return ' Reply in English.';
    }
  }

  static Future<AiResult> describeScene(Uint8List jpegBytes) => _vision(
        '$describePrompt$_languageRule',
        jpegBytes,
        maxTokens: 400,
      );

  static Future<AiResult> readText(Uint8List jpegBytes) =>
      _vision(readPrompt, jpegBytes, maxTokens: 1024);

  static Future<AiResult> askAboutImage(
    Uint8List jpegBytes,
    String question,
  ) =>
      _vision(
        '$askPrompt$_languageRule\n\nQuestion: ${question.trim()}',
        jpegBytes,
        maxTokens: 400,
      );

  static Future<AiResult> _vision(
    String prompt,
    Uint8List jpegBytes, {
    int maxTokens = 500,
  }) async {
    final settings = AppSettings.instance;
    if (!settings.isConfigured) {
      return const AiResult.fail('no_key');
    }
    return _generate(settings.apiKey, settings.model, [
      {'text': prompt},
      {
        'inline_data': {
          'mime_type': 'image/jpeg',
          'data': base64Encode(jpegBytes),
        },
      },
    ], maxTokens: maxTokens);
  }

  static Future<AiResult> testKey(String apiKey, String model) async {
    if (apiKey.trim().isEmpty) {
      return const AiResult.fail('no_key');
    }
    return _generate(apiKey.trim(), model, [
      {'text': 'Reply with the single word OK.'},
    ], maxTokens: 10);
  }

  static Future<AiResult> _generate(
    String apiKey,
    String model,
    List<Map<String, dynamic>> parts, {
    int maxTokens = 500,
  }) async {
    // First try the primary model (gemini-2.5-flash) with the configured key
    final primary = await _generateSingle(
      apiKey,
      model,
      parts,
      maxTokens: maxTokens,
    );
    if (primary.isOk) return primary;

    // Fallback to secondary key / fallback models if needed
    for (final fallbackModel in models) {
      for (final candidateKey in <String>{
        apiKey,
        AppSettings.builtInApiKey,
        AppSettings.secondaryApiKey,
      }) {
        if (candidateKey == apiKey && fallbackModel == model) continue;
        final res = await _generateSingle(
          candidateKey,
          fallbackModel,
          parts,
          maxTokens: maxTokens,
        );
        if (res.isOk) return res;
      }
    }
    return primary;
  }

  static Future<AiResult> _generateSingle(
    String apiKey,
    String model,
    List<Map<String, dynamic>> parts, {
    int maxTokens = 500,
  }) async {
    final body = <String, dynamic>{
      'contents': [
        {
          'role': 'user',
          'parts': parts,
        },
      ],
      'generationConfig': {
        'temperature': 0.2,
        'maxOutputTokens': maxTokens,
        'thinkingConfig': {'thinkingBudget': 0},
      },
    };

    try {
      final sw = Stopwatch()..start();
      var response = await _post(apiKey, model, body);
      if (response.statusCode == 400) {
        // Some models reject thinkingConfig; retry without it.
        (body['generationConfig'] as Map<String, dynamic>)
            .remove('thinkingConfig');
        response = await _post(apiKey, model, body);
      }
      sw.stop();
      debugPrint(
        'GeminiService ($model): HTTP ${response.statusCode} in ${sw.elapsedMilliseconds}ms',
      );

      if (response.statusCode != 200) {
        return AiResult.fail(_errorCode(response.statusCode));
      }

      final data =
          jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
      final text = _extractText(data);
      if (text == null || text.trim().isEmpty) {
        final blockReason =
            (data['promptFeedback'] as Map?)?['blockReason']?.toString();
        if (blockReason != null) {
          return const AiResult.fail('blocked');
        }
        return const AiResult.fail('empty');
      }
      return AiResult.ok(text.trim());
    } on TimeoutException {
      return const AiResult.fail('timeout');
    } on http.ClientException {
      return const AiResult.fail('network');
    } catch (_) {
      return const AiResult.fail('unknown');
    }
  }

  static Future<http.Response> _post(
    String apiKey,
    String model,
    Map<String, dynamic> body,
  ) {
    final uri = Uri.https(
      'generativelanguage.googleapis.com',
      '/v1beta/models/$model:generateContent',
    );
    return GeminiHttp.client
        .post(
          uri,
          headers: {
            'Content-Type': 'application/json',
            'x-goog-api-key': apiKey,
          },
          body: jsonEncode(body),
        )
        .timeout(const Duration(seconds: 40));
  }

  static String? _extractText(Map<String, dynamic> data) {
    final candidates = data['candidates'];
    if (candidates is! List || candidates.isEmpty) return null;
    final candidate = candidates.first;
    if (candidate is! Map) return null;
    if (candidate['finishReason'] == 'SAFETY') return null;
    final content = candidate['content'];
    if (content is! Map) return null;
    final parts = content['parts'];
    if (parts is! List) return null;
    final buffer = StringBuffer();
    for (final part in parts) {
      if (part is Map && part['thought'] != true && part['text'] is String) {
        buffer.write(part['text']);
      }
    }
    return buffer.toString();
  }

  static String _errorCode(int statusCode) {
    switch (statusCode) {
      case 400:
        return 'bad_request';
      case 401:
      case 403:
        return 'auth';
      case 404:
        return 'model';
      case 429:
        return 'quota';
      default:
        return statusCode >= 500 ? 'server' : 'http';
    }
  }
}
