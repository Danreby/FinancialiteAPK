import * as SecureStore from 'expo-secure-store';
import { CONFIG } from '@/constants/config';

export async function getToken(): Promise<string | null> {
  return SecureStore.getItemAsync(CONFIG.TOKEN_KEY);
}

export async function setToken(token: string): Promise<void> {
  await SecureStore.setItemAsync(CONFIG.TOKEN_KEY, token);
}

export async function removeToken(): Promise<void> {
  await SecureStore.deleteItemAsync(CONFIG.TOKEN_KEY);
}

export async function getStoredUser(): Promise<string | null> {
  return SecureStore.getItemAsync(CONFIG.USER_KEY);
}

export async function setStoredUser(userJson: string): Promise<void> {
  await SecureStore.setItemAsync(CONFIG.USER_KEY, userJson);
}

export async function removeStoredUser(): Promise<void> {
  await SecureStore.deleteItemAsync(CONFIG.USER_KEY);
}

export async function getStoredTheme(): Promise<string | null> {
  return SecureStore.getItemAsync(CONFIG.THEME_KEY);
}

export async function setStoredTheme(theme: string): Promise<void> {
  await SecureStore.setItemAsync(CONFIG.THEME_KEY, theme);
}

export async function clearAllStorage(): Promise<void> {
  await removeToken();
  await removeStoredUser();
  await SecureStore.deleteItemAsync(CONFIG.THEME_KEY);
}
