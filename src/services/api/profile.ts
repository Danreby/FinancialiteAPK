import { apiClient } from './client';
import type { User } from '@/types';

export const profileApi = {
  get() {
    return apiClient.get<User>('/profile');
  },

  update(data: { name?: string; email?: string; phone?: string }) {
    return apiClient.patch<User>('/profile', data as unknown as Record<string, unknown>);
  },

  updateTheme(theme: string) {
    return apiClient.patch<User>('/profile/theme', { theme });
  },

  updatePassword(data: { current_password: string; password: string; password_confirmation: string }) {
    return apiClient.patch('/profile/password', data as unknown as Record<string, unknown>);
  },

  delete(password: string) {
    return apiClient.request('/profile', { method: 'DELETE', body: { password } });
  },
};
