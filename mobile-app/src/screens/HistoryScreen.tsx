/**
 * Scan History Screen
 */
import React, { useEffect, useState } from 'react';
import {
  View,
  Text,
  StyleSheet,
  ScrollView,
  TouchableOpacity,
  RefreshControl,
} from 'react-native';
import { useNavigation } from '@react-navigation/native';
import Icon from '../utils/iconHelper';
import { colors } from '../theme/colors';
import { spacing, radii, textStyles } from '../theme/theme';
import { RiskLevel, ScanHistory } from '../types';
import { getScanHistory } from '../services/storage';

const HistoryScreen: React.FC = () => {
  const navigation = useNavigation();
  const [history, setHistory] = useState<ScanHistory[]>([]);
  const [refreshing, setRefreshing] = useState(false);

  const loadHistory = async () => {
    try {
      const data = await getScanHistory();
      setHistory(data);
    } catch (error) {
      console.error('Error loading history:', error);
    }
  };

  useEffect(() => {
    loadHistory();
  }, []);

  const onRefresh = async () => {
    setRefreshing(true);
    await loadHistory();
    setRefreshing(false);
  };

  const handleHistoryItemPress = (item: ScanHistory) => {
    // Navigate to results with historical data
    // This would require storing full analysis, for now just show a message
    navigation.navigate('Scan' as never);
  };

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

  if (history.length === 0) {
    return (
      <View style={styles.container}>
        <View style={styles.emptyContainer}>
          <Icon name="history" size={64} color={colors.textDisabled} />
          <Text style={styles.emptyText}>No Scan History</Text>
          <Text style={styles.emptySubtext}>
            Your previous scans will appear here
          </Text>
        </View>
      </View>
    );
  }

  return (
    <ScrollView
      style={styles.container}
      refreshControl={
        <RefreshControl refreshing={refreshing} onRefresh={onRefresh} />
      }
    >
      <View style={styles.header}>
        <Text style={styles.title}>Scan History</Text>
        {history.length > 0 && (
          <Text style={styles.subtitle}>{history.length} scans</Text>
        )}
      </View>

      {history.map((item) => (
        <TouchableOpacity
          key={item.id}
          style={styles.historyCard}
          onPress={() => handleHistoryItemPress(item)}
        >
          <View style={styles.historyHeader}>
            <View style={styles.scoreCircle}>
              <Text style={styles.scoreText}>{item.network_score}</Text>
            </View>
            <View style={styles.historyInfo}>
              <Text style={styles.historyDate}>
                {new Date(item.timestamp).toLocaleDateString()}
              </Text>
              <Text style={styles.historyTime}>
                {new Date(item.timestamp).toLocaleTimeString()}
              </Text>
            </View>
          </View>
          <View style={styles.historyStats}>
            <View style={styles.stat}>
              <Text style={styles.statLabel}>Devices</Text>
              <Text style={styles.statValue}>{item.total_devices}</Text>
            </View>
            <View style={styles.stat}>
              <Text style={styles.statLabel}>Critical</Text>
              <Text style={[styles.statValue, { color: colors.critical }]}>
                {item.critical_issues}
              </Text>
            </View>
            <View
              style={[
                styles.riskBadge,
                { backgroundColor: getRiskColor(item.overall_risk) + '20' },
              ]}
            >
              <Text
                style={[styles.riskBadgeText, { color: getRiskColor(item.overall_risk) }]}
              >
                {item.overall_risk}
              </Text>
            </View>
          </View>
        </TouchableOpacity>
      ))}
    </ScrollView>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: colors.background,
  },
  header: {
    padding: spacing.md,
    paddingTop: spacing.xxl,
  },
  title: {
    ...textStyles.headlineLarge,
    fontWeight: '700',
    color: colors.text,
  },
  subtitle: {
    ...textStyles.bodyMedium,
    color: colors.textSecondary,
    marginTop: spacing.xs,
  },
  emptyContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    padding: spacing.xxl,
  },
  emptyText: {
    ...textStyles.titleLarge,
    fontWeight: '600',
    color: colors.text,
    marginTop: spacing.md,
    marginBottom: spacing.sm,
  },
  emptySubtext: {
    ...textStyles.bodyMedium,
    color: colors.textSecondary,
    textAlign: 'center',
  },
  historyCard: {
    backgroundColor: colors.card,
    marginHorizontal: spacing.md,
    marginBottom: spacing.sm,
    padding: spacing.md,
    borderRadius: radii.md,
  },
  historyHeader: {
    flexDirection: 'row',
    alignItems: 'center',
    marginBottom: spacing.sm,
  },
  scoreCircle: {
    width: 60,
    height: 60,
    borderRadius: radii.full,
    backgroundColor: colors.primary + '20',
    justifyContent: 'center',
    alignItems: 'center',
    marginRight: spacing.md,
  },
  scoreText: {
    ...textStyles.titleLarge,
    fontWeight: '700',
    color: colors.primary,
  },
  historyInfo: {
    flex: 1,
  },
  historyDate: {
    ...textStyles.titleMedium,
    color: colors.text,
    marginBottom: spacing.xs,
  },
  historyTime: {
    ...textStyles.bodyMedium,
    color: colors.textSecondary,
  },
  historyStats: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
  },
  stat: {
    alignItems: 'center',
  },
  statLabel: {
    ...textStyles.labelMedium,
    color: colors.textSecondary,
    marginBottom: spacing.xs,
  },
  statValue: {
    ...textStyles.headlineSmall,
    fontWeight: '700',
    color: colors.text,
  },
  riskBadge: {
    paddingHorizontal: spacing.sm,
    paddingVertical: spacing.xs + 2,
    borderRadius: radii.sm,
  },
  riskBadgeText: {
    ...textStyles.labelMedium,
    fontWeight: '600',
    textTransform: 'uppercase',
  },
});

export default HistoryScreen;
