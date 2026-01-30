/**
 * Settings State Management
 */
import { createSlice, PayloadAction } from '@reduxjs/toolkit';
import { ScanSettings } from '../../types';
import AsyncStorage from '@react-native-async-storage/async-storage';

const SETTINGS_KEY = '@SecureNet:settings';

const defaultSettings: ScanSettings = {
  scanInterval: 'manual',
  defaultScanMode: 'real',
  enableNotifications: true,
  criticalAlerts: true,
  highRiskAlerts: true,
};

interface SettingsState {
  settings: ScanSettings;
  isLoading: boolean;
}

const initialState: SettingsState = {
  settings: defaultSettings,
  isLoading: true,
};

const settingsSlice = createSlice({
  name: 'settings',
  initialState,
  reducers: {
    setSettings: (state, action: PayloadAction<ScanSettings>) => {
      state.settings = action.payload;
      // Persist to storage
      AsyncStorage.setItem(SETTINGS_KEY, JSON.stringify(action.payload));
    },
    updateSetting: <K extends keyof ScanSettings>(
      state: SettingsState,
      action: PayloadAction<{ key: K; value: ScanSettings[K] }>
    ) => {
      state.settings[action.payload.key] = action.payload.value;
      AsyncStorage.setItem(SETTINGS_KEY, JSON.stringify(state.settings));
    },
    loadSettings: (state, action: PayloadAction<ScanSettings>) => {
      state.settings = action.payload;
      state.isLoading = false;
    },
    setLoading: (state, action: PayloadAction<boolean>) => {
      state.isLoading = action.payload;
    },
  },
});

export const { setSettings, updateSetting, loadSettings, setLoading } =
  settingsSlice.actions;

// Load settings from storage
export const loadSettingsFromStorage = async (dispatch: any) => {
  try {
    const stored = await AsyncStorage.getItem(SETTINGS_KEY);
    if (stored) {
      dispatch(loadSettings(JSON.parse(stored)));
    } else {
      dispatch(loadSettings(defaultSettings));
    }
  } catch (error) {
    console.error('Error loading settings:', error);
    dispatch(loadSettings(defaultSettings));
  }
};

export default settingsSlice.reducer;
