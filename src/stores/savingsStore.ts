import { create } from 'zustand';
import type { SavingsGoal, SavingsFormData } from '@/types';
import { SavingsGoalRepository } from '@/services/database/repositories';
import { syncEngine } from '@/services/sync/engine';
import { sanitizeObject } from '@/utils/sanitize';

interface SavingsState {
  goals: SavingsGoal[];
  summary: { total_target: number; total_saved: number; count: number };
  isLoading: boolean;
  error: string | null;
  load: (userId: number) => Promise<void>;
  create: (data: SavingsFormData, userId: number) => Promise<void>;
  update: (id: number, data: Partial<SavingsFormData>) => Promise<void>;
  remove: (id: number, userId: number) => Promise<void>;
  deposit: (id: number, amount: number, userId: number) => Promise<void>;
  withdraw: (id: number, amount: number, userId: number) => Promise<void>;
}

const repo = new SavingsGoalRepository();

export const useSavingsStore = create<SavingsState>((set, get) => ({
  goals: [],
  summary: { total_target: 0, total_saved: 0, count: 0 },
  isLoading: false,
  error: null,

  load: async (userId: number) => {
    set({ isLoading: true });
    try {
      const goals = await repo.getForUser(userId);
      const enriched = goals.map((g) => ({
        ...g,
        is_completed: !!g.completed_at,
        progress: g.target_amount > 0 ? Math.min((g.current_amount / g.target_amount) * 100, 100) : 0,
        remaining: Math.max(g.target_amount - g.current_amount, 0),
      })) as SavingsGoal[];
      const summary = await repo.getSummary(userId);
      set({ goals: enriched, summary, isLoading: false, error: null });
    } catch {
      set({ isLoading: false, error: 'Erro ao carregar metas' });
    }
  },

  create: async (data: SavingsFormData, userId: number) => {
    const sanitized = sanitizeObject(data as unknown as Record<string, unknown>);
    const now = new Date().toISOString();
    const tempId = Date.now();

    await repo.insert({
      id: tempId,
      ...sanitized,
      current_amount: 0,
      is_active: 1,
      user_id: userId,
      icon: data.icon || '💰',
      color: data.color || '#f43f5e',
      created_at: now,
      updated_at: now,
    } as Partial<SavingsGoal>);

    await syncEngine.enqueue('savings_goals', 'create', sanitized);
    await get().load(userId);
  },

  update: async (id: number, data: Partial<SavingsFormData>) => {
    const sanitized = sanitizeObject(data as unknown as Record<string, unknown>);
    await repo.update(id, { ...sanitized, updated_at: new Date().toISOString() } as Partial<SavingsGoal>);
    await syncEngine.enqueue('savings_goals', 'update', { id, ...sanitized });
    set((state) => ({
      goals: state.goals.map((g) => (g.id === id ? { ...g, ...sanitized } : g)),
    }));
  },

  remove: async (id: number, userId: number) => {
    await repo.softDelete(id);
    await syncEngine.enqueue('savings_goals', 'delete', { id });
    await get().load(userId);
  },

  deposit: async (id: number, amount: number, userId: number) => {
    const goal = get().goals.find((g) => g.id === id);
    if (!goal) return;
    const newAmount = goal.current_amount + amount;
    const completed = newAmount >= goal.target_amount;
    await repo.update(id, {
      current_amount: newAmount,
      completed_at: completed ? new Date().toISOString() : null,
      updated_at: new Date().toISOString(),
    } as Partial<SavingsGoal>);
    await syncEngine.enqueue('savings_goals', 'update', { id, action: 'deposit', amount });
    await get().load(userId);
  },

  withdraw: async (id: number, amount: number, userId: number) => {
    const goal = get().goals.find((g) => g.id === id);
    if (!goal) return;
    const newAmount = Math.max(goal.current_amount - amount, 0);
    await repo.update(id, {
      current_amount: newAmount,
      completed_at: null,
      updated_at: new Date().toISOString(),
    } as Partial<SavingsGoal>);
    await syncEngine.enqueue('savings_goals', 'update', { id, action: 'withdraw', amount });
    await get().load(userId);
  },
}));
