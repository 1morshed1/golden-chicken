import 'package:flutter/material.dart';
import 'package:golden_chicken/features/live_ai/domain/entities/live_ai_message.dart';

class LiveAiControls extends StatelessWidget {
  const LiveAiControls({
    required this.status,
    required this.onStart,
    required this.onStop,
    super.key,
  });

  final LiveSessionStatus status;
  final VoidCallback onStart;
  final VoidCallback onStop;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isActive = status == LiveSessionStatus.listening ||
        status == LiveSessionStatus.aiSpeaking;

    return Positioned(
      left: 0,
      right: 0,
      bottom: 32,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (status == LiveSessionStatus.connecting)
              const Padding(
                padding: EdgeInsets.only(bottom: 16),
                child: CircularProgressIndicator(),
              ),
            Text(
              _statusLabel,
              style: theme.textTheme.labelMedium?.copyWith(
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: isActive ? onStop : onStart,
              child: Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isActive ? Colors.red : theme.colorScheme.primary,
                  boxShadow: [
                    BoxShadow(
                      color: (isActive ? Colors.red : theme.colorScheme.primary)
                          .withValues(alpha: 0.4),
                      blurRadius: 16,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Icon(
                  isActive ? Icons.stop : Icons.mic,
                  color: Colors.white,
                  size: 32,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String get _statusLabel => switch (status) {
        LiveSessionStatus.idle => 'Tap to start',
        LiveSessionStatus.connecting => 'Connecting...',
        LiveSessionStatus.listening => 'Listening...',
        LiveSessionStatus.aiSpeaking => 'AI is speaking...',
        LiveSessionStatus.error => 'Session ended',
      };
}
