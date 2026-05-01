import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:golden_chicken/core/di/injection_container.dart';
import 'package:golden_chicken/features/live_ai/domain/entities/live_ai_message.dart';
import 'package:golden_chicken/features/live_ai/presentation/bloc/live_ai_bloc.dart';
import 'package:golden_chicken/features/live_ai/presentation/bloc/live_ai_event.dart';
import 'package:golden_chicken/features/live_ai/presentation/bloc/live_ai_state.dart';
import 'package:golden_chicken/features/live_ai/presentation/widgets/live_ai_controls.dart';
import 'package:golden_chicken/features/live_ai/presentation/widgets/live_transcript_overlay.dart';

class LiveAiScreen extends StatelessWidget {
  const LiveAiScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<LiveAiBloc>(),
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          title: const Text('Live AI'),
          actions: [
            BlocBuilder<LiveAiBloc, LiveAiState>(
              buildWhen: (prev, curr) =>
                  prev.status != curr.status ||
                  prev.isCameraActive != curr.isCameraActive,
              builder: (context, state) {
                final isActive = state.status == LiveSessionStatus.listening ||
                    state.status == LiveSessionStatus.aiSpeaking;
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (isActive)
                      IconButton(
                        onPressed: () => context
                            .read<LiveAiBloc>()
                            .add(const LiveAiCameraToggled()),
                        icon: Icon(
                          state.isCameraActive
                              ? Icons.videocam
                              : Icons.videocam_off,
                        ),
                      ),
                    if (isActive)
                      IconButton(
                        onPressed: () => context
                            .read<LiveAiBloc>()
                            .add(const LiveAiStopRequested()),
                        icon: const Icon(Icons.close),
                      ),
                  ],
                );
              },
            ),
          ],
        ),
        body: BlocConsumer<LiveAiBloc, LiveAiState>(
          listenWhen: (prev, curr) =>
              prev.errorMessage != curr.errorMessage &&
              curr.errorMessage != null,
          listener: (context, state) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage!),
                backgroundColor: Colors.red,
              ),
            );
          },
          builder: (context, state) {
            return Stack(
              children: [
                if (state.isCameraActive)
                  _CameraPreview(
                    controller: context
                        .read<LiveAiBloc>()
                        .cameraFrameService
                        .controller,
                  )
                else
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _statusIcon(state.status),
                          size: 80,
                          color: Colors.white24,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _statusHint(state.status),
                          style:
                              Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    color: Colors.white38,
                                  ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                LiveTranscriptOverlay(
                  inputTranscript: state.inputTranscript,
                  outputTranscript: state.outputTranscript,
                ),
                LiveAiControls(
                  status: state.status,
                  onStart: () => context
                      .read<LiveAiBloc>()
                      .add(const LiveAiStartRequested()),
                  onStop: () => context
                      .read<LiveAiBloc>()
                      .add(const LiveAiStopRequested()),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  IconData _statusIcon(LiveSessionStatus status) => switch (status) {
        LiveSessionStatus.idle => Icons.mic_none,
        LiveSessionStatus.connecting => Icons.sync,
        LiveSessionStatus.listening => Icons.hearing,
        LiveSessionStatus.aiSpeaking => Icons.record_voice_over,
        LiveSessionStatus.error => Icons.error_outline,
      };

  String _statusHint(LiveSessionStatus status) => switch (status) {
        LiveSessionStatus.idle =>
          'Start a live session to talk\nwith your AI farm assistant',
        LiveSessionStatus.connecting => 'Setting up your session...',
        LiveSessionStatus.listening => "Speak now — I'm listening",
        LiveSessionStatus.aiSpeaking => '',
        LiveSessionStatus.error => 'Something went wrong.\nTap to try again.',
      };
}

class _CameraPreview extends StatelessWidget {
  const _CameraPreview({required this.controller});

  final CameraController? controller;

  @override
  Widget build(BuildContext context) {
    if (controller == null || !controller!.value.isInitialized) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white24),
      );
    }
    return SizedBox.expand(
      child: FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          width: controller!.value.previewSize!.height,
          height: controller!.value.previewSize!.width,
          child: CameraPreview(controller!),
        ),
      ),
    );
  }
}
