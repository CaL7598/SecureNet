import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'dashboard_screen.dart';
import 'scan_screen.dart';
import 'map_screen.dart';
import 'history_screen.dart';
import 'settings_screen.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        backgroundColor: AppTheme.background,
        body: const TabBarView(
          children: [
            DashboardScreen(),
            ScanScreen(),
            MapScreen(),
            HistoryScreen(),
            SettingsScreen(),
          ],
        ),
        bottomNavigationBar: Container(
          decoration: const BoxDecoration(
            color: AppTheme.surface,
            border: Border(top: BorderSide(color: AppTheme.divider)),
          ),
          child: const TabBar(
            labelColor: AppTheme.primary,
            unselectedLabelColor: AppTheme.onSurfaceVariant,
            indicatorColor: Colors.transparent,
            tabs: [
              Tab(icon: Icon(Icons.dashboard_rounded), text: 'Home'),
              Tab(icon: Icon(Icons.qr_code_scanner_rounded), text: 'Scan'),
              Tab(icon: Icon(Icons.map_rounded), text: 'Map'),
              Tab(icon: Icon(Icons.history_rounded), text: 'History'),
              Tab(icon: Icon(Icons.settings_rounded), text: 'Settings'),
            ],
          ),
        ),
      ),
    );
  }
}
