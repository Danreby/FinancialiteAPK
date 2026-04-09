import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../../core/constants/storage_constants.dart';

class AppDatabase {
  static Database? _database;

  static Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  static Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, StorageConstants.dbName);

    return await openDatabase(
      path,
      version: StorageConstants.dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  static Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY,
        name TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        phone TEXT,
        theme TEXT DEFAULT 'rose',
        avatar TEXT,
        google_id TEXT,
        created_at TEXT,
        updated_at TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE categories (
        id INTEGER PRIMARY KEY,
        name TEXT NOT NULL,
        type TEXT NOT NULL,
        icon TEXT,
        color TEXT,
        user_id INTEGER NOT NULL,
        created_at TEXT,
        updated_at TEXT,
        synced INTEGER DEFAULT 0,
        FOREIGN KEY (user_id) REFERENCES users(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE banks (
        id INTEGER PRIMARY KEY,
        name TEXT NOT NULL,
        code TEXT,
        color TEXT,
        logo TEXT,
        created_at TEXT,
        updated_at TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE bank_users (
        id INTEGER PRIMARY KEY,
        user_id INTEGER NOT NULL,
        bank_id INTEGER NOT NULL,
        account_type TEXT DEFAULT 'checking',
        balance REAL DEFAULT 0,
        nickname TEXT,
        created_at TEXT,
        updated_at TEXT,
        synced INTEGER DEFAULT 0,
        FOREIGN KEY (user_id) REFERENCES users(id),
        FOREIGN KEY (bank_id) REFERENCES banks(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE cards (
        id INTEGER PRIMARY KEY,
        name TEXT NOT NULL,
        brand TEXT,
        color TEXT,
        logo TEXT,
        created_at TEXT,
        updated_at TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE card_users (
        id INTEGER PRIMARY KEY,
        user_id INTEGER NOT NULL,
        card_id INTEGER NOT NULL,
        due_day INTEGER DEFAULT 10,
        closing_day INTEGER DEFAULT 3,
        credit_limit REAL DEFAULT 0,
        nickname TEXT,
        created_at TEXT,
        updated_at TEXT,
        synced INTEGER DEFAULT 0,
        FOREIGN KEY (user_id) REFERENCES users(id),
        FOREIGN KEY (card_id) REFERENCES cards(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE transactions (
        id INTEGER PRIMARY KEY,
        title TEXT NOT NULL,
        amount REAL NOT NULL,
        type TEXT NOT NULL,
        status TEXT DEFAULT 'pending',
        date TEXT,
        description TEXT,
        is_recurring INTEGER DEFAULT 0,
        installments INTEGER DEFAULT 1,
        user_id INTEGER NOT NULL,
        category_id INTEGER,
        card_user_id INTEGER,
        bank_user_id INTEGER,
        created_at TEXT,
        updated_at TEXT,
        deleted_at TEXT,
        synced INTEGER DEFAULT 0,
        FOREIGN KEY (user_id) REFERENCES users(id),
        FOREIGN KEY (category_id) REFERENCES categories(id),
        FOREIGN KEY (card_user_id) REFERENCES card_users(id),
        FOREIGN KEY (bank_user_id) REFERENCES bank_users(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE transaction_parcelas (
        id INTEGER PRIMARY KEY,
        transaction_id INTEGER NOT NULL,
        parcela_number INTEGER NOT NULL,
        month_key TEXT NOT NULL,
        due_date TEXT,
        amount REAL NOT NULL,
        status TEXT DEFAULT 'pending',
        paid_at TEXT,
        created_at TEXT,
        updated_at TEXT,
        synced INTEGER DEFAULT 0,
        FOREIGN KEY (transaction_id) REFERENCES transactions(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE bills (
        id INTEGER PRIMARY KEY,
        title TEXT NOT NULL,
        amount REAL NOT NULL,
        due_day INTEGER NOT NULL,
        recurrence_type TEXT DEFAULT 'monthly',
        is_active INTEGER DEFAULT 1,
        category_id INTEGER,
        user_id INTEGER NOT NULL,
        description TEXT,
        created_at TEXT,
        updated_at TEXT,
        deleted_at TEXT,
        synced INTEGER DEFAULT 0,
        FOREIGN KEY (user_id) REFERENCES users(id),
        FOREIGN KEY (category_id) REFERENCES categories(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE bill_payments (
        id INTEGER PRIMARY KEY,
        bill_id INTEGER NOT NULL,
        amount REAL NOT NULL,
        due_date TEXT,
        paid_date TEXT,
        status TEXT DEFAULT 'pending',
        created_at TEXT,
        updated_at TEXT,
        synced INTEGER DEFAULT 0,
        FOREIGN KEY (bill_id) REFERENCES bills(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE incomes (
        id INTEGER PRIMARY KEY,
        title TEXT NOT NULL,
        amount REAL NOT NULL,
        type TEXT NOT NULL,
        payment_day INTEGER,
        is_recurring INTEGER DEFAULT 1,
        payment_day_type TEXT,
        payment_day_value INTEGER,
        is_active INTEGER DEFAULT 1,
        bank_user_id INTEGER,
        bank_account_id INTEGER,
        user_id INTEGER NOT NULL,
        description TEXT,
        received_at TEXT,
        created_at TEXT,
        updated_at TEXT,
        deleted_at TEXT,
        synced INTEGER DEFAULT 0,
        FOREIGN KEY (user_id) REFERENCES users(id),
        FOREIGN KEY (bank_user_id) REFERENCES bank_users(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE budgets (
        id INTEGER PRIMARY KEY,
        monthly_limit REAL NOT NULL,
        month_year TEXT NOT NULL,
        user_id INTEGER NOT NULL,
        created_at TEXT,
        updated_at TEXT,
        synced INTEGER DEFAULT 0,
        FOREIGN KEY (user_id) REFERENCES users(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE budget_categories (
        id INTEGER PRIMARY KEY,
        budget_id INTEGER NOT NULL,
        category_id INTEGER NOT NULL,
        limit_amount REAL NOT NULL,
        created_at TEXT,
        updated_at TEXT,
        synced INTEGER DEFAULT 0,
        FOREIGN KEY (budget_id) REFERENCES budgets(id),
        FOREIGN KEY (category_id) REFERENCES categories(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE savings_goals (
        id INTEGER PRIMARY KEY,
        title TEXT NOT NULL,
        target_amount REAL NOT NULL,
        current_amount REAL DEFAULT 0,
        icon TEXT,
        color TEXT,
        deadline TEXT,
        is_completed INTEGER DEFAULT 0,
        user_id INTEGER NOT NULL,
        description TEXT,
        created_at TEXT,
        updated_at TEXT,
        deleted_at TEXT,
        synced INTEGER DEFAULT 0,
        FOREIGN KEY (user_id) REFERENCES users(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE bank_transfers (
        id INTEGER PRIMARY KEY,
        from_bank_user_id INTEGER NOT NULL,
        to_bank_user_id INTEGER NOT NULL,
        amount REAL NOT NULL,
        description TEXT,
        user_id INTEGER NOT NULL,
        created_at TEXT,
        updated_at TEXT,
        synced INTEGER DEFAULT 0,
        FOREIGN KEY (from_bank_user_id) REFERENCES bank_users(id),
        FOREIGN KEY (to_bank_user_id) REFERENCES bank_users(id),
        FOREIGN KEY (user_id) REFERENCES users(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE notifications (
        id INTEGER PRIMARY KEY,
        title TEXT NOT NULL,
        message TEXT,
        type TEXT DEFAULT 'info',
        is_read INTEGER DEFAULT 0,
        user_id INTEGER NOT NULL,
        created_at TEXT,
        updated_at TEXT,
        FOREIGN KEY (user_id) REFERENCES users(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE sync_queue (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        table_name TEXT NOT NULL,
        record_id INTEGER NOT NULL,
        action TEXT NOT NULL,
        data TEXT,
        attempts INTEGER DEFAULT 0,
        created_at TEXT NOT NULL,
        processed_at TEXT
      )
    ''');

    await db.execute('CREATE INDEX idx_transactions_user ON transactions(user_id)');
    await db.execute('CREATE INDEX idx_transactions_date ON transactions(date)');
    await db.execute('CREATE INDEX idx_transactions_type ON transactions(type)');
    await db.execute('CREATE INDEX idx_bills_user ON bills(user_id)');
    await db.execute('CREATE INDEX idx_incomes_user ON incomes(user_id)');
    await db.execute('CREATE INDEX idx_budgets_user_month ON budgets(user_id, month_year)');
    await db.execute('CREATE INDEX idx_savings_user ON savings_goals(user_id)');
    await db.execute('CREATE INDEX idx_notifications_user ON notifications(user_id)');
    await db.execute('CREATE INDEX idx_sync_queue_table ON sync_queue(table_name, processed_at)');
  }

  static Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('ALTER TABLE incomes ADD COLUMN is_recurring INTEGER DEFAULT 1');
      await db.execute('ALTER TABLE incomes ADD COLUMN payment_day_type TEXT');
      await db.execute('ALTER TABLE incomes ADD COLUMN payment_day_value INTEGER');
      await db.execute('ALTER TABLE incomes ADD COLUMN bank_account_id INTEGER');
      await db.execute('ALTER TABLE incomes ADD COLUMN received_at TEXT');
    }
  }

  static Future<void> clearAll() async {
    final db = await database;
    final tables = [
      'sync_queue', 'notifications', 'bank_transfers', 'savings_goals',
      'budget_categories', 'budgets', 'incomes', 'bill_payments', 'bills',
      'transaction_parcelas', 'transactions', 'card_users', 'cards',
      'bank_users', 'banks', 'categories', 'users',
    ];
    for (final table in tables) {
      await db.delete(table);
    }
  }
}
