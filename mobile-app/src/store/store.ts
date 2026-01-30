/**
 * Redux Store Configuration
 */
import { configureStore } from '@reduxjs/toolkit';
import scanReducer from './slices/scanSlice';
import deviceReducer from './slices/deviceSlice';
import settingsReducer from './slices/settingsSlice';

export const store = configureStore({
  reducer: {
    scan: scanReducer,
    devices: deviceReducer,
    settings: settingsReducer,
  },
  middleware: (getDefaultMiddleware) =>
    getDefaultMiddleware({
      serializableCheck: {
        // Ignore these action types
        ignoredActions: ['scan/setAnalysis'],
      },
    }),
});

export type RootState = ReturnType<typeof store.getState>;
export type AppDispatch = typeof store.dispatch;
