import 'dart:async';

import 'package:record/record.dart';

class AudioRecorderService {
  AudioRecorderService() : _recorder = AudioRecorder();

  final AudioRecorder _recorder;
  StreamSubscription<List<int>>? _streamSubscription;

  Future<bool> hasPermission() => _recorder.hasPermission();

  Future<Stream<List<int>>> startRecording() async {
    final stream = await _recorder.startStream(
      const RecordConfig(
        encoder: AudioEncoder.pcm16bits,
        sampleRate: 16000,
        numChannels: 1,
        bitRate: 256000,
      ),
    );
    return stream;
  }

  Future<void> stopRecording() async {
    await _streamSubscription?.cancel();
    _streamSubscription = null;
    await _recorder.stop();
  }

  Future<void> dispose() async {
    await stopRecording();
    await _recorder.dispose();
  }
}
