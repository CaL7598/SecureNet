/**
 * Local Storage Service for Scan History
 */
import AsyncStorage from '@react-native-async-storage/async-storage';
import { ScanHistory } from '../types';

const HISTORY_KEY = '@SecureNet:scan_history';
const MAX_HISTORY_ITEMS = 50;

/**
 * Save scan to history
 */
export const saveScanHistory = async (analysis: {
  network_score: number;
  overall_risk: string;
  total_devices: number;
  critical_issues: number;
}): Promise<void> => {
  try {
    const history = await getScanHistory();
    const newEntry: ScanHistory = {
      id: Date.now().toString(),
      timestamp: new Date(),
      ...analysis,
      overall_risk: analysis.overall_risk as any,
    };

    // Add to beginning and limit to MAX_HISTORY_ITEMS
    const updatedHistory = [newEntry, ...history].slice(0, MAX_HISTORY_ITEMS);

    await AsyncStorage.setItem(HISTORY_KEY, JSON.stringify(updatedHistory));
  } catch (error) {
    console.error('Error saving scan history:', error);
  }
};

/**
 * Get scan history
 */
export const getScanHistory = async (): Promise<ScanHistory[]> => {
  try {
    const stored = await AsyncStorage.getItem(HISTORY_KEY);
    if (stored) {
      const history = JSON.parse(stored);
      // Convert timestamp strings back to Date objects
      return history.map((item: any) => ({
        ...item,
        timestamp: new Date(item.timestamp),
      }));
    }
    return [];
  } catch (error) {
    console.error('Error loading scan history:', error);
    return [];
  }
};

/**
 * Clear scan history
 */
export const clearScanHistory = async (): Promise<void> => {
  try {
    await AsyncStorage.removeItem(HISTORY_KEY);
  } catch (error) {
    console.error('Error clearing scan history:', error);
  }
};

/**
 * Delete a specific scan from history
 */
export const deleteScanHistory = async (id: string): Promise<void> => {
  try {
    const history = await getScanHistory();
    const updatedHistory = history.filter((item) => item.id !== id);
    await AsyncStorage.setItem(HISTORY_KEY, JSON.stringify(updatedHistory));
  } catch (error) {
    console.error('Error deleting scan history:', error);
  }
};
