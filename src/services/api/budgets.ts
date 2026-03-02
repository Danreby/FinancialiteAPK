import { apiClient } from './client';
import type { Budget, BudgetWithSpending } from '@/types';

export const budgetsApi = {
  list(): Promise<BudgetWithSpending[]> {
    return apiClient.get<BudgetWithSpending[]>('/budgets');
  },

  current(): Promise<BudgetWithSpending | null> {
    return apiClient.get<BudgetWithSpending | null>('/budgets/current');
  },

  create(data: {
    monthly_limit: number;
    month_year: string;
    category_limits?: { category_id: number; limit: number }[];
  }): Promise<Budget> {
    return apiClient.post<Budget>('/budgets', data);
  },

  update(id: number, data: Partial<{
    monthly_limit: number;
    month_year: string;
    category_limits: { category_id: number; limit: number }[];
  }>): Promise<Budget> {
    return apiClient.put<Budget>(`/budgets/${id}`, data);
  },

  delete(id: number): Promise<{ message: string }> {
    return apiClient.delete<{ message: string }>(`/budgets/${id}`);
  },

  getOrCreateCurrent(): Promise<Budget> {
    return apiClient.post<Budget>('/budgets/get-or-create-current');
  },
};
