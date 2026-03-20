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
              color: AppTheme.surfaceVariant,
              borderRadius: BorderRadius.circular(AppTheme.radiusLg),
            ),
            child: Column(
              children: [
                Text(
                  '${analysis.networkScore}',
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: _riskColor(analysis.overallRisk),
                      ),
                ),
                Text(
                  analysis.overallRisk,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppTheme.onSurfaceVariant,
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
    return Card(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingSm),
      color: AppTheme.surfaceVariant,
      child: ListTile(
        leading: const Icon(Icons.devices, color: AppTheme.primary),
        title: Text(
          device.deviceName ?? 'Unknown Device',
          style: const TextStyle(color: AppTheme.onSurface, fontWeight: FontWeight.w600),
        ),
        subtitle: Text(device.ipAddress, style: const TextStyle(color: AppTheme.onSurfaceVariant, fontSize: 12)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
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
        onTap: onTap,
      ),
    );
  }
}
