import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../theme/app_theme.dart';
import '../models/device.dart';
import '../services/api_service.dart';
import '../services/network_scanner.dart';
import 'scan_results_screen.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  final ApiService _api = ApiService();
  final NetworkScanner _scanner = NetworkScanner();
  bool _isScanning = false;
  bool _cancelRequested = false;
  int _progress = 0;
  String _message = '';
  bool _demoMode = !kReleaseMode;
  bool _deepScan = false;

  Future<void> _startScan() async {
    setState(() {
      _isScanning = true;
      _cancelRequested = false;
      _progress = 0;
      _message = 'Starting...';
    });

    List<DeviceScan> devices;
    if (_demoMode) {
      await Future.delayed(const Duration(milliseconds: 300));
      if (!mounted) return;
      setState(() {
        _progress = 30;
        _message = 'Loading demo data...';
      });
      await Future.delayed(const Duration(milliseconds: 400));
      devices = [
        DeviceScan(
          ipAddress: '192.168.1.1',
          macAddress: '00:11:22:33:44:55',
          deviceName: 'Netgear-Router',
          openPorts: [23, 80, 443],
          vendor: 'Netgear',
        ),
        DeviceScan(
          ipAddress: '192.168.1.100',
          macAddress: 'AA:BB:CC:DD:EE:FF',
          deviceName: 'Unknown Device',
          openPorts: [80],
          vendor: 'Unknown',
        ),
      ];
    } else {
      devices = await _scanner.scanWithOptions(
        onProgress: (progress, message) {
          if (!mounted) return;
          setState(() {
            _progress = progress;
            _message = message;
          });
        },
        deepScan: _deepScan,
        shouldCancel: () => _cancelRequested,
      );
      if (_cancelRequested) {
        if (!mounted) return;
        setState(() {
          _isScanning = false;
          _message = 'Scan canceled';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Scan canceled successfully.'),
            duration: Duration(seconds: 2),
          ),
        );
        return;
      }
    }

    if (!mounted) return;
    if (devices.isEmpty) {
      setState(() {
        _isScanning = false;
        _progress = 0;
        _message = 'No reachable devices found';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No reachable devices found on this network.'),
        ),
      );
      return;
    }

    if (_cancelRequested) {
      setState(() {
        _isScanning = false;
        _message = 'Scan canceled';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Scan canceled successfully.'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    setState(() {
      _progress = 70;
      _message = 'Analyzing network...';
    });

    final analysis = await _api.analyzeNetwork(devices);

    if (!mounted) return;
    setState(() {
      _isScanning = false;
      _progress = 100;
    });

    if (analysis != null) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => ScanResultsScreen(analysis: analysis),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Backend unavailable. Run the API server or use Demo mode.'),
          backgroundColor: AppTheme.error,
        ),
      );
    }
  }

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
              _buildHero(context),
              const SizedBox(height: AppTheme.spacingLg),
              _buildSectionLabel(context, 'Core capabilities'),
              const SizedBox(height: AppTheme.spacingSm),
              _buildFeature(context, Icons.router_rounded, 'Device Discovery', 'Maps every IP and MAC on your Wi‑Fi.', AppTheme.primary),
              _buildFeature(context, Icons.radar_rounded, 'Vulnerability Scan', 'Checks open ports and unpatched firmware.', AppTheme.secondary),
              _buildFeature(context, Icons.lock_rounded, 'Credential Audit', 'Detects dangerous default passwords.', AppTheme.tertiary),
              const SizedBox(height: AppTheme.spacingLg),
              if (!kReleaseMode) ...[
                _buildSectionLabel(context, 'Scan mode'),
                const SizedBox(height: AppTheme.spacingSm),
                _buildModeSelector(context),
              ] else ...[
                Container(
                  padding: const EdgeInsets.all(AppTheme.spacingSm),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceVariant.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.radar_rounded, size: 16, color: AppTheme.primary),
                      const SizedBox(width: AppTheme.spacingSm),
                      Expanded(
                        child: Text(
                          'Release mode uses real network scan automatically.',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppTheme.onSurfaceVariant,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: AppTheme.spacingMd),
              _buildSectionLabel(context, 'Scan depth'),
              const SizedBox(height: AppTheme.spacingSm),
              _buildDepthSelector(context),
              if (_isScanning) _buildProgressCard(context),
              const SizedBox(height: AppTheme.spacingXl),
              _buildPrimaryButton(context),
              const SizedBox(height: AppTheme.spacingXxl),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppTheme.primary.withOpacity(0.2),
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          ),
          child: const Icon(Icons.shield_rounded, size: 22, color: AppTheme.primary),
        ),
        const SizedBox(width: AppTheme.spacingMd),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'SecureNet',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppTheme.onSurface,
                  ),
            ),
            Text(
              'Network auditing for everyone',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppTheme.onSurfaceVariant,
                  ),
            ),
          ],
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

  Widget _buildHero(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(AppTheme.spacingXl),
        decoration: BoxDecoration(
          color: AppTheme.surfaceVariant.withOpacity(0.5),
          borderRadius: BorderRadius.circular(AppTheme.radiusXl),
          border: Border.all(color: AppTheme.primary.withOpacity(0.2)),
        ),
        child: Column(
          children: [
            Icon(Icons.qr_code_scanner_rounded, size: 80, color: AppTheme.primary.withOpacity(0.9)),
            const SizedBox(height: AppTheme.spacingMd),
            Text(
              'Scan your network',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.onSurface,
                  ),
            ),
            const SizedBox(height: AppTheme.spacingXs),
            Text(
              'Discover devices and identify security vulnerabilities.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeature(BuildContext context, IconData icon, String title, String sub, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.spacingMd),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(AppTheme.spacingSm),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
            ),
            child: Icon(icon, color: color, size: 20),
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
                  sub,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeSelector(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingXs),
      decoration: BoxDecoration(
        color: AppTheme.surfaceVariant,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: AppTheme.outline.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _ModeChip(
              label: 'Real scan',
              selected: !_demoMode,
              onTap: () => setState(() => _demoMode = false),
            ),
          ),
          Expanded(
            child: _ModeChip(
              label: 'Demo mode',
              selected: _demoMode,
              onTap: () => setState(() => _demoMode = true),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCard(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AppTheme.spacingLg),
      child: Container(
        padding: const EdgeInsets.all(AppTheme.spacingMd),
        decoration: BoxDecoration(
          color: AppTheme.surfaceVariant,
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          border: Border.all(color: AppTheme.primary.withOpacity(0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _message,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppTheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: AppTheme.spacingSm),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: _progress / 100,
                backgroundColor: AppTheme.background,
                valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primary),
                minHeight: 6,
              ),
            ),
            const SizedBox(height: AppTheme.spacingXs),
            Text(
              '$_progress%',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppTheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: AppTheme.spacingSm),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: _cancelRequested
                    ? null
                    : () {
                        setState(() {
                          _cancelRequested = true;
                          _message = 'Canceling scan...';
                        });
                      },
                icon: const Icon(Icons.stop_circle_outlined, size: 16, color: AppTheme.error),
                label: const Text(
                  'Cancel scan',
                  style: TextStyle(color: AppTheme.error, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrimaryButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: FilledButton(
        onPressed: _isScanning ? null : _startScan,
        style: FilledButton.styleFrom(
          backgroundColor: AppTheme.primary,
          foregroundColor: AppTheme.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          ),
          elevation: 0,
        ),
        child: _isScanning
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppTheme.onPrimary,
                ),
              )
            : const Text('Start scan', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
      ),
    );
  }

  Widget _buildDepthSelector(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingXs),
      decoration: BoxDecoration(
        color: AppTheme.surfaceVariant,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: AppTheme.outline.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _ModeChip(
              label: 'Quick',
              selected: !_deepScan,
              onTap: () => setState(() => _deepScan = false),
            ),
          ),
          Expanded(
            child: _ModeChip(
              label: 'Deep',
              selected: _deepScan,
              onTap: () => setState(() => _deepScan = true),
            ),
          ),
        ],
      ),
    );
  }
}

class _ModeChip extends StatelessWidget {
  const _ModeChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingMd),
          decoration: BoxDecoration(
            color: selected ? AppTheme.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: selected ? AppTheme.onPrimary : AppTheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
