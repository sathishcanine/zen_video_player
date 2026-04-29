import 'package:flutter/material.dart';

/// Full-screen dim scrim with a bright circular progress indicator.
/// Blocks touches ([ModalBarrier]) so the user cannot tap Play/Download
/// again while an ad is being resolved.
class RewardedLoadingOverlay extends StatelessWidget {
  const RewardedLoadingOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ModalBarrier(
            dismissible: false,
            color: Colors.black.withOpacity(0.58),
          ),
          Center(
            child: Opacity(
              opacity: 0.95,
              child: SizedBox(
                width: 52,
                height: 52,
                child: CircularProgressIndicator(
                  strokeWidth: 3.5,
                  backgroundColor: Colors.white.withOpacity(0.14),
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
