import { create } from 'zustand';
import type { Income, IncomeFormData } from '@/types';
import { IncomeRepository } from '@/services/database/repositories';
import { syncEngine } from '@/services/sync/engine';
import { sanitizeObject } from '@/utils/sanitize';

interface IncomeState {
  incomes: Income[];
  totalMonthly: number;
  isLoading: boolean;
  error: string | null;
  load: (userId: number) => Promise<void>;
  create: (data: IncomeFormData, userId: number) => Promise<void>;
  update: (id: number, data: Partial<IncomeFormData>) => Promise<void>;
  remove: (id: number, userId: number) => Promise<void>;
  toggleActive: (id: number, userId: number) => Promise<void>;
}

const repo = new IncomeRepository();

export const useIncomeStore = create<IncomeState>((set, get) => ({
  incomes: [],
  totalMonthly: 0,
  isLoading: false,
  error: null,

  load: async (userId: number) => {
    set({ isLoading: true });
    try {
      const incomes = await repo.getForUser(userId);
      const total = await repo.getTotalMonthly(userId);
      set({ incomes, totalMonthly: total, isLoading: false, error: null });
    } catch {
      set({ isLoading: false, error: 'Erro ao carregar receitas' });
    }
  },

  create: async (data: IncomeFormData, userId: number) => {
    const sanitized = sanitizeObject(data as unknown as Record<string, unknown>);
    const now = new Date().toISOString();
    const tempId = Date.now();

    await repo.insert({
      id: tempId,
      ...sanitized,
      user_id: userId,
      is_active: 1,
      created_at: now,
      updated_at: now,
    } as Partial<Income>);

    await syncEngine.enqueue('incomes', 'create', sanitized);
    await get().load(userId);
  },

  update: async (id: number, data: Partial<IncomeFormData>) => {
    const sanitized = sanitizeObject(data as unknown as Record<string, unknown>);
    await repo.update(id, { ...sanitized, updated_at: new Date().toISOString() } as Partial<Income>);
    await syncEngine.enqueue('incomes', 'update', { id, ...sanitized });
    set((state) => ({
      incomes: state.incomes.map((i) => (i.id === id ? { ...i, ...sanitized } : i)),
    }));
  },

  remove: async (id: number, userId: number) => {
    await repo.softDelete(id);
    await syncEngine.enqueue('incomes', 'delete', { id });
    await get().load(userId);
  },

  toggleActive: async (id: number, userId: number) => {
    const income = get().incomes.find((i) => i.id === id);
    if (!income) return;
    const newActive = !income.is_active;
    await repo.update(id, { is_active: newActive ? 1 : 0, updated_at: new Date().toISOString() } as unknown as Partial<Income>);
    await syncEngine.enqueue('incomes', 'update', { id, is_active: newActive });
    await get().load(userId);
  },
}));
