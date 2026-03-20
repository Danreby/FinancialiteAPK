import { apiClient } from './client';
import type { Budget, BudgetFormData } from '@/types';

export const budgetsApi = {
  list() {
    return apiClient.get<Budget[]>('/budgets');
  },

  current() {
    return apiClient.get<Budget>('/budgets/current');
  },

  getOrCreateCurrent() {
    return apiClient.post<Budget>('/budgets/get-or-create-current');
  },

  create(data: BudgetFormData) {
    return apiClient.post<Budget>('/budgets', data as unknown as Record<string, unknown>);
  },

  update(id: number, data: Partial<BudgetFormData>) {
    return apiClient.put<Budget>(`/budgets/${id}`, data as unknown as Record<string, unknown>);
  },

  delete(id: number) {
    return apiClient.delete(`/budgets/${id}`);
  },
};
