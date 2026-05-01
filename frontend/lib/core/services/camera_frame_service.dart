import 'dart:async';
import 'dart:convert';

import 'package:camera/camera.dart';

class CameraFrameService {
  CameraController? _controller;
  Timer? _captureTimer;
  bool _isCapturing = false;

  CameraController? get controller => _controller;
  bool get isInitialized => _controller?.value.isInitialized ?? false;

  Future<void> initialize() async {
    final cameras = await availableCameras();
    if (cameras.isEmpty) return;

    final backCamera = cameras.firstWhere(
      (c) => c.lensDirection == CameraLensDirection.back,
      orElse: () => cameras.first,
    );

    _controller = CameraController(
      backCamera,
      ResolutionPreset.low,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );
    await _controller!.initialize();
  }

  void startCapturing({
    required void Function(String base64Frame) onFrame,
    Duration interval = const Duration(seconds: 1),
  }) {
    if (_isCapturing || _controller == null || !_controller!.value.isInitialized) {
      return;
    }
    _isCapturing = true;
    _captureTimer = Timer.periodic(interval, (_) async {
      if (!_isCapturing) return;
      try {
        final file = await _controller!.takePicture();
        final bytes = await file.readAsBytes();
        onFrame(base64Encode(bytes));
      } on CameraException catch (_) {
        // Skip failed frames
      }
    });
  }

  void stopCapturing() {
    _isCapturing = false;
    _captureTimer?.cancel();
    _captureTimer = null;
  }

  Future<void> dispose() async {
    stopCapturing();
    await _controller?.dispose();
    _controller = null;
  }
}
