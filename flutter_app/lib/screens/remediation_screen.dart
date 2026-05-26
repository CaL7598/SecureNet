import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/device.dart';
import '../providers/app_state.dart';
import '../theme/app_theme.dart';
import '../utils/risk_utils.dart';

class RemediationScreen extends StatelessWidget {
  const RemediationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final analysis = context.watch<AppState>().lastAnalysis;
    final items = buildRemediationItems(analysis);
    final isVulnerable = analysis != null &&
        (analysis.criticalIssues > 0 ||
            analysis.highRiskDevices > 0 ||
            analysis.overallRisk.toUpperCase() != 'SECURE');

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingLg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppTheme.spacingMd),
              Text(
                'Remediation',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: AppTheme.onSurface,
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: AppTheme.spacingXs),
              Text(
                'Actionable fixes for issues found on your network',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: AppTheme.spacingLg),
              if (analysis == null)
                Expanded(child: _EmptyState(message: 'Run a scan first to get remediation recommendations.'))
              else if (!isVulnerable && items.isEmpty)
                Expanded(
                  child: _EmptyState(
                    message: 'Your latest scan looks healthy. No remediation steps are needed right now.',
                    icon: Icons.verified_user_rounded,
                    color: AppTheme.success,
                  ),
                )
              else ...[
                _SummaryBanner(analysis: analysis, itemCount: items.length),
                const SizedBox(height: AppTheme.spacingMd),
                Expanded(
                  child: ListView.separated(
                    itemCount: items.length,
                    separatorBuilder: (context, index) => const SizedBox(height: AppTheme.spacingSm),
                    itemBuilder: (context, index) => _RemediationCard(item: items[index]),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryBanner extends StatelessWidget {
  const _SummaryBanner({required this.analysis, required this.itemCount});

  final NetworkAnalysis analysis;
  final int itemCount;

  @override
  Widget build(BuildContext context) {
    final color = riskColor(analysis.overallRisk);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: color),
          const SizedBox(width: AppTheme.spacingSm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Network risk: ${analysis.overallRisk}',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: color,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                Text(
                  '$itemCount recommendation${itemCount == 1 ? '' : 's'} from your latest scan',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _RemediationCard extends StatelessWidget {
  const _RemediationCard({required this.item});

  final RemediationItem item;

  @override
  Widget build(BuildContext context) {
    final color = severityColor(item.severity);
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      decoration: BoxDecoration(
        color: AppTheme.surfaceVariant.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  item.severity,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: color,
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
              const Spacer(),
              Text(
                item.deviceName,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: AppTheme.onSurfaceVariant,
                    ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingSm),
          Text(
            item.description,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.onSurface,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: AppTheme.spacingXs),
          Text(
            item.ipAddress,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppTheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: AppTheme.spacingSm),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.lightbulb_outline_rounded, size: 18, color: AppTheme.primary),
              const SizedBox(width: AppTheme.spacingSm),
              Expanded(
                child: Text(
                  item.recommendation,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.onSurfaceVariant,
                        height: 1.45,
                      ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.message,
    this.icon = Icons.search_rounded,
    this.color = AppTheme.primary,
  });

  final String message;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingXl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: color),
            const SizedBox(height: AppTheme.spacingMd),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppTheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
