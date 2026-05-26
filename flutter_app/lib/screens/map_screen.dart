import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/device.dart';
import '../providers/app_state.dart';
import '../theme/app_theme.dart';
import '../utils/risk_utils.dart';
import 'device_detail_screen.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> with TickerProviderStateMixin {
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final analysis = context.watch<AppState>().lastAnalysis;
    final devices = analysis?.devices ?? const <DeviceAnalysis>[];

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingLg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppTheme.spacingMd),
              _buildHeader(context, devices.length),
              const SizedBox(height: AppTheme.spacingMd),
              Expanded(
                child: devices.isEmpty
                    ? _buildEmptyState(context)
                    : _buildLiveTopology(context, devices),
              ),
              const SizedBox(height: AppTheme.spacingLg),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, int deviceCount) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Network map',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: AppTheme.onSurface,
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: AppTheme.spacingXs),
        Text(
          deviceCount == 0
              ? 'Run a scan to map connected devices'
              : '$deviceCount connected device${deviceCount == 1 ? '' : 's'} from your latest scan',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.onSurfaceVariant,
              ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.hub_outlined, size: 56, color: AppTheme.primary.withValues(alpha: 0.8)),
          const SizedBox(height: AppTheme.spacingMd),
          Text(
            'No devices mapped yet',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppTheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: AppTheme.spacingSm),
          Text(
            'Scan your Wi-Fi network to see live device topology here.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildLiveTopology(BuildContext context, List<DeviceAnalysis> devices) {
    final router = devices.firstWhere(isLikelyRouter, orElse: () => devices.first);
    final satellites = devices.where((d) => d.ipAddress != router.ipAddress).toList();

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppTheme.surfaceVariant.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(AppTheme.radiusXl),
        border: Border.all(color: AppTheme.outline.withValues(alpha: 0.25)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppTheme.radiusXl),
        child: AnimatedBuilder(
          animation: _pulseController,
          builder: (context, _) {
            return CustomPaint(
              painter: _TopologyLinesPainter(
                nodeCount: satellites.length,
                pulse: _pulseController.value,
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Align(
                    alignment: Alignment.center,
                    child: _MapNodeCard(
                      device: router,
                      pulse: _pulseController.value,
                      isRouter: true,
                      onTap: () => _openDevice(context, router),
                    ),
                  ),
                  ...List.generate(satellites.length, (index) {
                    final angle = (2 * math.pi / satellites.length) * index - math.pi / 2;
                    final alignment = Alignment(
                      math.cos(angle) * 0.78,
                      math.sin(angle) * 0.72,
                    );
                    return Align(
                      alignment: alignment,
                      child: _MapNodeCard(
                        device: satellites[index],
                        pulse: _pulseController.value,
                        onTap: () => _openDevice(context, satellites[index]),
                      ),
                    );
                  }),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void _openDevice(BuildContext context, DeviceAnalysis device) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => DeviceDetailScreen(device: device)),
    );
  }
}

class _TopologyLinesPainter extends CustomPainter {
  _TopologyLinesPainter({required this.nodeCount, required this.pulse});

  final int nodeCount;
  final double pulse;

  @override
  void paint(Canvas canvas, Size size) {
    if (nodeCount == 0) return;

    final center = Offset(size.width / 2, size.height / 2);
    final paint = Paint()
      ..color = AppTheme.primary.withValues(alpha: 0.18 + pulse * 0.18)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    for (var i = 0; i < nodeCount; i++) {
      final angle = (2 * math.pi / nodeCount) * i - math.pi / 2;
      final end = Offset(
        center.dx + math.cos(angle) * size.width * 0.34,
        center.dy + math.sin(angle) * size.height * 0.30,
      );
      canvas.drawLine(center, end, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _TopologyLinesPainter oldDelegate) {
    return oldDelegate.pulse != pulse || oldDelegate.nodeCount != nodeCount;
  }
}

class _MapNodeCard extends StatelessWidget {
  const _MapNodeCard({
    required this.device,
    required this.pulse,
    required this.onTap,
    this.isRouter = false,
  });

  final DeviceAnalysis device;
  final double pulse;
  final VoidCallback onTap;
  final bool isRouter;

  @override
  Widget build(BuildContext context) {
    final color = riskColor(device.riskLevel);
    final scale = isRouter ? 1.0 + pulse * 0.04 : 0.96 + pulse * 0.04;

    return Transform.scale(
      scale: scale,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 150),
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.spacingSm,
              vertical: AppTheme.spacingSm,
            ),
            decoration: BoxDecoration(
              color: AppTheme.surfaceVariant,
              borderRadius: BorderRadius.circular(AppTheme.radiusLg),
              border: Border.all(color: color.withValues(alpha: 0.55)),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.12 + pulse * 0.12),
                  blurRadius: 14,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(AppTheme.spacingSm),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                  ),
                  child: Icon(deviceIcon(device), size: 18, color: color),
                ),
                const SizedBox(width: AppTheme.spacingSm),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isRouter ? 'Router' : deviceLabel(device),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                              color: AppTheme.onSurface,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      Text(
                        device.ipAddress,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: AppTheme.onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
