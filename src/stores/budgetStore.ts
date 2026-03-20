import { create } from 'zustand';
import type { Budget, BudgetFormData, BudgetCategory } from '@/types';
import { BudgetRepository, BudgetCategoryRepository } from '@/services/database/repositories';
import { syncEngine } from '@/services/sync/engine';
import { getMonthKey } from '@/utils/date';

interface BudgetState {
  budgets: Budget[];
  currentBudget: Budget | null;
  categoryLimits: (BudgetCategory & { category_name?: string; category_color?: string })[];
  isLoading: boolean;
  error: string | null;
  load: (userId: number) => Promise<void>;
  loadCurrent: (userId: number) => Promise<void>;
  create: (data: BudgetFormData, userId: number) => Promise<void>;
  update: (id: number, data: Partial<BudgetFormData>) => Promise<void>;
  remove: (id: number, userId: number) => Promise<void>;
}

const budgetRepo = new BudgetRepository();
const budgetCatRepo = new BudgetCategoryRepository();

export const useBudgetStore = create<BudgetState>((set, get) => ({
  budgets: [],
  currentBudget: null,
  categoryLimits: [],
  isLoading: false,
  error: null,

  load: async (userId: number) => {
    set({ isLoading: true });
    try {
      const budgets = await budgetRepo.getAll(userId);
      set({ budgets, isLoading: false, error: null });
    } catch {
      set({ isLoading: false, error: 'Erro ao carregar orçamentos' });
    }
  },

  loadCurrent: async (userId: number) => {
    const monthYear = getMonthKey();
    const budget = await budgetRepo.getCurrentForUser(userId, monthYear);
    if (budget) {
      const limits = await budgetRepo.getCategoryLimits(budget.id);
      set({ currentBudget: budget, categoryLimits: limits });
    } else {
      set({ currentBudget: null, categoryLimits: [] });
    }
  },

  create: async (data: BudgetFormData, userId: number) => {
    const now = new Date().toISOString();
    const tempId = Date.now();

    await budgetRepo.insert({
      id: tempId,
      monthly_limit: data.monthly_limit,
      month_year: data.month_year,
      is_active: data.is_active ?? true ? 1 : 0,
      user_id: userId,
      created_at: now,
      updated_at: now,
    } as unknown as Partial<Budget>);

    if (data.category_limits) {
      for (const cl of data.category_limits) {
        await budgetCatRepo.insert({
          id: Date.now() + Math.random(),
          budget_id: tempId,
          category_id: cl.category_id,
          limit: cl.limit,
          created_at: now,
          updated_at: now,
        } as unknown as Partial<BudgetCategory>);
      }
    }

    await syncEngine.enqueue('budgets', 'create', data as unknown as Record<string, unknown>);
    await get().load(userId);
    await get().loadCurrent(userId);
  },

  update: async (id: number, data: Partial<BudgetFormData>) => {
    await budgetRepo.update(id, { ...data, updated_at: new Date().toISOString() } as Partial<Budget>);
    await syncEngine.enqueue('budgets', 'update', { id, ...data } as Record<string, unknown>);
    set((state) => ({
      budgets: state.budgets.map((b) => (b.id === id ? { ...b, ...data } : b)),
      currentBudget: state.currentBudget?.id === id ? { ...state.currentBudget, ...data } : state.currentBudget,
    }));
  },

  remove: async (id: number, userId: number) => {
    await budgetRepo.delete(id);
    await syncEngine.enqueue('budgets', 'delete', { id });
    await get().load(userId);
    await get().loadCurrent(userId);
  },
}));
