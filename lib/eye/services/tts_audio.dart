import 'dart:convert';
import 'dart:typed_data';

/// Wraps raw 16-bit PCM in a WAV container so audio players can play the
/// bytes Gemini TTS returns. Gemini sends mono little-endian samples.
Uint8List wavFromPcm16(
  Uint8List pcm, {
  int sampleRate = 24000,
  int channels = 1,
}) {
  const bitsPerSample = 16;
  final blockAlign = channels * bitsPerSample ~/ 8;
  final byteRate = sampleRate * blockAlign;
  final dataLength = pcm.length;

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
  wav.setRange(44, 44 + dataLength, pcm);
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
          builder.add(base64Decode(encoded));
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
