import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Backdrop for login, sign-up, and password-reset screens.
///
/// The looping MP4 (`assets/auth_bg.mp4` via `video_player`) was disabled.
/// To restore it, re-add `video_player` in `pubspec.yaml` and reinstate the
/// previous `StatefulWidget` + `VideoPlayerController.asset` implementation.
class AuthVideoBackground extends StatelessWidget {
  const AuthVideoBackground({
    super.key,
    required this.child,
    this.overlayOpacity = 0.5,
  });

  final Widget child;
  final double overlayOpacity;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: Container(color: AppTheme.background),
        ),
        Positioned.fill(
          child: Container(
            color: Colors.black.withValues(alpha: overlayOpacity),
          ),
        ),
        child,
      ],
    );
  }
}
