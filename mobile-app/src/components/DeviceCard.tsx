/**
 * Device Card Component
 */
import React from 'react';
import { View, Text, StyleSheet, TouchableOpacity } from 'react-native';
import Icon from '../utils/iconHelper';
import { colors } from '../theme/colors';
import { DeviceAnalysis, RiskLevel } from '../types';

interface DeviceCardProps {
  device: DeviceAnalysis;
  onPress: () => void;
}

const DeviceCard: React.FC<DeviceCardProps> = ({ device, onPress }) => {
  const getRiskColor = (risk: RiskLevel): string => {
    switch (risk) {
      case RiskLevel.SECURE:
        return colors.secure;
      case RiskLevel.LOW:
        return colors.lowRisk;
      case RiskLevel.MEDIUM:
        return colors.mediumRisk;
      case RiskLevel.HIGH:
        return colors.highRisk;
      case RiskLevel.CRITICAL:
        return colors.critical;
      default:
        return colors.textSecondary;
    }
  };

  return (
    <TouchableOpacity style={styles.card} onPress={onPress}>
      <View style={styles.cardContent}>
        <Icon name="devices" size={32} color={colors.primary} />
        <View style={styles.deviceInfo}>
          <Text style={styles.deviceName} numberOfLines={1}>
            {device.device_name || 'Unknown Device'}
          </Text>
          <Text style={styles.deviceIp}>{device.ip_address}</Text>
        </View>
        <View style={styles.deviceStatus}>
          <View
            style={[
              styles.statusBadge,
              { backgroundColor: getRiskColor(device.risk_level) + '20' },
            ]}
          >
            <View
              style={[
                styles.statusDot,
                { backgroundColor: getRiskColor(device.risk_level) },
              ]}
            />
            <Text
              style={[styles.statusText, { color: getRiskColor(device.risk_level) }]}
            >
              {device.risk_level === RiskLevel.SECURE ? 'Secure' : device.risk_level}
            </Text>
          </View>
          <Text style={styles.issuesText}>
            {device.issues.length} {device.issues.length === 1 ? 'issue' : 'issues'}
          </Text>
        </View>
      </View>
      {device.device_name?.toLowerCase().includes('unknown') && (
        <View style={styles.unknownBadge}>
          <Icon name="help-circle" size={16} color={colors.warning} />
          <Text style={styles.unknownText}>Unknown</Text>
        </View>
      )}
      <Icon name="chevron-right" size={24} color={colors.textSecondary} />
    </TouchableOpacity>
  );
};

const styles = StyleSheet.create({
  card: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: colors.card,
    padding: 16,
    borderRadius: 12,
    marginBottom: 12,
  },
  cardContent: {
    flex: 1,
    flexDirection: 'row',
    alignItems: 'center',
  },
  deviceInfo: {
    flex: 1,
    marginLeft: 12,
  },
  deviceName: {
    fontSize: 16,
    fontWeight: '600',
    color: colors.text,
    marginBottom: 4,
  },
  deviceIp: {
    fontSize: 12,
    color: colors.textSecondary,
  },
  deviceStatus: {
    alignItems: 'flex-end',
    marginLeft: 12,
  },
  statusBadge: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingHorizontal: 8,
    paddingVertical: 4,
    borderRadius: 12,
    marginBottom: 4,
  },
  statusDot: {
    width: 8,
    height: 8,
    borderRadius: 4,
    marginRight: 6,
  },
  statusText: {
    fontSize: 11,
    fontWeight: '600',
    textTransform: 'uppercase',
  },
  issuesText: {
    fontSize: 12,
    color: colors.textSecondary,
  },
  unknownBadge: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: colors.warning + '20',
    paddingHorizontal: 8,
    paddingVertical: 4,
    borderRadius: 8,
    marginRight: 8,
  },
  unknownText: {
    fontSize: 11,
    color: colors.warning,
    marginLeft: 4,
    fontWeight: '600',
  },
});

export default DeviceCard;
