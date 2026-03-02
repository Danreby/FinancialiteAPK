import { apiClient } from './client';
import type { DashboardData } from '@/types';

export const dashboardApi = {
  getData(params?: {
    bank_user_id?: number;
    category_id?: number;
    page?: number;
    month?: string;
    year?: string;
  }): Promise<DashboardData> {
    return apiClient.get<DashboardData>('/dashboard', { params });
  },
};
