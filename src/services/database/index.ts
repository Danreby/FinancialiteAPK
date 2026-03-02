import * as SQLite from 'expo-sqlite';

let db: SQLite.SQLiteDatabase | null = null;

export async function getDatabase(): Promise<SQLite.SQLiteDatabase> {
  if (db) return db;
  db = await SQLite.openDatabaseAsync('financialite.db');
  await db.execAsync('PRAGMA journal_mode = WAL;');
  await db.execAsync('PRAGMA foreign_keys = ON;');
  await runMigrations(db);
  return db;
}

async function runMigrations(database: SQLite.SQLiteDatabase): Promise<void> {
  await database.execAsync(`
    CREATE TABLE IF NOT EXISTS db_version (
      id INTEGER PRIMARY KEY CHECK (id = 1),
      version INTEGER NOT NULL DEFAULT 0
    );
    INSERT OR IGNORE INTO db_version (id, version) VALUES (1, 0);
  `);

  const result = await database.getFirstAsync<{ version: number }>('SELECT version FROM db_version WHERE id = 1');
  const currentVersion = result?.version ?? 0;

  const migrations = getMigrations();

  for (let i = currentVersion; i < migrations.length; i++) {
    await database.execAsync(migrations[i]);
    await database.runAsync('UPDATE db_version SET version = ? WHERE id = 1', [i + 1]);
  }
}

function getMigrations(): string[] {
  return [
    // V1: Core tables
    `
    CREATE TABLE IF NOT EXISTS categories (
      id INTEGER PRIMARY KEY,
      server_id INTEGER,
      name TEXT NOT NULL,
      color TEXT,
      icon TEXT,
      type TEXT DEFAULT 'expense',
      user_id INTEGER,
      is_synced INTEGER DEFAULT 0,
      is_deleted INTEGER DEFAULT 0,
      created_at TEXT,
      updated_at TEXT
    );

    CREATE TABLE IF NOT EXISTS transacoes (
      id INTEGER PRIMARY KEY,
      server_id INTEGER,
      title TEXT NOT NULL,
      description TEXT,
      amount REAL NOT NULL,
      type TEXT NOT NULL DEFAULT 'debit',
      status TEXT DEFAULT 'unpaid',
      paid_date TEXT,
      total_installments INTEGER,
      current_installment INTEGER,
      is_recurring INTEGER DEFAULT 0,
      user_id INTEGER,
      bank_user_id INTEGER,
      category_id INTEGER,
      is_synced INTEGER DEFAULT 0,
      is_deleted INTEGER DEFAULT 0,
      created_at TEXT,
      updated_at TEXT
    );

    CREATE TABLE IF NOT EXISTS incomes (
      id INTEGER PRIMARY KEY,
      server_id INTEGER,
      title TEXT NOT NULL,
      description TEXT,
      amount REAL NOT NULL,
      type TEXT NOT NULL,
      payment_day_type TEXT,
      payment_day_value INTEGER,
      is_active INTEGER DEFAULT 1,
      is_recurring INTEGER DEFAULT 0,
      received_at TEXT,
      bank_user_id INTEGER,
      bank_account_id INTEGER,
      user_id INTEGER,
      is_synced INTEGER DEFAULT 0,
      is_deleted INTEGER DEFAULT 0,
      created_at TEXT,
      updated_at TEXT
    );

    CREATE TABLE IF NOT EXISTS bills (
      id INTEGER PRIMARY KEY,
      server_id INTEGER,
      title TEXT NOT NULL,
      description TEXT,
      amount REAL,
      recurrence_type TEXT DEFAULT 'monthly',
      due_day INTEGER NOT NULL,
      start_date TEXT,
      end_date TEXT,
      color TEXT,
      icon TEXT,
      status TEXT DEFAULT 'active',
      category_id INTEGER,
      user_id INTEGER,
      is_synced INTEGER DEFAULT 0,
      is_deleted INTEGER DEFAULT 0,
      created_at TEXT,
      updated_at TEXT
    );

    CREATE TABLE IF NOT EXISTS budgets (
      id INTEGER PRIMARY KEY,
      server_id INTEGER,
      monthly_limit REAL,
      month_year TEXT,
      is_active INTEGER DEFAULT 1,
      user_id INTEGER,
      is_synced INTEGER DEFAULT 0,
      is_deleted INTEGER DEFAULT 0,
      created_at TEXT,
      updated_at TEXT
    );

    CREATE TABLE IF NOT EXISTS budget_categories (
      id INTEGER PRIMARY KEY,
      server_id INTEGER,
      budget_id INTEGER,
      category_id INTEGER,
      "limit" REAL,
      is_synced INTEGER DEFAULT 0,
      created_at TEXT,
      updated_at TEXT,
      FOREIGN KEY (budget_id) REFERENCES budgets(id) ON DELETE CASCADE
    );

    CREATE TABLE IF NOT EXISTS savings_goals (
      id INTEGER PRIMARY KEY,
      server_id INTEGER,
      title TEXT NOT NULL,
      description TEXT,
      target_amount REAL NOT NULL,
      current_amount REAL DEFAULT 0,
      icon TEXT,
      color TEXT,
      is_active INTEGER DEFAULT 1,
      completed_at TEXT,
      user_id INTEGER,
      is_synced INTEGER DEFAULT 0,
      is_deleted INTEGER DEFAULT 0,
      created_at TEXT,
      updated_at TEXT
    );

    CREATE TABLE IF NOT EXISTS bank_accounts (
      id INTEGER PRIMARY KEY,
      server_id INTEGER,
      bank_id INTEGER,
      bank_name TEXT,
      balance REAL DEFAULT 0,
      user_id INTEGER,
      is_synced INTEGER DEFAULT 0,
      created_at TEXT,
      updated_at TEXT
    );

    CREATE TABLE IF NOT EXISTS card_users (
      id INTEGER PRIMARY KEY,
      server_id INTEGER,
      card_id INTEGER,
      card_name TEXT,
      brand TEXT,
      due_day INTEGER,
      closing_day INTEGER,
      credit_limit REAL,
      user_id INTEGER,
      is_synced INTEGER DEFAULT 0,
      created_at TEXT,
      updated_at TEXT
    );

    CREATE TABLE IF NOT EXISTS notifications (
      id INTEGER PRIMARY KEY,
      server_id INTEGER,
      title TEXT NOT NULL,
      message TEXT,
      type TEXT DEFAULT 'info',
      is_read INTEGER DEFAULT 0,
      read_at TEXT,
      user_id INTEGER,
      created_at TEXT
    );

    CREATE TABLE IF NOT EXISTS sync_queue (
      id TEXT PRIMARY KEY,
      entity TEXT NOT NULL,
      action TEXT NOT NULL,
      data TEXT NOT NULL,
      created_at TEXT NOT NULL,
      retries INTEGER DEFAULT 0,
      last_error TEXT
    );

    CREATE INDEX IF NOT EXISTS idx_transacoes_user ON transacoes(user_id);
    CREATE INDEX IF NOT EXISTS idx_transacoes_type ON transacoes(type);
    CREATE INDEX IF NOT EXISTS idx_transacoes_status ON transacoes(status);
    CREATE INDEX IF NOT EXISTS idx_transacoes_synced ON transacoes(is_synced);
    CREATE INDEX IF NOT EXISTS idx_incomes_user ON incomes(user_id);
    CREATE INDEX IF NOT EXISTS idx_bills_user ON bills(user_id);
    CREATE INDEX IF NOT EXISTS idx_bills_status ON bills(status);
    CREATE INDEX IF NOT EXISTS idx_categories_user ON categories(user_id);
    CREATE INDEX IF NOT EXISTS idx_sync_queue_entity ON sync_queue(entity);
    `,
  ];
}

export async function clearDatabase(): Promise<void> {
  const database = await getDatabase();
  const tables = [
    'sync_queue', 'notifications', 'budget_categories', 'budgets',
    'savings_goals', 'bills', 'incomes', 'transacoes', 'categories',
    'bank_accounts', 'card_users',
  ];
  for (const table of tables) {
    await database.execAsync(`DELETE FROM ${table};`);
  }
}
