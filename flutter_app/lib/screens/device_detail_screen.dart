import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/device.dart';

class DeviceDetailScreen extends StatelessWidget {
  const DeviceDetailScreen({super.key, required this.device});

  final DeviceAnalysis device;

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

  static Color _severityColor(String s) {
    switch (s.toUpperCase()) {
      case 'CRITICAL':
        return AppTheme.critical;
      case 'HIGH':
        return AppTheme.highRisk;
      case 'MEDIUM':
        return AppTheme.mediumRisk;
      case 'LOW':
        return AppTheme.lowRisk;
      default:
        return AppTheme.onSurfaceVariant;
    }
  }

  @override
  Widget build(BuildContext context) {
    final riskColor = _riskColor(device.riskLevel);
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Device Details'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppTheme.spacingMd),
        children: [
          Card(
            color: AppTheme.surfaceVariant,
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.spacingMd),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.devices, size: 48, color: AppTheme.primary),
                      const SizedBox(width: AppTheme.spacingMd),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              device.deviceName ?? 'Unknown Device',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppTheme.onSurface),
                            ),
                            Text(device.ipAddress, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppTheme.onSurfaceVariant)),
                            Text(device.macAddress, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppTheme.onSurfaceVariant)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppTheme.spacingMd),
                  Row(
                    children: [
                      Text(
                        'Security Score',
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(color: AppTheme.onSurfaceVariant),
                      ),
                      const SizedBox(width: AppTheme.spacingSm),
                      Text(
                        '${device.securityScore}/100',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(color: riskColor, fontWeight: FontWeight.w700),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: riskColor.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          device.riskLevel,
                          style: TextStyle(color: riskColor, fontWeight: FontWeight.w600, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppTheme.spacingLg),
          Text(
            'Issues (${device.issues.length})',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppTheme.onSurface),
          ),
          const SizedBox(height: AppTheme.spacingSm),
          if (device.issues.isEmpty)
            Text(
              'No issues found.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.onSurfaceVariant),
            )
          else
            ...device.issues.map(
              (issue) => Card(
                margin: const EdgeInsets.only(bottom: AppTheme.spacingSm),
                color: AppTheme.surfaceVariant,
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: _severityColor(issue.severity).withOpacity(0.3),
                    child: Icon(Icons.warning_amber, color: _severityColor(issue.severity), size: 20),
                  ),
                  title: Text(
                    issue.description,
                    style: const TextStyle(color: AppTheme.onSurface, fontSize: 14),
                  ),
                  subtitle: Text(
                    issue.recommendation,
                    style: const TextStyle(color: AppTheme.onSurfaceVariant, fontSize: 12),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
