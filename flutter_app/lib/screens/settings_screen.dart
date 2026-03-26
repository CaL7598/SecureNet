import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/app_state.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  static const String _currentAppVersion = '1.0.0+1';

  bool _notificationsEnabled = true;
  bool _dailySummaryEnabled = false;
  String _scanInterval = 'Manual only';
  String _defaultScanMode = 'Real scan';

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
              const SizedBox(height: AppTheme.spacingLg),
              _buildProfileCard(context),
              const SizedBox(height: AppTheme.spacingXl),
              _buildSectionLabel(context, 'Security preferences'),
              const SizedBox(height: AppTheme.spacingSm),
              _SettingTile(
                icon: Icons.access_time_rounded,
                title: 'Scan interval',
                subtitle: 'How often to automatically scan',
                value: _scanInterval,
                onTap: _chooseScanInterval,
              ),
              _SettingTile(
                icon: Icons.qr_code_scanner_rounded,
                title: 'Default scan mode',
                subtitle: 'Real or demo mode',
                value: _defaultScanMode,
                onTap: _chooseDefaultScanMode,
              ),
              const SizedBox(height: AppTheme.spacingLg),
              _buildSectionLabel(context, 'Notifications'),
              const SizedBox(height: AppTheme.spacingSm),
              _SettingTile(
                icon: Icons.notifications_rounded,
                title: 'Enable notifications',
                subtitle: 'Receive security alerts',
                trailing: Switch(
                  value: _notificationsEnabled,
                  onChanged: (value) => setState(() => _notificationsEnabled = value),
                  activeTrackColor: AppTheme.primary.withOpacity(0.5),
                  activeColor: AppTheme.primary,
                ),
              ),
              _SettingTile(
                icon: Icons.calendar_today_rounded,
                title: 'Daily security summary',
                subtitle: 'Get one report every morning',
                trailing: Switch(
                  value: _dailySummaryEnabled,
                  onChanged: (value) => setState(() => _dailySummaryEnabled = value),
                  activeTrackColor: AppTheme.primary.withOpacity(0.5),
                  activeColor: AppTheme.primary,
                ),
              ),
              const SizedBox(height: AppTheme.spacingXl),
              _buildSectionLabel(context, 'Account'),
              const SizedBox(height: AppTheme.spacingSm),
              _SettingTile(
                icon: Icons.verified_user_rounded,
                title: 'Privacy and data',
                subtitle: 'Control what gets stored and synced',
                onTap: _showPrivacyInfo,
              ),
              _SettingTile(
                icon: Icons.info_outline_rounded,
                title: 'About SecureNet',
                subtitle: 'Version $_currentAppVersion',
                onTap: _showAbout,
              ),
              const SizedBox(height: AppTheme.spacingMd),
              _LogoutTile(
                onLogout: () => Provider.of<AppState>(context, listen: false).logout(),
              ),
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
              'Settings',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppTheme.onSurface,
                    letterSpacing: -0.3,
                  ),
            ),
            const SizedBox(height: AppTheme.spacingXs),
            Text(
              'Configure app preferences',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.all(AppTheme.spacingMd),
          decoration: BoxDecoration(
            color: AppTheme.primary.withOpacity(0.15),
            borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          ),
          child: const Icon(Icons.settings_rounded, size: 28, color: AppTheme.primary),
        ),
      ],
    );
  }

  Widget _buildProfileCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      decoration: BoxDecoration(
        color: AppTheme.surfaceVariant,
        borderRadius: BorderRadius.circular(AppTheme.radiusXl),
        border: Border.all(color: AppTheme.outline.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.2),
              borderRadius: BorderRadius.circular(999),
            ),
            child: const Icon(Icons.person_rounded, color: AppTheme.primary),
          ),
          const SizedBox(width: AppTheme.spacingMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SecureNet User',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.onSurface,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Your network is being monitored',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.spacingSm,
              vertical: AppTheme.spacingXs,
            ),
            decoration: BoxDecoration(
              color: AppTheme.success.withOpacity(0.18),
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            ),
            child: Text(
              'Protected',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppTheme.success,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
        ],
      ),
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

  void _chooseScanInterval() {
    final options = <String>[
      'Manual only',
      'Every 6 hours',
      'Every 12 hours',
      'Daily',
      'Weekly',
    ];

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppTheme.radiusXl)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.spacingMd),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Choose scan interval',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppTheme.onSurface,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: AppTheme.spacingSm),
                ...options.map((option) => ListTile(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                      ),
                      title: Text(option),
                      trailing: option == _scanInterval
                          ? const Icon(Icons.check_rounded, color: AppTheme.primary)
                          : null,
                      onTap: () {
                        setState(() => _scanInterval = option);
                        Navigator.of(sheetContext).pop();
                      },
                    )),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showAbout() {
    showAboutDialog(
      context: context,
      applicationName: 'SecureNet',
      applicationVersion: _currentAppVersion,
      children: const [
        Text('SecureNet helps audit local Wi-Fi security and identify network risks.'),
      ],
    );
  }

  void _chooseDefaultScanMode() {
    final options = <String>['Real scan', 'Demo mode'];
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppTheme.radiusXl)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.spacingMd),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Choose default scan mode',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppTheme.onSurface,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: AppTheme.spacingSm),
                ...options.map(
                  (option) => ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                    ),
                    title: Text(option),
                    trailing: option == _defaultScanMode
                        ? const Icon(Icons.check_rounded, color: AppTheme.primary)
                        : null,
                    onTap: () {
                      setState(() => _defaultScanMode = option);
                      Navigator.of(sheetContext).pop();
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showPrivacyInfo() {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Privacy and data'),
        content: const Text(
          'SecureNet stores scan data for your account experience. '
          'Sensitive credentials are not shared, and you can sign out at any time.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

class _LogoutTile extends StatelessWidget {
  const _LogoutTile({required this.onLogout});

  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _showLogoutDialog(context),
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        child: Container(
          padding: const EdgeInsets.all(AppTheme.spacingMd),
          decoration: BoxDecoration(
            color: AppTheme.surfaceVariant,
            borderRadius: BorderRadius.circular(AppTheme.radiusLg),
            border: Border.all(color: AppTheme.error.withOpacity(0.3)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppTheme.spacingSm),
                decoration: BoxDecoration(
                  color: AppTheme.error.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                ),
                child: const Icon(Icons.logout_rounded, color: AppTheme.error, size: 22),
              ),
              const SizedBox(width: AppTheme.spacingMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Log out',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: AppTheme.error,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Sign out of your SecureNet account',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: AppTheme.error.withOpacity(0.7)),
            ],
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.surfaceVariant,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusLg)),
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
              onLogout();
            },
            style: FilledButton.styleFrom(
              backgroundColor: AppTheme.error,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              ),
            ),
            child: const Text('Log out'),
          ),
        ],
      ),
    );
  }
}

class _SettingTile extends StatelessWidget {
  const _SettingTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.value,
    this.trailing,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String? value;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.spacingSm),
      child: Material(
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
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppTheme.spacingSm),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                  ),
                  child: Icon(icon, color: AppTheme.primary, size: 22),
                ),
                const SizedBox(width: AppTheme.spacingMd),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              color: AppTheme.onSurface,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppTheme.onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                ),
                if (trailing != null)
                  trailing!
                else if (value != null)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        value!,
                        style: Theme.of(context).textTheme.labelMedium?.copyWith(
                              color: AppTheme.onSurfaceVariant,
                            ),
                      ),
                      const SizedBox(width: AppTheme.spacingXs),
                      const Icon(Icons.chevron_right_rounded, color: AppTheme.onSurfaceVariant),
                    ],
                  )
                else
                  const Icon(Icons.chevron_right_rounded, color: AppTheme.onSurfaceVariant),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
