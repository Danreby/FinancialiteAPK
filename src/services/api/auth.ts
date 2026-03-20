import { apiClient } from './client';
import type { AuthResponse, User } from '@/types';

export const authApi = {
  register(data: { name: string; email: string; password: string; password_confirmation: string; phone?: string }) {
    return apiClient.post<AuthResponse>('/auth/register', data as unknown as Record<string, unknown>);
  },

  login(data: { email: string; password: string }) {
    return apiClient.post<AuthResponse>('/auth/login', data as unknown as Record<string, unknown>);
  },

  logout() {
    return apiClient.post('/auth/logout');
  },

  getUser() {
    return apiClient.get<User>('/auth/user');
  },

  refreshToken() {
    return apiClient.post<{ token: string }>('/auth/refresh-token');
  },
};
