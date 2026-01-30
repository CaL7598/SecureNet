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
    padding: 20,
  },
  errorText: {
    fontSize: 18,
    color: colors.text,
    marginBottom: 20,
    textAlign: 'center',
  },
  statusCard: {
    backgroundColor: colors.card,
    margin: 20,
    padding: 24,
    borderRadius: 16,
    alignItems: 'center',
  },
  metricsContainer: {
    flexDirection: 'row',
    justifyContent: 'space-around',
    width: '100%',
    marginTop: 24,
  },
  metric: {
    alignItems: 'center',
  },
  metricLabel: {
    fontSize: 14,
    color: colors.textSecondary,
    marginBottom: 8,
  },
  metricValue: {
    fontSize: 24,
    fontWeight: 'bold',
    color: colors.text,
  },
  devicesSection: {
    paddingHorizontal: 20,
  },
  sectionHeader: {
    flexDirection: 'row',
    alignItems: 'center',
    marginBottom: 16,
  },
  sectionTitle: {
    fontSize: 18,
    fontWeight: '600',
    color: colors.text,
    marginLeft: 8,
  },
  scanAgainButton: {
    backgroundColor: colors.primary,
    margin: 20,
    paddingVertical: 18,
    borderRadius: 12,
    alignItems: 'center',
  },
  scanAgainButtonText: {
    fontSize: 18,
    fontWeight: 'bold',
    color: colors.text,
  },
});

export default ResultsScreen;
