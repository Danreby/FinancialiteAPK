import { apiClient } from './client';
import type { DashboardData } from '@/types';

export const dashboardApi = {
  get(params?: { bank_user_id?: number; category_id?: number; month?: string }) {
    return apiClient.get<DashboardData>('/dashboard', params as Record<string, string | number | undefined>);
  },
};
