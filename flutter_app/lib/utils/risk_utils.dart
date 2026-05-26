import 'package:flutter/material.dart';
import '../models/device.dart';
import '../theme/app_theme.dart';

Color riskColor(String risk) {
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

Color severityColor(String severity) {
  switch (severity.toUpperCase()) {
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

int severityRank(String severity) {
  switch (severity.toUpperCase()) {
    case 'CRITICAL':
      return 0;
    case 'HIGH':
      return 1;
    case 'MEDIUM':
      return 2;
    case 'LOW':
      return 3;
    default:
      return 4;
  }
}

IconData deviceIcon(DeviceAnalysis device) {
  final kind = (device.deviceKind ?? '').toLowerCase();
  final name = (device.deviceName ?? '').toLowerCase();
  if (kind.contains('router') || name.contains('router') || name.contains('gateway')) {
    return Icons.router_rounded;
  }
  if (kind.contains('phone') || name.contains('phone') || name.contains('iphone') || name.contains('android')) {
    return Icons.smartphone_rounded;
  }
  if (kind.contains('laptop') || kind.contains('computer') || name.contains('laptop') || name.contains('pc')) {
    return Icons.desktop_windows_rounded;
  }
  if (kind.contains('tv') || name.contains('tv') || name.contains('roku') || name.contains('firestick')) {
    return Icons.tv_rounded;
  }
  if (kind.contains('camera') || name.contains('camera')) {
    return Icons.videocam_rounded;
  }
  if (kind.contains('printer') || name.contains('printer')) {
    return Icons.print_rounded;
  }
  if (kind.contains('iot') || kind.contains('smart')) {
    return Icons.sensors_rounded;
  }
  return Icons.devices_other_rounded;
}

String deviceLabel(DeviceAnalysis device) {
  return device.deviceName?.trim().isNotEmpty == true
      ? device.deviceName!.trim()
      : (device.manufacturer?.trim().isNotEmpty == true
          ? device.manufacturer!.trim()
          : 'Unknown device');
}

bool isLikelyRouter(DeviceAnalysis device) {
  final kind = (device.deviceKind ?? '').toLowerCase();
  final name = (device.deviceName ?? '').toLowerCase();
  return kind.contains('router') ||
      name.contains('router') ||
      name.contains('gateway') ||
      device.ipAddress.endsWith('.1');
}

List<RemediationItem> buildRemediationItems(NetworkAnalysis? analysis) {
  if (analysis == null) return const [];

  final items = <RemediationItem>[];
  for (final device in analysis.devices) {
    for (final issue in device.issues) {
      items.add(
        RemediationItem(
          deviceName: deviceLabel(device),
          ipAddress: device.ipAddress,
          severity: issue.severity,
          description: issue.description,
          recommendation: issue.recommendation,
        ),
      );
    }
  }

  items.sort((a, b) => severityRank(a.severity).compareTo(severityRank(b.severity)));
  return items;
}

class RemediationItem {
  const RemediationItem({
    required this.deviceName,
    required this.ipAddress,
    required this.severity,
    required this.description,
    required this.recommendation,
  });

  final String deviceName;
  final String ipAddress;
  final String severity;
  final String description;
  final String recommendation;
}
