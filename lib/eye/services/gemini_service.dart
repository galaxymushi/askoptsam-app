import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../l10n/strings.dart';
import 'app_settings.dart';
import 'gemini_http.dart';
import 'gemini_voice.dart';

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
      'You are aEye, an expert orientation-and-mobility vision guide for a '
      'blind or low-vision person walking with periodic camera snapshots '
      '(not continuous video). Give clear, calm, actionable guidance in two '
      'to three short sentences:\n'
      '1. DANGER FIRST: If a hazard (stairs, drop, curb, ditch, vehicle, pole, '
      'person, or obstacle) is within 2 steps, start immediately with "SIMAMA!" '
      '(in Kiswahili) or "STOP!" (in English).\n'
      '2. STEPS & CLOCK DIRECTION: Give distances in human walking steps and '
      'clock positions where 12 o\'clock is straight ahead (for example: '
      '"3 steps ahead at 12 o\'clock" or "hatua 3 mbele yako saa 12").\n'
      '3. NEXT STEPS ACTION: Tell the person how to move safely for the next '
      '3 to 5 steps before the next snapshot arrives (for example: "Walk 4 '
      'steps straight ahead" or "Move one step left toward 11 o\'clock to '
      'pass the chair").\n'
      '4. CAMERA & LIGHT COACHING: If the image is very dark, blurry, or '
      'aimed at the floor/ceiling, tell them how to adjust the phone. '
      'Do not use lists, markdown, or emoji.';

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
    'gemini-3.5-flash-lite',
    'gemini-3.1-flash-lite',
    'gemini-3.5-flash',
    'gemini-2.5-flash-lite',
  ];

  static String get _languageRule {
    switch (AppSettings.instance.language) {
      case AppLanguage.sw:
        return ' Reply in Kiswahili.';
      case AppLanguage.en:
        return ' Reply in English.';
    }
  }

  static Future<AiResult> describeScene(
    Uint8List jpegBytes, {
    List<String> previousDescriptions = const [],
    String? targetObject,
    ValueChanged<String>? onPartialText,
  }) {
    final memoryBlock = previousDescriptions.isEmpty
        ? ''
        : '\n\nPrevious snapshots (oldest to newest — compare progress, do not '
            'repeat unchanged background, tell the user how far they moved or '
            'how much closer obstacles are now):\n'
            '${previousDescriptions.asMap().entries.map((e) => 'Frame ${e.key + 1}: ${e.value}').join('\n')}';
    final targetBlock = (targetObject == null || targetObject.trim().isEmpty)
        ? ''
        : '\n\nThe user is specifically looking for: "${targetObject.trim()}". '
            'Prioritize locating it with clock direction and step distance.';
    return _vision(
      '$describePrompt$_languageRule$targetBlock$memoryBlock',
      jpegBytes,
      maxTokens: 320,
      onPartialText: onPartialText,
    );
  }

  /// Detects whether the AI description indicates the scene is too dark so the
  /// camera screen can automatically turn on the flashlight for a blind user.
  static bool indicatesLowLight(String text) {
    final lower = text.toLowerCase();
    return lower.contains('giza') ||
        lower.contains('mwanga hafifu') ||
        lower.contains('too dark') ||
        lower.contains('very dark') ||
        lower.contains('low light');
  }

  static Future<AiResult> readText(
    Uint8List jpegBytes, {
    ValueChanged<String>? onPartialText,
  }) =>
      _vision(
        readPrompt,
        jpegBytes,
        maxTokens: 1024,
        onPartialText: onPartialText,
      );

  static Future<AiResult> askAboutImage(
    Uint8List jpegBytes,
    String question, {
    ValueChanged<String>? onPartialText,
  }) =>
      _vision(
        '$askPrompt$_languageRule\n\nQuestion: ${question.trim()}',
        jpegBytes,
        maxTokens: 400,
        onPartialText: onPartialText,
      );

  static Future<AiResult> _vision(
    String prompt,
    Uint8List jpegBytes, {
    int maxTokens = 500,
    ValueChanged<String>? onPartialText,
  }) async {
    final settings = AppSettings.instance;
    if (!settings.isConfigured) {
      return const AiResult.fail('no_key');
    }
    return _generate(
      settings.apiKey,
      settings.model,
      [
        {'text': prompt},
        {
          'inline_data': {
            'mime_type': 'image/jpeg',
            'data': base64Encode(jpegBytes),
          },
        },
      ],
      maxTokens: maxTokens,
      onPartialText: onPartialText,
    );
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
    ValueChanged<String>? onPartialText,
  }) async {
    // First try the primary model (gemini-3.5-flash-lite) with the configured key
    final primary = await _generateSingle(
      apiKey,
      model,
      parts,
      maxTokens: maxTokens,
      onPartialText: onPartialText,
    );
    if (primary.isOk) return primary;

    // Fallback to built-in key / fallback models if needed
    for (final fallbackModel in models) {
      for (final candidateKey in <String>{
        apiKey,
        AppSettings.builtInApiKey,
      }) {
        if (candidateKey.trim().isEmpty) continue;
        if (candidateKey == apiKey && fallbackModel == model) continue;
        final res = await _generateSingle(
          candidateKey,
          fallbackModel,
          parts,
          maxTokens: maxTokens,
          onPartialText: onPartialText,
        );
        if (res.isOk) return res;
      }
    }
    return primary;
  }

  static Map<String, dynamic> _thinkingConfigFor(String model) {
    if (model.startsWith('gemini-2.5')) {
      return const {'thinkingBudget': 0};
    }
    return const {'thinkingLevel': 'MINIMAL'};
  }

  static Future<AiResult> _generateSingle(
    String apiKey,
    String model,
    List<Map<String, dynamic>> parts, {
    int maxTokens = 500,
    ValueChanged<String>? onPartialText,
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
        'thinkingConfig': _thinkingConfigFor(model),
      },
    };

    // When onPartialText is provided, use SSE streaming for ~0.4s first-word
    // display and early first-sentence voice prefetching while vision streams!
    if (onPartialText != null) {
      try {
        final streamed = await _streamSingle(
          apiKey,
          model,
          body,
          onPartialText: onPartialText,
        );
        if (streamed != null && streamed.isOk) {
          return streamed;
        }
      } catch (_) {}
    }

    try {
      final sw = Stopwatch()..start();
      var response = await _post(apiKey, model, body);
      if (response.statusCode == 400) {
        // Retry without thinkingConfig if the model rejects it.
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
      final clean = text.trim();
      if (maxTokens > 20) {
        GeminiVoice.instance.prefetchFirstSentence(clean);
      }
      return AiResult.ok(clean);
    } on TimeoutException {
      return const AiResult.fail('timeout');
    } on http.ClientException {
      return const AiResult.fail('network');
    } catch (_) {
      return const AiResult.fail('unknown');
    }
  }

  static Future<AiResult?> _streamSingle(
    String apiKey,
    String model,
    Map<String, dynamic> body, {
    required ValueChanged<String> onPartialText,
  }) async {
    final uri = Uri.https(
      'generativelanguage.googleapis.com',
      '/v1beta/models/$model:streamGenerateContent',
      {'alt': 'sse'},
    );
    final request = http.Request('POST', uri)
      ..headers.addAll({
        'Content-Type': 'application/json',
        'Accept': 'text/event-stream',
        'x-goog-api-key': apiKey,
      })
      ..body = jsonEncode(body);

    final response = await GeminiHttp.client
        .send(request)
        .timeout(const Duration(seconds: 14));
    if (response.statusCode != 200) return null;

    final accumulated = StringBuffer();
    var prefetched = false;
    final lines = response.stream
        .transform(utf8.decoder)
        .transform(const LineSplitter())
        .timeout(const Duration(seconds: 25));

    await for (final line in lines) {
      if (!line.startsWith('data:')) continue;
      final payload = line.substring(5).trim();
      if (payload.isEmpty || payload == '[DONE]') continue;
      try {
        final data = jsonDecode(payload) as Map<String, dynamic>;
        final chunk = _extractText(data);
        if (chunk != null && chunk.isNotEmpty) {
          accumulated.write(chunk);
          final current = accumulated.toString().trim();
          onPartialText(current);
          if (!prefetched &&
              current.length >= 28 &&
              RegExp(r'[.!?]\s').hasMatch(current)) {
            prefetched = true;
            GeminiVoice.instance.prefetchFirstSentence(current);
          }
        }
      } catch (_) {}
    }

    final finalClean = accumulated.toString().trim();
    if (finalClean.isEmpty) return null;
    if (!prefetched) {
      GeminiVoice.instance.prefetchFirstSentence(finalClean);
    }
    return AiResult.ok(finalClean);
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
