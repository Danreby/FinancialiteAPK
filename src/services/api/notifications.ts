import { apiClient } from './client';
import type { AppNotification, PaginatedResponse } from '@/types';

export const notificationsApi = {
  list(page = 1, perPage = 20): Promise<PaginatedResponse<AppNotification>> {
    return apiClient.get<PaginatedResponse<AppNotification>>('/notifications', {
      params: { page, per_page: perPage },
    });
  },

  unreadCount(): Promise<{ count: number }> {
    return apiClient.get<{ count: number }>('/notifications/unread-count');
  },

  markAsRead(id: number): Promise<AppNotification> {
    return apiClient.patch<AppNotification>(`/notifications/${id}/read`);
  },

  markAllAsRead(): Promise<{ message: string }> {
    return apiClient.post<{ message: string }>('/notifications/mark-all-read');
  },

  clearAll(): Promise<{ message: string }> {
    return apiClient.delete<{ message: string }>('/notifications/clear-all');
  },
};
