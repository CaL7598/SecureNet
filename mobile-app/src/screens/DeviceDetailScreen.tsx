/**
 * Device Detail Screen
 */
import React from 'react';
import {
  View,
  Text,
  StyleSheet,
  ScrollView,
} from 'react-native';
import { useRoute } from '@react-navigation/native';
import Icon from '../utils/iconHelper';
import { colors } from '../theme/colors';
import { DeviceAnalysis, RiskLevel, Severity } from '../types';

const DeviceDetailScreen: React.FC = () => {
  const route = useRoute();
  const { device } = route.params as { device: DeviceAnalysis };

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

  const getSeverityColor = (severity: Severity): string => {
    switch (severity) {
      case Severity.CRITICAL:
        return colors.critical;
      case Severity.HIGH:
        return colors.highRisk;
      case Severity.MEDIUM:
        return colors.mediumRisk;
      case Severity.LOW:
        return colors.lowRisk;
      default:
        return colors.textSecondary;
    }
  };

  return (
    <ScrollView style={styles.container}>
      {/* Device Info Card */}
      <View style={styles.card}>
        <View style={styles.deviceHeader}>
          <Icon name="devices" size={48} color={colors.primary} />
          <View style={styles.deviceInfo}>
            <Text style={styles.deviceName}>
              {device.device_name || 'Unknown Device'}
            </Text>
            <Text style={styles.deviceIp}>{device.ip_address}</Text>
            <Text style={styles.deviceMac}>{device.mac_address}</Text>
          </View>
        </View>

        <View style={styles.scoreContainer}>
          <Text style={styles.scoreLabel}>Security Score</Text>
          <Text style={[styles.scoreValue, { color: getRiskColor(device.risk_level) }]}>
            {device.security_score}/100
          </Text>
          <View
            style={[
              styles.riskBadge,
              { backgroundColor: getRiskColor(device.risk_level) + '20' },
            ]}
          >
            <Text
              style={[styles.riskBadgeText, { color: getRiskColor(device.risk_level) }]}
            >
              {device.risk_level}
            </Text>
          </View>
        </View>
      </View>

      {/* Issues Card */}
      {device.issues.length > 0 ? (
        <View style={styles.card}>
          <Text style={styles.sectionTitle}>Security Issues ({device.issues.length})</Text>
          {device.issues.map((issue, index) => (
            <View key={index} style={styles.issueItem}>
              <View style={styles.issueHeader}>
                <View
                  style={[
                    styles.severityBadge,
                    { backgroundColor: getSeverityColor(issue.severity) + '20' },
                  ]}
                >
                  <Text
                    style={[
                      styles.severityBadgeText,
                      { color: getSeverityColor(issue.severity) },
                    ]}
                  >
                    {issue.severity}
                  </Text>
                </View>
                {issue.port && (
                  <Text style={styles.portText}>Port {issue.port}</Text>
                )}
              </View>
              <Text style={styles.issueType}>{issue.type.replace('_', ' ')}</Text>
              <Text style={styles.issueDescription}>{issue.description}</Text>
              <View style={styles.recommendationBox}>
                <Icon name="lightbulb-on" size={16} color={colors.primary} />
                <Text style={styles.recommendationText}>{issue.recommendation}</Text>
              </View>
            </View>
          ))}
        </View>
      ) : (
        <View style={styles.card}>
          <View style={styles.noIssuesContainer}>
            <Icon name="shield-check" size={64} color={colors.secure} />
            <Text style={styles.noIssuesText}>No Security Issues Found</Text>
            <Text style={styles.noIssuesSubtext}>
              This device appears to be secure
            </Text>
          </View>
        </View>
      )}
    </ScrollView>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: colors.background,
  },
  card: {
    backgroundColor: colors.card,
    margin: 20,
    padding: 20,
    borderRadius: 16,
  },
  deviceHeader: {
    flexDirection: 'row',
    alignItems: 'center',
    marginBottom: 20,
  },
  deviceInfo: {
    marginLeft: 16,
    flex: 1,
  },
  deviceName: {
    fontSize: 20,
    fontWeight: 'bold',
    color: colors.text,
    marginBottom: 4,
  },
  deviceIp: {
    fontSize: 14,
    color: colors.textSecondary,
    marginBottom: 2,
  },
  deviceMac: {
    fontSize: 12,
    color: colors.textDisabled,
  },
  scoreContainer: {
    alignItems: 'center',
    paddingTop: 20,
    borderTopWidth: 1,
    borderTopColor: colors.border,
  },
  scoreLabel: {
    fontSize: 14,
    color: colors.textSecondary,
    marginBottom: 8,
  },
  scoreValue: {
    fontSize: 36,
    fontWeight: 'bold',
    marginBottom: 12,
  },
  riskBadge: {
    paddingHorizontal: 16,
    paddingVertical: 6,
    borderRadius: 12,
  },
  riskBadgeText: {
    fontSize: 12,
    fontWeight: '600',
    textTransform: 'uppercase',
  },
  sectionTitle: {
    fontSize: 18,
    fontWeight: '600',
    color: colors.text,
    marginBottom: 16,
  },
  issueItem: {
    marginBottom: 20,
    paddingBottom: 20,
    borderBottomWidth: 1,
    borderBottomColor: colors.border,
  },
  issueHeader: {
    flexDirection: 'row',
    alignItems: 'center',
    marginBottom: 8,
  },
  severityBadge: {
    paddingHorizontal: 12,
    paddingVertical: 4,
    borderRadius: 8,
    marginRight: 8,
  },
  severityBadgeText: {
    fontSize: 10,
    fontWeight: '600',
    textTransform: 'uppercase',
  },
  portText: {
    fontSize: 12,
    color: colors.textSecondary,
  },
  issueType: {
    fontSize: 14,
    fontWeight: '600',
    color: colors.text,
    marginBottom: 8,
    textTransform: 'capitalize',
  },
  issueDescription: {
    fontSize: 14,
    color: colors.textSecondary,
    marginBottom: 12,
    lineHeight: 20,
  },
  recommendationBox: {
    flexDirection: 'row',
    backgroundColor: colors.surfaceVariant,
    padding: 12,
    borderRadius: 8,
    alignItems: 'flex-start',
  },
  recommendationText: {
    fontSize: 13,
    color: colors.text,
    marginLeft: 8,
    flex: 1,
    lineHeight: 18,
  },
  noIssuesContainer: {
    alignItems: 'center',
    paddingVertical: 40,
  },
  noIssuesText: {
    fontSize: 18,
    fontWeight: '600',
    color: colors.text,
    marginTop: 16,
    marginBottom: 8,
  },
  noIssuesSubtext: {
    fontSize: 14,
    color: colors.textSecondary,
  },
});

export default DeviceDetailScreen;
