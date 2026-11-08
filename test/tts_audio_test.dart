import 'dart:convert';
import 'dart:math' as math;
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:asksam/eye/services/tts_audio.dart';

void main() {
  group('TTS Audio tests', () {
    test('cleanAndFadePcm smooths tail and pads silence to prevent audio scratch', () {
      const sampleRate = 24000;
      final samples = sampleRate; // 1s
      final pcm = Uint8List(samples * 2);
      final bd = ByteData.sublistView(pcm);
      for (var i = 0; i < samples; i++) {
        final val = (math.sin(2 * math.pi * 440 * i / sampleRate) * 20000).round();
        bd.setInt16(i * 2, val, Endian.little);
      }

      final initialLastSample = bd.getInt16((samples - 1) * 2, Endian.little);
      expect(initialLastSample, isNot(equals(0)));

      final cleaned = cleanAndFadePcm(pcm, sampleRate: sampleRate);
      final cleanedBd = ByteData.sublistView(cleaned);
      final cleanedSamples = cleaned.length ~/ 2;

      expect(cleanedSamples, greaterThan(samples));
      // Trailing sample of audio before padding should be 0 (faded out)
      expect(cleanedBd.getInt16((samples - 1) * 2, Endian.little), equals(0));
      // Last sample of silence padding should be 0
      expect(cleanedBd.getInt16((cleanedSamples - 1) * 2, Endian.little), equals(0));
    });

    test('wavFromPcm16 creates a valid 44-byte RIFF WAVE header', () {
      final pcm = Uint8List(24000 * 2); // 1 sec of zeroes
      final wav = wavFromPcm16(pcm, sampleRate: 24000);

      expect(wav.length, greaterThan(44));
      // RIFF
      expect(wav[0], equals(0x52));
      expect(wav[1], equals(0x49));
      expect(wav[2], equals(0x46));
      expect(wav[3], equals(0x46));
      // WAVE
      expect(wav[8], equals(0x57));
      expect(wav[9], equals(0x41));
      expect(wav[10], equals(0x56));
      expect(wav[11], equals(0x45));
    });

    test('ttsExtractAllPcm unpacks multi-part audio and unwraps nested WAV', () {
      final samplePcm = Uint8List.fromList(List.generate(100, (i) => i % 256));
      final sampleWav = wavFromPcm16(samplePcm, sampleRate: 24000, applyFadeAndPadding: false);
      final fakeData = {
        'candidates': [
          {
            'content': {
              'parts': [
                {
                  'inlineData': {
                    'mimeType': 'audio/wav',
                    'data': base64Encode(sampleWav),
                  }
                }
              ]
            }
          }
        ]
      };

      final pcm = ttsExtractAllPcm(fakeData);
      expect(pcm, isNotNull);
      // When nested WAV is provided, it extracts the data chunk payload
      expect(pcm!.length, equals(samplePcm.length));
      expect(pcm, equals(samplePcm));
    });
  });
}
