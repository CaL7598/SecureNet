import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../providers/app_state.dart';
import '../services/api_service.dart';
import 'email_verification_screen.dart';

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
    final appState = context.watch<AppState>();
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
              _buildProfileCard(context, appState),
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
                  activeTrackColor: AppTheme.primary.withValues(alpha: 0.5),
                  activeThumbColor: AppTheme.primary,
                ),
              ),
              _SettingTile(
                icon: Icons.calendar_today_rounded,
                title: 'Daily security summary',
                subtitle: 'Get one report every morning',
                trailing: Switch(
                  value: _dailySummaryEnabled,
                  onChanged: (value) => setState(() => _dailySummaryEnabled = value),
                  activeTrackColor: AppTheme.primary.withValues(alpha: 0.5),
                  activeThumbColor: AppTheme.primary,
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
                onLogout: () {
                  ApiService().logout();
                  Provider.of<AppState>(context, listen: false).logout();
                },
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
            color: AppTheme.primary.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          ),
          child: const Icon(Icons.settings_rounded, size: 28, color: AppTheme.primary),
        ),
      ],
    );
  }

  Widget _buildProfileCard(BuildContext context, AppState appState) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryContainer.withValues(alpha: 0.15),
            AppTheme.surfaceVariant,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppTheme.radiusXl),
        border: Border.all(color: AppTheme.outline.withValues(alpha: 0.24)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(999),
            ),
            alignment: Alignment.center,
            child: Text(
              appState.initials,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: AppTheme.primary,
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
                  appState.displayName,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.onSurface,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  appState.email,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.onSurfaceVariant,
                      ),
                ),
                const SizedBox(height: AppTheme.spacingXs),
                if (appState.emailVerified)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppTheme.spacingSm,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.success.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: AppTheme.success.withValues(alpha: 0.35),
                      ),
                    ),
                    child: Text(
                      'Email verified',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: AppTheme.success,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  )
                else
                  TextButton.icon(
                    onPressed: () => _reverifyEmail(appState),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(0, 32),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      alignment: Alignment.centerLeft,
                    ),
                    icon: const Icon(Icons.mark_email_read_outlined, size: 16),
                    label: const Text('Verify email (optional)'),
                  ),
                const SizedBox(height: AppTheme.spacingXs),
                TextButton.icon(
                  onPressed: () => _resendWelcomeEmail(appState),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(0, 32),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    alignment: Alignment.centerLeft,
                  ),
                  icon: const Icon(Icons.mail_outline_rounded, size: 16),
                  label: const Text('Resend welcome email'),
                ),
                const SizedBox(height: AppTheme.spacingSm),
                Text(
                  'Phone: ${appState.phone}',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppTheme.onSurfaceVariant,
                      ),
                ),
                Text(
                  'Location: ${appState.location}',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppTheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              IconButton(
                tooltip: 'Edit profile',
                onPressed: () => _editProfile(appState),
                icon: const Icon(Icons.edit_rounded, color: AppTheme.primary),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spacingSm,
                  vertical: AppTheme.spacingXs,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.success.withValues(alpha: 0.18),
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
        ],
      ),
    );
  }

  Future<void> _resendWelcomeEmail(AppState appState) async {
    final api = ApiService()..setBearerToken(appState.accessToken);
    final sent = await api.resendWelcomeEmail();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          sent
              ? 'Welcome email sent to ${appState.email} (not a verification code).'
              : 'Could not send welcome email. Confirm SendGrid is configured on the server.',
        ),
      ),
    );
  }

  Future<void> _reverifyEmail(AppState appState) async {
    final api = ApiService();
    final resent = await api.resendVerification(appState.email);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          resent
              ? 'Verification code sent to ${appState.email}. Check inbox and spam.'
              : 'Could not send verification email right now.',
        ),
      ),
    );
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => EmailVerificationScreen(api: api)),
    );
  }

  Future<void> _editProfile(AppState appState) async {
    final nameController = TextEditingController(text: appState.displayName);
    final emailController = TextEditingController(text: appState.email);
    final phoneController = TextEditingController(
      text: appState.phone == 'Not set' ? '' : appState.phone,
    );
    final locationController = TextEditingController(
      text: appState.location == 'Not set' ? '' : appState.location,
    );

    String? validationError;

    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: AppTheme.surfaceVariant,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          ),
          title: const Text('Edit profile'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Full name'),
                ),
                const SizedBox(height: AppTheme.spacingSm),
                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(labelText: 'Email'),
                ),
                const SizedBox(height: AppTheme.spacingSm),
                TextField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(labelText: 'Phone number'),
                ),
                const SizedBox(height: AppTheme.spacingSm),
                TextField(
                  controller: locationController,
                  decoration: const InputDecoration(labelText: 'Location'),
                ),
                if (validationError != null) ...[
                  const SizedBox(height: AppTheme.spacingSm),
                  Text(
                    validationError!,
                    style: const TextStyle(color: AppTheme.error),
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final email = emailController.text.trim();
                if (!_looksLikeEmail(email)) {
                  setDialogState(() => validationError = 'Please enter a valid email.');
                  return;
                }
                Navigator.of(ctx).pop(true);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );

    if (saved == true) {
      final api = ApiService();
      await api.updateProfile(fullName: nameController.text.trim());
      await appState.updateProfile(
        displayName: nameController.text,
        email: emailController.text,
        phone: phoneController.text,
        location: locationController.text,
      );
    }
  }

  bool _looksLikeEmail(String value) {
    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    return emailRegex.hasMatch(value);
  }

  Widget _buildSectionLabel(BuildContext context, String text) {
    return Text(
      text.toUpperCase(),
      style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: AppTheme.onSurfaceVariant,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.0,
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
            border: Border.all(color: AppTheme.error.withValues(alpha: 0.3)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
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
                  color: AppTheme.error.withValues(alpha: 0.15),
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
              Icon(Icons.chevron_right_rounded, color: AppTheme.error.withValues(alpha: 0.7)),
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
              border: Border.all(color: AppTheme.outline.withValues(alpha: 0.2)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
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
                    color: AppTheme.primary.withValues(alpha: 0.15),
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
