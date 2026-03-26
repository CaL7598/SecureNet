import 'package:flutter/material.dart';

import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/auth_video_background.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final ApiService _api = ApiService();
  final _emailController = TextEditingController();
  final _codeController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _loading = false;
  bool _requested = false;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    _codeController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _requestResetCode() async {
    setState(() {
      _error = null;
      _loading = true;
    });

    final email = _emailController.text.trim();
    if (!_looksLikeEmail(email)) {
      setState(() {
        _loading = false;
        _error = 'Enter a valid email address.';
      });
      return;
    }

    final ok = await _api.requestPasswordReset(email);
    if (!mounted) return;

    if (ok) {
      setState(() {
        _loading = false;
        _requested = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Reset code sent. Check backend logs/email provider.'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    final backendOnline = await _api.healthCheck();
    if (!mounted) return;
    setState(() {
      _loading = false;
      _error = backendOnline
          ? 'Reset endpoint unavailable. Restart backend and try again.'
          : 'Backend unreachable. Check API server and phone/PC network.';
    });
  }

  Future<void> _confirmReset() async {
    setState(() {
      _error = null;
      _loading = true;
    });

    final email = _emailController.text.trim();
    final code = _codeController.text.trim();
    final password = _passwordController.text;
    final confirm = _confirmController.text;

    if (code.isEmpty || password.isEmpty || confirm.isEmpty) {
      setState(() {
        _loading = false;
        _error = 'Fill in code and new password fields.';
      });
      return;
    }
    if (password.length < 8) {
      setState(() {
        _loading = false;
        _error = 'Password must be at least 8 characters.';
      });
      return;
    }
    if (password != confirm) {
      setState(() {
        _loading = false;
        _error = 'Passwords do not match.';
      });
      return;
    }

    final ok = await _api.confirmPasswordReset(
      email: email,
      code: code,
      newPassword: password,
    );

    if (!mounted) return;
    setState(() => _loading = false);

    if (!ok) {
      setState(() {
        _error = 'Invalid code or reset failed.';
      });
      return;
    }

    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Password reset successful'),
        content: const Text('You can now sign in with your new password.'),
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Continue'),
          ),
        ],
      ),
    );
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  bool _looksLikeEmail(String value) {
    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    return emailRegex.hasMatch(value);
  }

  @override
  Widget build(BuildContext context) {
    final keyboardInset = MediaQuery.of(context).viewInsets.bottom;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Reset password'),
      ),
      extendBodyBehindAppBar: true,
      body: AuthVideoBackground(
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  AppTheme.spacingLg,
                  AppTheme.spacingLg,
                  AppTheme.spacingLg,
                  AppTheme.spacingLg + keyboardInset,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight - AppTheme.spacingLg),
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(AppTheme.spacingLg),
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceVariant.withOpacity(0.65),
                          borderRadius: BorderRadius.circular(AppTheme.radiusXl),
                          border: Border.all(color: AppTheme.outline.withOpacity(0.2)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                      Text(
                        _requested ? 'Enter code and new password' : 'Request reset code',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              color: AppTheme.onSurface,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const SizedBox(height: AppTheme.spacingSm),
                      Text(
                        _requested
                            ? 'Check your email for the verification code.'
                            : 'We will send a verification code to your email.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppTheme.onSurfaceVariant,
                            ),
                      ),
                      const SizedBox(height: AppTheme.spacingLg),
                      TextField(
                        controller: _emailController,
                        enabled: !_requested,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          hintText: 'you@example.com',
                          prefixIcon: const Icon(Icons.email_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                          ),
                          filled: true,
                          fillColor: AppTheme.background.withOpacity(0.55),
                        ),
                        keyboardType: TextInputType.emailAddress,
                      ),
                      if (_requested) ...[
                        const SizedBox(height: AppTheme.spacingMd),
                        TextField(
                          controller: _codeController,
                          decoration: InputDecoration(
                            labelText: 'Verification code',
                            hintText: '6-digit code',
                            prefixIcon: const Icon(Icons.verified_rounded),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                            ),
                            filled: true,
                            fillColor: AppTheme.background.withOpacity(0.55),
                          ),
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: AppTheme.spacingMd),
                        TextField(
                          controller: _passwordController,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            labelText: 'New password',
                            hintText: 'At least 8 characters',
                            prefixIcon: const Icon(Icons.lock_outline_rounded),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                              ),
                              onPressed: () =>
                                  setState(() => _obscurePassword = !_obscurePassword),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                            ),
                            filled: true,
                            fillColor: AppTheme.background.withOpacity(0.55),
                          ),
                        ),
                        const SizedBox(height: AppTheme.spacingMd),
                        TextField(
                          controller: _confirmController,
                          obscureText: _obscureConfirm,
                          decoration: InputDecoration(
                            labelText: 'Confirm password',
                            hintText: 'Repeat new password',
                            prefixIcon: const Icon(Icons.lock_outline_rounded),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureConfirm
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                              ),
                              onPressed: () =>
                                  setState(() => _obscureConfirm = !_obscureConfirm),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                            ),
                            filled: true,
                            fillColor: AppTheme.background.withOpacity(0.55),
                          ),
                        ),
                      ],
                      if (_error != null) ...[
                        const SizedBox(height: AppTheme.spacingMd),
                        Text(
                          _error!,
                          style: const TextStyle(color: AppTheme.error),
                        ),
                      ],
                      const SizedBox(height: AppTheme.spacingLg),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: FilledButton(
                          onPressed: _loading
                              ? null
                              : (_requested ? _confirmReset : _requestResetCode),
                          child: _loading
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : Text(_requested ? 'Reset password' : 'Send reset code'),
                        ),
                      ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppTheme.spacingXl),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

