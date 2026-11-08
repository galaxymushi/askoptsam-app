import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

import 'app_settings.dart';
import 'tts_audio.dart';

/// Speech through Google's Gemini text-to-speech preview model.
///
/// Returns `false` (never throws) so the caller can fall back to the phone's
/// own voice when the model is unavailable, offline, or over quota.
class GeminiVoice {
  GeminiVoice._();

  static final GeminiVoice instance = GeminiVoice._();

  static const String model = 'gemini-2.5-flash-preview-tts';

  static const List<String> fallbackTtsModels = [
    'gemini-2.5-flash-preview-tts',
    'gemini-3.8-flash-tts',
  ];

  /// Prebuilt voices supported by the Gemini TTS models.
  static const List<String> voices = [
    'Kore',
    'Puck',
    'Charon',
    'Aoede',
    'Fenrir',
    'Zephyr',
    'Leda',
    'Orus',
  ];

  static const int _maxCachedClips = 8;

  final AudioPlayer _player = AudioPlayer();
  final Map<String, Uint8List> _cache = {};
  bool _configured = false;

  Stream<void> get onComplete => _player.onPlayerComplete;

  Future<void> _ensureConfigured() async {
    if (_configured) return;
    await _player.setReleaseMode(ReleaseMode.stop);
    _configured = true;
  }

  Future<bool> speak(String text) async {
    final settings = AppSettings.instance;
    if (text.trim().isEmpty || !settings.isConfigured) return false;
    try {
      await _ensureConfigured();
      final cacheKey = '${settings.geminiVoice}:$text';
      var wav = _cache[cacheKey];
      if (wav == null) {
        wav = await _synthesize(
          settings.apiKey,
          text,
          settings.geminiVoice,
        );
        if (wav == null) return false;
        if (_cache.length >= _maxCachedClips) {
          _cache.remove(_cache.keys.first);
        }
        _cache[cacheKey] = wav;
      }
      await _player.stop();
      try {
        await _player.play(BytesSource(wav));
      } catch (_) {
        final dir = await getTemporaryDirectory();
        final file = File('${dir.path}/eye_voice_clip.wav');
        await file.writeAsBytes(wav, flush: true);
        await _player.play(DeviceFileSource(file.path));
      }
      return true;
    } catch (error) {
      debugPrint('Gemini voice failed: $error');
      return false;
    }
  }

  Future<void> stop() async {
    try {
      await _player.stop();
    } catch (error) {
      debugPrint('Gemini voice could not stop: $error');
    }
  }

  Future<Uint8List?> _synthesize(
    String apiKey,
    String text,
    String voice,
  ) async {
    final keysToTry = <String>{
      apiKey,
      AppSettings.builtInApiKey,
      AppSettings.secondaryApiKey,
    };

    for (final ttsModel in fallbackTtsModels) {
      for (final key in keysToTry) {
        if (key.trim().isEmpty) continue;
        try {
          final uri = Uri.https(
            'generativelanguage.googleapis.com',
            '/v1beta/models/$ttsModel:generateContent',
          );
          final body = jsonEncode({
            'contents': [
              {
                'parts': [
                  {'text': text},
                ],
              },
            ],
            'generationConfig': {
              'responseModalities': ['AUDIO'],
              'speechConfig': {
                'voiceConfig': {
                  'prebuiltVoiceConfig': {'voiceName': voice},
                },
              },
            },
          });

          final response = await http
              .post(
                uri,
                headers: {
                  'Content-Type': 'application/json',
                  'x-goog-api-key': key,
                },
                body: body,
              )
              .timeout(const Duration(seconds: 45));

          if (response.statusCode != 200) {
            debugPrint(
              'Gemini voice ($ttsModel) returned HTTP ${response.statusCode}',
            );
            continue;
          }

          final data = jsonDecode(utf8.decode(response.bodyBytes));
          if (data is! Map<String, dynamic>) continue;
          final encoded = ttsAudioBase64(data);
          if (encoded == null) continue;
          final pcm = base64Decode(encoded);
          if (pcm.isEmpty) continue;
          final sampleRate = sampleRateFromMime(ttsMimeType(data));
          return wavFromPcm16(pcm, sampleRate: sampleRate);
        } catch (e) {
          debugPrint('Gemini voice ($ttsModel) error: $e');
        }
      }
    }
    return null;
  }
}
