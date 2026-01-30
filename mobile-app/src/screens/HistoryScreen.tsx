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
    padding: 20,
    paddingTop: 40,
  },
  title: {
    fontSize: 32,
    fontWeight: 'bold',
    color: colors.text,
  },
  subtitle: {
    fontSize: 14,
    color: colors.textSecondary,
    marginTop: 4,
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
  historyCard: {
    backgroundColor: colors.card,
    marginHorizontal: 20,
    marginBottom: 12,
    padding: 16,
    borderRadius: 12,
  },
  historyHeader: {
    flexDirection: 'row',
    alignItems: 'center',
    marginBottom: 12,
  },
  scoreCircle: {
    width: 60,
    height: 60,
    borderRadius: 30,
    backgroundColor: colors.primary + '20',
    justifyContent: 'center',
    alignItems: 'center',
    marginRight: 16,
  },
  scoreText: {
    fontSize: 20,
    fontWeight: 'bold',
    color: colors.primary,
  },
  historyInfo: {
    flex: 1,
  },
  historyDate: {
    fontSize: 16,
    fontWeight: '600',
    color: colors.text,
    marginBottom: 4,
  },
  historyTime: {
    fontSize: 14,
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
    fontSize: 12,
    color: colors.textSecondary,
    marginBottom: 4,
  },
  statValue: {
    fontSize: 18,
    fontWeight: 'bold',
    color: colors.text,
  },
  riskBadge: {
    paddingHorizontal: 12,
    paddingVertical: 6,
    borderRadius: 12,
  },
  riskBadgeText: {
    fontSize: 12,
    fontWeight: '600',
    textTransform: 'uppercase',
  },
});

export default HistoryScreen;
