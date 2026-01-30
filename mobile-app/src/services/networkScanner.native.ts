/**
 * Native Network Scanner Implementation
 * This file provides platform-specific implementations
 */

import { Platform, NativeModules } from 'react-native';
import { DeviceScan } from '../types';

// Get native module
const { NetworkScanner } = NativeModules;

/**
 * Get local network information
 */
export const getLocalNetworkInfo = async (): Promise<{
  ipAddress: string;
  subnetMask: string;
  gateway: string;
} | null> => {
  try {
    if (NetworkScanner && NetworkScanner.getLocalNetworkInfo) {
      const info = await NetworkScanner.getLocalNetworkInfo();
      return {
        ipAddress: info.ipAddress || '',
        subnetMask: info.subnetMask || '',
        gateway: info.gateway || '',
      };
    }
    return null;
  } catch (error) {
    console.error('Error getting network info:', error);
    return null;
  }
};

/**
 * Scan ARP table for devices
 */
export const scanARPTable = async (): Promise<DeviceScan[]> => {
  try {
    if (NetworkScanner && NetworkScanner.scanARPTable) {
      const devices = await NetworkScanner.scanARPTable();
      return devices.map((device: any) => ({
        ip_address: device.ip_address,
        mac_address: device.mac_address || '00:00:00:00:00:00',
        device_name: device.device_name || 'Unknown Device',
        open_ports: [],
        vendor: device.vendor || 'Unknown',
      }));
    }
    return [];
  } catch (error) {
    console.error('Error scanning ARP table:', error);
    return [];
  }
};

/**
 * Scan ports on a device
 */
export const scanDevicePorts = async (
  ipAddress: string,
  ports: number[] = [23, 22, 80, 443, 21, 3389, 5900, 8080]
): Promise<number[]> => {
  try {
    if (NetworkScanner && NetworkScanner.scanPorts) {
      const openPorts = await NetworkScanner.scanPorts(ipAddress, ports);
      return openPorts || [];
    }
    return [];
  } catch (error) {
    console.error('Error scanning ports:', error);
    return [];
  }
};
