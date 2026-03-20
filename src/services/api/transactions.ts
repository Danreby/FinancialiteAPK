import { apiClient } from './client';
import type { Transacao, TransactionFormData, TransactionFilters } from '@/types';

export const transactionsApi = {
  list(filters?: TransactionFilters) {
    return apiClient.get<{ data: Transacao[] }>('/transacoes', filters as Record<string, string | number | undefined>);
  },

  get(id: number) {
    return apiClient.get<Transacao>(`/transacoes/${id}`);
  },

  create(data: TransactionFormData) {
    return apiClient.post<Transacao>('/transacoes', data as unknown as Record<string, unknown>);
  },

  update(id: number, data: Partial<TransactionFormData>) {
    return apiClient.put<Transacao>(`/transacoes/${id}`, data as unknown as Record<string, unknown>);
  },

  delete(id: number) {
    return apiClient.delete(`/transacoes/${id}`);
  },

  restore(id: number) {
    return apiClient.post(`/transacoes/${id}/restore`);
  },

  stats(params?: { bank_user_id?: number; month?: string }) {
    return apiClient.get<Record<string, unknown>>('/transacoes/stats', params as Record<string, string | number | undefined>);
  },

  insights(params?: { bank_user_id?: number }) {
    return apiClient.get<Record<string, unknown>>('/transacoes/insights', params as Record<string, string | number | undefined>);
  },

  topSpending(params?: { month_from: string; month_to: string; bank_user_id?: number; category_id?: number }) {
    return apiClient.get<Record<string, unknown>>('/transacoes/top-spending', params as Record<string, string | number | undefined>);
  },

  payMonth(data: { month_key: string; bank_user_id?: number; bank_account_id?: number }) {
    return apiClient.post('/transacoes/pay-month', data as unknown as Record<string, unknown>);
  },

  export(params?: { bank_user_id?: number; category_id?: number }) {
    return apiClient.get<Record<string, unknown>>('/transacoes/export', params as Record<string, string | number | undefined>);
  },
};
