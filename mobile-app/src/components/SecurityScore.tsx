/**
 * Security Score Circular Progress Component
 */
import React from 'react';
import { View, Text, StyleSheet } from 'react-native';
import { colors } from '../theme/colors';
import { RiskLevel } from '../types';

interface SecurityScoreProps {
  score: number;
  size?: number;
}

const SecurityScore: React.FC<SecurityScoreProps> = ({ score, size = 120 }) => {
  const getScoreColor = (score: number): string => {
    if (score >= 90) return colors.secure;
    if (score >= 70) return colors.lowRisk;
    if (score >= 50) return colors.mediumRisk;
    if (score >= 30) return colors.highRisk;
    return colors.critical;
  };

  const getScoreLabel = (score: number): string => {
    if (score >= 90) return 'Good';
    if (score >= 70) return 'Fair';
    if (score >= 50) return 'Poor';
    if (score >= 30) return 'Bad';
    return 'Critical';
  };

  const circumference = 2 * Math.PI * (size / 2 - 10);
  const strokeDashoffset = circumference - (score / 100) * circumference;

  return (
    <View style={[styles.container, { width: size, height: size }]}>
      {/* Circular progress background */}
      <View
        style={[
          styles.circle,
          {
            width: size,
            height: size,
            borderRadius: size / 2,
            borderWidth: 8,
            borderColor: colors.surfaceVariant,
          },
        ]}
      />
      
      {/* Score display */}
      <View style={styles.scoreContainer}>
        <Text style={[styles.scoreText, { color: getScoreColor(score) }]}>
          {score}
        </Text>
        <Text style={styles.scoreLabel}>{getScoreLabel(score)}</Text>
      </View>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    justifyContent: 'center',
    alignItems: 'center',
    position: 'relative',
  },
  circle: {
    position: 'absolute',
    borderStyle: 'solid',
  },
  scoreContainer: {
    alignItems: 'center',
    justifyContent: 'center',
  },
  scoreText: {
    fontSize: 48,
    fontWeight: 'bold',
  },
  scoreLabel: {
    fontSize: 16,
    color: colors.textSecondary,
    marginTop: 4,
  },
});

export default SecurityScore;
