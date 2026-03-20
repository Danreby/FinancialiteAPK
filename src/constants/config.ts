const API_BASE_URL = __DEV__
  ? 'http://10.0.2.2:8000/api/v1'
  : 'https://financialite.rolims.com/api/v1';

const GOOGLE_WEB_CLIENT_ID = '105982257579-bj5rmr9qcuuggr3rmf081ib4ri4ckfvh.apps.googleusercontent.com';

export const CONFIG = {
  API_BASE_URL,
  GOOGLE_WEB_CLIENT_ID,
  REQUEST_TIMEOUT: 15000,
  SYNC_INTERVAL: 30000,
  MAX_SYNC_RETRIES: 5,
  DB_NAME: 'financialite.db',
  DB_VERSION: 1,
  TOKEN_KEY: 'auth_token',
  USER_KEY: 'auth_user',
  THEME_KEY: 'app_theme',
  PAGINATION_LIMIT: 20,
  MAX_FILE_SIZE: 10 * 1024 * 1024,
} as const;

export const INCOME_TYPE_LABELS: Record<string, string> = {
  salary: 'Salário',
  freelance: 'Freelance',
  investment: 'Investimento',
  rental: 'Aluguel',
  benefit: 'Benefício',
  other: 'Outro',
  pix: 'Pix',
};

export const CATEGORY_TYPE_LABELS: Record<string, string> = {
  income: 'Receita',
  expense: 'Despesa',
};

export const BILL_RECURRENCE_LABELS: Record<string, string> = {
  none: 'Única',
  monthly: 'Mensal',
  yearly: 'Anual',
};

export const TRANSACTION_STATUS_LABELS: Record<string, string> = {
  paid: 'Pago',
  unpaid: 'Pendente',
  overdue: 'Atrasado',
};

export const CARD_BRANDS = [
  'visa',
  'mastercard',
  'elo',
  'hipercard',
  'american_express',
  'diners_club',
] as const;

export const NOTIFICATION_TYPES = ['info', 'warning', 'error', 'success'] as const;

export const VALID_THEMES = ['rose', 'black', 'forest', 'gold', 'lavender', 'midnight'] as const;
