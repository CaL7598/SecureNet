// Mobile (iOS/Android): production URL, LAN IP for physical device, or emulator defaults.
import 'dart:io';

/// Hosted API (set when building for phones outside your LAN).
///
/// ```sh
/// flutter build apk --dart-define=API_BASE_URL=https://api.yourdomain.com
/// ```
const String kApiBaseUrlFromEnvironment = String.fromEnvironment('API_BASE_URL');

/// Your PC's LAN IP when using a **physical phone** against a local backend.
/// Use `null` for emulator/simulator. Find IP: Windows `ipconfig`, macOS/Linux `ifconfig`.
const String? kPhysicalDeviceHost = null;

String _trimTrailingSlash(String url) {
  if (url.endsWith('/')) return url.substring(0, url.length - 1);
  return url;
}

String get apiBaseUrl {
  if (kApiBaseUrlFromEnvironment.isNotEmpty) {
    return _trimTrailingSlash(kApiBaseUrlFromEnvironment);
  }
  final host = kPhysicalDeviceHost;
  if (host != null && host.isNotEmpty) {
    return 'http://$host:8000';
  }
  if (Platform.isAndroid) return 'http://10.0.2.2:8000'; // Android emulator
  return 'http://localhost:8000'; // iOS simulator
}
