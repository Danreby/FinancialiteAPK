import { apiClient } from './client';
import type { Income } from '@/types';

export const incomesApi = {
  list(): Promise<Income[]> {
    return apiClient.get<Income[]>('/incomes');
  },

  create(data: {
    title: string;
    amount: number;
    type: string;
    description?: string;
    is_recurring?: boolean;
    payment_day_type?: string;
    payment_day_value?: number;
    received_at?: string;
    bank_user_id?: number;
    bank_account_id?: number;
  }): Promise<Income> {
    return apiClient.post<Income>('/incomes', data);
  },

  update(id: number, data: Partial<{
    title: string;
    amount: number;
    type: string;
    description: string;
    is_recurring: boolean;
    payment_day_type: string;
    payment_day_value: number;
    received_at: string;
    bank_user_id: number | null;
    bank_account_id: number | null;
  }>): Promise<Income> {
    return apiClient.put<Income>(`/incomes/${id}`, data);
  },

  delete(id: number): Promise<{ message: string }> {
    return apiClient.delete<{ message: string }>(`/incomes/${id}`);
  },

  toggleActive(id: number): Promise<Income> {
    return apiClient.patch<Income>(`/incomes/${id}/toggle`);
  },

  summary(): Promise<{ total_monthly_income: number }> {
    return apiClient.get<{ total_monthly_income: number }>('/incomes/summary');
  },
};
