// ignore_for_file: avoid_print
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

/// Generates a gentle two-note chime WAV file for break start.
void main() {
  const sampleRate = 44100;
  const duration = 0.6;
  final numSamples = (sampleRate * duration).toInt();

  final samples = Int16List(numSamples);

  for (var i = 0; i < numSamples; i++) {
    final t = i / sampleRate;

    // Note 1: E5 (659 Hz) with quick decay
    final note1Decay = exp(-t * 8.0);
    final note1 = sin(2 * pi * 659 * t) * note1Decay;

    // Note 2: G5 (784 Hz) delayed by 0.12s with slower decay
    double note2 = 0;
    if (t > 0.12) {
      final t2 = t - 0.12;
      final note2Decay = exp(-t2 * 5.0);
      note2 = sin(2 * pi * 784 * t2) * note2Decay;
      // Soft harmonic
      note2 += sin(2 * pi * 1568 * t2) * note2Decay * 0.15;
    }

    final sample = (note1 * 0.4 + note2 * 0.5) * 0.5;
    samples[i] = (sample * 32767).toInt().clamp(-32768, 32767);
  }

  // Build WAV file
  final dataSize = numSamples * 2;
  final fileSize = 36 + dataSize;
  final buffer = ByteData(44 + dataSize);

  // RIFF header
  buffer.setUint8(0, 0x52); // R
  buffer.setUint8(1, 0x49); // I
  buffer.setUint8(2, 0x46); // F
  buffer.setUint8(3, 0x46); // F
  buffer.setUint32(4, fileSize, Endian.little);
  buffer.setUint8(8, 0x57);  // W
  buffer.setUint8(9, 0x41);  // A
  buffer.setUint8(10, 0x56); // V
  buffer.setUint8(11, 0x45); // E

  // fmt chunk
  buffer.setUint8(12, 0x66); // f
  buffer.setUint8(13, 0x6D); // m
  buffer.setUint8(14, 0x74); // t
  buffer.setUint8(15, 0x20); // (space)
  buffer.setUint32(16, 16, Endian.little);
  buffer.setUint16(20, 1, Endian.little);  // PCM
  buffer.setUint16(22, 1, Endian.little);  // mono
  buffer.setUint32(24, sampleRate, Endian.little);
  buffer.setUint32(28, sampleRate * 2, Endian.little);
  buffer.setUint16(32, 2, Endian.little);
  buffer.setUint16(34, 16, Endian.little);

  // data chunk
  buffer.setUint8(36, 0x64); // d
  buffer.setUint8(37, 0x61); // a
  buffer.setUint8(38, 0x74); // t
  buffer.setUint8(39, 0x61); // a
  buffer.setUint32(40, dataSize, Endian.little);

  for (var i = 0; i < numSamples; i++) {
    buffer.setInt16(44 + i * 2, samples[i], Endian.little);
  }

  final file = File('assets/sounds/chime.wav');
  file.writeAsBytesSync(buffer.buffer.asUint8List());
  print('Generated ${file.path} (${file.lengthSync()} bytes)');
}
