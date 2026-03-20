import 'dart:io';

import '../models/device.dart';
import 'api_base_url.dart';

typedef ScanProgressCallback = void Function(int progress, String message);

/// Very simple TCP-based network scanner.
///
/// It:
/// - Derives a /24 subnet from the API base URL host
///   (e.g. 192.168.3.175 -> 192.168.3.x)
/// - Probes a small set of common ports on each IP
/// - Returns a list of DeviceScan entries with any open ports
class NetworkScanner {
  final List<int> _commonPorts = const [22, 23, 80, 443];

  Future<List<DeviceScan>> scan(ScanProgressCallback onProgress) async {
    // Derive subnet from the API host (which is your PC's IP on LAN).
    final host = Uri.parse(apiBaseUrl).host;
    final octets = host.split('.');
    if (octets.length != 4) {
      onProgress(100, 'Unable to detect subnet from $host');
      return [];
    }

    final subnet = '${octets[0]}.${octets[1]}.${octets[2]}';
    final devices = <DeviceScan>[];

    const start = 1;
    const end = 254;
    final total = (end - start + 1);

    for (var i = start; i <= end; i++) {
      final ip = '$subnet.$i';
      final percent = (5 + ((i - start) / total) * 60).round();
      onProgress(percent.clamp(5, 70), 'Scanning $ip...');

      final openPorts = <int>[];

      for (final port in _commonPorts) {
        try {
          final socket = await Socket.connect(
            ip,
            port,
            timeout: const Duration(milliseconds: 150),
          );
          socket.destroy();
          openPorts.add(port);
        } catch (_) {
          // Port closed/unreachable; ignore.
        }
      }

      if (openPorts.isNotEmpty) {
        devices.add(
          DeviceScan(
            ipAddress: ip,
            macAddress: 'UNKNOWN',
            deviceName: null,
            openPorts: openPorts,
            vendor: null,
          ),
        );
      }
    }

    onProgress(75, 'Found ${devices.length} devices, analyzing...');
    return devices;
  }
}

