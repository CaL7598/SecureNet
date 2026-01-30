/**
 * Error Handling Utilities
 */
import { Alert } from 'react-native';

export const handleError = (error: unknown, customMessage?: string): void => {
  let message = customMessage || 'An unexpected error occurred';
  
  if (error instanceof Error) {
    message = error.message;
  } else if (typeof error === 'string') {
    message = error;
  }

  console.error('Error:', error);
  
  Alert.alert('Error', message, [{ text: 'OK' }]);
};

export const handleNetworkError = (error: unknown): void => {
  let message = 'Network error. Please check your connection.';
  
  if (error instanceof Error) {
    if (error.message.includes('timeout')) {
      message = 'Request timed out. Please try again.';
    } else if (error.message.includes('Network')) {
      message = 'Cannot connect to server. Please check your connection.';
    } else {
      message = error.message;
    }
  }

  handleError(message);
};
