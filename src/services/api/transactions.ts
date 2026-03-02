import { apiClient } from './client';
import type { Transacao, PaginatedResponse, DashboardStats, FinancialInsights } from '@/types';

export const transacoesApi = {
  list(params?: {
    bank_user_id?: number;
    category_id?: number;
    per_page?: number;
    page?: number;
    month?: string | number;
    year?: string | number;
    type?: 'credit' | 'debit';
  }): Promise<PaginatedResponse<Transacao>> {
    return apiClient.get<PaginatedResponse<Transacao>>('/transacoes', { params });
  },

  show(id: number): Promise<Transacao> {
    return apiClient.get<Transacao>(`/transacoes/${id}`);
  },

  create(data: {
    title: string;
    amount: number;
    type: 'credit' | 'debit';
    description?: string;
    status?: string;
    paid_date?: string;
    total_installments?: number;
    current_installment?: number;
    is_recurring?: boolean;
    bank_user_id?: number;
    category_id?: number;
  }): Promise<Transacao> {
    return apiClient.post<Transacao>('/transacoes', data);
  },

  update(id: number, data: Partial<{
    title: string;
    amount: number;
    type: 'credit' | 'debit';
    description: string;
    status: string;
    paid_date: string;
    total_installments: number;
    current_installment: number;
    is_recurring: boolean;
    bank_user_id: number | null;
    category_id: number | null;
  }>): Promise<Transacao> {
    return apiClient.put<Transacao>(`/transacoes/${id}`, data);
  },

  delete(id: number): Promise<{ message: string }> {
    return apiClient.delete<{ message: string }>(`/transacoes/${id}`);
  },

  restore(id: number): Promise<{ message: string; transacao: Transacao }> {
    return apiClient.post<{ message: string; transacao: Transacao }>(`/transacoes/${id}/restore`);
  },

  stats(params?: { bank_user_id?: number; category_id?: number; month?: string | number; year?: string | number }): Promise<DashboardStats> {
    return apiClient.get<DashboardStats>('/transacoes/stats', { params });
  },

  insights(params?: { bank_user_id?: number }): Promise<FinancialInsights> {
    return apiClient.get<FinancialInsights>('/transacoes/insights', { params });
  },

  topSpending(params: {
    month_from: string;
    month_to: string;
    bank_user_id?: number;
    category_id?: number;
  }): Promise<unknown> {
    return apiClient.get('/transacoes/top-spending', { params });
  },

  payMonth(data: {
    month: string;
    bank_user_id?: number;
    bank_account_id: number;
  }): Promise<{ message: string; total_paid?: number }> {
    return apiClient.post('/transacoes/pay-month', data);
  },
};
