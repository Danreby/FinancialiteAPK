import { apiClient } from './client';
import type { Income, IncomeFormData } from '@/types';

export const incomesApi = {
  list() {
    return apiClient.get<Income[]>('/incomes');
  },

  create(data: IncomeFormData) {
    return apiClient.post<Income>('/incomes', data as unknown as Record<string, unknown>);
  },

  update(id: number, data: Partial<IncomeFormData>) {
    return apiClient.put<Income>(`/incomes/${id}`, data as unknown as Record<string, unknown>);
  },

  delete(id: number) {
    return apiClient.delete(`/incomes/${id}`);
  },

  toggleActive(id: number) {
    return apiClient.patch(`/incomes/${id}/toggle`);
  },

  summary() {
    return apiClient.get<{ total_monthly: number }>('/incomes/summary');
  },
};
