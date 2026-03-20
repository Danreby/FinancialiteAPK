import { create } from 'zustand';
import type { Transacao, TransactionFormData, TransactionFilters } from '@/types';
import { TransactionRepository } from '@/services/database/repositories';
import { transactionsApi } from '@/services/api/transactions';
import { syncEngine } from '@/services/sync/engine';
import { sanitizeObject } from '@/utils/sanitize';
import { getMonthKey } from '@/utils/date';

interface TransactionState {
  transactions: Transacao[];
  isLoading: boolean;
  error: string | null;
  filters: TransactionFilters;
  monthlyStats: { total_credit: number; total_debit: number; count: number } | null;
  load: (userId: number) => Promise<void>;
  create: (data: TransactionFormData, userId: number) => Promise<void>;
  update: (id: number, data: Partial<TransactionFormData>) => Promise<void>;
  remove: (id: number) => Promise<void>;
  setFilters: (filters: Partial<TransactionFilters>) => void;
  loadStats: (userId: number, monthKey?: string) => Promise<void>;
  exportData: (params?: { bank_user_id?: number; category_id?: number }) => Promise<Record<string, unknown>>;
}

const repo = new TransactionRepository();

export const useTransactionStore = create<TransactionState>((set, get) => ({
  transactions: [],
  isLoading: false,
  error: null,
  filters: {},
  monthlyStats: null,

  load: async (userId: number) => {
    set({ isLoading: true });
    try {
      const transactions = await repo.getForUser(userId, get().filters);
      set({ transactions, isLoading: false, error: null });
    } catch {
      set({ isLoading: false, error: 'Erro ao carregar transações' });
    }
  },

  create: async (data: TransactionFormData, userId: number) => {
    const sanitized = sanitizeObject(data as unknown as Record<string, unknown>);
    const now = new Date().toISOString();
    const tempId = Date.now();

    const localItem: Partial<Transacao> = {
      id: tempId,
      ...sanitized,
      user_id: userId,
      status: data.status || 'unpaid',
      total_installments: data.total_installments || 1,
      is_recurring: data.is_recurring || false,
      created_at: now,
      updated_at: now,
    };

    await repo.insert(localItem);
    await syncEngine.enqueue('transacoes', 'create', { ...sanitized, _temp_id: tempId });
    await get().load(userId);
  },

  update: async (id: number, data: Partial<TransactionFormData>) => {
    const sanitized = sanitizeObject(data as unknown as Record<string, unknown>);
    await repo.update(id, { ...sanitized, updated_at: new Date().toISOString() } as Partial<Transacao>);
    await syncEngine.enqueue('transacoes', 'update', { id, ...sanitized });

    set((state) => ({
      transactions: state.transactions.map((t) =>
        t.id === id ? { ...t, ...sanitized } : t
      ),
    }));
  },

  remove: async (id: number) => {
    await repo.softDelete(id);
    await syncEngine.enqueue('transacoes', 'delete', { id });
    set((state) => ({
      transactions: state.transactions.filter((t) => t.id !== id),
    }));
  },

  setFilters: (filters: Partial<TransactionFilters>) => {
    set((state) => ({ filters: { ...state.filters, ...filters } }));
  },

  loadStats: async (userId: number, monthKey?: string) => {
    const mk = monthKey || getMonthKey();
    const stats = await repo.getMonthlyStats(userId, mk);
    set({ monthlyStats: stats });
  },

  exportData: async (params?: { bank_user_id?: number; category_id?: number }) => {
    const response = await transactionsApi.export(params);
    return response.data;
  },
}));
