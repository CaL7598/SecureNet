import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/device.dart';
import '../providers/app_state.dart';
import '../theme/app_theme.dart';
import 'scan_screen.dart';
import 'scan_results_screen.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final history = context.watch<AppState>().scanHistory;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingLg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppTheme.spacingMd),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Scan history',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppTheme.onSurface,
                              letterSpacing: -0.3,
                            ),
                      ),
                      const SizedBox(height: AppTheme.spacingXs),
                      Text(
                        'Past network assessments',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppTheme.onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.all(AppTheme.spacingMd),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                    ),
                    child: const Icon(Icons.history_rounded, size: 24, color: AppTheme.primary),
                  ),
                ],
              ),
              const SizedBox(height: AppTheme.spacingXl),
              Expanded(
                child: history.isEmpty
                    ? Center(child: _buildEmptyState(context))
                    : _buildHistoryList(context, history),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxWidth: 320),
      padding: const EdgeInsets.all(AppTheme.spacingXl),
      decoration: BoxDecoration(
        color: AppTheme.surfaceVariant.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(AppTheme.radiusXl),
        border: Border.all(color: AppTheme.outline.withValues(alpha: 0.2)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(AppTheme.spacingLg),
            decoration: BoxDecoration(
              color: AppTheme.background,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.history_rounded,
              size: 48,
              color: AppTheme.onSurfaceVariant.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: AppTheme.spacingLg),
          Text(
            'No scan history yet',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.onSurface,
                ),
          ),
          const SizedBox(height: AppTheme.spacingSm),
          Text(
            'Your previous scans will appear here. Run a scan from the Scan tab to get started.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: AppTheme.spacingXl),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: FilledButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const ScanScreen()),
                );
              },
              icon: const Icon(Icons.qr_code_scanner_rounded, size: 20, color: AppTheme.onPrimary),
              label: const Text('Run a scan', style: TextStyle(fontWeight: FontWeight.w600)),
              style: FilledButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: AppTheme.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryList(BuildContext context, List<ScanHistoryEntry> history) {
    return ListView.separated(
      itemCount: history.length,
      separatorBuilder: (_, _) => const SizedBox(height: AppTheme.spacingSm),
      itemBuilder: (context, index) {
        final entry = history[index];
        final analysis = entry.analysis;
        final riskColor = _riskColor(analysis.overallRisk);
        return Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(AppTheme.radiusLg),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ScanResultsScreen(analysis: analysis),
                ),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(AppTheme.spacingMd),
              decoration: BoxDecoration(
                color: AppTheme.surfaceVariant.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                border: Border.all(color: AppTheme.outline.withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: riskColor.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '${analysis.networkScore}',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: riskColor,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ),
                  const SizedBox(width: AppTheme.spacingMd),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${analysis.overallRisk} risk',
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                color: AppTheme.onSurface,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${analysis.totalDevices} devices · ${analysis.criticalIssues} critical · ${analysis.highRiskDevices} high',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppTheme.onSurfaceVariant,
                              ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _formatDateTime(entry.scannedAt),
                          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                color: AppTheme.onSurfaceVariant,
                              ),
                        ),
                        if (analysis.devices.isNotEmpty) ...[
                          const SizedBox(height: 6),
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
                                label: _manufacturerFrom(analysis),
                              ),
                              _profileChip(
                                context: context,
                                icon: Icons.category_outlined,
                                label: _deviceTypeFrom(analysis),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded, color: AppTheme.onSurfaceVariant),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Color _riskColor(String risk) {
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

  String _formatDateTime(DateTime value) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${value.year}-${two(value.month)}-${two(value.day)} ${two(value.hour)}:${two(value.minute)}';
  }

  String _manufacturerFrom(NetworkAnalysis analysis) {
    final firstKnown = analysis.devices
        .map((d) => d.manufacturer?.trim() ?? '')
        .firstWhere((m) => m.isNotEmpty, orElse: () => '');
    return firstKnown.isEmpty ? 'Unknown maker' : firstKnown;
  }

  String _deviceTypeFrom(NetworkAnalysis analysis) {
    final firstKnown = analysis.devices
        .map((d) => d.deviceKind?.trim() ?? '')
        .firstWhere((k) => k.isNotEmpty, orElse: () => '');
    return firstKnown.isEmpty ? 'Unknown type' : firstKnown;
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
