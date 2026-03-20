import { apiClient } from './client';
import type { SavingsGoal, SavingsFormData } from '@/types';

export const savingsApi = {
  list() {
    return apiClient.get<SavingsGoal[]>('/savings');
  },

  create(data: SavingsFormData) {
    return apiClient.post<SavingsGoal>('/savings', data as unknown as Record<string, unknown>);
  },

  update(id: number, data: Partial<SavingsFormData>) {
    return apiClient.put<SavingsGoal>(`/savings/${id}`, data as unknown as Record<string, unknown>);
  },

  delete(id: number) {
    return apiClient.delete(`/savings/${id}`);
  },

  deposit(id: number, amount: number) {
    return apiClient.post(`/savings/${id}/deposit`, { amount });
  },

  withdraw(id: number, amount: number) {
    return apiClient.post(`/savings/${id}/withdraw`, { amount });
  },

  summary() {
    return apiClient.get<{ total_target: number; total_saved: number; count: number }>('/savings/summary');
  },
};
