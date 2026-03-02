import { apiClient } from './client';
import type { BankUser, Bank, BankTransfer } from '@/types';

export const banksApi = {
  listAccounts(): Promise<BankUser[]> {
    return apiClient.get<BankUser[]>('/bank-accounts');
  },

  availableBanks(): Promise<Bank[]> {
    return apiClient.get<Bank[]>('/bank-accounts/banks');
  },

  stats(): Promise<unknown> {
    return apiClient.get('/bank-accounts/stats');
  },

  show(id: number): Promise<unknown> {
    return apiClient.get(`/bank-accounts/${id}`);
  },

  create(data: { bank_id: number; balance?: number }): Promise<BankUser> {
    return apiClient.post<BankUser>('/bank-accounts', data);
  },

  update(id: number, balance: number): Promise<BankUser> {
    return apiClient.put<BankUser>(`/bank-accounts/${id}`, { balance });
  },

  delete(id: number): Promise<{ message: string }> {
    return apiClient.delete<{ message: string }>(`/bank-accounts/${id}`);
  },

  transfer(data: {
    from_bank_user_id: number;
    to_bank_user_id: number;
    amount: number;
    description?: string;
  }): Promise<BankTransfer> {
    return apiClient.post<BankTransfer>('/bank-transfers', data);
  },

  listTransfers(bankUserId?: number): Promise<BankTransfer[]> {
    return apiClient.get<BankTransfer[]>('/bank-transfers', {
      params: bankUserId ? { bank_user_id: bankUserId } : undefined,
    });
  },
};
