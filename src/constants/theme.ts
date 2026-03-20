import type { ThemeName } from '@/types';

export interface ThemeColors {
  primary: string;
  primaryLight: string;
  primaryDark: string;
  background: string;
  surface: string;
  surfaceElevated: string;
  text: string;
  textSecondary: string;
  textMuted: string;
  border: string;
  success: string;
  warning: string;
  danger: string;
  info: string;
  cardBg: string;
  income: string;
  expense: string;
  tabBar: string;
  tabBarBorder: string;
  statusBar: 'light' | 'dark';
}

const baseColors = {
  success: '#22c55e',
  warning: '#f59e0b',
  danger: '#ef4444',
  info: '#3b82f6',
  income: '#22c55e',
  expense: '#ef4444',
};

export const themes: Record<ThemeName, ThemeColors> = {
  rose: {
    primary: '#e11d48',
    primaryLight: '#fda4af',
    primaryDark: '#9f1239',
    background: '#0f172a',
    surface: '#1e293b',
    surfaceElevated: '#334155',
    text: '#f8fafc',
    textSecondary: '#94a3b8',
    textMuted: '#64748b',
    border: '#334155',
    cardBg: '#1e293b',
    tabBar: '#0f172a',
    tabBarBorder: '#1e293b',
    statusBar: 'light',
    ...baseColors,
  },
  black: {
    primary: '#a855f7',
    primaryLight: '#c4b5fd',
    primaryDark: '#7c3aed',
    background: '#09090b',
    surface: '#18181b',
    surfaceElevated: '#27272a',
    text: '#fafafa',
    textSecondary: '#a1a1aa',
    textMuted: '#71717a',
    border: '#27272a',
    cardBg: '#18181b',
    tabBar: '#09090b',
    tabBarBorder: '#18181b',
    statusBar: 'light',
    ...baseColors,
  },
  forest: {
    primary: '#22c55e',
    primaryLight: '#86efac',
    primaryDark: '#15803d',
    background: '#0c1a14',
    surface: '#14291f',
    surfaceElevated: '#1c3829',
    text: '#f0fdf4',
    textSecondary: '#86efac',
    textMuted: '#4ade80',
    border: '#1c3829',
    cardBg: '#14291f',
    tabBar: '#0c1a14',
    tabBarBorder: '#14291f',
    statusBar: 'light',
    ...baseColors,
  },
  gold: {
    primary: '#eab308',
    primaryLight: '#fde047',
    primaryDark: '#a16207',
    background: '#1a1608',
    surface: '#292211',
    surfaceElevated: '#3d331a',
    text: '#fefce8',
    textSecondary: '#fde047',
    textMuted: '#ca8a04',
    border: '#3d331a',
    cardBg: '#292211',
    tabBar: '#1a1608',
    tabBarBorder: '#292211',
    statusBar: 'light',
    ...baseColors,
  },
  lavender: {
    primary: '#8b5cf6',
    primaryLight: '#c4b5fd',
    primaryDark: '#6d28d9',
    background: '#0f0a1e',
    surface: '#1a1330',
    surfaceElevated: '#261d42',
    text: '#f5f3ff',
    textSecondary: '#c4b5fd',
    textMuted: '#8b5cf6',
    border: '#261d42',
    cardBg: '#1a1330',
    tabBar: '#0f0a1e',
    tabBarBorder: '#1a1330',
    statusBar: 'light',
    ...baseColors,
  },
  midnight: {
    primary: '#3b82f6',
    primaryLight: '#93c5fd',
    primaryDark: '#1d4ed8',
    background: '#0f172a',
    surface: '#1e293b',
    surfaceElevated: '#334155',
    text: '#f8fafc',
    textSecondary: '#94a3b8',
    textMuted: '#64748b',
    border: '#334155',
    cardBg: '#1e293b',
    tabBar: '#0f172a',
    tabBarBorder: '#1e293b',
    statusBar: 'light',
    ...baseColors,
  },
};

export const defaultTheme: ThemeName = 'midnight';
