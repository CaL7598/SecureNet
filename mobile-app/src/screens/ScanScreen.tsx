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
      {/* Header */}
      <View style={styles.header}>
        <View>
          <Text style={styles.title}>SecureNet</Text>
          <Text style={styles.subtitle}>Wi-Fi Security Auditor</Text>
        </View>
        <Icon name="shield-check" size={32} color={colors.primary} />
      </View>

      {/* Main Content */}
      <View style={styles.mainContent}>
        <Icon name="scan-helper" size={120} color={colors.primary} style={styles.icon} />
        
        <Text style={styles.scanTitle}>Scan Your Network</Text>
        <Text style={styles.description}>
          Discover devices on your Wi-Fi network and identify security vulnerabilities in seconds.
        </Text>

        {/* Features List */}
        <View style={styles.featuresList}>
          <View style={styles.featureItem}>
            <Icon name="check-circle" size={20} color={colors.success} />
            <Text style={styles.featureText}>Device Discovery</Text>
          </View>
          <View style={styles.featureItem}>
            <Icon name="check-circle" size={20} color={colors.success} />
            <Text style={styles.featureText}>Port Scanning</Text>
          </View>
          <View style={styles.featureItem}>
            <Icon name="check-circle" size={20} color={colors.success} />
            <Text style={styles.featureText}>Vulnerability Analysis</Text>
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
          <ActivityIndicator color={colors.text} />
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
    padding: 20,
  },
  header: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: 30,
    marginTop: 20,
  },
  title: {
    fontSize: 32,
    fontWeight: 'bold',
    color: colors.text,
  },
  subtitle: {
    fontSize: 16,
    color: colors.textSecondary,
    marginTop: 4,
  },
  mainContent: {
    flex: 1,
    alignItems: 'center',
    justifyContent: 'center',
    paddingVertical: 40,
  },
  icon: {
    marginBottom: 20,
  },
  scanTitle: {
    fontSize: 28,
    fontWeight: 'bold',
    color: colors.text,
    marginBottom: 16,
    textAlign: 'center',
  },
  description: {
    fontSize: 16,
    color: colors.textSecondary,
    textAlign: 'center',
    marginBottom: 30,
    paddingHorizontal: 20,
  },
  featuresList: {
    width: '100%',
    marginBottom: 30,
  },
  featureItem: {
    flexDirection: 'row',
    alignItems: 'center',
    marginBottom: 12,
    paddingLeft: 20,
  },
  featureText: {
    fontSize: 16,
    color: colors.text,
    marginLeft: 12,
  },
  scanModeContainer: {
    width: '100%',
    marginBottom: 30,
  },
  scanModeLabel: {
    fontSize: 16,
    color: colors.text,
    marginBottom: 12,
    paddingLeft: 20,
  },
  modeToggle: {
    flexDirection: 'row',
    backgroundColor: colors.surfaceVariant,
    borderRadius: 25,
    padding: 4,
  },
  modeButton: {
    flex: 1,
    paddingVertical: 12,
    paddingHorizontal: 20,
    borderRadius: 20,
    alignItems: 'center',
  },
  modeButtonActive: {
    backgroundColor: colors.primary,
  },
  modeButtonText: {
    fontSize: 14,
    color: colors.textSecondary,
    fontWeight: '500',
  },
  modeButtonTextActive: {
    color: colors.text,
    fontWeight: '600',
  },
  scanButton: {
    backgroundColor: colors.primary,
    paddingVertical: 18,
    borderRadius: 12,
    alignItems: 'center',
    marginTop: 'auto',
    marginBottom: 20,
  },
  scanButtonDisabled: {
    opacity: 0.6,
  },
  scanButtonText: {
    fontSize: 18,
    fontWeight: 'bold',
    color: colors.text,
  },
  progressContainer: {
    marginBottom: 20,
    paddingHorizontal: 20,
  },
  progressText: {
    fontSize: 14,
    color: colors.textSecondary,
    marginBottom: 8,
    textAlign: 'center',
  },
  progressBar: {
    height: 4,
    backgroundColor: colors.surfaceVariant,
    borderRadius: 2,
    overflow: 'hidden',
    marginBottom: 4,
  },
  progressFill: {
    height: '100%',
    backgroundColor: colors.primary,
    borderRadius: 2,
  },
  progressPercent: {
    fontSize: 12,
    color: colors.textSecondary,
    textAlign: 'center',
  },
});

export default ScanScreen;
