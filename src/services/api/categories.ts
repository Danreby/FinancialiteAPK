import { apiClient } from './client';
import type { Category } from '@/types';

export const categoriesApi = {
  list(): Promise<Category[]> {
    return apiClient.get<Category[]>('/categories');
  },

  create(data: {
    name: string;
    color?: string;
    icon?: string;
    type?: 'income' | 'expense';
  }): Promise<Category> {
    return apiClient.post<Category>('/categories', data);
  },

  update(id: number, data: Partial<{
    name: string;
    color: string;
    icon: string;
    type: 'income' | 'expense';
  }>): Promise<Category> {
    return apiClient.put<Category>(`/categories/${id}`, data);
  },

  delete(id: number): Promise<{ message: string }> {
    return apiClient.delete<{ message: string }>(`/categories/${id}`);
  },
};
