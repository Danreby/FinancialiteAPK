import { getDatabase } from './index';
import type { SQLiteBindParams } from 'expo-sqlite';
import { v4 as uuidv4 } from 'uuid';

type EntityType = 'transacoes' | 'incomes' | 'bills' | 'categories' | 'budgets' | 'savings_goals' | 'bank_accounts' | 'card_users' | 'notifications';

export const localDb = {
  async getAll<T>(table: EntityType, where?: string, params?: unknown[]): Promise<T[]> {
    const db = await getDatabase();
    const whereClause = where ? ` WHERE ${where}` : ' WHERE is_deleted = 0';
    return db.getAllAsync<T>(`SELECT * FROM ${table}${whereClause} ORDER BY created_at DESC`, (params ?? []) as SQLiteBindParams);
  },

  async getById<T>(table: EntityType, id: number): Promise<T | null> {
    const db = await getDatabase();
    return db.getFirstAsync<T>(`SELECT * FROM ${table} WHERE id = ?`, [id]);
  },

  async insert(table: EntityType, data: Record<string, unknown>): Promise<number> {
    const db = await getDatabase();
    const now = new Date().toISOString();
    const withTimestamps = { ...data, created_at: now, updated_at: now };
    const keys = Object.keys(withTimestamps);
    const values = Object.values(withTimestamps);
    const placeholders = keys.map(() => '?').join(', ');
    const result = await db.runAsync(
      `INSERT INTO ${table} (${keys.join(', ')}) VALUES (${placeholders})`,
      values as (string | number | null)[]
    );
    return result.lastInsertRowId;
  },

  async update(table: EntityType, id: number, data: Record<string, unknown>): Promise<void> {
    const db = await getDatabase();
    const withTimestamp = { ...data, updated_at: new Date().toISOString(), is_synced: 0 };
    const keys = Object.keys(withTimestamp);
    const values = Object.values(withTimestamp);
    const setClause = keys.map((k) => `${k} = ?`).join(', ');
    await db.runAsync(`UPDATE ${table} SET ${setClause} WHERE id = ?`, [...values, id] as (string | number | null)[]);
  },

  async softDelete(table: EntityType, id: number): Promise<void> {
    const db = await getDatabase();
    await db.runAsync(
      `UPDATE ${table} SET is_deleted = 1, is_synced = 0, updated_at = ? WHERE id = ?`,
      [new Date().toISOString(), id]
    );
  },

  async hardDelete(table: EntityType, id: number): Promise<void> {
    const db = await getDatabase();
    await db.runAsync(`DELETE FROM ${table} WHERE id = ?`, [id]);
  },

  async upsertFromServer(table: EntityType, serverId: number, data: Record<string, unknown>): Promise<void> {
    const db = await getDatabase();
    const existing = await db.getFirstAsync<{ id: number }>(
      `SELECT id FROM ${table} WHERE server_id = ?`,
      [serverId]
    );

    if (existing) {
      const keys = Object.keys(data);
      const values = Object.values(data);
      const setClause = keys.map((k) => `${k} = ?`).join(', ');
      await db.runAsync(
        `UPDATE ${table} SET ${setClause}, is_synced = 1 WHERE server_id = ?`,
        [...values, serverId] as (string | number | null)[]
      );
    } else {
      const withSync = { ...data, server_id: serverId, is_synced: 1 };
      const keys = Object.keys(withSync);
      const values = Object.values(withSync);
      const placeholders = keys.map(() => '?').join(', ');
      await db.runAsync(
        `INSERT INTO ${table} (${keys.join(', ')}) VALUES (${placeholders})`,
        values as (string | number | null)[]
      );
    }
  },

  async getUnsynced(table: EntityType): Promise<unknown[]> {
    const db = await getDatabase();
    return db.getAllAsync(`SELECT * FROM ${table} WHERE is_synced = 0`);
  },

  async markSynced(table: EntityType, id: number, serverId: number): Promise<void> {
    const db = await getDatabase();
    await db.runAsync(
      `UPDATE ${table} SET is_synced = 1, server_id = ? WHERE id = ?`,
      [serverId, id]
    );
  },

  // Sync queue operations
  async addToSyncQueue(entity: string, action: string, data: Record<string, unknown>): Promise<void> {
    const db = await getDatabase();
    const id = uuidv4();
    await db.runAsync(
      'INSERT INTO sync_queue (id, entity, action, data, created_at) VALUES (?, ?, ?, ?, ?)',
      [id, entity, action, JSON.stringify(data), new Date().toISOString()]
    );
  },

  async getSyncQueue(): Promise<{ id: string; entity: string; action: string; data: string; retries: number }[]> {
    const db = await getDatabase();
    return db.getAllAsync('SELECT * FROM sync_queue ORDER BY created_at ASC');
  },

  async removeSyncQueueItem(id: string): Promise<void> {
    const db = await getDatabase();
    await db.runAsync('DELETE FROM sync_queue WHERE id = ?', [id]);
  },

  async incrementSyncRetry(id: string, error: string): Promise<void> {
    const db = await getDatabase();
    await db.runAsync(
      'UPDATE sync_queue SET retries = retries + 1, last_error = ? WHERE id = ?',
      [error, id]
    );
  },

  async clearSyncQueue(): Promise<void> {
    const db = await getDatabase();
    await db.execAsync('DELETE FROM sync_queue');
  },

  async count(table: EntityType, where?: string, params?: unknown[]): Promise<number> {
    const db = await getDatabase();
    const whereClause = where ? ` WHERE ${where}` : '';
    const result = await db.getFirstAsync<{ count: number }>(
      `SELECT COUNT(*) as count FROM ${table}${whereClause}`,
      (params ?? []) as SQLiteBindParams
    );
    return result?.count ?? 0;
  },
};
