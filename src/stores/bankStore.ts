import { create } from 'zustand';
import type { BankUser, BankTransfer, Bank } from '@/types';
import { BankUserRepository, BankRepository, BankTransferRepository } from '@/services/database/repositories';
import { banksApi } from '@/services/api/banks';
import { syncEngine } from '@/services/sync/engine';

interface BankState {
  bankAccounts: (BankUser & { bank_name?: string })[];
  availableBanks: Bank[];
  transfers: BankTransfer[];
  totalBalance: number;
  isLoading: boolean;
  error: string | null;
  load: (userId: number) => Promise<void>;
  loadAvailableBanks: () => Promise<void>;
  create: (bankId: number, balance: number, userId: number) => Promise<void>;
  updateBalance: (id: number, balance: number) => Promise<void>;
  remove: (id: number, userId: number) => Promise<void>;
  transfer: (fromId: number, toId: number, amount: number, description: string, userId: number) => Promise<void>;
  loadTransfers: (userId: number) => Promise<void>;
}

const bankUserRepo = new BankUserRepository();
const bankRepo = new BankRepository();
const transferRepo = new BankTransferRepository();

export const useBankStore = create<BankState>((set, get) => ({
  bankAccounts: [],
  availableBanks: [],
  transfers: [],
  totalBalance: 0,
  isLoading: false,
  error: null,

  load: async (userId: number) => {
    set({ isLoading: true });
    try {
      const accounts = await bankUserRepo.getAllForUser(userId);
      const total = await bankUserRepo.getTotalBalance(userId);
      set({ bankAccounts: accounts, totalBalance: total, isLoading: false, error: null });
    } catch {
      set({ isLoading: false, error: 'Erro ao carregar contas' });
    }
  },

  loadAvailableBanks: async () => {
    try {
      const banks = await bankRepo.getAll();
      set({ availableBanks: banks });
    } catch {
      // Silent - use cached
    }
  },

  create: async (bankId: number, balance: number, userId: number) => {
    const now = new Date().toISOString();
    const tempId = Date.now();
    await bankUserRepo.insert({
      id: tempId,
      bank_id: bankId,
      user_id: userId,
      balance,
      created_at: now,
      updated_at: now,
    });
    await syncEngine.enqueue('bank_accounts', 'create', { bank_id: bankId, balance });
    await get().load(userId);
  },

  updateBalance: async (id: number, balance: number) => {
    await bankUserRepo.update(id, { balance, updated_at: new Date().toISOString() });
    await syncEngine.enqueue('bank_accounts', 'update', { id, balance });
    set((state) => ({
      bankAccounts: state.bankAccounts.map((a) =>
        a.id === id ? { ...a, balance } : a
      ),
      totalBalance: state.bankAccounts.reduce((sum, a) =>
        a.id === id ? sum + balance : sum + a.balance, 0
      ),
    }));
  },

  remove: async (id: number, userId: number) => {
    await bankUserRepo.delete(id);
    await syncEngine.enqueue('bank_accounts', 'delete', { id });
    await get().load(userId);
  },

  transfer: async (fromId: number, toId: number, amount: number, description: string, userId: number) => {
    const now = new Date().toISOString();
    const fromAccount = get().bankAccounts.find((a) => a.id === fromId);
    const toAccount = get().bankAccounts.find((a) => a.id === toId);
    if (!fromAccount || !toAccount) return;

    await bankUserRepo.update(fromId, { balance: fromAccount.balance - amount, updated_at: now });
    await bankUserRepo.update(toId, { balance: toAccount.balance + amount, updated_at: now });

    const tempId = Date.now();
    await transferRepo.insert({
      id: tempId,
      user_id: userId,
      from_bank_user_id: fromId,
      to_bank_user_id: toId,
      amount,
      description,
      created_at: now,
      updated_at: now,
    });

    await syncEngine.enqueue('bank_transfers', 'create', {
      from_bank_user_id: fromId,
      to_bank_user_id: toId,
      amount,
      description,
    });

    await get().load(userId);
  },

  loadTransfers: async (userId: number, bankUserId?: number) => {
    const transfers = await transferRepo.getForUser(userId, bankUserId);
    set({ transfers: transfers as BankTransfer[] });
  },
}));
