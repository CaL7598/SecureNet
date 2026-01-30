/**
 * SecureNet Color Theme
 * Dark theme matching the design specifications
 */
export const colors = {
  // Primary colors
  primary: '#00D4FF', // Light blue
  primaryDark: '#0099CC',
  primaryLight: '#33DDFF',
  
  // Background colors
  background: '#000000',
  surface: '#1A1A1A',
  surfaceVariant: '#2A2A2A',
  card: '#1E1E1E',
  
  // Text colors
  text: '#FFFFFF',
  textSecondary: '#CCCCCC',
  textDisabled: '#666666',
  
  // Status colors
  success: '#4CAF50', // Green
  warning: '#FF9800', // Orange
  error: '#F44336', // Red
  info: '#2196F3', // Blue
  
  // Risk level colors
  secure: '#4CAF50',
  lowRisk: '#8BC34A',
  mediumRisk: '#FF9800',
  highRisk: '#FF5722',
  critical: '#D32F2F',
  
  // Accent colors
  purple: '#9C27B0',
  yellow: '#FFC107',
  
  // UI elements
  border: '#333333',
  divider: '#2A2A2A',
  disabled: '#444444',
  
  // Navigation
  tabActive: '#00D4FF',
  tabInactive: '#666666',
};

export type ColorTheme = typeof colors;
