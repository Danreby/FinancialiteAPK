import * as SQLite from 'expo-sqlite';
import { CONFIG } from '@/constants/config';

let db: SQLite.SQLiteDatabase | null = null;

export async function getDatabase(): Promise<SQLite.SQLiteDatabase> {
  if (db) return db;
  db = await SQLite.openDatabaseAsync(CONFIG.DB_NAME);
  await db.execAsync('PRAGMA journal_mode = WAL;');
  await db.execAsync('PRAGMA foreign_keys = ON;');
  await runMigrations(db);
  return db;
}

async function runMigrations(database: SQLite.SQLiteDatabase): Promise<void> {
  await database.execAsync(`
    CREATE TABLE IF NOT EXISTS _migrations (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      version INTEGER NOT NULL UNIQUE,
      applied_at TEXT NOT NULL DEFAULT (datetime('now'))
    );
  `);

  const result = await database.getFirstAsync<{ max_version: number | null }>(
    'SELECT MAX(version) as max_version FROM _migrations'
  );
  const currentVersion = result?.max_version ?? 0;

  for (const migration of migrations) {
    if (migration.version > currentVersion) {
      await database.execAsync(migration.sql);
      await database.runAsync('INSERT INTO _migrations (version) VALUES (?)', [migration.version]);
    }
  }
}

interface Migration {
  version: number;
  sql: string;
}

const migrations: Migration[] = [
  {
    version: 1,
    sql: `
      CREATE TABLE IF NOT EXISTS users (
        id INTEGER PRIMARY KEY,
        name TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        phone TEXT,
        theme TEXT NOT NULL DEFAULT 'midnight',
        google_id TEXT,
        avatar TEXT,
        email_verified_at TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      );

      CREATE TABLE IF NOT EXISTS banks (
        id INTEGER PRIMARY KEY,
        name TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      );

      CREATE TABLE IF NOT EXISTS bank_users (
        id INTEGER PRIMARY KEY,
        bank_id INTEGER NOT NULL REFERENCES banks(id),
        user_id INTEGER NOT NULL,
        balance REAL NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        UNIQUE(bank_id, user_id)
      );

      CREATE TABLE IF NOT EXISTS cards (
        id INTEGER PRIMARY KEY,
        name TEXT NOT NULL,
        brand TEXT,
        description TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      );

      CREATE TABLE IF NOT EXISTS card_users (
        id INTEGER PRIMARY KEY,
        card_id INTEGER NOT NULL REFERENCES cards(id),
        user_id INTEGER NOT NULL,
        due_day INTEGER,
        closing_day INTEGER,
        credit_limit REAL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      );

      CREATE TABLE IF NOT EXISTS categories (
        id INTEGER PRIMARY KEY,
        name TEXT NOT NULL,
        color TEXT,
        icon TEXT,
        type TEXT NOT NULL CHECK(type IN ('income', 'expense')),
        user_id INTEGER NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        UNIQUE(user_id, name)
      );

      CREATE TABLE IF NOT EXISTS transacoes (
        id INTEGER PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT,
        amount REAL NOT NULL,
        type TEXT NOT NULL CHECK(type IN ('credit', 'debit')),
        status TEXT NOT NULL DEFAULT 'unpaid' CHECK(status IN ('paid', 'unpaid', 'overdue')),
        paid_date TEXT,
        total_installments INTEGER NOT NULL DEFAULT 1,
        current_installment INTEGER DEFAULT 1,
        is_recurring INTEGER NOT NULL DEFAULT 0,
        user_id INTEGER NOT NULL,
        bank_user_id INTEGER REFERENCES card_users(id),
        category_id INTEGER REFERENCES categories(id),
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        deleted_at TEXT
      );

      CREATE INDEX IF NOT EXISTS idx_transacoes_user ON transacoes(user_id);
      CREATE INDEX IF NOT EXISTS idx_transacoes_bank_user ON transacoes(bank_user_id);
      CREATE INDEX IF NOT EXISTS idx_transacoes_category ON transacoes(category_id);
      CREATE INDEX IF NOT EXISTS idx_transacoes_status ON transacoes(user_id, status);

      CREATE TABLE IF NOT EXISTS faturas (
        id INTEGER PRIMARY KEY,
        user_id INTEGER NOT NULL,
        month_key TEXT NOT NULL,
        bank_user_id INTEGER REFERENCES card_users(id),
        paid_at TEXT,
        total_paid REAL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      );

      CREATE TABLE IF NOT EXISTS fatura_transacao (
        fatura_id INTEGER NOT NULL REFERENCES faturas(id),
        transacao_id INTEGER NOT NULL REFERENCES transacoes(id),
        PRIMARY KEY(fatura_id, transacao_id)
      );

      CREATE TABLE IF NOT EXISTS incomes (
        id INTEGER PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT,
        amount REAL NOT NULL,
        type TEXT NOT NULL,
        payment_day_type TEXT NOT NULL CHECK(payment_day_type IN ('fixed', 'business_day')),
        payment_day_value INTEGER NOT NULL,
        is_active INTEGER NOT NULL DEFAULT 1,
        is_recurring INTEGER NOT NULL DEFAULT 1,
        received_at TEXT,
        bank_user_id INTEGER REFERENCES card_users(id),
        bank_account_id INTEGER REFERENCES bank_users(id),
        user_id INTEGER NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        deleted_at TEXT
      );

      CREATE INDEX IF NOT EXISTS idx_incomes_user ON incomes(user_id, is_active);

      CREATE TABLE IF NOT EXISTS bills (
        id INTEGER PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT,
        amount REAL,
        recurrence_type TEXT NOT NULL DEFAULT 'monthly',
        due_day INTEGER NOT NULL,
        start_date TEXT NOT NULL,
        end_date TEXT,
        color TEXT NOT NULL DEFAULT '#3b82f6',
        icon TEXT NOT NULL DEFAULT 'FileText',
        status TEXT NOT NULL DEFAULT 'active' CHECK(status IN ('active', 'inactive', 'completed')),
        category_id INTEGER REFERENCES categories(id),
        user_id INTEGER NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        deleted_at TEXT
      );

      CREATE INDEX IF NOT EXISTS idx_bills_user ON bills(user_id, status);

      CREATE TABLE IF NOT EXISTS bill_payments (
        id INTEGER PRIMARY KEY,
        bill_id INTEGER NOT NULL REFERENCES bills(id),
        due_date TEXT NOT NULL,
        paid_date TEXT,
        amount_due REAL NOT NULL,
        amount_paid REAL,
        status TEXT NOT NULL DEFAULT 'pending' CHECK(status IN ('pending', 'paid', 'overdue', 'cancelled')),
        notes TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        UNIQUE(bill_id, due_date)
      );

      CREATE INDEX IF NOT EXISTS idx_bill_payments_status ON bill_payments(bill_id, status);

      CREATE TABLE IF NOT EXISTS budgets (
        id INTEGER PRIMARY KEY,
        monthly_limit REAL NOT NULL,
        month_year TEXT NOT NULL,
        is_active INTEGER NOT NULL DEFAULT 1,
        user_id INTEGER NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        UNIQUE(user_id, month_year)
      );

      CREATE TABLE IF NOT EXISTS budget_categories (
        id INTEGER PRIMARY KEY,
        budget_id INTEGER NOT NULL REFERENCES budgets(id),
        category_id INTEGER NOT NULL REFERENCES categories(id),
        amount_limit REAL NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        UNIQUE(budget_id, category_id)
      );

      CREATE TABLE IF NOT EXISTS savings_goals (
        id INTEGER PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT,
        target_amount REAL NOT NULL,
        current_amount REAL NOT NULL DEFAULT 0,
        icon TEXT NOT NULL DEFAULT '💰',
        color TEXT NOT NULL DEFAULT '#f43f5e',
        is_active INTEGER NOT NULL DEFAULT 1,
        completed_at TEXT,
        user_id INTEGER NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        deleted_at TEXT
      );

      CREATE INDEX IF NOT EXISTS idx_savings_user ON savings_goals(user_id, is_active);

      CREATE TABLE IF NOT EXISTS notifications (
        id INTEGER PRIMARY KEY,
        user_id INTEGER NOT NULL,
        title TEXT NOT NULL,
        message TEXT NOT NULL,
        type TEXT NOT NULL DEFAULT 'info' CHECK(type IN ('info', 'warning', 'error', 'success')),
        is_read INTEGER NOT NULL DEFAULT 0,
        read_at TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      );

      CREATE INDEX IF NOT EXISTS idx_notifications_user ON notifications(user_id, is_read);

      CREATE TABLE IF NOT EXISTS bank_transfers (
        id INTEGER PRIMARY KEY,
        user_id INTEGER NOT NULL,
        from_bank_user_id INTEGER NOT NULL REFERENCES bank_users(id),
        to_bank_user_id INTEGER NOT NULL REFERENCES bank_users(id),
        amount REAL NOT NULL,
        description TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      );

      CREATE TABLE IF NOT EXISTS sync_queue (
        id TEXT PRIMARY KEY,
        entity TEXT NOT NULL,
        action TEXT NOT NULL CHECK(action IN ('create', 'update', 'delete')),
        data TEXT NOT NULL,
        created_at TEXT NOT NULL DEFAULT (datetime('now')),
        retries INTEGER NOT NULL DEFAULT 0
      );

      CREATE INDEX IF NOT EXISTS idx_sync_queue_entity ON sync_queue(entity, action);
    `,
  },
];

export async function clearDatabase(): Promise<void> {
  const database = await getDatabase();
  const tables = [
    'sync_queue', 'bank_transfers', 'notifications', 'savings_goals',
    'budget_categories', 'budgets', 'bill_payments', 'bills', 'fatura_transacao',
    'faturas', 'transacoes', 'incomes', 'categories', 'card_users', 'cards',
    'bank_users', 'banks', 'users',
  ];
  for (const table of tables) {
    await database.runAsync(`DELETE FROM ${table}`);
  }
}

export async function closeDatabase(): Promise<void> {
  if (db) {
    await db.closeAsync();
    db = null;
  }
}
