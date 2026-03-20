import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key, required this.onGetStarted});

  final VoidCallback onGetStarted;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _logoScale;
  late final Animation<double> _logoOpacity;
  late final Animation<double> _ringPulse;
  late final Animation<double> _textFloat;
  bool _finished = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _logoScale = Tween<double>(begin: 0.9, end: 1.05).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _logoOpacity = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _ringPulse = Tween<double>(begin: 0.0, end: 8.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _textFloat = Tween<double>(begin: -2, end: 2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    Future<void>.delayed(const Duration(milliseconds: 2200), () {
      if (!mounted || _finished) return;
      _finished = true;
      widget.onGetStarted();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingXl),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppTheme.background,
                    const Color(0xFF121224),
                    AppTheme.background,
                  ],
                ),
              ),
              child: Column(
                children: [
                  const Spacer(flex: 2),
                  _buildAnimatedLogo(),
                  const SizedBox(height: AppTheme.spacingXl),
                  Transform.translate(
                    offset: Offset(0, _textFloat.value),
                    child: Text(
                      'SecureNet',
                      style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: AppTheme.onSurface,
                            letterSpacing: -0.3,
                          ),
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingSm),
                  Text(
                    'Network Security, Simplified',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppTheme.onSurfaceVariant,
                        ),
                  ),
                  const SizedBox(height: AppTheme.spacingLg),
                  _buildLoadingRow(context),
                  const Spacer(flex: 3),
                  _buildAnimatedNetworkCard(context),
                  const SizedBox(height: AppTheme.spacingMd),
                  Text(
                    'Initializing secure environment...',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: AppTheme.onSurfaceVariant,
                        ),
                  ),
                  const SizedBox(height: AppTheme.spacingXl),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildAnimatedLogo() {
    return Opacity(
      opacity: _logoOpacity.value,
      child: Transform.scale(
        scale: _logoScale.value,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 120 + _ringPulse.value,
              height: 120 + _ringPulse.value,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppTheme.primary.withOpacity(0.35),
                  width: 2,
                ),
              ),
            ),
            Container(
              width: 100 + _ringPulse.value / 2,
              height: 100 + _ringPulse.value / 2,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppTheme.primary.withOpacity(0.25),
                  width: 2,
                ),
              ),
            ),
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.primary,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primary.withOpacity(0.35),
                    blurRadius: 24,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: const Icon(
                Icons.shield_rounded,
                size: 40,
                color: AppTheme.onPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedNetworkCard(BuildContext context) {
    final waveValue = 0.55 + (_controller.value * 0.1);

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 400),
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      decoration: BoxDecoration(
        color: AppTheme.surfaceVariant.withOpacity(0.6),
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: AppTheme.primary.withOpacity(0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.wifi, color: AppTheme.primary, size: 24),
              const SizedBox(width: AppTheme.spacingSm),
              Text(
                'Protected Network',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppTheme.onSurface,
                    ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingXs),
          Text(
            'Scanning for vulnerabilities...',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: AppTheme.spacingSm),
          Row(
            children: [
              Text(
                'Network Integrity',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: AppTheme.onSurface,
                    ),
              ),
              const SizedBox(width: AppTheme.spacingSm),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: waveValue,
                    backgroundColor: AppTheme.background,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppTheme.primary,
                    ),
                    minHeight: 6,
                  ),
                ),
              ),
              const SizedBox(width: AppTheme.spacingSm),
              Text(
                '${(waveValue * 100).round()}%',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: AppTheme.onSurface,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingRow(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _pulseDot(0.0),
        const SizedBox(width: AppTheme.spacingSm),
        _pulseDot(0.2),
        const SizedBox(width: AppTheme.spacingSm),
        _pulseDot(0.4),
      ],
    );
  }

  Widget _pulseDot(double phase) {
    final value = ((_controller.value + phase) % 1.0);
    final opacity = 0.35 + (value * 0.65);
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: AppTheme.primary.withOpacity(opacity),
        shape: BoxShape.circle,
      ),
    );
  }
}
