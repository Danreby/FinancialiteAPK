import { apiClient } from './client';
import type { Card, CardUser, CardFormData } from '@/types';

export interface CardUserStats {
  card_user_id: number;
  card_id: number;
  card_name: string;
  total_faturas: number;
  paid_faturas: number;
  unpaid_faturas: number;
  overdue_faturas: number;
  total_amount: number;
  income_amount: number;
  expense_amount: number;
}

export const cardResourcesApi = {
  list() {
    return apiClient.get<{ data: Card[] }>('/card-resources');
  },

  get(id: number) {
    return apiClient.get<Card>(`/card-resources/${id}`);
  },

  create(data: { name: string; brand?: string; description?: string; closing_day?: number; credit_limit?: number }) {
    return apiClient.post<Card>('/card-resources', data as unknown as Record<string, unknown>);
  },

  update(id: number, data: Partial<{ name: string; brand: string; description: string; closing_day: number; credit_limit: number }>) {
    return apiClient.put<Card>(`/card-resources/${id}`, data as unknown as Record<string, unknown>);
  },

  delete(id: number) {
    return apiClient.delete(`/card-resources/${id}`);
  },
};

export const cardUsersApi = {
  list() {
    return apiClient.get<{ data: CardUser[] }>('/card-users');
  },

  get(id: number) {
    return apiClient.get<CardUser>(`/card-users/${id}`);
  },

  create(data: { card_id: number; due_day?: number; closing_day?: number; credit_limit?: number }) {
    return apiClient.post<CardUser>('/card-users', data as unknown as Record<string, unknown>);
  },

  delete(id: number) {
    return apiClient.delete(`/card-users/${id}`);
  },

  stats() {
    return apiClient.get<CardUserStats[]>('/card-users/stats');
  },
};
