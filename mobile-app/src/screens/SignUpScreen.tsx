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

type SignUpScreenNavigationProp = StackNavigationProp<AuthStackParamList, 'SignUp'>;

const SignUpScreen: React.FC = () => {
  const navigation = useNavigation<SignUpScreenNavigationProp>();
  const { login } = useAuth();
  const { width } = useWindowDimensions();
  const isLargeScreen = width >= 768;

  const [name, setName] = useState('');
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [confirmPassword, setConfirmPassword] = useState('');
  const [acceptTerms, setAcceptTerms] = useState(false);
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const handleSignUp = async () => {
    setError(null);

    if (!email || !password || !confirmPassword) {
      setError('Please fill in all required fields.');
      return;
    }

    if (password.length < 8) {
      setError('Password must be at least 8 characters.');
      return;
    }

    if (password !== confirmPassword) {
      setError('Passwords do not match.');
      return;
    }

    if (!acceptTerms) {
      setError('You need to accept the Terms & Privacy Policy.');
      return;
    }

    setIsSubmitting(true);

    try {
      // TODO: Replace with real sign-up API call
      await new Promise((resolve) => setTimeout(resolve, 900));
      login();
    } catch (e) {
      setError('Unable to create your account. Please try again.');
    } finally {
      setIsSubmitting(false);
    }
  };

  const handleNavigateToLogin = () => {
    navigation.navigate('Login');
  };

  const toggleAcceptTerms = () => {
    setAcceptTerms((prev) => !prev);
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
            <Icon name="account-plus" size={26} color={colors.onPrimary} />
          </View>
          <Text style={[styles.title, isLargeScreen && styles.titleLarge]}>
            Create account
          </Text>
          <Text style={styles.subtitle}>
            Save scan history and sync settings across devices.
          </Text>
        </View>

        <View style={[styles.card, isLargeScreen && styles.cardLarge]}>
          <View style={styles.field}>
            <Text style={styles.label}>Full Name (optional)</Text>
            <TextInput
              style={styles.input}
              placeholder="Jane Doe"
              placeholderTextColor={colors.textSecondary}
              value={name}
              onChangeText={setName}
            />
          </View>

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
              placeholder="At least 8 characters"
              placeholderTextColor={colors.textSecondary}
              value={password}
              onChangeText={setPassword}
              secureTextEntry
            />
          </View>

          <View style={styles.field}>
            <Text style={styles.label}>Confirm Password</Text>
            <TextInput
              style={styles.input}
              placeholder="Repeat your password"
              placeholderTextColor={colors.textSecondary}
              value={confirmPassword}
              onChangeText={setConfirmPassword}
              secureTextEntry
            />
          </View>

          <Text style={styles.helperText}>
            Use at least 8 characters, including a number or symbol.
          </Text>

          <TouchableOpacity style={styles.checkboxRow} onPress={toggleAcceptTerms}>
            <View
              style={[
                styles.checkbox,
                acceptTerms && {
                  backgroundColor: colors.primary,
                  borderColor: colors.primary,
                },
              ]}
            >
              {acceptTerms && <Icon name="check" size={16} color={colors.onPrimary} />}
            </View>
            <Text style={styles.checkboxLabel}>
              I agree to the <Text style={styles.linkInline}>Terms</Text> &amp;{' '}
              <Text style={styles.linkInline}>Privacy Policy</Text>
            </Text>
          </TouchableOpacity>

          {error && <Text style={styles.errorText}>{error}</Text>}

          <TouchableOpacity
            style={[styles.primaryButton, isSubmitting && styles.primaryButtonDisabled]}
            onPress={handleSignUp}
            disabled={isSubmitting}
          >
            {isSubmitting ? (
              <ActivityIndicator color={colors.onPrimary} />
            ) : (
              <Text style={styles.primaryButtonText}>Create Account</Text>
            )}
          </TouchableOpacity>
        </View>

        <View style={styles.footer}>
          <Text style={styles.footerText}>Already have an account?</Text>
          <TouchableOpacity onPress={handleNavigateToLogin}>
            <Text style={styles.footerLink}>Log in</Text>
          </TouchableOpacity>
        </View>
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
    flexGrow: 1,
    backgroundColor: colors.background,
    paddingHorizontal: spacing.md,
    paddingTop: spacing.xl,
    paddingBottom: spacing.lg,
    justifyContent: 'center',
  },
  containerLarge: {
    paddingHorizontal: spacing.xl,
  },
  header: {
    alignItems: 'center',
    marginBottom: spacing.lg,
  },
  logoCircle: {
    width: 52,
    height: 52,
    borderRadius: radii.full,
    backgroundColor: colors.primary,
    alignItems: 'center',
    justifyContent: 'center',
    marginBottom: 10,
  },
  title: {
    ...textStyles.headlineMedium,
    fontWeight: '700',
    color: colors.text,
    marginTop: spacing.xs,
  },
  titleLarge: {
    fontSize: 30,
  },
  subtitle: {
    ...textStyles.bodySmall,
    color: colors.textSecondary,
    marginTop: spacing.xs,
    textAlign: 'center',
  },
  card: {
    backgroundColor: colors.card,
    borderRadius: radii.lg,
    padding: spacing.md,
  },
  cardLarge: {
    alignSelf: 'center',
    width: '100%',
    maxWidth: 520,
  },
  field: {
    marginBottom: spacing.sm + 2,
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
  helperText: {
    ...textStyles.labelSmall,
    color: colors.textSecondary,
    marginBottom: spacing.sm,
  },
  checkboxRow: {
    flexDirection: 'row',
    alignItems: 'center',
    marginBottom: spacing.sm,
  },
  checkbox: {
    width: 20,
    height: 20,
    borderRadius: radii.sm,
    borderWidth: 1,
    borderColor: colors.border,
    alignItems: 'center',
    justifyContent: 'center',
    marginRight: spacing.sm,
  },
  checkboxLabel: {
    flex: 1,
    ...textStyles.labelMedium,
    color: colors.textSecondary,
  },
  linkInline: {
    color: colors.primary,
  },
  errorText: {
    color: colors.error,
    ...textStyles.bodySmall,
    marginBottom: spacing.sm,
  },
  primaryButton: {
    backgroundColor: colors.primary,
    borderRadius: radii.md,
    paddingVertical: spacing.sm + 2,
    alignItems: 'center',
    marginTop: spacing.xs,
    minHeight: 48,
  },
  primaryButtonDisabled: {
    opacity: 0.7,
  },
  primaryButtonText: {
    color: colors.onPrimary,
    ...textStyles.titleMedium,
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
});

export default SignUpScreen;

