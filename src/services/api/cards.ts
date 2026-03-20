import { apiClient } from './client';
import type { CardUser, CardFormData, Card } from '@/types';

export const cardsApi = {
  list() {
    return apiClient.get<CardUser[]>('/cards');
  },

  create(data: CardFormData) {
    return apiClient.post<CardUser>('/cards', data as unknown as Record<string, unknown>);
  },

  update(id: number, data: Partial<CardFormData>) {
    return apiClient.put<CardUser>(`/cards/${id}`, data as unknown as Record<string, unknown>);
  },

  delete(id: number) {
    return apiClient.delete(`/cards/${id}`);
  },

  availableCards() {
    return apiClient.get<Card[]>('/cards/available');
  },
};
