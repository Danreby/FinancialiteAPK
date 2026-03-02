import React, { useEffect, useState, useCallback } from 'react';
import { View, Text, FlatList, RefreshControl, TouchableOpacity } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { Ionicons } from '@expo/vector-icons';
import { notificationsApi } from '@/services/api/notifications';
import { Header } from '@/components/ui/Header';
import { Loading } from '@/components/ui/Loading';
import { EmptyState } from '@/components/ui/EmptyState';
import { Button } from '@/components/ui/Button';
import { formatRelativeDate } from '@/utils/date';
import type { AppNotification } from '@/types';

export default function NotificationsScreen() {
  const [loading, setLoading] = useState(true);
  const [refreshing, setRefreshing] = useState(false);
  const [notifications, setNotifications] = useState<AppNotification[]>([]);
  const [unreadCount, setUnreadCount] = useState(0);

  const loadData = useCallback(async () => {
    try {
      const [data, count] = await Promise.all([
        notificationsApi.list(),
        notificationsApi.unreadCount().catch(() => ({ count: 0 })),
      ]);
      setNotifications(Array.isArray(data) ? data : (data as any)?.data || []);
      setUnreadCount(typeof count === 'number' ? count : (count as any)?.count || 0);
    } catch {}
    setLoading(false);
    setRefreshing(false);
  }, []);

  useEffect(() => { loadData(); }, [loadData]);

  const onRefresh = useCallback(async () => {
    setRefreshing(true);
    await loadData();
  }, [loadData]);

  const handleRead = useCallback(async (id: number) => {
    try {
      await notificationsApi.markAsRead(id);
      setNotifications((prev) =>
        prev.map((n) => n.id === id ? { ...n, is_read: true, read_at: new Date().toISOString() } : n)
      );
      setUnreadCount((c) => Math.max(0, c - 1));
    } catch {}
  }, []);

  const handleMarkAllRead = useCallback(async () => {
    try {
      await notificationsApi.markAllAsRead();
      setNotifications((prev) => prev.map((n) => ({ ...n, is_read: true, read_at: n.read_at || new Date().toISOString() })));
      setUnreadCount(0);
    } catch {}
  }, []);

  const handleClearAll = useCallback(async () => {
    try {
      await notificationsApi.clearAll();
      setNotifications([]);
      setUnreadCount(0);
    } catch {}
  }, []);

  const getIcon = (type?: AppNotification['type']): keyof typeof Ionicons.glyphMap => {
    switch (type) {
      case 'warning': return 'warning-outline';
      case 'error': return 'alert-circle-outline';
      case 'success': return 'checkmark-circle-outline';
      case 'security': return 'shield-outline';
      case 'info':
      default: return 'notifications-outline';
    }
  };

  if (loading) return <Loading fullScreen message="Carregando notificações..." />;

  return (
    <SafeAreaView className="flex-1 bg-dark-100 dark:bg-dark-950" edges={['top']}>
      <Header
        title="Notificações"
        showBack
        rightActions={[
          ...(unreadCount > 0 ? [{ icon: 'checkmark-done-outline' as keyof typeof Ionicons.glyphMap, onPress: handleMarkAllRead }] : []),
          ...(notifications.length > 0 ? [{ icon: 'trash-outline' as keyof typeof Ionicons.glyphMap, onPress: handleClearAll }] : []),
        ]}
      />

      {unreadCount > 0 && (
        <View className="px-5 py-2">
          <View className="bg-primary-50 dark:bg-primary-900/20 rounded-xl px-4 py-2">
            <Text className="text-xs text-primary-600 dark:text-primary-400">
              {unreadCount} {unreadCount === 1 ? 'notificação não lida' : 'notificações não lidas'}
            </Text>
          </View>
        </View>
      )}

      <FlatList
        data={notifications}
        keyExtractor={(item) => String(item.id)}
        contentContainerClassName="px-5 py-2"
        renderItem={({ item }) => {
          const isUnread = !item.is_read;
          return (
            <TouchableOpacity
              onPress={() => isUnread && handleRead(item.id)}
              className={`flex-row p-4 rounded-2xl mb-2 ${
                isUnread
                  ? 'bg-primary-50 dark:bg-primary-900/10 border border-primary-100 dark:border-primary-800'
                  : 'bg-white dark:bg-dark-800'
              }`}
              activeOpacity={0.7}
            >
              <View className={`w-10 h-10 rounded-full items-center justify-center mr-3 ${
                isUnread ? 'bg-primary-100 dark:bg-primary-800/40' : 'bg-dark-200 dark:bg-dark-700'
              }`}>
                <Ionicons
                  name={getIcon(item.type)}
                  size={20}
                  color={isUnread ? '#6366f1' : '#94a3b8'}
                />
              </View>
              <View className="flex-1">
                <Text className={`text-sm ${
                  isUnread
                    ? 'font-bold text-dark-900 dark:text-dark-100'
                    : 'font-medium text-dark-700 dark:text-dark-300'
                }`}>
                  {item.title}
                </Text>
                {item.message && (
                  <Text className="text-xs text-dark-500 dark:text-dark-400 mt-0.5" numberOfLines={2}>
                    {item.message}
                  </Text>
                )}
                <Text className="text-[10px] text-dark-400 mt-1">
                  {formatRelativeDate(item.created_at)}
                </Text>
              </View>
              {isUnread && (
                <View className="w-2.5 h-2.5 rounded-full bg-primary-500 ml-2 mt-1" />
              )}
            </TouchableOpacity>
          );
        }}
        ListEmptyComponent={
          <EmptyState
            icon="notifications-off-outline"
            title="Sem notificações"
            description="Você está em dia com tudo!"
          />
        }
        refreshControl={<RefreshControl refreshing={refreshing} onRefresh={onRefresh} tintColor="#6366f1" />}
        showsVerticalScrollIndicator={false}
      />
    </SafeAreaView>
  );
}
