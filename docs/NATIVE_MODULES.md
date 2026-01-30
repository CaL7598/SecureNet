# Native Modules Implementation Guide

## Overview

SecureNet uses native modules for network scanning functionality that requires platform-specific APIs. This document explains how to set up and use these modules.

## Android Implementation

### Files Created
- `android/app/src/main/java/com/securenet/NetworkScannerModule.kt`
- `android/app/src/main/java/com/securenet/NetworkScannerPackage.kt`

### Setup Steps

1. **Register the Package** in `MainApplication.java` or `MainApplication.kt`:

```kotlin
import com.securenet.NetworkScannerPackage

override fun getPackages(): List<ReactPackage> {
    return listOf(
        MainReactPackage(),
        NetworkScannerPackage() // Add this
    )
}
```

2. **Add Permissions** to `AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
<uses-permission android:name="android.permission.ACCESS_WIFI_STATE" />
<uses-permission android:name="android.permission.CHANGE_WIFI_STATE" />
```

### Limitations

- **ARP Table Access**: Reading `/proc/net/arp` may require root access on some devices
- **Port Scanning**: TCP connection attempts may be blocked by firewall
- **Network Info**: Requires appropriate permissions

## iOS Implementation

### Files Created
- `ios/NetworkScanner.m` (Bridge header)
- `ios/NetworkScanner.swift` (Implementation)

### Setup Steps

1. **Add to Xcode Project**:
   - Open `ios/SecureNet.xcworkspace` in Xcode
   - Add `NetworkScanner.m` and `NetworkScanner.swift` to the project
   - Ensure they're added to the target

2. **Create Bridging Header** (if needed):
   - Create `SecureNet-Bridging-Header.h`
   - Add: `#import <React/RCTBridgeModule.h>`

3. **Add Capabilities**:
   - Enable "Network Extensions" capability if needed
   - Add "Local Network" usage description in Info.plist

### Limitations

- **ARP Table**: iOS doesn't provide direct ARP table access
- **Port Scanning**: May be limited by iOS security restrictions
- **Network Info**: Requires appropriate permissions

## Usage

The native modules are automatically used by `networkScanner.native.ts`:

```typescript
import { scanARPTable, scanDevicePorts, getLocalNetworkInfo } from './networkScanner.native';

// Get network info
const info = await getLocalNetworkInfo();

// Scan ARP table
const devices = await scanARPTable();

// Scan ports
const openPorts = await scanDevicePorts('192.168.1.1', [80, 443]);
```

## Fallback Behavior

If native modules are not available or fail:
- The JavaScript implementation in `networkScanner.ts` will use fallback methods
- Demo mode is always available for testing
- Network info falls back to `react-native-network-info` library

## Testing

1. **Test on Real Device**: Native modules work best on physical devices
2. **Check Permissions**: Ensure all required permissions are granted
3. **Use Demo Mode**: For development/testing without network access

## Troubleshooting

### Android
- **Module not found**: Ensure package is registered in MainApplication
- **Permission denied**: Check AndroidManifest.xml permissions
- **ARP table empty**: May require root access on some devices

### iOS
- **Build errors**: Ensure Swift files are added to target
- **Module not found**: Check bridging header configuration
- **Network access denied**: Check Info.plist permissions

## Future Enhancements

- Root/privileged access handling
- Alternative device discovery methods
- Background scanning support
- Network topology detection
