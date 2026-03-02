import { create } from 'zustand';
import type { User } from '@/types';
import { authApi } from '@/services/api/auth';
import { SecureStorage } from '@/services/storage/secure';
import { clearDatabase } from '@/services/database';
import { ApiClientError } from '@/services/api/client';

interface AuthState {
  user: User | null;
  isAuthenticated: boolean;
  isLoading: boolean;
  isInitialized: boolean;
  error: string | null;

  initialize: () => Promise<void>;
  login: (email: string, password: string) => Promise<boolean>;
  register: (data: { name: string; email: string; password: string; password_confirmation: string; phone?: string }) => Promise<boolean>;
  logout: () => Promise<void>;
  updateUser: (user: Partial<User>) => void;
  clearError: () => void;
}

export const useAuthStore = create<AuthState>((set, get) => ({
  user: null,
  isAuthenticated: false,
  isLoading: false,
  isInitialized: false,
  error: null,

  initialize: async () => {
    try {
      const token = await SecureStorage.getToken();
      if (!token) {
        set({ isInitialized: true, isAuthenticated: false });
        return;
      }

      const userData = await SecureStorage.getUserData();
      if (userData) {
        const user = JSON.parse(userData) as User;
        set({ user, isAuthenticated: true, isInitialized: true });
      }

      // Validate token with server (non-blocking)
      try {
        const freshUser = await authApi.getUser();
        await SecureStorage.setUserData(JSON.stringify(freshUser));
        set({ user: freshUser, isAuthenticated: true, isInitialized: true });
      } catch {
        // Token invalid - keep offline data but mark as need re-auth on next sync
        if (!userData) {
          await SecureStorage.removeToken();
          set({ isAuthenticated: false, isInitialized: true });
        } else {
          set({ isInitialized: true });
        }
      }
    } catch {
      set({ isInitialized: true, isAuthenticated: false });
    }
  },

  login: async (email, password) => {
    set({ isLoading: true, error: null });
    try {
      const response = await authApi.login(email, password);
      await SecureStorage.setToken(response.token);
      await SecureStorage.setUserData(JSON.stringify(response.user));
      set({ user: response.user, isAuthenticated: true, isLoading: false });
      return true;
    } catch (error) {
      const message = error instanceof ApiClientError
        ? error.data && typeof error.data === 'object' && 'errors' in error.data
          ? Object.values((error.data as { errors: Record<string, string[]> }).errors).flat().join('\n')
          : error.message
        : 'Erro ao fazer login. Tente novamente.';
      set({ isLoading: false, error: message });
      return false;
    }
  },

  register: async (data) => {
    set({ isLoading: true, error: null });
    try {
      const response = await authApi.register(data);
      await SecureStorage.setToken(response.token);
      await SecureStorage.setUserData(JSON.stringify(response.user));
      set({ user: response.user, isAuthenticated: true, isLoading: false });
      return true;
    } catch (error) {
      const message = error instanceof ApiClientError
        ? error.data && typeof error.data === 'object' && 'errors' in error.data
          ? Object.values((error.data as { errors: Record<string, string[]> }).errors).flat().join('\n')
          : error.message
        : 'Erro ao criar conta. Tente novamente.';
      set({ isLoading: false, error: message });
      return false;
    }
  },

  logout: async () => {
    try {
      await authApi.logout();
    } catch {
      // Ignore server errors on logout
    }
    await SecureStorage.clearAll();
    await clearDatabase();
    set({ user: null, isAuthenticated: false, error: null });
  },

  updateUser: (updates) => {
    const current = get().user;
    if (current) {
      const updated = { ...current, ...updates };
      set({ user: updated });
      SecureStorage.setUserData(JSON.stringify(updated));
    }
  },

  clearError: () => set({ error: null }),
}));
