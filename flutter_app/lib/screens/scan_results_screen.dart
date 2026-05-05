import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/device.dart';
import 'device_detail_screen.dart';

class ScanResultsScreen extends StatelessWidget {
  const ScanResultsScreen({super.key, required this.analysis});

  final NetworkAnalysis analysis;

  static Color _riskColor(String risk) {
    switch (risk.toUpperCase()) {
      case 'SECURE':
        return AppTheme.secure;
      case 'LOW':
        return AppTheme.lowRisk;
      case 'MEDIUM':
        return AppTheme.mediumRisk;
      case 'HIGH':
        return AppTheme.highRisk;
      case 'CRITICAL':
        return AppTheme.critical;
      default:
        return AppTheme.onSurfaceVariant;
    }
  }

  @override
  Widget build(BuildContext context) {
    final overallColor = _riskColor(analysis.overallRisk);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Scan Results'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Done'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppTheme.spacingMd),
        children: [
          Container(
            padding: const EdgeInsets.all(AppTheme.spacingLg),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.primaryContainer.withValues(alpha: 0.2),
                  AppTheme.surfaceVariant.withValues(alpha: 0.9),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(AppTheme.radiusLg),
              border: Border.all(color: overallColor.withValues(alpha: 0.35)),
            ),
            child: Column(
              children: [
                Container(
                  width: 104,
                  height: 104,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.background.withValues(alpha: 0.6),
                    border: Border.all(color: overallColor.withValues(alpha: 0.55), width: 2),
                  ),
                  child: Text(
                    '${analysis.networkScore}',
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: overallColor,
                        ),
                  ),
                ),
                const SizedBox(height: AppTheme.spacingSm),
                Text(
                  analysis.overallRisk,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: overallColor,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: AppTheme.spacingLg),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _metric('Devices', '${analysis.totalDevices}'),
                    _metric('Critical', '${analysis.criticalIssues}', color: AppTheme.critical),
                    _metric('High Risk', '${analysis.highRiskDevices}', color: AppTheme.highRisk),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppTheme.spacingLg),
          Row(
            children: [
              Icon(Icons.laptop_mac, color: AppTheme.primary, size: 20),
              const SizedBox(width: AppTheme.spacingSm),
              Text(
                'All Devices (${analysis.totalDevices})',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppTheme.onSurface),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingSm),
          ...analysis.devices.map(
            (d) => _DeviceCard(
              device: d,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => DeviceDetailScreen(device: d),
                ),
              ),
            ),
          ),
          const SizedBox(height: AppTheme.spacingMd),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Scan Again'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _metric(String label, String value, {Color? color}) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppTheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: color ?? AppTheme.onSurface,
          ),
        ),
      ],
    );
  }
}

class _DeviceCard extends StatelessWidget {
  const _DeviceCard({required this.device, required this.onTap});

  final DeviceAnalysis device;
  final VoidCallback onTap;

  static Color _riskColor(String risk) {
    switch (risk.toUpperCase()) {
      case 'SECURE':
        return AppTheme.secure;
      case 'LOW':
        return AppTheme.lowRisk;
      case 'MEDIUM':
        return AppTheme.mediumRisk;
      case 'HIGH':
        return AppTheme.highRisk;
      case 'CRITICAL':
        return AppTheme.critical;
      default:
        return AppTheme.onSurfaceVariant;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _riskColor(device.riskLevel);
    final manufacturer = (device.manufacturer?.trim().isNotEmpty ?? false)
        ? device.manufacturer!.trim()
        : 'Unknown maker';
    final deviceKind = (device.deviceKind?.trim().isNotEmpty ?? false)
        ? device.deviceKind!.trim()
        : 'Unknown type';
    return Card(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingSm),
      color: AppTheme.surfaceVariant,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        side: BorderSide(color: color.withValues(alpha: 0.25)),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppTheme.spacingMd,
            AppTheme.spacingMd,
            AppTheme.spacingMd,
            AppTheme.spacingSm,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.devices, color: AppTheme.primary),
                  const SizedBox(width: AppTheme.spacingSm),
                  Expanded(
                    child: Text(
                      device.deviceName ?? 'Unknown Device',
                      style: const TextStyle(color: AppTheme.onSurface, fontWeight: FontWeight.w600),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      device.riskLevel,
                      style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.chevron_right, color: AppTheme.onSurfaceVariant),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                device.ipAddress,
                style: const TextStyle(color: AppTheme.onSurfaceVariant, fontSize: 12),
              ),
              const SizedBox(height: AppTheme.spacingSm),
              Text(
                'Device Profile',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppTheme.onSurfaceVariant,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.6,
                    ),
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: AppTheme.spacingSm,
                runSpacing: AppTheme.spacingXs,
                children: [
                  _profileChip(
                    context: context,
                    icon: Icons.factory_outlined,
                    label: manufacturer,
                  ),
                  _profileChip(
                    context: context,
                    icon: Icons.category_outlined,
                    label: deviceKind,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _profileChip({
    required BuildContext context,
    required IconData icon,
    required String label,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingSm,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: AppTheme.background.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppTheme.outline.withValues(alpha: 0.24)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: AppTheme.onSurfaceVariant),
          const SizedBox(width: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppTheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}
