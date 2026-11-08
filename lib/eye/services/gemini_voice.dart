import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

import 'app_settings.dart';
import 'gemini_http.dart';
import 'tts_audio.dart';

class _PcmChunk {
  const _PcmChunk(this.pcm, this.sampleRate);
  final Uint8List pcm;
  final int sampleRate;
}

/// Speech through Google's Gemini text-to-speech models with sentence-level
/// parallel prefetching so speech begins in ~2.5-3s and plays continuously
/// to the end without cutting off mid-way.
class GeminiVoice {
  GeminiVoice._();

  static final GeminiVoice instance = GeminiVoice._();

  static const String model = 'gemini-3.8-flash-lite-tts';

  static const List<String> fallbackTtsModels = [
    'gemini-3.8-flash-lite-tts',
    'gemini-3.1-flash-tts-preview',
    'gemini-2.5-pro-preview-tts',
    'gemini-3.8-flash-tts',
    'gemini-2.5-flash-preview-tts',
  ];

  /// Prebuilt voices supported by the Gemini TTS models.
  static const List<String> voices = [
    'Charon',
    'Kore',
    'Puck',
    'Aoede',
    'Fenrir',
    'Zephyr',
    'Leda',
    'Orus',
  ];

  static const int _maxCachedClips = 16;

  final AudioPlayer _player = AudioPlayer();
  final Map<String, _PcmChunk> _pcmCache = {};
  final StreamController<void> _completionController =
      StreamController<void>.broadcast();
  bool _configured = false;
  int _activeRunId = 0;

  Stream<void> get onComplete => _completionController.stream;

  Future<void> _ensureConfigured() async {
    if (_configured) return;
    await _player.setReleaseMode(ReleaseMode.stop);
    try {
      await _player.setAudioContext(
        AudioContext(
          android: const AudioContextAndroid(
            isSpeakerphoneOn: true,
            stayAwake: true,
            contentType: AndroidContentType.speech,
            usageType: AndroidUsageType.assistant,
            audioFocus: AndroidAudioFocus.gainTransientMayDuck,
          ),
        ),
      );
    } catch (_) {}
    _configured = true;
  }

  /// Splits [raw] into sentence chunks so the first sentence is synthesized
  /// and spoken immediately (~2.5s) while remaining sentences are synthesized
  /// in parallel in the background.
  static List<String> splitSentences(String raw) {
    final cleaned = raw
        .replaceAll(RegExp(r'\r\n|\r'), '\n')
        .replaceAll(RegExp(r'\n+'), '. ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    if (cleaned.isEmpty) return const [];
    if (cleaned.length <= 95) return [cleaned];

    final parts = cleaned
        .split(RegExp(r'(?<=[.!?।:;])\s+'))
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    if (parts.length <= 1) {
      // Long unpunctuated sentence: split around word boundary near 90 chars.
      final words = cleaned.split(' ');
      final chunks = <String>[];
      final buf = StringBuffer();
      var limit = 85;
      for (final w in words) {
        if (buf.isNotEmpty && buf.length + 1 + w.length > limit) {
          chunks.add(buf.toString());
          buf.clear();
          limit = 160;
        }
        if (buf.isNotEmpty) buf.write(' ');
        buf.write(w);
      }
      if (buf.isNotEmpty) chunks.add(buf.toString());
      return chunks;
    }

    final chunks = <String>[];
    // Keep chunk 0 short (first sentence) for fast time-to-first-audio.
    chunks.add(parts.first);

    // Group remaining sentences up to ~170 chars per request so parallel
    // requests are fast and never hit TTS truncation limits.
    final buf = StringBuffer();
    for (var i = 1; i < parts.length; i++) {
      final sentence = parts[i];
      if (buf.isNotEmpty && buf.length + 1 + sentence.length > 170) {
        chunks.add(buf.toString());
        buf.clear();
      }
      if (buf.isNotEmpty) buf.write(' ');
      buf.write(sentence);
    }
    if (buf.isNotEmpty) {
      chunks.add(buf.toString());
    }
    return chunks;
  }

  Future<bool> speak(String text) async {
    final settings = AppSettings.instance;
    final trimmed = text.trim();
    if (trimmed.isEmpty || !settings.isConfigured) return false;

    final runId = ++_activeRunId;
    try {
      await _ensureConfigured();
      await _player.stop();
      if (runId != _activeRunId) return false;

      final voice = settings.geminiVoice;
      final apiKey = settings.apiKey;
      final chunks = splitSentences(trimmed);
      if (chunks.isEmpty) return false;

      // Launch synthesis for ALL chunks concurrently at t = 0!
      final chunkFutures = <Future<_PcmChunk?>>[
        for (final chunk in chunks) _getOrSynthesizeChunk(apiKey, chunk, voice),
      ];

      final firstChunk = await chunkFutures.first;
      if (runId != _activeRunId) return false;
      if (firstChunk == null) return false;

      final firstWav = wavFromPcm16(
        firstChunk.pcm,
        sampleRate: firstChunk.sampleRate,
      );
      final playedFirst = await _playWavBytes(firstWav, '${runId}_0');
      if (!playedFirst || runId != _activeRunId) return false;

      // Continue playing remaining prefetched chunks seamlessly in background.
      unawaited(_finishPlaybackQueue(runId, chunkFutures, firstChunk.sampleRate));
      return true;
    } catch (error) {
      debugPrint('Gemini voice failed: $error');
      return false;
    }
  }

  Future<void> _finishPlaybackQueue(
    int runId,
    List<Future<_PcmChunk?>> chunkFutures,
    int defaultSampleRate,
  ) async {
    try {
      if (chunkFutures.length > 1) {
        // Wait for all remaining parallel requests while chunk 0 is playing.
        final remainingFutures = chunkFutures.sublist(1);
        // Wait for chunk 0 to finish playing on the audio player.
        await _waitForClipEnd(runId);
        if (runId != _activeRunId) return;

        final remainingChunks = await Future.wait(remainingFutures);
        if (runId != _activeRunId) return;

        final combinedPcm = BytesBuilder(copy: false);
        var sampleRate = defaultSampleRate;
        for (final c in remainingChunks) {
          if (c != null && c.pcm.isNotEmpty) {
            combinedPcm.add(c.pcm);
            sampleRate = c.sampleRate;
          }
        }

        if (combinedPcm.isNotEmpty && runId == _activeRunId) {
          final restWav = wavFromPcm16(
            combinedPcm.takeBytes(),
            sampleRate: sampleRate,
          );
          final playedRest = await _playWavBytes(restWav, '${runId}_rest');
          if (playedRest && runId == _activeRunId) {
            await _waitForClipEnd(runId);
          }
        }
      } else {
        await _waitForClipEnd(runId);
      }
    } catch (e) {
      debugPrint('GeminiVoice queue completion error: $e');
    } finally {
      if (runId == _activeRunId) {
        _completionController.add(null);
      }
    }
  }

  Future<void> _waitForClipEnd(int runId) async {
    try {
      await _player.onPlayerComplete.first.timeout(
        const Duration(seconds: 90),
      );
    } catch (_) {}
  }

  Future<bool> _playWavBytes(Uint8List wav, String tag) async {
    await _player.stop();
    if (!kIsWeb) {
      try {
        final dir = await getTemporaryDirectory();
        final file = File('${dir.path}/eye_voice_$tag.wav');
        await file.writeAsBytes(wav, flush: true);
        debugPrint(
          'GeminiVoice: playing ${wav.length} bytes from ${file.path}',
        );
        await _player.play(DeviceFileSource(file.path));
        return true;
      } catch (fileErr) {
        debugPrint('GeminiVoice: file playback fallback to BytesSource: $fileErr');
      }
    }
    await _player.play(BytesSource(wav));
    return true;
  }

  Future<void> stop() async {
    _activeRunId++;
    try {
      await _player.stop();
    } catch (error) {
      debugPrint('Gemini voice could not stop: $error');
    }
  }

  Future<_PcmChunk?> _getOrSynthesizeChunk(
    String apiKey,
    String text,
    String voice,
  ) async {
    final cacheKey = '$voice:$text';
    final cached = _pcmCache[cacheKey];
    if (cached != null) return cached;

    final synthesized = await _synthesizePcm(apiKey, text, voice);
    if (synthesized != null) {
      if (_pcmCache.length >= _maxCachedClips) {
        _pcmCache.remove(_pcmCache.keys.first);
      }
      _pcmCache[cacheKey] = synthesized;
    }
    return synthesized;
  }

  Future<_PcmChunk?> _synthesizePcm(
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

          final sw = Stopwatch()..start();
          final response = await GeminiHttp.client
              .post(
                uri,
                headers: {
                  'Content-Type': 'application/json',
                  'x-goog-api-key': key,
                },
                body: body,
              )
              .timeout(const Duration(seconds: 35));
          sw.stop();
          debugPrint(
            'GeminiVoice ($ttsModel, voice=$voice, len=${text.length}): HTTP ${response.statusCode} in ${sw.elapsedMilliseconds}ms (${response.bodyBytes.length} bytes)',
          );

          if (response.statusCode != 200) {
            continue;
          }

          final data = jsonDecode(utf8.decode(response.bodyBytes));
          if (data is! Map<String, dynamic>) continue;
          final pcm = ttsExtractAllPcm(data);
          if (pcm == null || pcm.isEmpty) continue;
          final sampleRate = sampleRateFromMime(ttsMimeType(data));
          return _PcmChunk(pcm, sampleRate);
        } catch (e) {
          debugPrint('Gemini voice ($ttsModel) error: $e');
        }
      }
    }
    return null;
  }
}
