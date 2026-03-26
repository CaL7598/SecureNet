import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/auth_video_background.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key, required this.onSignUp, required this.onNavigateToLogin});

  final VoidCallback onSignUp;
  final VoidCallback onNavigateToLogin;

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _acceptTerms = false;
  bool _loading = false;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  String? _error;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _error = null;
      if (_emailController.text.trim().isEmpty ||
          _passwordController.text.isEmpty ||
          _confirmController.text.isEmpty) {
        _error = 'Please fill in all required fields.';
        return;
      }
      if (_passwordController.text.length < 8) {
        _error = 'Password must be at least 8 characters.';
        return;
      }
      if (_passwordController.text != _confirmController.text) {
        _error = 'Passwords do not match.';
        return;
      }
      if (!_acceptTerms) {
        _error = 'You need to accept the Terms & Privacy Policy.';
        return;
      }
      _loading = true;
    });
    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    setState(() => _loading = false);
    widget.onSignUp();
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Create account',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      extendBodyBehindAppBar: true,
      body: AuthVideoBackground(
        child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingLg),
              child: Column(
                children: [
              const SizedBox(height: AppTheme.spacingLg),
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.primary.withOpacity(0.2),
                  border: Border.all(color: AppTheme.primary.withOpacity(0.5), width: 2),
                ),
                child: const Icon(Icons.person_add_rounded, color: AppTheme.primary, size: 32),
              ),
              const SizedBox(height: AppTheme.spacingMd),
              Text(
                'Join SecureNet',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppTheme.onSurface,
                    ),
              ),
              const SizedBox(height: AppTheme.spacingXs),
              Text(
                'Save scan history and sync settings across devices.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppTheme.onSurfaceVariant),
              ),
              const SizedBox(height: AppTheme.spacingXl),
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
                    TextField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Full name (optional)',
                        hintText: 'Jane Doe',
                        prefixIcon: const Icon(Icons.person_outline_rounded, size: 22, color: AppTheme.onSurfaceVariant),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppTheme.radiusMd)),
                        filled: true,
                        fillColor: AppTheme.background.withOpacity(0.5),
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacingMd),
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
                        hintText: 'At least 8 characters',
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
                    const SizedBox(height: AppTheme.spacingMd),
                    TextField(
                      controller: _confirmController,
                      obscureText: _obscureConfirm,
                      decoration: InputDecoration(
                        labelText: 'Confirm password',
                        hintText: 'Repeat your password',
                        prefixIcon: const Icon(Icons.lock_outline_rounded, size: 22, color: AppTheme.onSurfaceVariant),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureConfirm ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                            size: 22,
                            color: AppTheme.onSurfaceVariant,
                          ),
                          onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                        ),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppTheme.radiusMd)),
                        filled: true,
                        fillColor: AppTheme.background.withOpacity(0.5),
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacingXs),
                    Text(
                      'Use at least 8 characters, including a number or symbol.',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(color: AppTheme.onSurfaceVariant),
                    ),
                    const SizedBox(height: AppTheme.spacingMd),
                    InkWell(
                      onTap: () => setState(() => _acceptTerms = !_acceptTerms),
                      borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingXs),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              _acceptTerms ? Icons.check_box_rounded : Icons.check_box_outline_blank_rounded,
                              color: _acceptTerms ? AppTheme.primary : AppTheme.outline,
                              size: 24,
                            ),
                            const SizedBox(width: AppTheme.spacingSm),
                            Expanded(
                              child: RichText(
                                text: TextSpan(
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppTheme.onSurfaceVariant),
                                  children: const [
                                    TextSpan(text: 'I agree to the '),
                                    TextSpan(text: 'Terms', style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w500)),
                                    TextSpan(text: ' & '),
                                    TextSpan(text: 'Privacy Policy', style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w500)),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
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
                              child: Text(_error!, style: const TextStyle(color: AppTheme.error, fontSize: 13)),
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
                            : const Text('Create account', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
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
                    'Already have an account? ',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.onSurfaceVariant),
                  ),
                  GestureDetector(
                    onTap: widget.onNavigateToLogin,
                    child: Text(
                      'Log in',
                      style: TextStyle(color: AppTheme.primary, fontWeight: FontWeight.w600, fontSize: 14),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppTheme.spacingXxl),
                ],
              ),
            ),
          ),
      ),
    );
  }
}
