import { create } from 'zustand';
import type { Bill, BillFormData } from '@/types';
import { BillRepository } from '@/services/database/repositories';
import { syncEngine } from '@/services/sync/engine';
import { sanitizeObject } from '@/utils/sanitize';

interface BillState {
  bills: Bill[];
  isLoading: boolean;
  error: string | null;
  load: (userId: number) => Promise<void>;
  create: (data: BillFormData, userId: number) => Promise<void>;
  update: (id: number, data: Partial<BillFormData>) => Promise<void>;
  remove: (id: number, userId: number) => Promise<void>;
  toggleStatus: (id: number, userId: number) => Promise<void>;
}

const repo = new BillRepository();

export const useBillStore = create<BillState>((set, get) => ({
  bills: [],
  isLoading: false,
  error: null,

  load: async (userId: number) => {
    set({ isLoading: true });
    try {
      const bills = await repo.getForUser(userId);
      set({ bills, isLoading: false, error: null });
    } catch {
      set({ isLoading: false, error: 'Erro ao carregar contas' });
    }
  },

  create: async (data: BillFormData, userId: number) => {
    const sanitized = sanitizeObject(data as unknown as Record<string, unknown>);
    const now = new Date().toISOString();
    const tempId = Date.now();

    await repo.insert({
      id: tempId,
      ...sanitized,
      user_id: userId,
      status: 'active',
      created_at: now,
      updated_at: now,
    } as Partial<Bill>);

    await syncEngine.enqueue('bills', 'create', sanitized);
    await get().load(userId);
  },

  update: async (id: number, data: Partial<BillFormData>) => {
    const sanitized = sanitizeObject(data as unknown as Record<string, unknown>);
    await repo.update(id, { ...sanitized, updated_at: new Date().toISOString() } as Partial<Bill>);
    await syncEngine.enqueue('bills', 'update', { id, ...sanitized });
    set((state) => ({
      bills: state.bills.map((b) => (b.id === id ? { ...b, ...sanitized } : b)),
    }));
  },

  remove: async (id: number, userId: number) => {
    await repo.softDelete(id);
    await syncEngine.enqueue('bills', 'delete', { id });
    await get().load(userId);
  },

  toggleStatus: async (id: number, userId: number) => {
    const bill = get().bills.find((b) => b.id === id);
    if (!bill) return;
    const newStatus = bill.status === 'active' ? 'inactive' : 'active';
    await repo.update(id, { status: newStatus, updated_at: new Date().toISOString() });
    await syncEngine.enqueue('bills', 'update', { id, status: newStatus });
    await get().load(userId);
  },
}));
