/**
 * SecureNet Mobile App Entry Point
 */
import React, { useEffect } from 'react';
import { Platform } from 'react-native';
import { Provider as PaperProvider } from 'react-native-paper';
import { SafeAreaProvider } from 'react-native-safe-area-context';
import { Provider as ReduxProvider, useDispatch } from 'react-redux';
import { store } from './src/store/store';
import { loadSettingsFromStorage } from './src/store/slices/settingsSlice';
import AppNavigator from './src/navigation/AppNavigator';
import ErrorBoundary from './src/components/ErrorBoundary';

// Conditional StatusBar import (expo-status-bar doesn't work on web)
let StatusBar: any;
if (Platform.OS !== 'web') {
  StatusBar = require('expo-status-bar').StatusBar;
} else {
  // Web fallback - StatusBar is not needed on web
  StatusBar = () => null;
}

const AppContent: React.FC = () => {
  const dispatch = useDispatch();

  useEffect(() => {
    // Load settings from storage on app start
    loadSettingsFromStorage(dispatch);
  }, [dispatch]);

  return <AppNavigator />;
};

const App: React.FC = () => {
  return (
    <ErrorBoundary>
      <ReduxProvider store={store}>
        <SafeAreaProvider>
          <PaperProvider>
            <StatusBar style="light" />
            <AppContent />
          </PaperProvider>
        </SafeAreaProvider>
      </ReduxProvider>
    </ErrorBoundary>
  );
};

export default App;
