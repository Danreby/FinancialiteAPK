import { getDatabase } from './connection';

export class BaseRepository<T extends { id: number }> {
  constructor(protected tableName: string) {}

  async getAll(userId?: number): Promise<T[]> {
    const db = await getDatabase();
    if (userId) {
      return db.getAllAsync<T>(
        `SELECT * FROM ${this.tableName} WHERE user_id = ? AND (deleted_at IS NULL OR deleted_at = '') ORDER BY created_at DESC`,
        [userId]
      );
    }
    return db.getAllAsync<T>(`SELECT * FROM ${this.tableName} ORDER BY created_at DESC`);
  }

  async getById(id: number): Promise<T | null> {
    const db = await getDatabase();
    return db.getFirstAsync<T>(`SELECT * FROM ${this.tableName} WHERE id = ?`, [id]);
  }

  async upsert(data: Partial<T> & { id: number }): Promise<void> {
    const db = await getDatabase();
    const existing = await this.getById(data.id);
    if (existing) {
      await this.update(data.id, data);
    } else {
      await this.insert(data);
    }
  }

  async insert(data: Partial<T>): Promise<void> {
    const db = await getDatabase();
    const keys = Object.keys(data);
    const values = Object.values(data);
    const placeholders = keys.map(() => '?').join(', ');
    await db.runAsync(
      `INSERT OR REPLACE INTO ${this.tableName} (${keys.join(', ')}) VALUES (${placeholders})`,
      values as (string | number | null)[]
    );
  }

  async update(id: number, data: Partial<T>): Promise<void> {
    const db = await getDatabase();
    const entries = Object.entries(data).filter(([key]) => key !== 'id');
    if (entries.length === 0) return;
    const setClause = entries.map(([key]) => `${key} = ?`).join(', ');
    const values = entries.map(([, value]) => value);
    await db.runAsync(
      `UPDATE ${this.tableName} SET ${setClause} WHERE id = ?`,
      [...(values as (string | number | null)[]), id]
    );
  }

  async delete(id: number): Promise<void> {
    const db = await getDatabase();
    await db.runAsync(`DELETE FROM ${this.tableName} WHERE id = ?`, [id]);
  }

  async softDelete(id: number): Promise<void> {
    const db = await getDatabase();
    await db.runAsync(
      `UPDATE ${this.tableName} SET deleted_at = datetime('now') WHERE id = ?`,
      [id]
    );
  }

  async deleteAll(userId?: number): Promise<void> {
    const db = await getDatabase();
    if (userId) {
      await db.runAsync(`DELETE FROM ${this.tableName} WHERE user_id = ?`, [userId]);
    } else {
      await db.runAsync(`DELETE FROM ${this.tableName}`);
    }
  }

  async count(userId?: number): Promise<number> {
    const db = await getDatabase();
    const where = userId ? ' WHERE user_id = ?' : '';
    const params = userId ? [userId] : [];
    const result = await db.getFirstAsync<{ count: number }>(
      `SELECT COUNT(*) as count FROM ${this.tableName}${where}`,
      params
    );
    return result?.count ?? 0;
  }

  async bulkUpsert(items: (Partial<T> & { id: number })[]): Promise<void> {
    const db = await getDatabase();
    await db.withTransactionAsync(async () => {
      for (const item of items) {
        await this.upsert(item);
      }
    });
  }
}
