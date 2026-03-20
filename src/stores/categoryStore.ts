import { create } from 'zustand';
import type { Category, CategoryFormData } from '@/types';
import { CategoryRepository } from '@/services/database/repositories';
import { syncEngine } from '@/services/sync/engine';
import { sanitizeObject } from '@/utils/sanitize';

interface CategoryState {
  categories: Category[];
  isLoading: boolean;
  error: string | null;
  load: (userId: number, type?: string) => Promise<void>;
  create: (data: CategoryFormData, userId: number) => Promise<void>;
  update: (id: number, data: Partial<CategoryFormData>) => Promise<void>;
  remove: (id: number, userId: number) => Promise<void>;
}

const repo = new CategoryRepository();

export const useCategoryStore = create<CategoryState>((set, get) => ({
  categories: [],
  isLoading: false,
  error: null,

  load: async (userId: number, type?: string) => {
    set({ isLoading: true });
    try {
      const categories = await repo.getAllForUser(userId, type);
      set({ categories, isLoading: false, error: null });
    } catch {
      set({ isLoading: false, error: 'Erro ao carregar categorias' });
    }
  },

  create: async (data: CategoryFormData, userId: number) => {
    const sanitized = sanitizeObject(data as unknown as Record<string, unknown>);
    const now = new Date().toISOString();
    const tempId = Date.now();

    await repo.insert({
      id: tempId,
      ...sanitized,
      user_id: userId,
      created_at: now,
      updated_at: now,
    } as Partial<Category>);

    await syncEngine.enqueue('categories', 'create', sanitized);
    await get().load(userId);
  },

  update: async (id: number, data: Partial<CategoryFormData>) => {
    const sanitized = sanitizeObject(data as unknown as Record<string, unknown>);
    await repo.update(id, { ...sanitized, updated_at: new Date().toISOString() } as Partial<Category>);
    await syncEngine.enqueue('categories', 'update', { id, ...sanitized });
    set((state) => ({
      categories: state.categories.map((c) => (c.id === id ? { ...c, ...sanitized } : c)),
    }));
  },

  remove: async (id: number, userId: number) => {
    await repo.softDelete(id);
    await syncEngine.enqueue('categories', 'delete', { id });
    await get().load(userId);
  },
}));
