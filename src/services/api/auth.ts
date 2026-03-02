import { apiClient } from './client';
import type { AuthResponse, User } from '@/types';

export const authApi = {
  login(email: string, password: string): Promise<AuthResponse> {
    return apiClient.post<AuthResponse>('/auth/login', { email, password });
  },

  register(data: {
    name: string;
    email: string;
    password: string;
    password_confirmation: string;
    phone?: string;
  }): Promise<AuthResponse> {
    return apiClient.post<AuthResponse>('/auth/register', data);
  },

  logout(): Promise<{ message: string }> {
    return apiClient.post<{ message: string }>('/auth/logout');
  },

  getUser(): Promise<User> {
    return apiClient.get<User>('/auth/user');
  },

  refreshToken(): Promise<{ token: string }> {
    return apiClient.post<{ token: string }>('/auth/refresh-token');
  },
};
