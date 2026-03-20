import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/api_service.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final ApiService _api = ApiService();
  late Future<bool> _healthFuture;

  @override
  void initState() {
    super.initState();
    _healthFuture = _api.healthCheck();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingLg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppTheme.spacingMd),
              _buildHeader(context),
              const SizedBox(height: AppTheme.spacingXl),
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceVariant.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(AppTheme.radiusXl),
                    border: Border.all(color: AppTheme.outline.withOpacity(0.2)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(AppTheme.radiusXl),
                    child: Center(
                      child: AspectRatio(
                        aspectRatio: 1.1,
                        child: _buildTopology(),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppTheme.spacingLg),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Network map',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppTheme.onSurface,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                  ),
            ),
            const SizedBox(height: AppTheme.spacingXs),
            Text(
              'High-level view of your Wi‑Fi topology',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
        FutureBuilder<bool>(
          future: _healthFuture,
          builder: (context, snapshot) {
            final online = snapshot.data ?? false;
            return Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.spacingMd,
                vertical: AppTheme.spacingSm,
              ),
              decoration: BoxDecoration(
                color: (online ? AppTheme.success : AppTheme.error).withOpacity(0.15),
                borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                border: Border.all(
                  color: (online ? AppTheme.success : AppTheme.error).withOpacity(0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    online ? Icons.cloud_done_rounded : Icons.cloud_off_rounded,
                    size: 18,
                    color: online ? AppTheme.success : AppTheme.error,
                  ),
                  const SizedBox(width: AppTheme.spacingSm),
                  Text(
                    online ? 'Online' : 'Offline',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: online ? AppTheme.success : AppTheme.error,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildTopology() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Align(
          alignment: const Alignment(0, 0),
          child: _MapNodeCard(
            icon: Icons.router_rounded,
            label: 'Router',
            subtitle: '192.168.1.1',
            color: AppTheme.primary,
          ),
        ),
        Align(
          alignment: const Alignment(-0.75, -0.55),
          child: _MapNodeCard(
            icon: Icons.desktop_windows_rounded,
            label: 'Laptop',
            subtitle: '192.168.1.24',
            color: AppTheme.secure,
          ),
        ),
        Align(
          alignment: const Alignment(0.8, -0.5),
          child: _MapNodeCard(
            icon: Icons.smartphone_rounded,
            label: 'Phone',
            subtitle: '192.168.1.42',
            color: AppTheme.lowRisk,
          ),
        ),
        Align(
          alignment: const Alignment(-0.85, 0.65),
          child: _MapNodeCard(
            icon: Icons.tv_rounded,
            label: 'Smart TV',
            subtitle: '192.168.1.67',
            color: AppTheme.mediumRisk,
          ),
        ),
        Align(
          alignment: const Alignment(0.75, 0.7),
          child: _MapNodeCard(
            icon: Icons.devices_other_rounded,
            label: 'Unknown',
            subtitle: '192.168.1.88',
            color: AppTheme.critical,
          ),
        ),
      ],
    );
  }
}

class _MapNodeCard extends StatelessWidget {
  const _MapNodeCard({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingMd,
        vertical: AppTheme.spacingSm,
      ),
      decoration: BoxDecoration(
        color: AppTheme.surfaceVariant,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: color.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.15),
            blurRadius: 12,
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
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
            ),
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(width: AppTheme.spacingSm),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: AppTheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppTheme.onSurfaceVariant,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
