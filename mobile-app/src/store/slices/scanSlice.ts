/**
 * Scan State Management
 */
import { createSlice, PayloadAction } from '@reduxjs/toolkit';
import { NetworkAnalysis } from '../../types';

interface ScanState {
  isScanning: boolean;
  scanProgress: number;
  scanMessage: string;
  currentAnalysis: NetworkAnalysis | null;
  error: string | null;
}

const initialState: ScanState = {
  isScanning: false,
  scanProgress: 0,
  scanMessage: '',
  currentAnalysis: null,
  error: null,
};

const scanSlice = createSlice({
  name: 'scan',
  initialState,
  reducers: {
    startScan: (state) => {
      state.isScanning = true;
      state.scanProgress = 0;
      state.scanMessage = 'Starting scan...';
      state.error = null;
      state.currentAnalysis = null;
    },
    updateProgress: (
      state,
      action: PayloadAction<{ progress: number; message: string }>
    ) => {
      state.scanProgress = action.payload.progress;
      state.scanMessage = action.payload.message;
    },
    setAnalysis: (state, action: PayloadAction<NetworkAnalysis>) => {
      state.currentAnalysis = action.payload;
      state.isScanning = false;
      state.scanProgress = 100;
      state.scanMessage = 'Scan complete!';
    },
    setError: (state, action: PayloadAction<string>) => {
      state.error = action.payload;
      state.isScanning = false;
      state.scanMessage = 'Scan failed';
    },
    resetScan: (state) => {
      state.isScanning = false;
      state.scanProgress = 0;
      state.scanMessage = '';
      state.error = null;
      state.currentAnalysis = null;
    },
  },
});

export const { startScan, updateProgress, setAnalysis, setError, resetScan } =
  scanSlice.actions;
export default scanSlice.reducer;
