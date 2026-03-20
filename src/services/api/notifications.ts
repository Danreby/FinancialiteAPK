import { apiClient } from './client';
import type { Notification } from '@/types';

export const notificationsApi = {
  list() {
    return apiClient.get<Notification[]>('/notifications');
  },

  unreadCount() {
    return apiClient.get<{ count: number }>('/notifications/unread-count');
  },

  markAsRead(id: number) {
    return apiClient.patch(`/notifications/${id}/read`);
  },

  markAllAsRead() {
    return apiClient.post('/notifications/mark-all-read');
  },

  clearAll() {
    return apiClient.delete('/notifications/clear-all');
  },
};
