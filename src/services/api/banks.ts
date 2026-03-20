import { apiClient } from './client';
import type { BankUser, BankTransfer, BankFormData, Bank } from '@/types';

export const banksApi = {
  list() {
    return apiClient.get<BankUser[]>('/bank-accounts');
  },

  get(id: number) {
    return apiClient.get<BankUser>(`/bank-accounts/${id}`);
  },

  create(data: BankFormData) {
    return apiClient.post<BankUser>('/bank-accounts', data as unknown as Record<string, unknown>);
  },

  update(id: number, data: Partial<BankFormData>) {
    return apiClient.put<BankUser>(`/bank-accounts/${id}`, data as unknown as Record<string, unknown>);
  },

  delete(id: number) {
    return apiClient.delete(`/bank-accounts/${id}`);
  },

  availableBanks() {
    return apiClient.get<Bank[]>('/bank-accounts/banks');
  },

  stats() {
    return apiClient.get<{ total_balance: number; account_count: number }>('/bank-accounts/stats');
  },

  transfers(params?: { bank_user_id?: number }) {
    return apiClient.get<BankTransfer[]>('/bank-transfers', params as Record<string, string | number | undefined>);
  },

  transfer(data: { from_bank_user_id: number; to_bank_user_id: number; amount: number; description?: string }) {
    return apiClient.post<BankTransfer>('/bank-transfers', data as unknown as Record<string, unknown>);
  },
};
