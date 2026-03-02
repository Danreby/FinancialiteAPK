import { apiClient } from './client';
import type { User, CardUser, Card } from '@/types';

export const profileApi = {
  show(): Promise<User> {
    return apiClient.get<User>('/profile');
  },

  update(data: { name?: string; email?: string; phone?: string }): Promise<User> {
    return apiClient.patch<User>('/profile', data);
  },

  updateTheme(theme: string): Promise<{ theme: string }> {
    return apiClient.patch<{ theme: string }>('/profile/theme', { theme });
  },

  updatePassword(data: {
    current_password: string;
    password: string;
    password_confirmation: string;
  }): Promise<{ message: string }> {
    return apiClient.patch<{ message: string }>('/profile/password', data);
  },

  deleteAccount(password?: string): Promise<{ message: string }> {
    return apiClient.delete<{ message: string }>('/profile', password ? { password } : undefined);
  },
};

export const cardsApi = {
  list(): Promise<CardUser[]> {
    return apiClient.get<CardUser[]>('/cards');
  },

  availableCards(): Promise<Card[]> {
    return apiClient.get<Card[]>('/cards/available');
  },

  create(data: {
    card_id: number;
    due_day?: number;
    closing_day?: number;
    credit_limit?: number;
  }): Promise<CardUser> {
    return apiClient.post<CardUser>('/cards', data);
  },

  update(id: number, data: {
    due_day?: number;
    closing_day?: number;
    credit_limit?: number;
  }): Promise<CardUser> {
    return apiClient.put<CardUser>(`/cards/${id}`, data);
  },

  delete(id: number): Promise<{ message: string }> {
    return apiClient.delete<{ message: string }>(`/cards/${id}`);
  },
};
