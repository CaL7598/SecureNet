import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';
import 'providers/app_state.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/reset_password_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/main_screen.dart';
import 'services/api_service.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => AppState(),
      child: const SecureNetApp(),
    ),
  );
}

class SecureNetApp extends StatelessWidget {
  const SecureNetApp({super.key});

  static final ApiService _api = ApiService();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SecureNet',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: Consumer<AppState>(
        builder: (context, state, _) {
          _api.setBearerToken(state.accessToken);
          _api.setRefreshToken(state.refreshToken);
          if (state.showSplash) {
            return SplashScreen(onGetStarted: state.finishSplash);
          }
          if (!state.isAuthenticated) {
            return LoginScreen(
              onLogin: (email, password) async {
                final session = await _api.login(email: email, password: password);
                if (session == null) {
                  return _api.lastAuthError ?? 'Login failed. Please try again.';
                }
                final token = session['access_token'] as String?;
                final refreshToken = session['refresh_token'] as String?;
                final user = session['user'] as Map<String, dynamic>?;
                if (token == null || refreshToken == null || user == null) {
                  return 'Unexpected auth response from server.';
                }
                _api.setBearerToken(token);
                _api.setRefreshToken(refreshToken);
                state.loginWithSession(
                  token: token,
                  refreshToken: refreshToken,
                  email: (user['email'] as String?) ?? email,
                  displayName: user['full_name'] as String?,
                  emailVerified: user['is_email_verified'] == true,
                  promptEmailVerification: false,
                );
                await state.syncProfileAndHistoryFromBackend(_api);
                return null;
              },
              onForgotPassword: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const ResetPasswordScreen(),
                  ),
                );
              },
              onNavigateToSignUp: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => SignUpScreen(
                      onSignUp: (email, password, fullName) async {
                        final session = await _api.register(
                          email: email,
                          password: password,
                          fullName: fullName,
                        );
                        if (session == null) {
                          return _api.lastAuthError ?? 'Sign up failed. Please try again.';
                        }
                        final token = session['access_token'] as String?;
                        final refreshToken = session['refresh_token'] as String?;
                        final user = session['user'] as Map<String, dynamic>?;
                        if (token == null || refreshToken == null || user == null) {
                          return 'Unexpected auth response from server.';
                        }
                        _api.setBearerToken(token);
                        _api.setRefreshToken(refreshToken);
                        final welcomeSent = session['welcome_email_sent'] as bool?;
                        state.loginWithSession(
                          token: token,
                          refreshToken: refreshToken,
                          email: (user['email'] as String?) ?? email,
                          displayName: user['full_name'] as String?,
                          emailVerified: user['is_email_verified'] == true,
                          promptEmailVerification: false,
                          welcomeEmailStatus: welcomeSent == true
                              ? WelcomeEmailStatus.sent
                              : WelcomeEmailStatus.failed,
                        );
                        await state.syncProfileAndHistoryFromBackend(_api);
                        return null;
                      },
                      onNavigateToLogin: () => Navigator.of(context).pop(),
                    ),
                  ),
                );
              },
            );
          }
          return _AuthedHome(api: _api);
        },
      ),
    );
  }
}

class _AuthedHome extends StatefulWidget {
  const _AuthedHome({required this.api});

  final ApiService api;

  @override
  State<_AuthedHome> createState() => _AuthedHomeState();
}

class _AuthedHomeState extends State<_AuthedHome> {
  bool _synced = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_synced) return;
    _synced = true;
    _syncSession();
  }

  void _maybeShowWelcomeEmailNotice() {
    final state = context.read<AppState>();
    final status = state.consumeWelcomeEmailStatus();
    if (status == WelcomeEmailStatus.none) return;

    final message = status == WelcomeEmailStatus.sent
        ? 'Welcome! We sent an email to ${state.email} with your account details.'
        : 'Account created, but we could not send the welcome email yet. Check spam or try again later.';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: status == WelcomeEmailStatus.sent ? null : AppTheme.warning.withValues(alpha: 0.95),
      ),
    );
  }

  Future<void> _syncSession() async {
    final state = context.read<AppState>();
    await state.syncProfileAndHistoryFromBackend(widget.api);
    final me = await widget.api.me();
    if (me != null) {
      if (mounted) _maybeShowWelcomeEmailNotice();
      return;
    }
    final refreshed = await widget.api.refreshSession();
    if (refreshed == null) return;
    final token = refreshed['access_token'] as String?;
    final refreshToken = refreshed['refresh_token'] as String?;
    final user = refreshed['user'] as Map<String, dynamic>?;
    if (token == null || refreshToken == null || user == null) return;
    widget.api.setBearerToken(token);
    widget.api.setRefreshToken(refreshToken);
    state.loginWithSession(
      token: token,
      refreshToken: refreshToken,
      email: (user['email'] as String?) ?? state.email,
      displayName: user['full_name'] as String?,
      emailVerified: user['is_email_verified'] == true,
      promptEmailVerification: false,
    );
    await state.syncProfileAndHistoryFromBackend(widget.api);
    if (mounted) _maybeShowWelcomeEmailNotice();
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _maybeShowWelcomeEmailNotice();
    });
    return const MainScreen();
  }
}
