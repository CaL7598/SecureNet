/**
 * Device State Management
 */
import { createSlice, PayloadAction } from '@reduxjs/toolkit';
import { DeviceAnalysis } from '../../types';

interface DeviceState {
  selectedDevice: DeviceAnalysis | null;
  devices: DeviceAnalysis[];
}

const initialState: DeviceState = {
  selectedDevice: null,
  devices: [],
};

const deviceSlice = createSlice({
  name: 'devices',
  initialState,
  reducers: {
    setDevices: (state, action: PayloadAction<DeviceAnalysis[]>) => {
      state.devices = action.payload;
    },
    setSelectedDevice: (state, action: PayloadAction<DeviceAnalysis | null>) => {
      state.selectedDevice = action.payload;
    },
    clearDevices: (state) => {
      state.devices = [];
      state.selectedDevice = null;
    },
  },
});

export const { setDevices, setSelectedDevice, clearDevices } = deviceSlice.actions;
export default deviceSlice.reducer;
