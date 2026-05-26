import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/app_state.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';

class EmailVerificationScreen extends StatefulWidget {
  const EmailVerificationScreen({super.key, required this.api});

  final ApiService api;

  @override
  State<EmailVerificationScreen> createState() => _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<EmailVerificationScreen> {
  final _codeController = TextEditingController();
  bool _busy = false;
  String? _message;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    final appState = context.read<AppState>();
    final code = _codeController.text.trim();
    if (code.isEmpty) {
      setState(() => _message = 'Enter the verification code sent to your email.');
      return;
    }
    setState(() {
      _busy = true;
      _message = null;
    });
    final ok = await widget.api.verifyEmail(email: appState.email, code: code);
    if (!mounted) return;
    if (ok) {
      await appState.setEmailVerified(true);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Email verified successfully.')),
      );
      Navigator.of(context).pop();
      return;
    }
    setState(() {
      _busy = false;
      _message = widget.api.lastMessageError ??
          'Verification failed. Check the code and try again.';
    });
  }

  Future<void> _resend() async {
    final appState = context.read<AppState>();
    setState(() {
      _busy = true;
      _message = null;
    });
    final ok = await widget.api.resendVerification(appState.email);
    if (!mounted) return;
    setState(() {
      _busy = false;
      _message = ok
          ? 'Verification code sent. Check your inbox and spam folder.'
          : (widget.api.lastMessageError ?? 'Unable to resend code right now.');
    });
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppTheme.spacingLg),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Container(
                padding: const EdgeInsets.all(AppTheme.spacingLg),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceVariant.withValues(alpha: 0.7),
                  borderRadius: BorderRadius.circular(AppTheme.radiusXl),
                  border: Border.all(color: AppTheme.outline.withValues(alpha: 0.24)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Verify your email',
                      style: Theme.of(
                        context,
                      ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: AppTheme.spacingSm),
                    Text(
                      'Enter the 6-digit code sent to ${appState.email}. Use Settings → Verify email if you need a new code.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppTheme.onSurfaceVariant,
                          ),
                    ),
                    const SizedBox(height: AppTheme.spacingLg),
                    TextField(
                      controller: _codeController,
                      decoration: const InputDecoration(
                        labelText: 'Verification code',
                        hintText: '6-digit code',
                        prefixIcon: Icon(Icons.mark_email_read_outlined),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: AppTheme.spacingMd),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: FilledButton(
                        onPressed: _busy ? null : _verify,
                        child: _busy
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('Verify email'),
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacingSm),
                    SizedBox(
                      width: double.infinity,
                      child: TextButton(
                        onPressed: _busy ? null : _resend,
                        child: const Text('Resend code'),
                      ),
                    ),
                    if (_message != null) ...[
                      const SizedBox(height: AppTheme.spacingSm),
                      Text(
                        _message!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppTheme.onSurfaceVariant,
                            ),
                      ),
                    ],
                    const SizedBox(height: AppTheme.spacingMd),
                    TextButton.icon(
                      onPressed: _busy
                          ? null
                          : () {
                              widget.api.logout();
                              appState.logout();
                            },
                      icon: const Icon(Icons.logout_rounded),
                      label: const Text('Log out'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
