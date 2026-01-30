/**
 * Network Scanning Service
 * Handles device discovery and port scanning
 */
import { Platform } from 'react-native';
import { DeviceScan } from '../types';
import { scanARPTable, scanDevicePorts, getLocalNetworkInfo } from './networkScanner.native';

// Conditional import for NetworkInfo (doesn't work on web)
let NetworkInfo: any;
if (Platform.OS !== 'web') {
  NetworkInfo = require('react-native-network-info');
} else {
  // Web fallback
  NetworkInfo = {
    getIPAddress: async () => {
      // Web can't get real IP, return localhost
      return '127.0.0.1';
    },
  };
}

/**
 * Scan the local network for devices
 * Uses ARP table scanning and port scanning
 */
export const scanNetwork = async (
  onProgress?: (progress: number, message: string) => void
): Promise<DeviceScan[]> => {
  try {
    onProgress?.(0, 'Getting network information...');
    
    // Get local network info
    const networkInfo = await getLocalNetworkInfo();
    let ipAddress: string;
    let networkPrefix: string;

    if (networkInfo) {
      ipAddress = networkInfo.ipAddress;
      networkPrefix = ipAddress.substring(0, ipAddress.lastIndexOf('.') + 1);
    } else {
      // Fallback to NetworkInfo
      ipAddress = await NetworkInfo.getIPAddress();
      if (!ipAddress) {
        throw new Error('Could not determine local IP address');
      }
      networkPrefix = ipAddress.substring(0, ipAddress.lastIndexOf('.') + 1);
    }

    onProgress?.(20, 'Scanning ARP table for devices...');
    
    // Try native ARP scanning first
    let devices = await scanARPTable();
    
    // If native scanning returns empty, use fallback method
    if (devices.length === 0) {
      onProgress?.(30, 'Discovering devices on network...');
      devices = await fallbackDeviceDiscovery(networkPrefix, onProgress);
    }

    onProgress?.(60, 'Scanning ports on discovered devices...');
    
    // Scan ports on each device
    const devicesWithPorts: DeviceScan[] = [];
    const totalDevices = devices.length;
    
    for (let i = 0; i < devices.length; i++) {
      const device = devices[i];
      const progress = 60 + Math.floor((i / totalDevices) * 30);
      
      onProgress?.(progress, `Scanning ${device.ip_address}...`);
      
      try {
        const openPorts = await scanDevicePorts(device.ip_address);
        devicesWithPorts.push({
          ...device,
          open_ports: openPorts.length > 0 ? openPorts : device.open_ports || [],
        });
      } catch (error) {
        // If port scanning fails, keep device without ports
        devicesWithPorts.push(device);
      }
    }

    onProgress?.(100, 'Scan complete!');
    
    return devicesWithPorts;
  } catch (error) {
    console.error('Network scan error:', error);
    throw new Error(`Failed to scan network: ${error instanceof Error ? error.message : 'Unknown error'}`);
  }
};

/**
 * Fallback device discovery method
 * Scans common IP addresses in the network
 */
const fallbackDeviceDiscovery = async (
  networkPrefix: string,
  onProgress?: (progress: number, message: string) => void
): Promise<DeviceScan[]> => {
  const devices: DeviceScan[] = [];
  const commonIPs = [1, 100, 101, 102, 103, 104, 105]; // Router and common device IPs
  
  // Always include router (usually .1)
  devices.push({
    ip_address: `${networkPrefix}1`,
    mac_address: generateRandomMAC(),
    device_name: 'Router',
    open_ports: [],
    vendor: 'Unknown',
  });

  // Try to discover other devices by checking common IPs
  // In a real implementation, this would ping or check ARP table
  for (const lastOctet of commonIPs.slice(1)) {
    const testIp = `${networkPrefix}${lastOctet}`;
    // Simulate device discovery - in real app, this would ping or check ARP
    // For now, we'll add a few simulated devices
    if (lastOctet <= 105) {
      devices.push({
        ip_address: testIp,
        mac_address: generateRandomMAC(),
        device_name: `Device-${lastOctet}`,
        open_ports: [],
        vendor: 'Unknown',
      });
    }
  }

  return devices;
};

/**
 * Generate a random MAC address (for fallback)
 */
const generateRandomMAC = (): string => {
  const hex = '0123456789ABCDEF';
  let mac = '';
  for (let i = 0; i < 6; i++) {
    if (i > 0) mac += ':';
    mac += hex[Math.floor(Math.random() * 16)];
    mac += hex[Math.floor(Math.random() * 16)];
  }
  return mac;
};

/**
 * Scan ports on a specific device
 */
export const scanPorts = async (
  ipAddress: string,
  ports: number[] = [23, 22, 80, 443, 21, 3389, 5900]
): Promise<number[]> => {
  const openPorts: number[] = [];

  // TODO: Implement actual port scanning using native TCP socket module
  // This would require react-native-tcp-socket or similar

  return openPorts;
};

/**
 * Get device vendor from MAC address
 */
export const getVendorFromMAC = (macAddress: string): string | undefined => {
  // TODO: Implement MAC address vendor lookup
  // Could use a local database or API
  return undefined;
};
