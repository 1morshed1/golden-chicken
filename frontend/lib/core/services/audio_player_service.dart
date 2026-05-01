import 'dart:async';
import 'dart:typed_data';

import 'package:just_audio/just_audio.dart';

class AudioPlayerService {
  AudioPlayerService() : _player = AudioPlayer();

  final AudioPlayer _player;
  final _audioQueue = <Uint8List>[];
  bool _isPlaying = false;

  Future<void> enqueueAudioChunk(List<int> pcmData) async {
    _audioQueue.add(Uint8List.fromList(pcmData));
    if (!_isPlaying) {
      await _playNext();
    }
  }

  Future<void> _playNext() async {
    if (_audioQueue.isEmpty) {
      _isPlaying = false;
      return;
    }
    _isPlaying = true;
    final chunk = _audioQueue.removeAt(0);

    try {
      final source = _PcmAudioSource(chunk, sampleRate: 24000);
      await _player.setAudioSource(source);
      await _player.play();
      await _player.playerStateStream.firstWhere(
        (s) => s.processingState == ProcessingState.completed,
      );
    } on Exception catch (_) {
      // Skip unplayable chunks
    }

    await _playNext();
  }

  Future<void> stop() async {
    _audioQueue.clear();
    _isPlaying = false;
    await _player.stop();
  }

  Future<void> dispose() async {
    await stop();
    await _player.dispose();
  }
}

// StreamAudioSource is the only just_audio API for raw PCM playback.
// ignore: experimental_member_use
class _PcmAudioSource extends StreamAudioSource {
  _PcmAudioSource(this._pcmData, {required this.sampleRate});

  final Uint8List _pcmData;
  final int sampleRate;

  @override
  Future<StreamAudioResponse> request([int? start, int? end]) async {
    final effectiveStart = start ?? 0;
    final effectiveEnd = end ?? _wavBytes.length;
    // Required by StreamAudioSource contract.
    // ignore: experimental_member_use
    return StreamAudioResponse(
      sourceLength: _wavBytes.length,
      contentLength: effectiveEnd - effectiveStart,
      offset: effectiveStart,
      stream: Stream.value(
        _wavBytes.sublist(effectiveStart, effectiveEnd),
      ),
      contentType: 'audio/wav',
    );
  }

  Uint8List get _wavBytes {
    final dataSize = _pcmData.length;
    final header = ByteData(44)
      ..setUint8(0, 0x52) // R
      ..setUint8(1, 0x49) // I
      ..setUint8(2, 0x46) // F
      ..setUint8(3, 0x46) // F
      ..setUint32(4, 36 + dataSize, Endian.little)
      ..setUint8(8, 0x57) // W
      ..setUint8(9, 0x41) // A
      ..setUint8(10, 0x56) // V
      ..setUint8(11, 0x45) // E
      ..setUint8(12, 0x66) // f
      ..setUint8(13, 0x6D) // m
      ..setUint8(14, 0x74) // t
      ..setUint8(15, 0x20) // (space)
      ..setUint32(16, 16, Endian.little)
      ..setUint16(20, 1, Endian.little) // PCM
      ..setUint16(22, 1, Endian.little) // mono
      ..setUint32(24, sampleRate, Endian.little)
      ..setUint32(28, sampleRate * 2, Endian.little)
      ..setUint16(32, 2, Endian.little) // block align
      ..setUint16(34, 16, Endian.little) // bits per sample
      ..setUint8(36, 0x64) // d
      ..setUint8(37, 0x61) // a
      ..setUint8(38, 0x74) // t
      ..setUint8(39, 0x61) // a
      ..setUint32(40, dataSize, Endian.little);

    return Uint8List.fromList([
      ...header.buffer.asUint8List(),
      ..._pcmData,
    ]);
  }
}
