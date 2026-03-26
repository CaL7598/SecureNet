import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../theme/app_theme.dart';

class AuthVideoBackground extends StatefulWidget {
  const AuthVideoBackground({
    super.key,
    required this.child,
    this.assetPath = 'assets/auth_bg.mp4',
    this.overlayOpacity = 0.5,
  });

  final Widget child;
  final String assetPath;
  final double overlayOpacity;

  @override
  State<AuthVideoBackground> createState() => _AuthVideoBackgroundState();
}

class _AuthVideoBackgroundState extends State<AuthVideoBackground> {
  late final VideoPlayerController _videoController;

  @override
  void initState() {
    super.initState();
    _videoController = VideoPlayerController.asset(widget.assetPath)
      ..setLooping(true)
      ..setVolume(0)
      ..initialize().then((_) {
        if (!mounted) return;
        _videoController.play();
        setState(() {});
      });
  }

  @override
  void dispose() {
    _videoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: _videoController.value.isInitialized
              ? FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width: _videoController.value.size.width,
                    height: _videoController.value.size.height,
                    child: VideoPlayer(_videoController),
                  ),
                )
              : Container(color: AppTheme.background),
        ),
        Positioned.fill(
          child: Container(
            color: Colors.black.withOpacity(widget.overlayOpacity),
          ),
        ),
        widget.child,
      ],
    );
  }
}

