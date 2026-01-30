/**
 * API Client for SecureNet Backend
 */
import axios from 'axios';
import { Platform } from 'react-native';
import { NetworkAnalysis, DeviceScan } from '../types';

// ============================================
// IMPORTANT: For Physical Device Setup
// ============================================
// 1. Find your computer's IP address:
//    Windows: ipconfig
//    macOS/Linux: ifconfig
// 2. Replace PHONE_IP below with your IP (e.g., '192.168.1.100')
// 3. Make sure both devices are on the same Wi-Fi network
// ============================================

// Set this to your computer's IP address for physical devices
const PHONE_IP = '192.168.1.100'; // ⬅️ CHANGE THIS TO YOUR IP!

// Configure API URL based on platform
const getApiUrl = () => {
  if (!__DEV__) {
    return 'https://api.securenet.app'; // Production
  }

  // ============================================
  // FOR PHYSICAL DEVICE: Uncomment the line below
  // and make sure PHONE_IP is set to your IP
  // ============================================
  // return `http://${PHONE_IP}:8000`;

  // Default: platform-specific URLs (for simulators/emulators/web)
  if (Platform.OS === 'android') {
    return 'http://10.0.2.2:8000'; // Android emulator
  } else if (Platform.OS === 'ios') {
    return 'http://localhost:8000'; // iOS simulator
  } else if (Platform.OS === 'web') {
    return 'http://localhost:8000'; // Web browser
  }
  return 'http://localhost:8000'; // Default
};

const API_BASE_URL = getApiUrl();

const api = axios.create({
  baseURL: API_BASE_URL,
  headers: {
    'Content-Type': 'application/json',
  },
  timeout: 30000,
});

export const analyzeNetwork = async (
  devices: DeviceScan[]
): Promise<NetworkAnalysis> => {
  try {
    console.log('API Base URL:', API_BASE_URL);
    console.log('Sending request to:', `${API_BASE_URL}/api/v1/analyze-network`);
    console.log('Devices:', devices);
    
    const response = await api.post<NetworkAnalysis>(
      '/api/v1/analyze-network',
      {
        devices,
        scan_timestamp: new Date().toISOString(),
      }
    );
    
    console.log('API Response:', response.data);
    return response.data;
  } catch (error) {
    console.error('API Error:', error);
    if (axios.isAxiosError(error)) {
      const errorMessage = error.response?.data?.detail || 
        error.message || 
        'Failed to analyze network. Make sure the backend is running on http://localhost:8000';
      console.error('Error details:', {
        message: error.message,
        response: error.response?.data,
        status: error.response?.status,
      });
      throw new Error(errorMessage);
    }
    throw error;
  }
};

export const getVulnerabilities = async () => {
  try {
    const response = await api.get('/api/v1/vulnerabilities');
    return response.data;
  } catch (error) {
    if (axios.isAxiosError(error)) {
      throw new Error('Failed to fetch vulnerabilities');
    }
    throw error;
  }
};

export const healthCheck = async (): Promise<boolean> => {
  try {
    const response = await api.get('/api/v1/health');
    return response.data.status === 'healthy';
  } catch (error) {
    return false;
  }
};

export default api;
