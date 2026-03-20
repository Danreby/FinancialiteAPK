import { apiClient } from './client';
import type { Category, CategoryFormData } from '@/types';

export const categoriesApi = {
  list(type?: string) {
    return apiClient.get<Category[]>('/categories', type ? { type } : undefined);
  },

  create(data: CategoryFormData) {
    return apiClient.post<Category>('/categories', data as unknown as Record<string, unknown>);
  },

  update(id: number, data: Partial<CategoryFormData>) {
    return apiClient.put<Category>(`/categories/${id}`, data as unknown as Record<string, unknown>);
  },

  delete(id: number) {
    return apiClient.delete(`/categories/${id}`);
  },
};
