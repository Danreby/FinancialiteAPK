import { Platform } from 'react-native';

const DEV_API_URL = Platform.select({
  android: 'http://10.0.2.2:8000',
  ios: 'http://localhost:8000',
  default: 'http://localhost:8000',
});

export const CONFIG = {
  API_BASE_URL: __DEV__ ? DEV_API_URL : 'https://financialite.rolims.com',
  API_VERSION: 'v1',
  APP_NAME: 'Financialite',

  // Storage keys
  STORAGE_KEYS: {
    AUTH_TOKEN: 'auth_token',
    USER_DATA: 'user_data',
    LAST_SYNC: 'last_sync_timestamp',
    THEME: 'app_theme',
  },

  // Sync
  SYNC_INTERVAL_MS: 5 * 60 * 1000, // 5 minutes
  MAX_SYNC_RETRIES: 3,
  SYNC_BATCH_SIZE: 50,

  // Pagination
  DEFAULT_PAGE_SIZE: 15,

  // Cache TTL (ms)
  CACHE_TTL: {
    DASHBOARD: 2 * 60 * 1000,
    CATEGORIES: 10 * 60 * 1000,
    BANKS: 10 * 60 * 1000,
  },

  // Validation
  VALIDATION: {
    MAX_AMOUNT: 999999999.99,
    MIN_AMOUNT: 0.01,
    MAX_TITLE_LENGTH: 255,
    MIN_TITLE_LENGTH: 2,
    MAX_DESCRIPTION_LENGTH: 1000,
    MAX_INSTALLMENTS: 360,
    ALLOWED_THEMES: ['rose', 'black', 'forest', 'gold', 'lavender', 'midnight'] as const,
    INCOME_TYPES: ['salary', 'freelance', 'investment', 'rental', 'benefit', 'other', 'pix'] as const,
    CARD_BRANDS: ['visa', 'mastercard', 'elo', 'hipercard', 'american_express', 'diners_club'] as const,
  },
} as const;

export const API_URL = `${CONFIG.API_BASE_URL}/api/${CONFIG.API_VERSION}`;
