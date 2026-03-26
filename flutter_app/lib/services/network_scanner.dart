import 'dart:io';

import '../models/device.dart';
import 'api_base_url.dart';

typedef ScanProgressCallback = void Function(int progress, String message);
typedef ShouldCancelScan = bool Function();

class NetworkScanner {
  static const List<int> _commonPorts = [
    22, // SSH
    23, // Telnet
    53, // DNS
    80, // HTTP
    139, // NetBIOS
    443, // HTTPS
    445, // SMB
    554, // RTSP (cameras)
    8000, // common admin/dev port
  ];

  static const Duration _portTimeout = Duration(milliseconds: 220);
  static const int _maxParallelHosts = 24;

  Future<List<DeviceScan>> scan(ScanProgressCallback onProgress) async {
    return scanWithOptions(
      onProgress: onProgress,
      deepScan: false,
      shouldCancel: null,
    );
  }

  Future<List<DeviceScan>> scanWithOptions({
    required ScanProgressCallback onProgress,
    required bool deepScan,
    ShouldCancelScan? shouldCancel,
  }) async {
    final subnetInfo = await _resolveSubnet();
    if (subnetInfo == null) {
      onProgress(100, 'Unable to detect local subnet');
      return [];
    }

    final subnet = subnetInfo.$1;
    final selfIp = subnetInfo.$2;
    final devices = <DeviceScan>[];

    const start = 1;
    const end = 254;
    final totalHosts = end - start + 1;
    var scannedHosts = 0;

    final portsToScan = deepScan
        ? const <int>[
            21,
            22,
            23,
            53,
            80,
            110,
            123,
            135,
            139,
            143,
            389,
            443,
            445,
            554,
            631,
            993,
            995,
            1723,
            1900,
            3389,
            5000,
            5353,
            8000,
            8080,
            8443,
          ]
        : _commonPorts;

    for (var batchStart = start; batchStart <= end; batchStart += _maxParallelHosts) {
      if (shouldCancel?.call() == true) {
        onProgress(_progressFor(scannedHosts, totalHosts), 'Scan canceled');
        return devices;
      }

      final batchEnd = (batchStart + _maxParallelHosts - 1).clamp(start, end);
      final futures = <Future<DeviceScan?>>[];

      for (var i = batchStart; i <= batchEnd; i++) {
        final ip = '$subnet.$i';
        if (ip == selfIp) {
          scannedHosts++;
          continue;
        }
        futures.add(_scanHost(ip, portsToScan, shouldCancel));
      }

      final batchResults = await Future.wait(futures);
      for (final result in batchResults) {
        scannedHosts++;
        if (result != null) devices.add(result);
      }

      final percent = _progressFor(scannedHosts, totalHosts);
      onProgress(percent, 'Scanning $subnet.x ($scannedHosts/$totalHosts)');
    }

    devices.sort((a, b) => _ipToSortableInt(a.ipAddress).compareTo(_ipToSortableInt(b.ipAddress)));
    onProgress(75, 'Found ${devices.length} devices, analyzing...');
    return devices;
  }

  Future<DeviceScan?> _scanHost(
    String ip,
    List<int> ports,
    ShouldCancelScan? shouldCancel,
  ) async {
    final openPorts = <int>[];
    for (final port in ports) {
      if (shouldCancel?.call() == true) return null;
      try {
        final socket = await Socket.connect(
          ip,
          port,
          timeout: _portTimeout,
        );
        socket.destroy();
        openPorts.add(port);
      } catch (_) {
        // Closed/unreachable port.
      }
    }

    if (openPorts.isEmpty) return null;
    return DeviceScan(
      ipAddress: ip,
      macAddress: 'UNKNOWN',
      deviceName: null,
      openPorts: openPorts,
      vendor: null,
    );
  }

  int _progressFor(int scannedHosts, int totalHosts) {
    return (5 + (scannedHosts / totalHosts) * 65).round().clamp(5, 70);
  }

  Future<(String, String)?> _resolveSubnet() async {
    try {
      final interfaces = await NetworkInterface.list(
        includeLoopback: false,
        includeLinkLocal: false,
        type: InternetAddressType.IPv4,
      );

      for (final iface in interfaces) {
        for (final addr in iface.addresses) {
          final ip = addr.address;
          if (_isPrivateIpv4(ip)) {
            final octets = ip.split('.');
            return ('${octets[0]}.${octets[1]}.${octets[2]}', ip);
          }
        }
      }
    } catch (_) {
      // Fall back below.
    }

    final host = Uri.parse(apiBaseUrl).host;
    if (_isPrivateIpv4(host)) {
      final octets = host.split('.');
      return ('${octets[0]}.${octets[1]}.${octets[2]}', host);
    }
    return null;
  }

  bool _isPrivateIpv4(String ip) {
    final octets = ip.split('.');
    if (octets.length != 4) return false;
    final a = int.tryParse(octets[0]);
    final b = int.tryParse(octets[1]);
    if (a == null || b == null) return false;
    if (a == 10) return true;
    if (a == 172 && b >= 16 && b <= 31) return true;
    if (a == 192 && b == 168) return true;
    return false;
  }

  int _ipToSortableInt(String ip) {
    final parts = ip.split('.').map((e) => int.tryParse(e) ?? 0).toList();
    if (parts.length != 4) return 0;
    return (parts[0] << 24) + (parts[1] << 16) + (parts[2] << 8) + parts[3];
  }
}

