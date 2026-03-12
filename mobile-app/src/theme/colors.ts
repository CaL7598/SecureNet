/**
 * SecureNet Color Theme (from design-agent prompt)
 * Dark theme by default; semantic risk colors for scan results.
 */
import { colorsDark, semanticColors } from './theme';

const d = colorsDark;

export const colors = {
  // Design tokens (dark)
  primary: d.primary,
  onPrimary: d.on_primary,
  primaryContainer: d.primary_container,
  onPrimaryContainer: d.on_primary_container,
  secondary: d.secondary,
  onSecondary: d.on_secondary,
  secondaryContainer: d.secondary_container,
  onSecondaryContainer: d.on_secondary_container,
  tertiary: d.tertiary,
  onTertiary: d.on_tertiary,
  background: d.background,
  onBackground: d.on_background,
  secondaryBackground: d.secondary_background,
  surface: d.surface,
  onSurface: d.on_surface,
  surfaceVariant: d.surface_variant,
  onSurfaceVariant: d.on_surface_variant,
  outline: d.outline,
  divider: d.divider,
  error: d.error,
  onError: d.on_error,
  errorContainer: d.error_container,
  onErrorContainer: d.on_error_container,
  inverseSurface: d.inverse_surface,
  inverseOnSurface: d.inverse_on_surface,
  inversePrimary: d.inverse_primary,

  // Legacy aliases (for backward compatibility)
  primaryDark: d.primary_container,
  primaryLight: d.on_primary_container,
  card: d.surface_variant,
  text: d.on_surface,
  textSecondary: d.secondary_text,
  textDisabled: d.outline,

  // Status / risk (semantic)
  ...semanticColors,

  // UI
  border: d.outline,
  disabled: d.surface_variant,

  // Navigation
  tabActive: d.primary,
  tabInactive: d.secondary_text,
} as const;

export type ColorTheme = typeof colors;
