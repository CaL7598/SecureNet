// Mobile (iOS/Android): emulator/simulator use local host; physical device uses your PC's IP.
import 'dart:io';

/// Set to your PC's IP (e.g. '192.168.1.100') when running on a **physical phone** in debug.
/// Leave null for emulator/simulator. Find your IP: Windows `ipconfig`, macOS/Linux `ifconfig`.
const String kPhysicalDeviceHost = '192.168.1.175';

String get apiBaseUrl {
  if (kPhysicalDeviceHost != null && kPhysicalDeviceHost!.isNotEmpty) {
    return 'http://$kPhysicalDeviceHost:8000';
  }
  if (Platform.isAndroid) return 'http://10.0.2.2:8000'; // Android emulator
  return 'http://localhost:8000'; // iOS simulator
}
