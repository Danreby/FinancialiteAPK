import { create } from 'zustand';
import type { User } from '@/types';
import { authApi } from '@/services/api/auth';
import { getToken, setToken, removeToken, setStoredUser, getStoredUser, removeStoredUser, clearAllStorage } from '@/services/storage/secure';
import { UserRepository } from '@/services/database/repositories';
import { clearDatabase } from '@/services/database/connection';
import { syncEngine } from '@/services/sync/engine';
import { sanitizeObject } from '@/utils/sanitize';

interface AuthState {
  user: User | null;
  isAuthenticated: boolean;
  isLoading: boolean;
  error: string | null;
  initialize: () => Promise<void>;
  login: (email: string, password: string) => Promise<void>;
  register: (name: string, email: string, password: string, phone?: string) => Promise<void>;
  logout: () => Promise<void>;
  refreshUser: () => Promise<void>;
  clearError: () => void;
}

const userRepo = new UserRepository();

export const useAuthStore = create<AuthState>((set, get) => ({
  user: null,
  isAuthenticated: false,
  isLoading: true,
  error: null,

  initialize: async () => {
    try {
      const token = await getToken();
      if (!token) {
        set({ isLoading: false, isAuthenticated: false });
        return;
      }

      const storedUser = await getStoredUser();
      if (storedUser) {
        const user = JSON.parse(storedUser) as User;
        set({ user, isAuthenticated: true, isLoading: false });
        syncEngine.start();
        return;
      }

      const response = await authApi.getUser();
      const user = response.data;
      await setStoredUser(JSON.stringify(user));
      await userRepo.upsert(user);
      set({ user, isAuthenticated: true, isLoading: false });
      syncEngine.start();
    } catch {
      await clearAllStorage();
      set({ user: null, isAuthenticated: false, isLoading: false });
    }
  },

  login: async (email: string, password: string) => {
    set({ isLoading: true, error: null });
    try {
      const response = await authApi.login({ email, password });
      const { user, token } = response.data;
      await setToken(token);
      await setStoredUser(JSON.stringify(user));
      await userRepo.upsert(user);
      set({ user, isAuthenticated: true, isLoading: false });
      syncEngine.start();
      syncEngine.trySync();
    } catch (error) {
      set({
        isLoading: false,
        error: error instanceof Error ? error.message : 'Erro ao fazer login',
      });
      throw error;
    }
  },

  register: async (name: string, email: string, password: string, phone?: string) => {
    set({ isLoading: true, error: null });
    try {
      const sanitized = sanitizeObject({ name, email, phone: phone || '' });
      const response = await authApi.register({
        name: sanitized.name,
        email: sanitized.email,
        password,
        password_confirmation: password,
        phone: sanitized.phone || undefined,
      });
      const { user, token } = response.data;
      await setToken(token);
      await setStoredUser(JSON.stringify(user));
      await userRepo.upsert(user);
      set({ user, isAuthenticated: true, isLoading: false });
      syncEngine.start();
    } catch (error) {
      set({
        isLoading: false,
        error: error instanceof Error ? error.message : 'Erro ao criar conta',
      });
      throw error;
    }
  },

  logout: async () => {
    try {
      await authApi.logout();
    } catch {
      // Continue logout even if API fails
    }
    syncEngine.stop();
    await clearAllStorage();
    await clearDatabase();
    set({ user: null, isAuthenticated: false, isLoading: false, error: null });
  },

  refreshUser: async () => {
    try {
      const response = await authApi.getUser();
      const user = response.data;
      await setStoredUser(JSON.stringify(user));
      await userRepo.upsert(user);
      set({ user });
    } catch {
      // Silent fail - use cached user
    }
  },

  clearError: () => set({ error: null }),
}));
