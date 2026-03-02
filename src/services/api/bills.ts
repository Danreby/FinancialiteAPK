import { apiClient } from './client';
import type { Bill } from '@/types';

export const billsApi = {
  list(): Promise<Bill[]> {
    return apiClient.get<Bill[]>('/bills');
  },

  create(data: {
    title: string;
    amount?: number;
    recurrence_type: string;
    due_day: number;
    description?: string;
    start_date?: string;
    end_date?: string;
    color?: string;
    icon?: string;
    category_id?: number;
  }): Promise<Bill> {
    return apiClient.post<Bill>('/bills', data);
  },

  update(id: number, data: Partial<{
    title: string;
    amount: number;
    recurrence_type: string;
    due_day: number;
    description: string;
    start_date: string;
    end_date: string;
    color: string;
    icon: string;
    status: string;
    category_id: number | null;
  }>): Promise<Bill> {
    return apiClient.put<Bill>(`/bills/${id}`, data);
  },

  delete(id: number): Promise<{ message: string }> {
    return apiClient.delete<{ message: string }>(`/bills/${id}`);
  },

  upcoming(): Promise<Bill[]> {
    return apiClient.get<Bill[]>('/bills/upcoming');
  },

  markAsPaid(id: number, data?: { amount_paid?: number; notes?: string }): Promise<unknown> {
    return apiClient.post(`/bills/${id}/pay`, data);
  },

  toggleStatus(id: number): Promise<Bill> {
    return apiClient.patch<Bill>(`/bills/${id}/toggle`);
  },
};
