import { BaseRepository } from './base.repository';
import { getDatabase } from './connection';
import type {
  Transacao,
  BankUser,
  CardUser,
  Category,
  Income,
  Bill,
  BillPayment,
  Budget,
  BudgetCategory,
  SavingsGoal,
  Notification,
  BankTransfer,
  Fatura,
  Bank,
  Card,
  User,
} from '@/types';

export class UserRepository extends BaseRepository<User> {
  constructor() { super('users'); }
}

export class BankRepository extends BaseRepository<Bank> {
  constructor() { super('banks'); }

  async getAll(): Promise<Bank[]> {
    const db = await getDatabase();
    return db.getAllAsync<Bank>('SELECT * FROM banks ORDER BY name ASC');
  }
}

export class BankUserRepository extends BaseRepository<BankUser> {
  constructor() { super('bank_users'); }

  async getAllForUser(userId: number): Promise<(BankUser & { bank_name: string })[]> {
    const db = await getDatabase();
    return db.getAllAsync<BankUser & { bank_name: string }>(
      `SELECT bu.*, b.name as bank_name FROM bank_users bu
       JOIN banks b ON b.id = bu.bank_id
       WHERE bu.user_id = ?
       ORDER BY b.name ASC`,
      [userId]
    );
  }

  async getTotalBalance(userId: number): Promise<number> {
    const db = await getDatabase();
    const result = await db.getFirstAsync<{ total: number | null }>(
      'SELECT SUM(balance) as total FROM bank_users WHERE user_id = ?',
      [userId]
    );
    return result?.total ?? 0;
  }
}

export class CardRepository extends BaseRepository<Card> {
  constructor() { super('cards'); }
}

export class CardUserRepository extends BaseRepository<CardUser> {
  constructor() { super('card_users'); }

  async getAllForUser(userId: number): Promise<(CardUser & { card_name: string; brand: string | null })[]> {
    const db = await getDatabase();
    return db.getAllAsync<CardUser & { card_name: string; brand: string | null }>(
      `SELECT cu.*, c.name as card_name, c.brand FROM card_users cu
       JOIN cards c ON c.id = cu.card_id
       WHERE cu.user_id = ?
       ORDER BY c.name ASC`,
      [userId]
    );
  }
}

export class CategoryRepository extends BaseRepository<Category> {
  constructor() { super('categories'); }

  async getAllForUser(userId: number, type?: string): Promise<Category[]> {
    const db = await getDatabase();
    if (type) {
      return db.getAllAsync<Category>(
        'SELECT * FROM categories WHERE user_id = ? AND type = ? ORDER BY name ASC',
        [userId, type]
      );
    }
    return db.getAllAsync<Category>(
      'SELECT * FROM categories WHERE user_id = ? ORDER BY name ASC',
      [userId]
    );
  }
}

export class TransactionRepository extends BaseRepository<Transacao> {
  constructor() { super('transacoes'); }

  async getForUser(userId: number, filters?: {
    bank_user_id?: number;
    category_id?: number;
    type?: string;
    status?: string;
    month?: string;
    search?: string;
  }): Promise<Transacao[]> {
    const db = await getDatabase();
    let query = `SELECT t.*, c.name as category_name, c.color as category_color, c.icon as category_icon
                 FROM transacoes t
                 LEFT JOIN categories c ON c.id = t.category_id
                 WHERE t.user_id = ? AND (t.deleted_at IS NULL OR t.deleted_at = '')`;
    const params: (string | number)[] = [userId];

    if (filters?.bank_user_id) {
      query += ' AND t.bank_user_id = ?';
      params.push(filters.bank_user_id);
    }
    if (filters?.category_id) {
      query += ' AND t.category_id = ?';
      params.push(filters.category_id);
    }
    if (filters?.type) {
      query += ' AND t.type = ?';
      params.push(filters.type);
    }
    if (filters?.status) {
      query += ' AND t.status = ?';
      params.push(filters.status);
    }
    if (filters?.month) {
      query += " AND strftime('%Y-%m', t.created_at) = ?";
      params.push(filters.month);
    }
    if (filters?.search) {
      query += ' AND t.title LIKE ?';
      params.push(`%${filters.search}%`);
    }

    query += ' ORDER BY t.created_at DESC';
    return db.getAllAsync<Transacao>(query, params);
  }

  async getMonthlyStats(userId: number, monthKey: string): Promise<{
    total_credit: number;
    total_debit: number;
    count: number;
  }> {
    const db = await getDatabase();
    const result = await db.getFirstAsync<{
      total_credit: number | null;
      total_debit: number | null;
      count: number;
    }>(
      `SELECT
        COALESCE(SUM(CASE WHEN type = 'credit' THEN amount ELSE 0 END), 0) as total_credit,
        COALESCE(SUM(CASE WHEN type = 'debit' THEN amount ELSE 0 END), 0) as total_debit,
        COUNT(*) as count
       FROM transacoes
       WHERE user_id = ? AND strftime('%Y-%m', created_at) = ?
         AND (deleted_at IS NULL OR deleted_at = '')`,
      [userId, monthKey]
    );
    return {
      total_credit: result?.total_credit ?? 0,
      total_debit: result?.total_debit ?? 0,
      count: result?.count ?? 0,
    };
  }

  async getTopCategories(userId: number, monthKey: string, limit = 5): Promise<{
    name: string;
    color: string;
    total: number;
  }[]> {
    const db = await getDatabase();
    return db.getAllAsync<{ name: string; color: string; total: number }>(
      `SELECT c.name, c.color, SUM(t.amount) as total
       FROM transacoes t
       JOIN categories c ON c.id = t.category_id
       WHERE t.user_id = ? AND t.type = 'debit'
         AND strftime('%Y-%m', t.created_at) = ?
         AND (t.deleted_at IS NULL OR t.deleted_at = '')
       GROUP BY c.id
       ORDER BY total DESC
       LIMIT ?`,
      [userId, monthKey, limit]
    );
  }
}

export class FaturaRepository extends BaseRepository<Fatura> {
  constructor() { super('faturas'); }

  async getForMonth(userId: number, monthKey: string, bankUserId?: number): Promise<Fatura | null> {
    const db = await getDatabase();
    let query = 'SELECT * FROM faturas WHERE user_id = ? AND month_key = ?';
    const params: (string | number)[] = [userId, monthKey];
    if (bankUserId) {
      query += ' AND bank_user_id = ?';
      params.push(bankUserId);
    }
    return db.getFirstAsync<Fatura>(query, params);
  }
}

export class IncomeRepository extends BaseRepository<Income> {
  constructor() { super('incomes'); }

  async getForUser(userId: number): Promise<Income[]> {
    const db = await getDatabase();
    return db.getAllAsync<Income>(
      `SELECT i.*, bu.balance as bank_balance
       FROM incomes i
       LEFT JOIN bank_users bu ON bu.id = i.bank_account_id
       WHERE i.user_id = ? AND (i.deleted_at IS NULL OR i.deleted_at = '')
       ORDER BY i.is_active DESC, i.title ASC`,
      [userId]
    );
  }

  async getTotalMonthly(userId: number): Promise<number> {
    const db = await getDatabase();
    const result = await db.getFirstAsync<{ total: number | null }>(
      `SELECT SUM(amount) as total FROM incomes
       WHERE user_id = ? AND is_active = 1 AND is_recurring = 1
         AND (deleted_at IS NULL OR deleted_at = '')`,
      [userId]
    );
    return result?.total ?? 0;
  }
}

export class BillRepository extends BaseRepository<Bill> {
  constructor() { super('bills'); }

  async getForUser(userId: number): Promise<Bill[]> {
    const db = await getDatabase();
    return db.getAllAsync<Bill>(
      `SELECT b.*, c.name as category_name, c.color as category_color
       FROM bills b
       LEFT JOIN categories c ON c.id = b.category_id
       WHERE b.user_id = ? AND (b.deleted_at IS NULL OR b.deleted_at = '')
       ORDER BY b.due_day ASC`,
      [userId]
    );
  }

  async getUpcoming(userId: number, days = 30): Promise<Bill[]> {
    const db = await getDatabase();
    return db.getAllAsync<Bill>(
      `SELECT * FROM bills
       WHERE user_id = ? AND status = 'active'
         AND (deleted_at IS NULL OR deleted_at = '')
       ORDER BY due_day ASC`,
      [userId]
    );
  }
}

export class BillPaymentRepository extends BaseRepository<BillPayment> {
  constructor() { super('bill_payments'); }

  async getForBill(billId: number): Promise<BillPayment[]> {
    const db = await getDatabase();
    return db.getAllAsync<BillPayment>(
      'SELECT * FROM bill_payments WHERE bill_id = ? ORDER BY due_date DESC',
      [billId]
    );
  }
}

export class BudgetRepository extends BaseRepository<Budget> {
  constructor() { super('budgets'); }

  async getCurrentForUser(userId: number, monthYear: string): Promise<Budget | null> {
    const db = await getDatabase();
    return db.getFirstAsync<Budget>(
      'SELECT * FROM budgets WHERE user_id = ? AND month_year = ? AND is_active = 1',
      [userId, monthYear]
    );
  }

  async getCategoryLimits(budgetId: number): Promise<(BudgetCategory & { category_name: string; category_color: string })[]> {
    const db = await getDatabase();
    return db.getAllAsync<BudgetCategory & { category_name: string; category_color: string }>(
      `SELECT bc.*, c.name as category_name, c.color as category_color
       FROM budget_categories bc
       JOIN categories c ON c.id = bc.category_id
       WHERE bc.budget_id = ?`,
      [budgetId]
    );
  }
}

export class BudgetCategoryRepository extends BaseRepository<BudgetCategory> {
  constructor() { super('budget_categories'); }
}

export class SavingsGoalRepository extends BaseRepository<SavingsGoal> {
  constructor() { super('savings_goals'); }

  async getForUser(userId: number): Promise<SavingsGoal[]> {
    const db = await getDatabase();
    return db.getAllAsync<SavingsGoal>(
      `SELECT * FROM savings_goals
       WHERE user_id = ? AND (deleted_at IS NULL OR deleted_at = '')
       ORDER BY is_active DESC, created_at DESC`,
      [userId]
    );
  }

  async getSummary(userId: number): Promise<{ total_target: number; total_saved: number; count: number }> {
    const db = await getDatabase();
    const result = await db.getFirstAsync<{ total_target: number | null; total_saved: number | null; count: number }>(
      `SELECT SUM(target_amount) as total_target, SUM(current_amount) as total_saved, COUNT(*) as count
       FROM savings_goals
       WHERE user_id = ? AND is_active = 1 AND (deleted_at IS NULL OR deleted_at = '')`,
      [userId]
    );
    return {
      total_target: result?.total_target ?? 0,
      total_saved: result?.total_saved ?? 0,
      count: result?.count ?? 0,
    };
  }
}

export class NotificationRepository extends BaseRepository<Notification> {
  constructor() { super('notifications'); }

  async getForUser(userId: number): Promise<Notification[]> {
    const db = await getDatabase();
    return db.getAllAsync<Notification>(
      'SELECT * FROM notifications WHERE user_id = ? ORDER BY created_at DESC',
      [userId]
    );
  }

  async getUnreadCount(userId: number): Promise<number> {
    const db = await getDatabase();
    const result = await db.getFirstAsync<{ count: number }>(
      'SELECT COUNT(*) as count FROM notifications WHERE user_id = ? AND is_read = 0',
      [userId]
    );
    return result?.count ?? 0;
  }

  async markAsRead(id: number): Promise<void> {
    const db = await getDatabase();
    await db.runAsync(
      "UPDATE notifications SET is_read = 1, read_at = datetime('now') WHERE id = ?",
      [id]
    );
  }

  async markAllAsRead(userId: number): Promise<void> {
    const db = await getDatabase();
    await db.runAsync(
      "UPDATE notifications SET is_read = 1, read_at = datetime('now') WHERE user_id = ? AND is_read = 0",
      [userId]
    );
  }
}

export class BankTransferRepository extends BaseRepository<BankTransfer> {
  constructor() { super('bank_transfers'); }

  async getForUser(userId: number, bankUserId?: number): Promise<BankTransfer[]> {
    const db = await getDatabase();
    const conditions = ['bt.user_id = ?'];
    const params: (number)[] = [userId];

    if (bankUserId) {
      conditions.push('(bt.from_bank_user_id = ? OR bt.to_bank_user_id = ?)');
      params.push(bankUserId, bankUserId);
    }

    return db.getAllAsync<BankTransfer>(
      `SELECT bt.*,
        fb.balance as from_balance, tb.balance as to_balance,
        fbank.name as from_bank_name, tbank.name as to_bank_name
       FROM bank_transfers bt
       LEFT JOIN bank_users fb ON fb.id = bt.from_bank_user_id
       LEFT JOIN bank_users tb ON tb.id = bt.to_bank_user_id
       LEFT JOIN banks fbank ON fbank.id = fb.bank_id
       LEFT JOIN banks tbank ON tbank.id = tb.bank_id
       WHERE ${conditions.join(' AND ')}
       ORDER BY bt.created_at DESC`,
      params
    );
  }
}

export class SyncQueueRepository {
  async getAll(): Promise<{ id: string; entity: string; action: string; data: string; created_at: string; retries: number }[]> {
    const db = await getDatabase();
    return db.getAllAsync(
      'SELECT * FROM sync_queue ORDER BY created_at ASC'
    );
  }

  async add(id: string, entity: string, action: string, data: Record<string, unknown>): Promise<void> {
    const db = await getDatabase();
    await db.runAsync(
      'INSERT INTO sync_queue (id, entity, action, data) VALUES (?, ?, ?, ?)',
      [id, entity, action, JSON.stringify(data)]
    );
  }

  async remove(id: string): Promise<void> {
    const db = await getDatabase();
    await db.runAsync('DELETE FROM sync_queue WHERE id = ?', [id]);
  }

  async incrementRetries(id: string): Promise<void> {
    const db = await getDatabase();
    await db.runAsync('UPDATE sync_queue SET retries = retries + 1 WHERE id = ?', [id]);
  }

  async count(): Promise<number> {
    const db = await getDatabase();
    const result = await db.getFirstAsync<{ count: number }>('SELECT COUNT(*) as count FROM sync_queue');
    return result?.count ?? 0;
  }

  async clear(): Promise<void> {
    const db = await getDatabase();
    await db.runAsync('DELETE FROM sync_queue');
  }
}
