import { DarkTheme, DefaultTheme, ThemeProvider } from '@react-navigation/native';
import { Stack } from 'expo-router';
import React, { useEffect } from 'react';
import { useColorScheme, StatusBar } from 'react-native';
import { SafeAreaProvider } from 'react-native-safe-area-context';
import { useAuthStore } from '@/stores/authStore';
import { useSyncStore, startAutoSync, stopAutoSync } from '@/stores/syncStore';
import { getDatabase } from '@/services/database';
import { Loading } from '@/components/ui/Loading';
import { NetworkBanner } from '@/components/common/NetworkBanner';
import '../global.css';

export default function RootLayout() {
  const colorScheme = useColorScheme();
  const { isInitialized, initialize, isAuthenticated } = useAuthStore();
  const { checkConnection } = useSyncStore();

  useEffect(() => {
    async function boot() {
      await getDatabase();
      await initialize();
      await checkConnection();
    }
    boot();
  }, []);

  useEffect(() => {
    if (isAuthenticated) {
      startAutoSync();
    } else {
      stopAutoSync();
    }
    return () => stopAutoSync();
  }, [isAuthenticated]);

  if (!isInitialized) {
    return <Loading fullScreen message="Carregando..." />;
  }

  return (
    <SafeAreaProvider>
      <ThemeProvider value={colorScheme === 'dark' ? DarkTheme : DefaultTheme}>
        <StatusBar
          barStyle={colorScheme === 'dark' ? 'light-content' : 'dark-content'}
          backgroundColor="transparent"
          translucent
        />
        <NetworkBanner />
        <Stack screenOptions={{ headerShown: false, animation: 'slide_from_right' }}>
          <Stack.Screen name="index" />
          <Stack.Screen name="(auth)" options={{ animation: 'fade' }} />
          <Stack.Screen name="(tabs)" options={{ animation: 'fade' }} />
        </Stack>
      </ThemeProvider>
    </SafeAreaProvider>
  );
}
