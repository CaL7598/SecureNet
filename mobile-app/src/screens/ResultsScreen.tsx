/**
 * Scan Results Screen
 */
import React from 'react';
import {
  View,
  Text,
  StyleSheet,
  ScrollView,
  TouchableOpacity,
} from 'react-native';
import { useNavigation, useRoute } from '@react-navigation/native';
import Icon from '../utils/iconHelper';
import { colors } from '../theme/colors';
import { spacing, radii, textStyles } from '../theme/theme';
import { NetworkAnalysis, RiskLevel, DeviceAnalysis } from '../types';
import DeviceCard from '../components/DeviceCard';
import SecurityScore from '../components/SecurityScore';

const ResultsScreen: React.FC = () => {
  const navigation = useNavigation();
  const route = useRoute();
  const routeParams = route.params as { analysis?: NetworkAnalysis } | undefined;
  const analysis = routeParams?.analysis;

  // Fallback if analysis is missing
  if (!analysis) {
    return (
      <View style={styles.container}>
        <View style={styles.errorContainer}>
          <Text style={styles.errorText}>No scan results available</Text>
          <TouchableOpacity
            style={styles.scanAgainButton}
            onPress={() => navigation.goBack()}
          >
            <Text style={styles.scanAgainButtonText}>Go Back</Text>
          </TouchableOpacity>
        </View>
      </View>
    );
  }

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

  const handleDevicePress = (device: DeviceAnalysis) => {
    navigation.navigate('DeviceDetail' as never, { device } as never);
  };

  return (
    <ScrollView style={styles.container}>
      {/* Status Card */}
      <View style={styles.statusCard}>
        <SecurityScore score={analysis.network_score} />
        
        <View style={styles.metricsContainer}>
          <View style={styles.metric}>
            <Text style={styles.metricLabel}>Total Devices</Text>
            <Text style={styles.metricValue}>{analysis.total_devices}</Text>
          </View>
          <View style={styles.metric}>
            <Text style={styles.metricLabel}>Critical Issues</Text>
            <Text style={[styles.metricValue, { color: colors.critical }]}>
              {analysis.critical_issues}
            </Text>
          </View>
          <View style={styles.metric}>
            <Text style={styles.metricLabel}>High Risk Devices</Text>
            <Text style={[styles.metricValue, { color: colors.highRisk }]}>
              {analysis.high_risk_devices}
            </Text>
          </View>
        </View>
      </View>

      {/* Devices Section */}
      <View style={styles.devicesSection}>
        <View style={styles.sectionHeader}>
          <Icon name="laptop" size={20} color={colors.primary} />
          <Text style={styles.sectionTitle}>
            All Devices ({analysis.total_devices})
          </Text>
        </View>

        {analysis.devices.map((device, index) => (
          <DeviceCard
            key={index}
            device={device}
            onPress={() => handleDevicePress(device)}
          />
        ))}
      </View>

      {/* Scan Again Button */}
      <TouchableOpacity
        style={styles.scanAgainButton}
        onPress={() => navigation.goBack()}
      >
        <Text style={styles.scanAgainButtonText}>Scan Again</Text>
      </TouchableOpacity>
    </ScrollView>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: colors.background,
  },
  errorContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    padding: spacing.md,
  },
  errorText: {
    ...textStyles.titleMedium,
    color: colors.text,
    marginBottom: spacing.md,
    textAlign: 'center',
  },
  statusCard: {
    backgroundColor: colors.card,
    margin: spacing.md,
    padding: spacing.lg,
    borderRadius: radii.lg,
    alignItems: 'center',
  },
  metricsContainer: {
    flexDirection: 'row',
    justifyContent: 'space-around',
    width: '100%',
    marginTop: spacing.lg,
  },
  metric: {
    alignItems: 'center',
  },
  metricLabel: {
    ...textStyles.bodyMedium,
    color: colors.textSecondary,
    marginBottom: spacing.sm,
  },
  metricValue: {
    ...textStyles.headlineSmall,
    fontWeight: '700',
    color: colors.text,
  },
  devicesSection: {
    paddingHorizontal: spacing.md,
  },
  sectionHeader: {
    flexDirection: 'row',
    alignItems: 'center',
    marginBottom: spacing.md,
  },
  sectionTitle: {
    ...textStyles.titleMedium,
    color: colors.text,
    marginLeft: spacing.sm,
  },
  scanAgainButton: {
    backgroundColor: colors.primary,
    margin: spacing.md,
    paddingVertical: spacing.md,
    borderRadius: radii.md,
    alignItems: 'center',
    minHeight: 48,
  },
  scanAgainButtonText: {
    ...textStyles.titleMedium,
    color: colors.onPrimary,
  },
});

export default ResultsScreen;
