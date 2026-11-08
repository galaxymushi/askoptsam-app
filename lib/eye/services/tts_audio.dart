import 'dart:convert';
import 'dart:math' as math;
import 'dart:typed_data';

/// Strips RIFF containers if present, applies a smooth cosine fade-out on the tail,
/// and appends silence padding so mobile audio codecs/speakers never click, pop,
/// or emit radio static ("mkwanguo") when playback ends.
Uint8List cleanAndFadePcm(
  Uint8List rawPcm, {
  int sampleRate = 24000,
  int fadeMs = 60,
  int trailingSilenceMs = 120,
}) {
  if (rawPcm.length < 4) return rawPcm;

  // 1. If buffer has a RIFF WAVE container, extract the pure PCM payload
  Uint8List pcm = rawPcm;
  if (pcm.length >= 44 &&
      pcm[0] == 0x52 &&
      pcm[1] == 0x49 &&
      pcm[2] == 0x46 &&
      pcm[3] == 0x46 &&
      pcm[8] == 0x57 &&
      pcm[9] == 0x41 &&
      pcm[10] == 0x56 &&
      pcm[11] == 0x45) {
    var offset = 12;
    while (offset + 8 <= pcm.length) {
      final chunkId = String.fromCharCodes(pcm.sublist(offset, offset + 4));
      final chunkSize =
          ByteData.sublistView(pcm).getUint32(offset + 4, Endian.little);
      if (chunkId == 'data') {
        final start = offset + 8;
        final end = (start + chunkSize).clamp(start, pcm.length);
        pcm = pcm.sublist(start, end);
        break;
      }
      offset += 8 + chunkSize;
    }
  }

  // 2. Ensure even number of bytes for 16-bit samples
  final sampleBytes = pcm.length - (pcm.length % 2);
  final totalSamples = sampleBytes ~/ 2;
  if (totalSamples == 0) return pcm;

  final bd = ByteData.sublistView(pcm, 0, sampleBytes);
  final fadeSamples = ((sampleRate * fadeMs) ~/ 1000).clamp(1, totalSamples);
  final fadeStart = totalSamples - fadeSamples;

  // 3. Smooth cosine fade-out on the tail so amplitude smoothly reaches zero
  for (var i = 0; i < fadeSamples; i++) {
    final sampleIndex = fadeStart + i;
    final original = bd.getInt16(sampleIndex * 2, Endian.little);
    final progress = i / fadeSamples;
    final factor = 0.5 * (1.0 + math.cos(math.pi * progress));
    final smoothed = (original * factor).round().clamp(-32768, 32767);
    bd.setInt16(sampleIndex * 2, smoothed, Endian.little);
  }

  // 4. Add trailing silence padding (prevents DAC cutoff pop/radio scratch)
  final silenceSamples = (sampleRate * trailingSilenceMs) ~/ 1000;
  final silenceBytes = silenceSamples * 2;
  final out = Uint8List(sampleBytes + silenceBytes);
  out.setRange(0, sampleBytes, pcm.sublist(0, sampleBytes));
  return out;
}

/// Wraps raw 16-bit PCM in a WAV container so audio players can play the
/// bytes Gemini TTS returns. Gemini sends mono little-endian samples.
Uint8List wavFromPcm16(
  Uint8List pcm, {
  int sampleRate = 24000,
  int channels = 1,
  bool applyFadeAndPadding = true,
}) {
  final cleanPcm = applyFadeAndPadding
      ? cleanAndFadePcm(pcm, sampleRate: sampleRate)
      : pcm;
  const bitsPerSample = 16;
  final blockAlign = channels * bitsPerSample ~/ 8;
  final byteRate = sampleRate * blockAlign;
  final dataLength = cleanPcm.length;

  final header = ByteData(44);
  void tag(int offset, String value) {
    for (var i = 0; i < value.length; i++) {
      header.setUint8(offset + i, value.codeUnitAt(i));
    }
  }

  tag(0, 'RIFF');
  header.setUint32(4, 36 + dataLength, Endian.little);
  tag(8, 'WAVE');
  tag(12, 'fmt ');
  header.setUint32(16, 16, Endian.little);
  header.setUint16(20, 1, Endian.little);
  header.setUint16(22, channels, Endian.little);
  header.setUint32(24, sampleRate, Endian.little);
  header.setUint32(28, byteRate, Endian.little);
  header.setUint16(32, blockAlign, Endian.little);
  header.setUint16(34, bitsPerSample, Endian.little);
  tag(36, 'data');
  header.setUint32(40, dataLength, Endian.little);

  final wav = Uint8List(44 + dataLength);
  wav.setRange(0, 44, header.buffer.asUint8List());
  wav.setRange(44, 44 + dataLength, cleanPcm);
  return wav;
}

/// Reads the first base64 audio payload from a Gemini TTS generateContent response.
String? ttsAudioBase64(Map<String, dynamic> data) {
  final candidates = data['candidates'];
  if (candidates is! List || candidates.isEmpty) return null;
  final candidate = candidates.first;
  if (candidate is! Map) return null;
  final content = candidate['content'];
  if (content is! Map) return null;
  final parts = content['parts'];
  if (parts is! List) return null;
  for (final part in parts) {
    if (part is! Map) continue;
    final inline = part['inlineData'] ?? part['inline_data'];
    if (inline is Map && inline['data'] is String) {
      final encoded = inline['data'] as String;
      if (encoded.isNotEmpty) return encoded;
    }
  }
  return null;
}

/// Extracts and concatenates all PCM audio parts from a Gemini TTS response
/// so multi-part audio responses are never truncated.
Uint8List? ttsExtractAllPcm(Map<String, dynamic> data) {
  final candidates = data['candidates'];
  if (candidates is! List || candidates.isEmpty) return null;
  final candidate = candidates.first;
  if (candidate is! Map) return null;
  final content = candidate['content'];
  if (content is! Map) return null;
  final parts = content['parts'];
  if (parts is! List) return null;

  final builder = BytesBuilder(copy: false);
  for (final part in parts) {
    if (part is! Map) continue;
    final inline = part['inlineData'] ?? part['inline_data'];
    if (inline is Map && inline['data'] is String) {
      final encoded = (inline['data'] as String).trim();
      if (encoded.isNotEmpty) {
        try {
          final decoded = base64Decode(encoded);
          if (decoded.length >= 44 &&
              decoded[0] == 0x52 &&
              decoded[1] == 0x49 &&
              decoded[2] == 0x46 &&
              decoded[3] == 0x46 &&
              decoded[8] == 0x57 &&
              decoded[9] == 0x41 &&
              decoded[10] == 0x56 &&
              decoded[11] == 0x45) {
            var offset = 12;
            var found = false;
            while (offset + 8 <= decoded.length) {
              final chunkId =
                  String.fromCharCodes(decoded.sublist(offset, offset + 4));
              final chunkSize = ByteData.sublistView(decoded)
                  .getUint32(offset + 4, Endian.little);
              if (chunkId == 'data') {
                final start = offset + 8;
                final end = (start + chunkSize).clamp(start, decoded.length);
                builder.add(decoded.sublist(start, end));
                found = true;
                break;
              }
              offset += 8 + chunkSize;
            }
            if (!found) builder.add(decoded);
          } else {
            builder.add(decoded);
          }
        } catch (_) {}
      }
    }
  }
  if (builder.isEmpty) return null;
  return builder.takeBytes();
}

/// Reads the sample rate from a TTS mime type such as
/// `audio/L16;codec=pcm;rate=24000`. Defaults to [fallback].
int sampleRateFromMime(String? mimeType, {int fallback = 24000}) {
  if (mimeType == null) return fallback;
  final match = RegExp(r'rate=(\d+)').firstMatch(mimeType);
  return int.tryParse(match?.group(1) ?? '') ?? fallback;
}

/// Returns the mime type of the first audio part, if present.
String? ttsMimeType(Map<String, dynamic> data) {
  final candidates = data['candidates'];
  if (candidates is! List || candidates.isEmpty) return null;
  final candidate = candidates.first;
  if (candidate is! Map) return null;
  final content = candidate['content'];
  if (content is! Map) return null;
  final parts = content['parts'];
  if (parts is! List) return null;
  for (final part in parts) {
    if (part is! Map) continue;
    final inline = part['inlineData'] ?? part['inline_data'];
    if (inline is Map && inline['mimeType'] is String) {
      return inline['mimeType'] as String;
    }
  }
  return null;
}
