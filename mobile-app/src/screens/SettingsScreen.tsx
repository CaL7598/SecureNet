/**
 * Settings Screen
 */
import React, { useState, useEffect } from 'react';
import {
  View,
  Text,
  StyleSheet,
  ScrollView,
  TouchableOpacity,
  Switch,
} from 'react-native';
import Icon from '../utils/iconHelper';
import { colors } from '../theme/colors';
import AsyncStorage from '@react-native-async-storage/async-storage';
import { ScanSettings } from '../types';

const SETTINGS_KEY = '@SecureNet:settings';

const SettingsScreen: React.FC = () => {
  const [settings, setSettings] = useState<ScanSettings>({
    scanInterval: 'manual',
    defaultScanMode: 'real',
    enableNotifications: true,
    criticalAlerts: true,
    highRiskAlerts: true,
  });

  useEffect(() => {
    loadSettings();
  }, []);

  const loadSettings = async () => {
    try {
      const stored = await AsyncStorage.getItem(SETTINGS_KEY);
      if (stored) {
        setSettings(JSON.parse(stored));
      }
    } catch (error) {
      console.error('Error loading settings:', error);
    }
  };

  const saveSettings = async (newSettings: ScanSettings) => {
    try {
      await AsyncStorage.setItem(SETTINGS_KEY, JSON.stringify(newSettings));
      setSettings(newSettings);
    } catch (error) {
      console.error('Error saving settings:', error);
    }
  };

  const updateSetting = <K extends keyof ScanSettings>(
    key: K,
    value: ScanSettings[K]
  ) => {
    const newSettings = { ...settings, [key]: value };
    saveSettings(newSettings);
  };

  return (
    <ScrollView style={styles.container}>
      {/* Header */}
      <View style={styles.header}>
        <View>
          <Text style={styles.title}>Settings</Text>
          <Text style={styles.subtitle}>Configure app preferences</Text>
        </View>
        <Icon name="cog" size={32} color={colors.primary} />
      </View>

      {/* Scan Configuration */}
      <View style={styles.section}>
        <Text style={styles.sectionTitle}>Scan Configuration</Text>

        <TouchableOpacity style={styles.settingCard}>
          <Icon name="clock-outline" size={24} color={colors.primary} />
          <View style={styles.settingContent}>
            <Text style={styles.settingTitle}>Scan Interval</Text>
            <Text style={styles.settingDescription}>
              How often to automatically scan your network
            </Text>
          </View>
          <View style={styles.settingValue}>
            <Text style={styles.settingValueText}>
              {settings.scanInterval === 'manual'
                ? 'Manual Only'
                : settings.scanInterval === '1hour'
                ? 'Every Hour'
                : settings.scanInterval === '6hours'
                ? 'Every 6 Hours'
                : 'Daily'}
            </Text>
            <Icon name="chevron-right" size={24} color={colors.textSecondary} />
          </View>
        </TouchableOpacity>

        <TouchableOpacity style={styles.settingCard}>
          <Icon name="scan-helper" size={24} color={colors.primary} />
          <View style={styles.settingContent}>
            <Text style={styles.settingTitle}>Default Scan Mode</Text>
            <Text style={styles.settingDescription}>
              Choose between real scanning or demo mode
            </Text>
          </View>
          <View style={styles.settingValue}>
            <Text style={styles.settingValueText}>
              {settings.defaultScanMode === 'real'
                ? 'Real Network Scan'
                : 'Demo Mode'}
            </Text>
            <Icon name="chevron-right" size={24} color={colors.textSecondary} />
          </View>
        </TouchableOpacity>
      </View>

      {/* Notifications */}
      <View style={styles.section}>
        <View style={styles.sectionHeader}>
          <Icon name="wrench" size={20} color={colors.purple} />
          <Text style={styles.sectionTitle}>Notifications</Text>
        </View>

        <View style={styles.settingCard}>
          <Icon name="bell" size={24} color={colors.primary} />
          <View style={styles.settingContent}>
            <Text style={styles.settingTitle}>Enable Notifications</Text>
            <Text style={styles.settingDescription}>
              Receive alerts about security issues
            </Text>
          </View>
          <Switch
            value={settings.enableNotifications}
            onValueChange={(value) => updateSetting('enableNotifications', value)}
            trackColor={{ false: colors.disabled, true: colors.primary + '80' }}
            thumbColor={settings.enableNotifications ? colors.primary : colors.textDisabled}
          />
        </View>

        <View style={styles.settingCard}>
          <Icon name="alert-circle" size={24} color={colors.primary} />
          <View style={styles.settingContent}>
            <Text style={styles.settingTitle}>Critical Vulnerability Alerts</Text>
            <Text style={styles.settingDescription}>
              Get notified immediately for critical issues
            </Text>
          </View>
          <Switch
            value={settings.criticalAlerts}
            onValueChange={(value) => updateSetting('criticalAlerts', value)}
            disabled={!settings.enableNotifications}
            trackColor={{ false: colors.disabled, true: colors.primary + '80' }}
            thumbColor={settings.criticalAlerts ? colors.primary : colors.textDisabled}
          />
        </View>

        <View style={styles.settingCard}>
          <Icon name="alert" size={24} color={colors.primary} />
          <View style={styles.settingContent}>
            <Text style={styles.settingTitle}>High Risk Device Alerts</Text>
            <Text style={styles.settingDescription}>
              Alert when high-risk devices are found
            </Text>
          </View>
          <Switch
            value={settings.highRiskAlerts}
            onValueChange={(value) => updateSetting('highRiskAlerts', value)}
            disabled={!settings.enableNotifications}
            trackColor={{ false: colors.disabled, true: colors.primary + '80' }}
            thumbColor={settings.highRiskAlerts ? colors.primary : colors.textDisabled}
          />
        </View>
      </View>
    </ScrollView>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: colors.background,
  },
  header: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    padding: 20,
    paddingTop: 40,
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
  section: {
    paddingHorizontal: 20,
    marginBottom: 32,
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
  settingCard: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: colors.card,
    padding: 16,
    borderRadius: 12,
    marginBottom: 12,
  },
  settingContent: {
    flex: 1,
    marginLeft: 16,
  },
  settingTitle: {
    fontSize: 16,
    fontWeight: '600',
    color: colors.text,
    marginBottom: 4,
  },
  settingDescription: {
    fontSize: 13,
    color: colors.textSecondary,
  },
  settingValue: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  settingValueText: {
    fontSize: 14,
    color: colors.textSecondary,
    marginRight: 8,
  },
});

export default SettingsScreen;
