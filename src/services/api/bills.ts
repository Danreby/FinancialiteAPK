import { apiClient } from './client';
import type { Bill, BillFormData } from '@/types';

export const billsApi = {
  list() {
    return apiClient.get<Bill[]>('/bills');
  },

  create(data: BillFormData) {
    return apiClient.post<Bill>('/bills', data as unknown as Record<string, unknown>);
  },

  update(id: number, data: Partial<BillFormData>) {
    return apiClient.put<Bill>(`/bills/${id}`, data as unknown as Record<string, unknown>);
  },

  delete(id: number) {
    return apiClient.delete(`/bills/${id}`);
  },

  upcoming(days = 30) {
    return apiClient.get<Bill[]>('/bills/upcoming', { days });
  },

  markAsPaid(id: number, data?: { amount_paid?: number; notes?: string }) {
    return apiClient.post(`/bills/${id}/pay`, data as unknown as Record<string, unknown>);
  },

  toggleStatus(id: number) {
    return apiClient.patch(`/bills/${id}/toggle`);
  },
};
