export type ThemeName = 'rose' | 'black' | 'forest' | 'gold' | 'lavender' | 'midnight';

export interface User {
  id: number;
  name: string;
  email: string;
  phone: string | null;
  theme: ThemeName;
  google_id: string | null;
  avatar: string | null;
  email_verified_at: string | null;
  created_at: string;
  updated_at: string;
}

export interface Bank {
  id: number;
  name: string;
  created_at: string;
  updated_at: string;
}

export interface BankUser {
  id: number;
  bank_id: number;
  user_id: number;
  balance: number;
  bank?: Bank;
  created_at: string;
  updated_at: string;
}

export interface Card {
  id: number;
  name: string;
  brand: CardBrand | null;
  description: string | null;
  created_at: string;
  updated_at: string;
}

export type CardBrand = 'visa' | 'mastercard' | 'elo' | 'hipercard' | 'american_express' | 'diners_club';

export interface CardUser {
  id: number;
  card_id: number;
  user_id: number;
  due_day: number | null;
  closing_day: number | null;
  credit_limit: number | null;
  card?: Card;
  created_at: string;
  updated_at: string;
}

export type TransactionType = 'credit' | 'debit';
export type TransactionStatus = 'paid' | 'unpaid' | 'overdue';

export interface Transacao {
  id: number;
  title: string;
  description: string | null;
  amount: number;
  type: TransactionType;
  status: TransactionStatus;
  paid_date: string | null;
  total_installments: number;
  current_installment: number | null;
  is_recurring: boolean;
  user_id: number;
  bank_user_id: number | null;
  category_id: number | null;
  category?: Category;
  bank_user?: CardUser;
  created_at: string;
  updated_at: string;
}

export interface Fatura {
  id: number;
  user_id: number;
  month_key: string;
  bank_user_id: number | null;
  paid_at: string | null;
  total_paid: number | null;
  transacoes?: Transacao[];
  created_at: string;
  updated_at: string;
}

export type CategoryType = 'income' | 'expense';

export interface Category {
  id: number;
  name: string;
  color: string | null;
  icon: string | null;
  type: CategoryType;
  user_id: number;
  created_at: string;
  updated_at: string;
}

export type IncomeType = 'salary' | 'freelance' | 'investment' | 'rental' | 'benefit' | 'other' | 'pix';
export type PaymentDayType = 'fixed' | 'business_day';

export interface Income {
  id: number;
  title: string;
  description: string | null;
  amount: number;
  type: IncomeType;
  payment_day_type: PaymentDayType;
  payment_day_value: number;
  is_active: boolean;
  is_recurring: boolean;
  received_at: string | null;
  bank_user_id: number | null;
  bank_account_id: number | null;
  user_id: number;
  bank_account?: BankUser;
  created_at: string;
  updated_at: string;
}

export type BillRecurrenceType = 'none' | 'monthly' | 'yearly';
export type BillStatus = 'active' | 'inactive' | 'completed';
export type BillPaymentStatus = 'pending' | 'paid' | 'overdue' | 'cancelled';

export interface Bill {
  id: number;
  title: string;
  description: string | null;
  amount: number | null;
  recurrence_type: BillRecurrenceType;
  due_day: number;
  start_date: string;
  end_date: string | null;
  color: string;
  icon: string;
  status: BillStatus;
  category_id: number | null;
  user_id: number;
  category?: Category;
  payments?: BillPayment[];
  created_at: string;
  updated_at: string;
}

export interface BillPayment {
  id: number;
  bill_id: number;
  due_date: string;
  paid_date: string | null;
  amount_due: number;
  amount_paid: number | null;
  status: BillPaymentStatus;
  notes: string | null;
  created_at: string;
  updated_at: string;
}

export interface Budget {
  id: number;
  monthly_limit: number;
  month_year: string;
  is_active: boolean;
  user_id: number;
  category_limits?: BudgetCategory[];
  created_at: string;
  updated_at: string;
}

export interface BudgetCategory {
  id: number;
  budget_id: number;
  category_id: number;
  limit: number;
  category?: Category;
  created_at: string;
  updated_at: string;
}

export interface SavingsGoal {
  id: number;
  user_id: number;
  title: string;
  description: string | null;
  target_amount: number;
  current_amount: number;
  icon: string;
  color: string;
  is_active: boolean;
  completed_at: string | null;
  is_completed: boolean;
  progress: number;
  remaining: number;
  created_at: string;
  updated_at: string;
}

export type NotificationType = 'info' | 'warning' | 'error' | 'success';

export interface Notification {
  id: number;
  user_id: number;
  title: string;
  message: string;
  type: NotificationType;
  is_read: boolean;
  read_at: string | null;
  created_at: string;
  updated_at: string;
}

export interface BankTransfer {
  id: number;
  user_id: number;
  from_bank_user_id: number;
  to_bank_user_id: number;
  amount: number;
  description: string | null;
  from_bank_user?: BankUser;
  to_bank_user?: BankUser;
  created_at: string;
  updated_at: string;
}

export interface AuthResponse {
  user: User;
  token: string;
}

export interface ApiPaginatedResponse<T> {
  data: T[];
  current_page: number;
  last_page: number;
  per_page: number;
  total: number;
}

export interface DashboardData {
  stats: DashboardStats;
  recent_transactions: Transacao[];
  upcoming_bills: Bill[];
  budget_progress: BudgetProgress | null;
  insights: DashboardInsights;
}

export interface DashboardStats {
  total_balance: number;
  monthly_income: number;
  monthly_expenses: number;
  monthly_savings: number;
}

export interface BudgetProgress {
  monthly_limit: number;
  total_spent: number;
  percentage: number;
  categories: BudgetCategoryProgress[];
}

export interface BudgetCategoryProgress {
  category_id: number;
  category_name: string;
  limit: number;
  spent: number;
  percentage: number;
}

export interface DashboardInsights {
  financial_health_score: number;
  spending_trend: 'up' | 'down' | 'stable';
  top_categories: { name: string; amount: number; color: string }[];
}

export interface SyncOperation {
  id: string;
  entity: string;
  action: 'create' | 'update' | 'delete';
  data: Record<string, unknown>;
  created_at: string;
  retries: number;
}

export interface TransactionFilters {
  bank_user_id?: number;
  category_id?: number;
  type?: TransactionType;
  status?: TransactionStatus;
  month?: string;
  search?: string;
}

export interface IncomeFormData {
  title: string;
  description?: string;
  amount: number;
  type: IncomeType;
  payment_day_type: PaymentDayType;
  payment_day_value: number;
  is_recurring: boolean;
  bank_user_id?: number;
  bank_account_id?: number;
}

export interface TransactionFormData {
  title: string;
  description?: string;
  amount: number;
  type: TransactionType;
  status?: TransactionStatus;
  paid_date?: string;
  total_installments?: number;
  is_recurring?: boolean;
  bank_user_id?: number;
  category_id?: number;
}

export interface BillFormData {
  title: string;
  description?: string;
  amount?: number;
  recurrence_type: BillRecurrenceType;
  due_day: number;
  start_date: string;
  end_date?: string;
  color?: string;
  icon?: string;
  category_id?: number;
}

export interface BudgetFormData {
  monthly_limit: number;
  month_year: string;
  is_active?: boolean;
  category_limits?: { category_id: number; limit: number }[];
}

export interface SavingsFormData {
  title: string;
  description?: string;
  target_amount: number;
  icon?: string;
  color?: string;
}

export interface CategoryFormData {
  name: string;
  color?: string;
  icon?: string;
  type: CategoryType;
}

export interface BankFormData {
  bank_id: number;
  balance?: number;
}

export interface CardFormData {
  card_id?: number;
  name?: string;
  brand?: CardBrand;
  due_day?: number;
  closing_day?: number;
  credit_limit?: number;
}

export interface CardUserStats {
  card_user_id: number;
  card_id: number;
  card_name: string;
  total_faturas: number;
  paid_faturas: number;
  unpaid_faturas: number;
  overdue_faturas: number;
  total_amount: number;
  income_amount: number;
  expense_amount: number;
}
