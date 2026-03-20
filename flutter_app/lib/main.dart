import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';
import 'providers/app_state.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/main_screen.dart';

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

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SecureNet',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: Consumer<AppState>(
        builder: (context, state, _) {
          if (state.showSplash) {
            return SplashScreen(onGetStarted: state.finishSplash);
          }
          if (!state.isAuthenticated) {
            return LoginScreen(
              onLogin: state.login,
              onNavigateToSignUp: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => SignUpScreen(
                      onSignUp: state.login,
                      onNavigateToLogin: () => Navigator.of(context).pop(),
                    ),
                  ),
                );
              },
            );
          }
          return const MainScreen();
        },
      ),
    );
  }
}
