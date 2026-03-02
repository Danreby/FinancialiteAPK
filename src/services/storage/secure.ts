import * as SecureStore from 'expo-secure-store';
import { CONFIG } from '@/constants/config';

export const SecureStorage = {
  async getToken(): Promise<string | null> {
    try {
      return await SecureStore.getItemAsync(CONFIG.STORAGE_KEYS.AUTH_TOKEN);
    } catch {
      return null;
    }
  },

  async setToken(token: string): Promise<void> {
    await SecureStore.setItemAsync(CONFIG.STORAGE_KEYS.AUTH_TOKEN, token);
  },

  async removeToken(): Promise<void> {
    await SecureStore.deleteItemAsync(CONFIG.STORAGE_KEYS.AUTH_TOKEN);
  },

  async getUserData(): Promise<string | null> {
    try {
      return await SecureStore.getItemAsync(CONFIG.STORAGE_KEYS.USER_DATA);
    } catch {
      return null;
    }
  },

  async setUserData(data: string): Promise<void> {
    await SecureStore.setItemAsync(CONFIG.STORAGE_KEYS.USER_DATA, data);
  },

  async removeUserData(): Promise<void> {
    await SecureStore.deleteItemAsync(CONFIG.STORAGE_KEYS.USER_DATA);
  },

  async getLastSync(): Promise<string | null> {
    try {
      return await SecureStore.getItemAsync(CONFIG.STORAGE_KEYS.LAST_SYNC);
    } catch {
      return null;
    }
  },

  async setLastSync(timestamp: string): Promise<void> {
    await SecureStore.setItemAsync(CONFIG.STORAGE_KEYS.LAST_SYNC, timestamp);
  },

  async clearAll(): Promise<void> {
    const keys = Object.values(CONFIG.STORAGE_KEYS);
    await Promise.all(keys.map((key) => SecureStore.deleteItemAsync(key)));
  },
};
