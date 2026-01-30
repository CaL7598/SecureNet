/**
 * Network Map Screen (Future Enhancement)
 */
import React from 'react';
import {
  View,
  Text,
  StyleSheet,
} from 'react-native';
import Icon from '../utils/iconHelper';
import { colors } from '../theme/colors';

const MapScreen: React.FC = () => {
  return (
    <View style={styles.container}>
      <View style={styles.emptyContainer}>
        <Icon name="map" size={64} color={colors.textDisabled} />
        <Text style={styles.emptyText}>Network Map</Text>
        <Text style={styles.emptySubtext}>
          Visual network topology coming soon
        </Text>
      </View>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: colors.background,
  },
  emptyContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    padding: 40,
  },
  emptyText: {
    fontSize: 20,
    fontWeight: '600',
    color: colors.text,
    marginTop: 16,
    marginBottom: 8,
  },
  emptySubtext: {
    fontSize: 14,
    color: colors.textSecondary,
    textAlign: 'center',
  },
});

export default MapScreen;
