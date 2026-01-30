/**
 * Web Compatibility Utilities
 */
import { Platform } from 'react-native';

/**
 * Check if running on web
 */
export const isWeb = Platform.OS === 'web';

/**
 * Safe icon component that works on web
 */
export const getIconComponent = () => {
  if (isWeb) {
    // For web, return a simple text-based icon or use a web-compatible library
    return ({ name, size, color }: any) => {
      // Simple fallback - you could use react-icons or similar
      return null; // Will be handled by conditional rendering
    };
  }
  // For native, use react-native-vector-icons
  const Icon = require('react-native-vector-icons/MaterialCommunityIcons').default;
  return Icon;
};
