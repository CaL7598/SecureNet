/**
 * SecureNet Splash Screen
 * Dark theme with logo, network integrity card, and Get Started CTA.
 */
import React, { useEffect, useRef } from 'react';
import {
  View,
  Text,
  StyleSheet,
  TouchableOpacity,
  Animated,
  Dimensions,
} from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import Icon from '../utils/iconHelper';
import { colors } from '../theme/colors';
import { spacing, radii, textStyles } from '../theme/theme';

const { width: SCREEN_WIDTH } = Dimensions.get('window');

interface SplashScreenProps {
  onGetStarted: () => void;
}

const SplashScreen: React.FC<SplashScreenProps> = ({ onGetStarted }) => {
  const ringScale = useRef(new Animated.Value(1)).current;
  const ringOpacity = useRef(new Animated.Value(0.4)).current;

  useEffect(() => {
    const pulse = Animated.loop(
      Animated.parallel([
        Animated.sequence([
          Animated.timing(ringScale, {
            toValue: 1.15,
            duration: 1500,
            useNativeDriver: true,
          }),
          Animated.timing(ringScale, {
            toValue: 1,
            duration: 1500,
            useNativeDriver: true,
          }),
        ]),
        Animated.sequence([
          Animated.timing(ringOpacity, {
            toValue: 0.15,
            duration: 1500,
            useNativeDriver: true,
          }),
          Animated.timing(ringOpacity, {
            toValue: 0.4,
            duration: 1500,
            useNativeDriver: true,
          }),
        ]),
      ]),
      { iterations: -1 }
    );
    pulse.start();
    return () => pulse.stop();
  }, [ringScale, ringOpacity]);

  return (
    <SafeAreaView style={styles.container} edges={['top', 'bottom']}>
      {/* Background orbs */}
      <View style={[styles.orb, styles.orbTopRight]} />
      <View style={[styles.orb, styles.orbBottomLeft]} />

      {/* Logo + concentric rings */}
      <View style={styles.logoSection}>
        <View style={styles.ringsWrap}>
          <Animated.View
            style={[
              styles.ring,
              {
                transform: [{ scale: ringScale }],
                opacity: ringOpacity,
              },
            ]}
          />
          <Animated.View
            style={[
              styles.ring,
              styles.ringMid,
              {
                transform: [{ scale: ringScale }],
                opacity: ringOpacity,
              },
            ]}
          />
          <View style={styles.ringInner}>
            <View style={styles.logoCircle}>
              <Icon name="shield-check" size={40} color={colors.onPrimary} />
            </View>
          </View>
        </View>
        <Text style={styles.appName}>SecureNet</Text>
        <Text style={styles.tagline}>AI-Powered Network Auditing</Text>
      </View>

      {/* Network Integrity Card */}
      <View style={styles.card}>
        <View style={styles.cardRow}>
          <Icon name="wifi" size={24} color={colors.primary} />
          <Text style={styles.networkName}>Home_WiFi_5G</Text>
        </View>
        <Text style={styles.scanningText}>Scanning for vulnerabilities...</Text>
        <View style={styles.progressRow}>
          <Text style={styles.progressLabel}>Network Integrity</Text>
          <View style={styles.progressBarWrap}>
            <View style={[styles.progressBarFill, { width: '65%' }]} />
          </View>
          <Text style={styles.progressPercent}>65%</Text>
        </View>
      </View>

      {/* Get Started */}
      <TouchableOpacity
        style={styles.getStartedButton}
        onPress={onGetStarted}
        activeOpacity={0.85}
      >
        <Text style={styles.getStartedText}>Get Started</Text>
        <Icon name="arrow-right" size={22} color={colors.onPrimary} />
      </TouchableOpacity>

      {/* Feature lines */}
      <View style={styles.features}>
        <Text style={styles.featureText}>Protecting 12,000+ Home Devices</Text>
        <View style={styles.featureRow}>
          <Icon name="check-circle" size={16} color={colors.success} />
          <Text style={styles.featureText}>Enterprise-grade security</Text>
        </View>
      </View>

      {/* Footer */}
      <Text style={styles.footer}>v1.0.4 • SecureNet Labs</Text>
    </SafeAreaView>
  );
};

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: colors.background,
    paddingHorizontal: spacing.lg,
    paddingTop: spacing.xxxl,
    paddingBottom: spacing.xl,
    justifyContent: 'space-between',
    alignItems: 'center',
  },
  orb: {
    position: 'absolute',
    width: Math.max(SCREEN_WIDTH * 0.6, 280),
    height: Math.max(SCREEN_WIDTH * 0.6, 280),
    borderRadius: 9999,
    opacity: 0.12,
  },
  orbTopRight: {
    top: -80,
    right: -80,
    backgroundColor: colors.primary,
  },
  orbBottomLeft: {
    bottom: -60,
    left: -60,
    backgroundColor: colors.secondary,
  },
  logoSection: {
    alignItems: 'center',
    marginTop: spacing.xxl,
  },
  ringsWrap: {
    position: 'relative',
    width: 120,
    height: 120,
    alignItems: 'center',
    justifyContent: 'center',
    marginBottom: spacing.lg,
  },
  ring: {
    position: 'absolute',
    width: 120,
    height: 120,
    borderRadius: 60,
    borderWidth: 2,
    borderColor: colors.primary,
  },
  ringMid: {
    width: 100,
    height: 100,
    borderRadius: 50,
    top: 10,
    left: 10,
  },
  ringInner: {
    width: 88,
    height: 88,
    borderRadius: 44,
    backgroundColor: colors.primary,
    alignItems: 'center',
    justifyContent: 'center',
  },
  logoCircle: {
    alignItems: 'center',
    justifyContent: 'center',
  },
  appName: {
    ...textStyles.headlineLarge,
    fontWeight: '700',
    color: colors.text,
    marginBottom: spacing.xs,
  },
  tagline: {
    ...textStyles.bodyLarge,
    color: colors.textSecondary,
  },
  card: {
    width: '100%',
    maxWidth: 400,
    backgroundColor: colors.surfaceVariant,
    borderRadius: radii.lg,
    padding: spacing.md,
    borderWidth: 1,
    borderColor: colors.primary + '60',
  },
  cardRow: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: spacing.sm,
    marginBottom: spacing.xs,
  },
  networkName: {
    ...textStyles.titleMedium,
    color: colors.text,
  },
  scanningText: {
    ...textStyles.bodySmall,
    color: colors.textSecondary,
    marginBottom: spacing.sm,
  },
  progressRow: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: spacing.sm,
  },
  progressLabel: {
    ...textStyles.labelMedium,
    color: colors.text,
    minWidth: 100,
  },
  progressBarWrap: {
    flex: 1,
    height: 6,
    backgroundColor: colors.background,
    borderRadius: radii.full,
    overflow: 'hidden',
  },
  progressBarFill: {
    height: '100%',
    backgroundColor: colors.primary,
    borderRadius: radii.full,
  },
  progressPercent: {
    ...textStyles.labelMedium,
    color: colors.text,
    minWidth: 32,
    textAlign: 'right',
  },
  getStartedButton: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    backgroundColor: colors.primary,
    paddingVertical: spacing.md,
    paddingHorizontal: spacing.xl,
    borderRadius: radii.full,
    gap: spacing.sm,
    minHeight: 52,
  },
  getStartedText: {
    ...textStyles.titleMedium,
    color: colors.onPrimary,
    fontWeight: '600',
  },
  features: {
    alignItems: 'center',
    gap: spacing.xs,
  },
  featureText: {
    ...textStyles.bodySmall,
    color: colors.textSecondary,
  },
  featureRow: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: spacing.xs,
  },
  footer: {
    ...textStyles.labelSmall,
    color: colors.textSecondary,
  },
});

export default SplashScreen;
