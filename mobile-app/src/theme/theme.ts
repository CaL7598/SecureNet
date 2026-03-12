/**
 * SecureNet design theme (from design-agent prompt)
 * Fonts: primary = Alexandria, secondary/mono = Poppins (use system until loaded)
 */
export const spacing = {
  none: 0,
  xs: 4,
  sm: 8,
  md: 16,
  lg: 24,
  xl: 32,
  xxl: 48,
  xxxl: 64,
} as const;

export const radii = {
  none: 0,
  xs: 2,
  sm: 4,
  md: 8,
  lg: 16,
  xl: 24,
  xxl: 32,
  full: 9999,
} as const;

export const textStyles = {
  displayLarge: { fontSize: 57, fontWeight: '400' as const, lineHeight: 64 },
  displayMedium: { fontSize: 45, fontWeight: '400' as const, lineHeight: 52 },
  displaySmall: { fontSize: 36, fontWeight: '400' as const, lineHeight: 44 },
  headlineLarge: { fontSize: 32, fontWeight: '400' as const, lineHeight: 40 },
  headlineMedium: { fontSize: 28, fontWeight: '400' as const, lineHeight: 36 },
  headlineSmall: { fontSize: 24, fontWeight: '400' as const, lineHeight: 32 },
  titleLarge: { fontSize: 22, fontWeight: '400' as const, lineHeight: 28 },
  titleMedium: { fontSize: 16, fontWeight: '500' as const, lineHeight: 24 },
  titleSmall: { fontSize: 14, fontWeight: '500' as const, lineHeight: 20 },
  labelLarge: { fontSize: 14, fontWeight: '500' as const, lineHeight: 20 },
  labelMedium: { fontSize: 12, fontWeight: '500' as const, lineHeight: 16 },
  labelSmall: { fontSize: 11, fontWeight: '500' as const, lineHeight: 16 },
  bodyLarge: { fontSize: 16, fontWeight: '400' as const, lineHeight: 24 },
  bodyMedium: { fontSize: 14, fontWeight: '400' as const, lineHeight: 20 },
  bodySmall: { fontSize: 12, fontWeight: '400' as const, lineHeight: 16 },
} as const;

const darkPalette = {
  primary: '#00F5FF',
  on_primary: '#003840',
  primary_container: '#005058',
  on_primary_container: '#C0F5FF',
  secondary: '#FF66FF',
  on_secondary: '#500050',
  secondary_container: '#700070',
  on_secondary_container: '#FFD0FF',
  tertiary: '#B388FF',
  on_tertiary: '#1A0030',
  error: '#FF6699',
  on_error: '#690005',
  error_container: '#93000A',
  on_error_container: '#FFDAD6',
  background: '#0A0A0F',
  on_background: '#E4E4E8',
  secondary_background: '#1A1A20',
  surface: '#0A0A0F',
  on_surface: '#E4E4E8',
  surface_variant: '#35354A',
  on_surface_variant: '#C6C6D8',
  primary_text: '#E4E4E8',
  secondary_text: '#B0B0C0',
  outline: '#8080A0',
  divider: '#35354A',
  shadow: '#00F5FF',
  scrim: '#000000',
  inverse_surface: '#E4E4E8',
  inverse_on_surface: '#2D1B4E',
  inverse_primary: '#008080',
};

const lightPalette = {
  primary: '#00F5FF',
  on_primary: '#003840',
  primary_container: '#C0F5FF',
  on_primary_container: '#001F25',
  secondary: '#FF00FF',
  on_secondary: '#400040',
  secondary_container: '#FFD0FF',
  on_secondary_container: '#2D002D',
  tertiary: '#2D1B4E',
  on_tertiary: '#FFFFFF',
  error: '#FF3366',
  on_error: '#FFFFFF',
  error_container: '#FFDAD6',
  on_error_container: '#410002',
  background: '#F0F0F5',
  on_background: '#0A0A0F',
  secondary_background: '#E8E8F0',
  surface: '#F0F0F5',
  on_surface: '#0A0A0F',
  surface_variant: '#D8D8E0',
  on_surface_variant: '#44444F',
  primary_text: '#0A0A0F',
  secondary_text: '#44444F',
  outline: '#75757F',
  divider: '#C6C6D0',
  shadow: '#7B00FF',
  scrim: '#000000',
  inverse_surface: '#2D1B4E',
  inverse_on_surface: '#F0E8FF',
  inverse_primary: '#00F5FF',
};

export const colorsDark = darkPalette;
export const colorsLight = lightPalette;

/** Risk/status colors (same in light/dark) */
export const semanticColors = {
  success: '#4ADE80',
  warning: '#FB923C',
  error: '#FF6699',
  info: '#22D3EE',
  secure: '#4ADE80',
  lowRisk: '#A3E635',
  mediumRisk: '#FB923C',
  highRisk: '#F97316',
  critical: '#FF6699',
};

export const componentDefaults = {
  button: { radius: 8, paddingVertical: 12, paddingHorizontal: 24, minHeight: 40 },
  card: { radius: 12, padding: 16 },
  textfield: { radius: 4, borderWidth: 1, paddingVertical: 16, paddingHorizontal: 12 },
  chip: { radius: 8, paddingVertical: 8, paddingHorizontal: 12, minHeight: 32 },
  dialog: { radius: 28, padding: 24 },
  fab: { radius: 16, size: 56 },
  iconButton: { radius: 20, size: 40 },
} as const;

export type Theme = {
  spacing: typeof spacing;
  radii: typeof radii;
  textStyles: typeof textStyles;
  colors: typeof darkPalette & typeof semanticColors;
  componentDefaults: typeof componentDefaults;
};

const darkTheme: Theme = {
  spacing,
  radii,
  textStyles,
  colors: { ...darkPalette, ...semanticColors },
  componentDefaults,
};

export default darkTheme;
