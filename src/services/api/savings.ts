import { apiClient } from './client';
import type { SavingsGoal } from '@/types';

export const savingsApi = {
  list(): Promise<SavingsGoal[]> {
    return apiClient.get<SavingsGoal[]>('/savings');
  },

  create(data: {
    title: string;
    target_amount: number;
    description?: string;
    icon?: string;
    color?: string;
  }): Promise<SavingsGoal> {
    return apiClient.post<SavingsGoal>('/savings', data);
  },

  update(id: number, data: Partial<{
    title: string;
    target_amount: number;
    description: string;
    icon: string;
    color: string;
  }>): Promise<SavingsGoal> {
    return apiClient.put<SavingsGoal>(`/savings/${id}`, data);
  },

  delete(id: number): Promise<{ message: string }> {
    return apiClient.delete<{ message: string }>(`/savings/${id}`);
  },

  deposit(id: number, amount: number): Promise<SavingsGoal> {
    return apiClient.post<SavingsGoal>(`/savings/${id}/deposit`, { amount });
  },

  withdraw(id: number, amount: number): Promise<SavingsGoal> {
    return apiClient.post<SavingsGoal>(`/savings/${id}/withdraw`, { amount });
  },

  summary(): Promise<{
    total_saved: number;
    total_target: number;
    goals_count: number;
    completed_count: number;
  }> {
    return apiClient.get('/savings/summary');
  },
};
