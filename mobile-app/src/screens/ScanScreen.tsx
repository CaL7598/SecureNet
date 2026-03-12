/**
 * Main Scan Screen
 */
import React, { useState } from 'react';
import {
  View,
  Text,
  StyleSheet,
  TouchableOpacity,
  ScrollView,
  ActivityIndicator,
  Alert,
} from 'react-native';
import { useNavigation } from '@react-navigation/native';
import Icon from '../utils/iconHelper';
import { colors } from '../theme/colors';
import { spacing, radii, textStyles } from '../theme/theme';
import { DeviceScan } from '../types';
import { analyzeNetwork } from '../services/api';
import { scanNetwork } from '../services/networkScanner';
import { useAppDispatch, useAppSelector } from '../store/hooks';
import { startScan, updateProgress, setAnalysis, setError, resetScan } from '../store/slices/scanSlice';
import { saveScanHistory } from '../services/storage';

const ScanScreen: React.FC = () => {
  const navigation = useNavigation();
  const dispatch = useAppDispatch();
  const { isScanning, scanProgress, scanMessage } = useAppSelector((state) => state.scan);
  const { settings } = useAppSelector((state) => state.settings);
  const [scanMode, setScanMode] = useState<'real' | 'demo'>(settings.defaultScanMode);

  const handleStartScan = async () => {
    dispatch(startScan());
    
    try {
      // Check if backend is accessible (only in demo mode for now)
      if (scanMode === 'demo') {
        console.log('Demo mode - skipping backend check');
      }
      
      let devices: DeviceScan[] = [];

      if (scanMode === 'demo') {
        // Demo mode - use mock data
        dispatch(updateProgress({ progress: 20, message: 'Loading demo data...' }));
        
        await new Promise((resolve) => setTimeout(resolve, 500));
        
        devices = [
          {
            ip_address: '192.168.1.1',
            mac_address: '00:11:22:33:44:55',
            device_name: 'Netgear-Router',
            open_ports: [23, 80, 443],
            vendor: 'Netgear',
          },
          {
            ip_address: '192.168.1.100',
            mac_address: 'AA:BB:CC:DD:EE:FF',
            device_name: 'Unknown Device',
            open_ports: [80],
            vendor: 'Unknown',
          },
        ];
        
        dispatch(updateProgress({ progress: 60, message: 'Analyzing vulnerabilities...' }));
      } else {
        // Real network scan
        devices = await scanNetwork((progress, message) => {
          dispatch(updateProgress({ progress, message }));
        });
      }

      dispatch(updateProgress({ progress: 80, message: 'Analyzing network security...' }));

      // Analyze network
      console.log('Sending devices to API:', devices);
      const analysis = await analyzeNetwork(devices);
      console.log('Received analysis:', analysis);
      
      if (!analysis) {
        throw new Error('No analysis data received from server');
      }
      
      // Save to history
      try {
        await saveScanHistory({
          network_score: analysis.network_score,
          overall_risk: analysis.overall_risk,
          total_devices: analysis.total_devices,
          critical_issues: analysis.critical_issues,
        });
      } catch (historyError) {
        console.warn('Failed to save history:', historyError);
        // Continue even if history save fails
      }

      dispatch(setAnalysis(analysis));

      // Navigate to results
      console.log('Navigating to Results screen...');
      try {
        (navigation as any).navigate('Results', { analysis });
      } catch (navError) {
        console.error('Navigation error:', navError);
        // Try alternative navigation method
        (navigation as any).push('Results', { analysis });
      }
    } catch (error) {
      console.error('Scan error:', error);
      const errorMessage = error instanceof Error ? error.message : 'Failed to scan network';
      dispatch(setError(errorMessage));
      
      Alert.alert(
        'Scan Failed',
        errorMessage,
        [{ text: 'OK', onPress: () => dispatch(resetScan()) }]
      );
    }
  };

  return (
    <ScrollView style={styles.container} contentContainerStyle={styles.content}>
      {/* Header - design: SECURENET + tagline */}
      <View style={styles.header}>
        <View style={styles.headerLeft}>
          <View style={styles.logoIcon}>
            <Icon name="shield-check" size={20} color={colors.onPrimary} />
          </View>
          <Text style={styles.title}>SECURENET</Text>
        </View>
        <Text style={styles.version}>v1.0</Text>
      </View>
      <Text style={styles.tagline}>NETWORK AUDITING FOR EVERYONE</Text>

      {/* Main Content */}
      <View style={styles.mainContent}>
        <Icon name="scan-helper" size={100} color={colors.primary} style={styles.icon} />
        <Text style={styles.scanTitle}>Scan Your Network</Text>
        <Text style={styles.description}>
          Discover devices on your Wi‑Fi and identify security vulnerabilities in seconds.
        </Text>

        {/* Features List - design: core capabilities */}
        <Text style={styles.featuresLabel}>CORE CAPABILITIES</Text>
        <View style={styles.featuresList}>
          <View style={styles.featureItem}>
            <Icon name="check-circle" size={20} color={colors.primary} />
            <View>
              <Text style={styles.featureText}>Device Discovery</Text>
              <Text style={styles.featureSub}>Maps every IP and MAC on your Wi‑Fi.</Text>
            </View>
          </View>
          <View style={styles.featureItem}>
            <Icon name="check-circle" size={20} color={colors.secondary} />
            <View>
              <Text style={styles.featureText}>Vulnerability Scan</Text>
              <Text style={styles.featureSub}>Checks open ports and unpatched firmware.</Text>
            </View>
          </View>
          <View style={styles.featureItem}>
            <Icon name="check-circle" size={20} color={colors.tertiary} />
            <View>
              <Text style={styles.featureText}>Credential Audit</Text>
              <Text style={styles.featureSub}>Detects dangerous default passwords.</Text>
            </View>
          </View>
        </View>

        {/* Scan Mode Toggle */}
        <View style={styles.scanModeContainer}>
          <Text style={styles.scanModeLabel}>Scan Mode</Text>
          <View style={styles.modeToggle}>
            <TouchableOpacity
              style={[
                styles.modeButton,
                scanMode === 'real' && styles.modeButtonActive,
              ]}
              onPress={() => setScanMode('real')}
            >
              <Text
                style={[
                  styles.modeButtonText,
                  scanMode === 'real' && styles.modeButtonTextActive,
                ]}
              >
                Real Network Scan
              </Text>
            </TouchableOpacity>
            <TouchableOpacity
              style={[
                styles.modeButton,
                scanMode === 'demo' && styles.modeButtonActive,
              ]}
              onPress={() => setScanMode('demo')}
            >
              <Text
                style={[
                  styles.modeButtonText,
                  scanMode === 'demo' && styles.modeButtonTextActive,
                ]}
              >
                Demo Mode
              </Text>
            </TouchableOpacity>
          </View>
        </View>
      </View>

      {/* Progress Indicator */}
      {isScanning && (
        <View style={styles.progressContainer}>
          <Text style={styles.progressText}>{scanMessage}</Text>
          <View style={styles.progressBar}>
            <View
              style={[
                styles.progressFill,
                { width: `${scanProgress}%` },
              ]}
            />
          </View>
          <Text style={styles.progressPercent}>{scanProgress}%</Text>
        </View>
      )}

      {/* Start Scan Button */}
      <TouchableOpacity
        style={[styles.scanButton, isScanning && styles.scanButtonDisabled]}
        onPress={handleStartScan}
        disabled={isScanning}
      >
        {isScanning ? (
          <ActivityIndicator color={colors.onPrimary} />
        ) : (
          <Text style={styles.scanButtonText}>Start Scan</Text>
        )}
      </TouchableOpacity>
    </ScrollView>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: colors.background,
  },
  content: {
    flexGrow: 1,
    padding: spacing.md,
    paddingTop: spacing.lg,
  },
  header: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: spacing.sm,
  },
  headerLeft: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: spacing.sm,
  },
  logoIcon: {
    width: 32,
    height: 32,
    borderRadius: radii.sm,
    backgroundColor: colors.primary,
    alignItems: 'center',
    justifyContent: 'center',
  },
  title: {
    ...textStyles.titleLarge,
    fontWeight: '900',
    color: colors.text,
  },
  version: {
    ...textStyles.labelSmall,
    color: colors.success,
  },
  tagline: {
    ...textStyles.labelSmall,
    color: colors.textSecondary,
    fontWeight: '700',
    marginBottom: spacing.xl,
  },
  mainContent: {
    flex: 1,
    alignItems: 'center',
    paddingVertical: spacing.xxl,
  },
  icon: {
    marginBottom: spacing.md,
  },
  scanTitle: {
    ...textStyles.headlineSmall,
    fontWeight: '700',
    color: colors.text,
    marginBottom: spacing.md,
    textAlign: 'center',
  },
  description: {
    ...textStyles.bodyLarge,
    color: colors.textSecondary,
    textAlign: 'center',
    marginBottom: spacing.xl,
    paddingHorizontal: spacing.md,
  },
  featuresLabel: {
    ...textStyles.labelSmall,
    color: colors.textSecondary,
    fontWeight: '700',
    alignSelf: 'flex-start',
    marginBottom: spacing.sm,
  },
  featuresList: {
    width: '100%',
    marginBottom: spacing.xl,
  },
  featureItem: {
    flexDirection: 'row',
    alignItems: 'flex-start',
    marginBottom: spacing.md,
    gap: spacing.sm,
  },
  featureText: {
    ...textStyles.titleMedium,
    color: colors.text,
  },
  featureSub: {
    ...textStyles.bodySmall,
    color: colors.textSecondary,
    marginTop: 2,
  },
  scanModeContainer: {
    width: '100%',
    marginBottom: spacing.xl,
  },
  scanModeLabel: {
    ...textStyles.titleSmall,
    color: colors.text,
    marginBottom: spacing.sm,
  },
  modeToggle: {
    flexDirection: 'row',
    backgroundColor: colors.surfaceVariant,
    borderRadius: radii.xl,
    padding: spacing.xs,
  },
  modeButton: {
    flex: 1,
    paddingVertical: spacing.sm,
    paddingHorizontal: spacing.md,
    borderRadius: radii.lg,
    alignItems: 'center',
  },
  modeButtonActive: {
    backgroundColor: colors.primary,
  },
  modeButtonText: {
    ...textStyles.labelLarge,
    color: colors.textSecondary,
  },
  modeButtonTextActive: {
    color: colors.onPrimary,
    fontWeight: '600',
  },
  scanButton: {
    backgroundColor: colors.primary,
    paddingVertical: spacing.md,
    borderRadius: radii.md,
    alignItems: 'center',
    marginTop: 'auto',
    marginBottom: spacing.md,
    minHeight: 48,
  },
  scanButtonDisabled: {
    opacity: 0.6,
  },
  scanButtonText: {
    ...textStyles.titleMedium,
    color: colors.onPrimary,
  },
  progressContainer: {
    marginBottom: spacing.md,
    paddingHorizontal: spacing.md,
  },
  progressText: {
    ...textStyles.bodyMedium,
    color: colors.textSecondary,
    marginBottom: spacing.sm,
    textAlign: 'center',
  },
  progressBar: {
    height: 4,
    backgroundColor: colors.surfaceVariant,
    borderRadius: radii.xs,
    overflow: 'hidden',
    marginBottom: spacing.xs,
  },
  progressFill: {
    height: '100%',
    backgroundColor: colors.primary,
    borderRadius: radii.xs,
  },
  progressPercent: {
    ...textStyles.labelSmall,
    color: colors.textSecondary,
    textAlign: 'center',
  },
});

export default ScanScreen;
