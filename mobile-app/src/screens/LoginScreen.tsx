import React, { useState } from 'react';
import {
  View,
  Text,
  StyleSheet,
  TextInput,
  TouchableOpacity,
  ActivityIndicator,
  ScrollView,
  KeyboardAvoidingView,
  Platform,
} from 'react-native';
import { useWindowDimensions } from 'react-native';
import { StackNavigationProp } from '@react-navigation/stack';
import { useNavigation } from '@react-navigation/native';
import Icon from '../utils/iconHelper';
import { colors } from '../theme/colors';
import { spacing, radii, textStyles } from '../theme/theme';
import { AuthStackParamList } from '../navigation/AuthNavigator';
import { useAuth } from '../../App';

type LoginScreenNavigationProp = StackNavigationProp<AuthStackParamList, 'Login'>;

const LoginScreen: React.FC = () => {
  const navigation = useNavigation<LoginScreenNavigationProp>();
  const { login } = useAuth();
  const { width } = useWindowDimensions();
  const isLargeScreen = width >= 768;

  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const handleLogin = async () => {
    setError(null);

    if (!email || !password) {
      setError('Please enter your email and password.');
      return;
    }

    setIsSubmitting(true);

    try {
      // TODO: Replace with real auth API call
      await new Promise((resolve) => setTimeout(resolve, 800));
      login();
    } catch (e) {
      setError('Unable to log in. Please try again.');
    } finally {
      setIsSubmitting(false);
    }
  };

  const handleNavigateToSignUp = () => {
    navigation.navigate('SignUp');
  };

  return (
    <KeyboardAvoidingView
      style={styles.flex}
      behavior={Platform.OS === 'ios' ? 'padding' : undefined}
    >
      <ScrollView
        contentContainerStyle={[
          styles.container,
          isLargeScreen && styles.containerLarge,
        ]}
        keyboardShouldPersistTaps="handled"
      >
        <View style={styles.header}>
          <View style={styles.logoCircle}>
            <Icon name="shield-check" size={28} color={colors.onPrimary} />
          </View>
          <Text style={[styles.title, isLargeScreen && styles.titleLarge]}>SecureNet</Text>
          <Text style={styles.subtitle}>Sign in to secure your Wi‑Fi</Text>
        </View>

        <View style={[styles.card, isLargeScreen && styles.cardLarge]}>
          <Text style={styles.cardTitle}>Welcome back</Text>
          <Text style={styles.cardSubtitle}>Log in with your SecureNet account</Text>

          <View style={styles.field}>
            <Text style={styles.label}>Email</Text>
            <TextInput
              style={styles.input}
              placeholder="you@example.com"
              placeholderTextColor={colors.textSecondary}
              value={email}
              onChangeText={setEmail}
              keyboardType="email-address"
              autoCapitalize="none"
              autoCorrect={false}
            />
          </View>

          <View style={styles.field}>
            <Text style={styles.label}>Password</Text>
            <TextInput
              style={styles.input}
              placeholder="••••••••"
              placeholderTextColor={colors.textSecondary}
              value={password}
              onChangeText={setPassword}
              secureTextEntry
            />
          </View>

          {error && <Text style={styles.errorText}>{error}</Text>}

          <TouchableOpacity
            style={[styles.primaryButton, isSubmitting && styles.primaryButtonDisabled]}
            onPress={handleLogin}
            disabled={isSubmitting}
          >
            {isSubmitting ? (
              <ActivityIndicator color={colors.onPrimary} />
            ) : (
              <Text style={styles.primaryButtonText}>Log In</Text>
            )}
          </TouchableOpacity>

          <TouchableOpacity style={styles.linkButton}>
            <Text style={styles.linkText}>Forgot password?</Text>
          </TouchableOpacity>
        </View>

        <View style={styles.footer}>
          <Text style={styles.footerText}>New to SecureNet?</Text>
          <TouchableOpacity onPress={handleNavigateToSignUp}>
            <Text style={styles.footerLink}>Create account</Text>
          </TouchableOpacity>
        </View>

        <Text style={styles.privacyText}>
          Your credentials are encrypted and never shared.
        </Text>
      </ScrollView>
    </KeyboardAvoidingView>
  );
};

const styles = StyleSheet.create({
  flex: {
    flex: 1,
    backgroundColor: colors.background,
  },
  container: {
    flex: 1,
    backgroundColor: colors.background,
    paddingHorizontal: spacing.md,
    paddingTop: spacing.xxl,
    paddingBottom: spacing.lg,
    justifyContent: 'center',
  },
  containerLarge: {
    paddingHorizontal: spacing.xl,
  },
  header: {
    alignItems: 'center',
    marginBottom: spacing.xl,
  },
  logoCircle: {
    width: 56,
    height: 56,
    borderRadius: radii.full,
    backgroundColor: colors.primary,
    alignItems: 'center',
    justifyContent: 'center',
    marginBottom: 12,
  },
  title: {
    ...textStyles.headlineLarge,
    fontWeight: '700',
    color: colors.text,
    marginTop: spacing.sm,
  },
  titleLarge: {
    fontSize: 36,
  },
  subtitle: {
    ...textStyles.bodyMedium,
    color: colors.textSecondary,
    marginTop: spacing.xs,
  },
  card: {
    backgroundColor: colors.card,
    borderRadius: radii.lg,
    padding: spacing.md,
  },
  cardLarge: {
    alignSelf: 'center',
    width: '100%',
    maxWidth: 480,
  },
  cardTitle: {
    ...textStyles.titleLarge,
    color: colors.text,
    marginBottom: spacing.xs,
  },
  cardSubtitle: {
    ...textStyles.bodySmall,
    color: colors.textSecondary,
    marginBottom: spacing.md,
  },
  field: {
    marginBottom: spacing.md,
  },
  label: {
    ...textStyles.labelMedium,
    color: colors.textSecondary,
    marginBottom: spacing.xs,
  },
  input: {
    backgroundColor: colors.surfaceVariant,
    borderRadius: radii.sm,
    paddingHorizontal: spacing.sm,
    paddingVertical: spacing.sm,
    color: colors.text,
    ...textStyles.bodyLarge,
  },
  primaryButton: {
    backgroundColor: colors.primary,
    borderRadius: radii.md,
    paddingVertical: spacing.sm + 2,
    alignItems: 'center',
    marginTop: spacing.sm,
    minHeight: 48,
  },
  primaryButtonDisabled: {
    opacity: 0.7,
  },
  primaryButtonText: {
    color: colors.onPrimary,
    ...textStyles.titleMedium,
  },
  linkButton: {
    marginTop: spacing.sm,
    alignItems: 'center',
  },
  linkText: {
    color: colors.primary,
    ...textStyles.labelLarge,
  },
  errorText: {
    color: colors.error,
    ...textStyles.bodySmall,
    marginBottom: spacing.sm,
  },
  footer: {
    flexDirection: 'row',
    justifyContent: 'center',
    alignItems: 'center',
    marginTop: spacing.lg,
  },
  footerText: {
    color: colors.textSecondary,
    ...textStyles.bodySmall,
  },
  footerLink: {
    color: colors.primary,
    ...textStyles.labelLarge,
    marginLeft: spacing.xs,
    fontWeight: '600',
  },
  privacyText: {
    ...textStyles.labelSmall,
    color: colors.textSecondary,
    textAlign: 'center',
    marginTop: spacing.sm,
  },
});

export default LoginScreen;

