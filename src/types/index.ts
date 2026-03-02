export interface User {
  id: number;
  name: string;
  email: string;
  phone: string | null;
  theme: ThemeName;
  is_verified: boolean;
  created_at?: string;
}

export type ThemeName = 'rose' | 'black' | 'forest' | 'gold' | 'lavender' | 'midnight';

export interface AuthResponse {
  user: User;
  token: string;
}

export interface Transacao {
  id: number;
  title: string;
  description: string | null;
  amount: string;
  type: 'credit' | 'debit';
  status: 'paid' | 'unpaid' | 'overdue';
  paid_date: string | null;
  total_installments: number | null;
  current_installment: number | null;
  is_recurring: boolean;
  user_id: number;
  bank_user_id: number | null;
  category_id: number | null;
  created_at: string;
  updated_at: string;
  bank_user?: CardUser;
  category?: Category;
  anexos?: Anexo[];
}

export interface CardUser {
  id: number;
  card_id: number;
  user_id: number;
  due_day: number | null;
  closing_day: number | null;
  credit_limit: number | null;
  card?: Card;
  name?: string;
  brand?: string;
}

export interface Card {
  id: number;
  name: string;
  brand: string | null;
  description: string | null;
}

export interface Bank {
  id: number;
  name: string;
}

export interface BankUser {
  id: number;
  bank_id: number;
  user_id: number;
  balance: number;
  bank?: Bank;
  name?: string;
}

export interface BankTransfer {
  id: number;
  user_id: number;
  from_bank_user_id: number;
  to_bank_user_id: number;
  amount: number;
  description: string | null;
  created_at: string;
}

export interface Category {
  id: number;
  name: string;
  color: string | null;
  icon: string | null;
  type: 'income' | 'expense';
  user_id: number;
}

export interface Income {
  id: number;
  title: string;
  description: string | null;
  amount: string;
  type: IncomeType;
  payment_day_type: 'fixed' | 'business_day' | null;
  payment_day_value: number | null;
  is_active: boolean;
  is_recurring: boolean;
  received_at: string | null;
  bank_user_id: number | null;
  bank_account_id: number | null;
  user_id: number;
  created_at: string;
}

export type IncomeType = 'salary' | 'freelance' | 'investment' | 'rental' | 'benefit' | 'other' | 'pix';

export interface Bill {
  id: number;
  title: string;
  description: string | null;
  amount: number | null;
  recurrence_type: 'monthly' | 'yearly' | 'none';
  due_day: number;
  start_date: string | null;
  end_date: string | null;
  color: string | null;
  icon: string | null;
  status: 'active' | 'inactive' | 'completed';
  category_id: number | null;
  user_id: number;
  category?: Category;
  last_payment?: BillPayment | null;
  due_date?: string;
  is_overdue?: boolean;
  is_paid?: boolean;
  days_until_due?: number;
}

export interface BillPayment {
  id: number;
  bill_id: number;
  due_date: string;
  paid_date: string | null;
  amount_due: number;
  amount_paid: number | null;
  status: string;
  notes: string | null;
}

export interface Budget {
  id: number;
  monthly_limit: number;
  month_year: string;
  is_active: boolean;
  user_id: number;
  budget_categories?: BudgetCategory[];
}

export interface BudgetCategory {
  id: number;
  budget_id: number;
  category_id: number;
  limit: number;
  category?: Category;
  spent?: number;
  remaining?: number;
  percentage?: number;
}

export interface BudgetWithSpending {
  budget: Budget;
  total_spent: number;
  remaining: number;
  percentage: number;
  categories: BudgetCategory[];
}

export interface SavingsGoal {
  id: number;
  title: string;
  description: string | null;
  target_amount: number;
  current_amount: number;
  icon: string | null;
  color: string | null;
  is_active: boolean;
  completed_at: string | null;
  user_id: number;
  created_at: string;
}

export interface AppNotification {
  id: number;
  user_id: number;
  title: string;
  message: string;
  type: 'info' | 'warning' | 'error' | 'success' | 'security';
  is_read: boolean;
  read_at: string | null;
  created_at: string;
}

export interface Anexo {
  id: number;
  user_id: number;
  original_name: string;
  stored_name: string;
  mime_type: string;
  extension: string;
  size: number;
  description: string | null;
}

export interface PaginatedResponse<T> {
  data: T[];
  current_page: number;
  last_page: number;
  per_page: number;
  total: number;
}

export interface DashboardData {
  transactions: PaginatedResponse<Transacao>;
  stats: DashboardStats;
  insights: FinancialInsights;
  bankAccounts: BankUser[];
  categories: Category[];
}

export interface DashboardStats {
  total_credit: number;
  total_debit: number;
  balance: number;
  paid_count: number;
  unpaid_count: number;
  overdue_count: number;
}

export interface FinancialInsights {
  health_score: number;
  savings_rate: number;
  budget_adherence: number;
  top_categories: { name: string; total: number; color: string }[];
  monthly_trend: { month: string; income: number; expense: number }[];
}

export interface SyncQueueItem {
  id: string;
  entity: string;
  action: 'create' | 'update' | 'delete';
  data: Record<string, unknown>;
  created_at: string;
  retries: number;
}
