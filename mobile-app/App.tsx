/**
 * SecureNet Mobile App Entry Point
 */
import React, { useEffect, useState, createContext, useContext } from 'react';
import { Platform } from 'react-native';
import { NavigationContainer } from '@react-navigation/native';
import { Provider as PaperProvider } from 'react-native-paper';
import { SafeAreaProvider } from 'react-native-safe-area-context';
import { Provider as ReduxProvider, useDispatch } from 'react-redux';
import { store } from './src/store/store';
import { loadSettingsFromStorage } from './src/store/slices/settingsSlice';
import AppNavigator from './src/navigation/AppNavigator';
import AuthNavigator from './src/navigation/AuthNavigator';
import SplashScreen from './src/screens/SplashScreen';
import ErrorBoundary from './src/components/ErrorBoundary';

// Conditional StatusBar import (expo-status-bar doesn't work on web)
let StatusBar: any;
if (Platform.OS !== 'web') {
  StatusBar = require('expo-status-bar').StatusBar;
} else {
  // Web fallback - StatusBar is not needed on web
  StatusBar = () => null;
}

type AuthContextType = {
  isAuthenticated: boolean;
  login: () => void;
  logout: () => void;
};

export const AuthContext = createContext<AuthContextType | undefined>(undefined);

export const useAuth = () => {
  const ctx = useContext(AuthContext);
  if (!ctx) {
    throw new Error('useAuth must be used within AuthProvider');
  }
  return ctx;
};

const AppContent: React.FC = () => {
  const dispatch = useDispatch();
  const [isAuthenticated, setIsAuthenticated] = useState(false);
  const [showSplash, setShowSplash] = useState(true);

  useEffect(() => {
    // Load settings from storage on app start
    loadSettingsFromStorage(dispatch);
  }, [dispatch]);

  const authValue: AuthContextType = {
    isAuthenticated,
    login: () => setIsAuthenticated(true),
    logout: () => setIsAuthenticated(false),
  };

  if (showSplash) {
    return (
      <SplashScreen onGetStarted={() => setShowSplash(false)} />
    );
  }

  return (
    <AuthContext.Provider value={authValue}>
      <NavigationContainer>
        {isAuthenticated ? <AppNavigator /> : <AuthNavigator />}
      </NavigationContainer>
    </AuthContext.Provider>
  );
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
