import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../theme/app_theme.dart';
import 'scan_screen.dart';
import 'history_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingLg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppTheme.spacingMd),
              _buildHeader(context),
              const SizedBox(height: AppTheme.spacingXl),
              _buildRiskCard(context),
              const SizedBox(height: AppTheme.spacingLg),
              _buildSectionLabel(context, 'Quick actions'),
              const SizedBox(height: AppTheme.spacingSm),
              _buildQuickActions(context),
              const SizedBox(height: AppTheme.spacingLg),
              _buildSectionLabel(context, "Today's snapshot"),
              const SizedBox(height: AppTheme.spacingSm),
              _buildSummaryRow(context),
              const SizedBox(height: AppTheme.spacingXxl),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome back',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: AppTheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
            ),
            const SizedBox(height: AppTheme.spacingXs),
            Text(
              'Your Wi‑Fi posture',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppTheme.onSurface,
                    letterSpacing: -0.3,
                  ),
            ),
          ],
        ),
        Row(
          children: [
            _IconBadge(
              icon: Icons.shield_rounded,
              color: AppTheme.primary,
              size: 28,
              padding: const EdgeInsets.all(AppTheme.spacingMd),
            ),
            const SizedBox(width: AppTheme.spacingSm),
            _IconButtonBadge(
              icon: Icons.logout_rounded,
              color: AppTheme.error,
              onTap: () => _showLogoutDialog(context),
            ),
          ],
        ),
      ],
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surfaceVariant,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        ),
        title: const Text('Log out?'),
        content: const Text(
          'You will need to sign in again to access your scans and settings.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              Provider.of<AppState>(context, listen: false).logout();
            },
            style: FilledButton.styleFrom(backgroundColor: AppTheme.error),
            child: const Text('Log out'),
          ),
        ],
      ),
    );
  }

  Widget _buildRiskCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppTheme.spacingLg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.surfaceVariant,
            AppTheme.surfaceVariant.withOpacity(0.7),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppTheme.radiusXl),
        border: Border.all(color: AppTheme.primary.withOpacity(0.25)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.background,
              border: Border.all(color: AppTheme.secure.withOpacity(0.5), width: 2),
            ),
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '82',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppTheme.secure,
                      ),
                ),
                Text(
                  'Secure',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppTheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppTheme.spacingLg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Overall network health',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppTheme.onSurface,
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: AppTheme.spacingXs),
                Text(
                  '3 devices need attention · Demo metrics',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.onSurfaceVariant,
                      ),
                ),
                const SizedBox(height: AppTheme.spacingSm),
                Wrap(
                  spacing: AppTheme.spacingMd,
                  runSpacing: AppTheme.spacingXs,
                  children: [
                    _riskChip(context, AppTheme.secure, 'Secure'),
                    _riskChip(context, AppTheme.mediumRisk, 'Medium'),
                    _riskChip(context, AppTheme.critical, 'High'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _riskChip(BuildContext context, Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: AppTheme.spacingXs),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppTheme.onSurfaceVariant,
              ),
        ),
      ],
    );
  }

  Widget _buildSectionLabel(BuildContext context, String text) {
    return Text(
      text.toUpperCase(),
      style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: AppTheme.onSurfaceVariant,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.8,
          ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ActionCard(
            icon: Icons.radar_rounded,
            label: 'Start scan',
            subtitle: 'Audit current Wi‑Fi',
            color: AppTheme.primary,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const ScanScreen()),
              );
            },
          ),
        ),
        const SizedBox(width: AppTheme.spacingMd),
        Expanded(
          child: _ActionCard(
            icon: Icons.history_rounded,
            label: 'View history',
            subtitle: 'Previous assessments',
            color: AppTheme.secondary,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const HistoryScreen()),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryRow(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _SummaryCard(
            icon: Icons.devices_other_rounded,
            label: 'Active devices',
            value: '7',
          ),
        ),
        const SizedBox(width: AppTheme.spacingMd),
        Expanded(
          child: _SummaryCard(
            icon: Icons.warning_amber_rounded,
            label: 'Open alerts',
            value: '3',
            valueColor: AppTheme.warning,
          ),
        ),
      ],
    );
  }
}

class _IconBadge extends StatelessWidget {
  const _IconBadge({
    required this.icon,
    required this.color,
    this.size = 24,
    this.padding,
  });

  final IconData icon;
  final Color color;
  final double size;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.all(AppTheme.spacingSm),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
      ),
      child: Icon(icon, color: color, size: size),
    );
  }
}

class _IconButtonBadge extends StatelessWidget {
  const _IconButtonBadge({
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        child: Container(
          padding: const EdgeInsets.all(AppTheme.spacingMd),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          ),
          child: Icon(icon, color: color, size: 22),
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        child: Container(
          padding: const EdgeInsets.all(AppTheme.spacingMd),
          decoration: BoxDecoration(
            color: AppTheme.surfaceVariant,
            borderRadius: BorderRadius.circular(AppTheme.radiusLg),
            border: Border.all(color: AppTheme.outline.withOpacity(0.2)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _IconBadge(icon: icon, color: color, size: 22),
              const SizedBox(height: AppTheme.spacingMd),
              Text(
                label,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: AppTheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: AppTheme.spacingXs),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.onSurfaceVariant,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      decoration: BoxDecoration(
        color: AppTheme.surfaceVariant,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: AppTheme.outline.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          _IconBadge(icon: icon, color: AppTheme.primary, size: 20),
          const SizedBox(width: AppTheme.spacingMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppTheme.onSurfaceVariant,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: valueColor ?? AppTheme.onSurface,
                        fontWeight: FontWeight.w700,
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
