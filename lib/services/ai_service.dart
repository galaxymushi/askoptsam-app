import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;

import '../config.dart';
import '../content/citations.dart';
import '../eye/services/app_settings.dart';
import '../eye/services/gemini_http.dart';
import '../eye/services/gemini_voice.dart';
import '../models.dart';

class AiException implements Exception {
  const AiException(this.kind, [this.detail = '']);
  final String kind; // not-configured | offline | auth | rate | server
  final String detail;

  @override
  String toString() => 'AiException($kind) $detail';
}

class AiService {
  AiService._();

  static final AiService instance = AiService._();

  static const _timeout = Duration(seconds: 90);

  bool get configured => AppConfig.aiConfigured;

  String get _base => AppConfig.aiBaseUrl.replaceAll(RegExp(r'/+$'), '');

  Future<bool> hasConnection() async {
    // dart:io is unavailable on the web; the request surfaces failures itself.
    if (kIsWeb) return true;
    for (final host in <String>[
      Uri.parse(_base).host,
      'generativelanguage.googleapis.com',
    ]) {
      try {
        final result = await InternetAddress.lookup(host)
            .timeout(const Duration(seconds: 4));
        if (result.isNotEmpty && result.first.rawAddress.isNotEmpty) {
          return true;
        }
      } catch (_) {}
    }
    return false;
  }

  /// Streams the assistant reply token by token.
  Stream<String> streamReply(List<ChatMessage> history, {String lang = 'sw'}) async* {
    if (!configured) {
      throw const AiException('not-configured');
    }
    if (!await hasConnection()) {
      throw const AiException('offline');
    }
    if (AppConfig.aiProtocol == 'askoptsam') {
      // Primary ultra-fast path: stream directly from Google Gemini 3.5 Flash-Lite
      // with thinkingLevel: MINIMAL (~0.35s time-to-first-token).
      if (AppSettings.instance.isConfigured) {
        try {
          yield* _streamGeminiDirect(history, lang);
          return;
        } catch (_) {
          // Fall back to hosted AskOptSam endpoint if direct Gemini fails.
        }
      }
      yield* _streamAskOptsam(history, lang);
    } else {
      yield* _streamOpenAi(history);
    }
  }

  Stream<String> _streamGeminiDirect(
    List<ChatMessage> history,
    String lang,
  ) async* {
    final turns = history.where((m) => m.text.trim().isNotEmpty).toList();
    if (turns.isEmpty) throw const AiException('server', 'no user message');
    final contents = <Map<String, dynamic>>[];
    for (final m in turns) {
      contents.add({
        'role': m.isUser ? 'user' : 'model',
        'parts': [
          {'text': m.text.trim()},
        ],
      });
    }
    final systemPrompt = lang == 'en'
        ? 'You are AskOptSam, the friendly expert optometry and eye-health AI assistant for Optsam Eye Care in Dar es Salaam, Tanzania (founded by J.M. Samwel and J.M. Emanueli). Give clear, accurate, well-structured clinical eye-care guidance in English.'
        : 'Wewe ni AskOptSam, msaidizi mahiri na rafiki wa afya ya macho wa kliniki ya Optsam Eye Care, Dar es Salaam, Tanzania (iliyoanzishwa na J.M. Samwel na J.M. Emanueli). Jibu kwa ufasaha, kwa mpangilio mzuri na kwa Kiswahili sanifu.';

    for (final model in const [
      'gemini-3.5-flash-lite',
      'gemini-3.1-flash-lite',
      'gemini-3.5-flash',
    ]) {
      for (final apiKey in <String>{
        AppSettings.instance.apiKey,
        AppSettings.builtInApiKey,
      }) {
        if (apiKey.trim().isEmpty) continue;
        try {
          final uri = Uri.https(
            'generativelanguage.googleapis.com',
            '/v1beta/models/$model:streamGenerateContent',
            {'alt': 'sse'},
          );
          final genConfig = <String, dynamic>{
            'temperature': 0.4,
            'maxOutputTokens': 1024,
            'thinkingConfig': model.startsWith('gemini-2.5')
                ? const {'thinkingBudget': 0}
                : const {'thinkingLevel': 'MINIMAL'},
          };

          final request = http.Request('POST', uri)
            ..headers.addAll({
              'Content-Type': 'application/json',
              'Accept': 'text/event-stream',
              'x-goog-api-key': apiKey,
            })
            ..body = jsonEncode({
              'systemInstruction': {
                'parts': [
                  {'text': systemPrompt},
                ],
              },
              'contents': contents,
              'generationConfig': genConfig,
            });

          final response = await GeminiHttp.client
              .send(request)
              .timeout(const Duration(seconds: 12));

          if (response.statusCode != 200) {
            continue;
          }

          var emitted = 0;
          var prefetchedVoice = false;
          final accumulated = StringBuffer();
          final lines = response.stream
              .transform(utf8.decoder)
              .transform(const LineSplitter())
              .timeout(const Duration(seconds: 30));

          await for (final line in lines) {
            if (!line.startsWith('data:')) continue;
            final payload = line.substring(5).trim();
            if (payload.isEmpty || payload == '[DONE]') continue;
            try {
              final data = jsonDecode(payload) as Map<String, dynamic>;
              final candidates = data['candidates'];
              if (candidates is List && candidates.isNotEmpty) {
                final parts =
                    (candidates.first as Map?)?['content']?['parts'];
                if (parts is List) {
                  for (final part in parts) {
                    if (part is Map &&
                        part['thought'] != true &&
                        part['text'] is String) {
                      final chunk = part['text'] as String;
                      if (chunk.isNotEmpty) {
                        emitted += chunk.length;
                        accumulated.write(chunk);
                        yield chunk;
                        if (!prefetchedVoice &&
                            accumulated.length >= 35 &&
                            RegExp(r'[.!?]\s').hasMatch(accumulated.toString())) {
                          prefetchedVoice = true;
                          GeminiVoice.instance.prefetchFirstSentence(
                            accumulated.toString(),
                          );
                        }
                      }
                    }
                  }
                }
              }
            } catch (_) {}
          }

          if (emitted > 0) {
            if (!prefetchedVoice) {
              GeminiVoice.instance.prefetchFirstSentence(
                accumulated.toString(),
              );
            }
            return;
          }
        } catch (_) {}
      }
    }
    throw const AiException('server', 'gemini direct stream failed');
  }

  /// Collects a complete single-turn response from AskOptSam's AI brain.
  Future<String> completePrompt(String prompt, {String lang = 'sw'}) async {
    final buffer = StringBuffer();
    final turn = ChatMessage(
      id: 'daily-${DateTime.now().microsecondsSinceEpoch}',
      role: 'user',
      text: prompt,
      createdAt: DateTime.now(),
    );
    await for (final chunk in streamReply([turn], lang: lang)) {
      buffer.write(chunk);
    }
    // Source markers (`[S1]`) are stripped so the daily briefing never shows
    // them either — the JSON parser would otherwise keep them in a value.
    return stripCitations(buffer.toString()).trim();
  }

  /// Hosted AskOptsam assistant (same persona, sources and guardrails as the
  /// web app). Server-sent events: meta, token, done, error.
  Stream<String> _streamAskOptsam(List<ChatMessage> history, String lang) async* {
    final turns = history.where((m) => m.text.trim().isNotEmpty).toList();
    final cut = turns.lastIndexWhere((m) => m.isUser);
    if (cut < 0) throw const AiException('server', 'no user message');

    final prior = turns
        .sublist(0, cut)
        .map((m) => {
              'role': m.isUser ? 'user' : 'assistant',
              'content': m.text.trim(),
            })
        .toList();

    final client = http.Client();
    try {
      final request = http.Request('POST', Uri.parse('$_base/api/chat'))
        ..headers.addAll({
          'Content-Type': 'application/json',
          'Accept': 'text/event-stream',
          'Cache-Control': 'no-cache',
        })
        ..body = jsonEncode({
          'message': turns[cut].text.trim(),
          'history': prior,
          'lang': lang == 'en' ? 'en' : 'sw',
        });

      final response =
          await client.send(request).timeout(const Duration(seconds: 12));

      if (response.statusCode == 401 || response.statusCode == 403) {
        throw const AiException('auth');
      }
      if (response.statusCode == 429) {
        throw const AiException('rate');
      }
      if (response.statusCode >= 400) {
        final body = await response.stream.bytesToString();
        throw AiException('server', '${response.statusCode} $body');
      }

      var emitted = 0;
      final lines = response.stream
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .timeout(_timeout);

      await for (final (event, payload) in _sseFrames(lines)) {
        if (event == 'token') {
          final delta = _field(payload, 'delta');
          if (delta != null && delta.isNotEmpty) {
            emitted += delta.length;
            yield delta;
          }
        } else if (event == 'done' && emitted == 0) {
          final text = _field(payload, 'text');
          if (text != null && text.isNotEmpty) {
            emitted += text.length;
            yield text;
          }
        } else if (event == 'error') {
          throw AiException(
            'server',
            _field(payload, 'message') ?? 'stream error',
          );
        }
      }

      if (emitted == 0) {
        throw const AiException('server', 'empty response');
      }
    } on SocketException {
      throw const AiException('offline');
    } on http.ClientException {
      throw const AiException('offline');
    } on TimeoutException {
      throw const AiException('offline');
    } finally {
      client.close();
    }
  }

  Stream<String> _streamOpenAi(List<ChatMessage> history) async* {
    final client = http.Client();
    try {
      final request = http.Request('POST', Uri.parse('$_base/chat/completions'))
        ..headers.addAll({
          'Content-Type': 'application/json',
          'Accept': 'text/event-stream',
          'Authorization': 'Bearer ${AppConfig.aiApiKey}',
        })
        ..body = jsonEncode({
          'model': AppConfig.aiModel,
          'stream': true,
          'temperature': 0.6,
          'messages': [
            {'role': 'system', 'content': AppConfig.aiSystemPrompt},
            ...history.map((m) => {
                  'role': m.isUser ? 'user' : 'assistant',
                  'content': m.text,
                }),
          ],
        });

      final response =
          await client.send(request).timeout(const Duration(seconds: 12));

      if (response.statusCode == 401 || response.statusCode == 403) {
        throw const AiException('auth');
      }
      if (response.statusCode == 429) {
        throw const AiException('rate');
      }
      if (response.statusCode >= 400) {
        final body = await response.stream.bytesToString();
        throw AiException('server', '${response.statusCode} $body');
      }

      final buffer = StringBuffer();
      await for (final chunk in response.stream
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .timeout(_timeout)) {
        if (!chunk.startsWith('data:')) continue;
        final payload = chunk.substring(5).trim();
        if (payload.isEmpty) continue;
        if (payload == '[DONE]') break;
        try {
          final json = jsonDecode(payload) as Map<String, dynamic>;
          final choices = json['choices'] as List?;
          if (choices == null || choices.isEmpty) continue;
          final delta = choices.first['delta'] as Map<String, dynamic>?;
          final content = delta?['content'];
          if (content is String && content.isNotEmpty) {
            buffer.write(content);
            yield content;
          }
        } catch (_) {
          // Ignore keep-alive or malformed frames.
        }
      }

      if (buffer.isEmpty) {
        throw const AiException('server', 'empty response');
      }
    } on SocketException {
      throw const AiException('offline');
    } on http.ClientException {
      throw const AiException('offline');
    } on TimeoutException {
      throw const AiException('offline');
    } finally {
      client.close();
    }
  }

  static Stream<(String, String)> _sseFrames(Stream<String> lines) async* {
    var event = 'message';
    var data = StringBuffer();
    await for (final line in lines) {
      if (line.isEmpty) {
        if (data.isNotEmpty) yield (event, data.toString());
        event = 'message';
        data = StringBuffer();
        continue;
      }
      if (line.startsWith('event:')) {
        event = line.substring(6).trim();
      } else if (line.startsWith('data:')) {
        data.write(line.substring(5).trim());
      }
    }
    if (data.isNotEmpty) yield (event, data.toString());
  }

  static String? _field(String payload, String key) {
    try {
      final json = jsonDecode(payload);
      final value = json is Map ? json[key] : null;
      return value is String ? value : null;
    } catch (_) {
      return null;
    }
  }
}
