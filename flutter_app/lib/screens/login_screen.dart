import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, required this.onLogin, required this.onNavigateToSignUp});

  final VoidCallback onLogin;
  final VoidCallback onNavigateToSignUp;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;
  bool _obscurePassword = true;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _error = null;
      if (_emailController.text.trim().isEmpty || _passwordController.text.isEmpty) {
        _error = 'Please enter your email and password.';
        return;
      }
      _loading = true;
    });
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    setState(() => _loading = false);
    widget.onLogin();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingLg),
          child: Column(
            children: [
              const SizedBox(height: AppTheme.spacingXxxl),
              // Logo with subtle glow
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.primary,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primary.withOpacity(0.4),
                      blurRadius: 24,
                      spreadRadius: 0,
                    ),
                  ],
                ),
                child: const Icon(Icons.shield_rounded, color: AppTheme.onPrimary, size: 36),
              ),
              const SizedBox(height: AppTheme.spacingLg),
              Text(
                'SecureNet',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: AppTheme.onSurface,
                      letterSpacing: -0.5,
                    ),
              ),
              const SizedBox(height: AppTheme.spacingXs),
              Text(
                'Sign in to secure your Wi‑Fi',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppTheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: AppTheme.spacingXxl),
              // Card with modern elevation
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppTheme.spacingLg),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceVariant.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(AppTheme.radiusXl),
                  border: Border.all(color: AppTheme.outline.withOpacity(0.2), width: 1),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome back',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: AppTheme.onSurface,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: AppTheme.spacingXs),
                    Text(
                      'Log in with your SecureNet account',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.onSurfaceVariant,
                          ),
                    ),
                    const SizedBox(height: AppTheme.spacingLg),
                    TextField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        hintText: 'you@example.com',
                        prefixIcon: const Icon(Icons.email_outlined, size: 22, color: AppTheme.onSurfaceVariant),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppTheme.radiusMd)),
                        filled: true,
                        fillColor: AppTheme.background.withOpacity(0.5),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      autocorrect: false,
                    ),
                    const SizedBox(height: AppTheme.spacingMd),
                    TextField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        hintText: '••••••••',
                        prefixIcon: const Icon(Icons.lock_outline_rounded, size: 22, color: AppTheme.onSurfaceVariant),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                            size: 22,
                            color: AppTheme.onSurfaceVariant,
                          ),
                          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                        ),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppTheme.radiusMd)),
                        filled: true,
                        fillColor: AppTheme.background.withOpacity(0.5),
                      ),
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: AppTheme.spacingSm),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingSm, vertical: AppTheme.spacingXs),
                        decoration: BoxDecoration(
                          color: AppTheme.error.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.error_outline, size: 18, color: AppTheme.error),
                            const SizedBox(width: AppTheme.spacingSm),
                            Expanded(
                              child: Text(
                                _error!,
                                style: const TextStyle(color: AppTheme.error, fontSize: 13),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: AppTheme.spacingLg),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: FilledButton(
                        onPressed: _loading ? null : _submit,
                        style: FilledButton.styleFrom(
                          backgroundColor: AppTheme.primary,
                          foregroundColor: AppTheme.onPrimary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusMd)),
                          elevation: 0,
                        ),
                        child: _loading
                            ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.onPrimary),
                              )
                            : const Text('Log in', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacingMd),
                    Center(
                      child: TextButton(
                        onPressed: () {},
                        child: Text(
                          'Forgot password?',
                          style: TextStyle(color: AppTheme.primary, fontSize: 14, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppTheme.spacingXl),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'New to SecureNet? ',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.onSurfaceVariant),
                  ),
                  GestureDetector(
                    onTap: widget.onNavigateToSignUp,
                    child: Text(
                      'Create account',
                      style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w600, fontSize: 14),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppTheme.spacingMd),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.lock_outline, size: 14, color: AppTheme.onSurfaceVariant.withOpacity(0.8)),
                  const SizedBox(width: AppTheme.spacingXs),
                  Text(
                    'Your credentials are encrypted and never shared.',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppTheme.onSurfaceVariant),
                  ),
                ],
              ),
              const SizedBox(height: AppTheme.spacingXxl),
            ],
          ),
        ),
      ),
    );
  }
}
