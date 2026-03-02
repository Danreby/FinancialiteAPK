import React from 'react';
import { View, Text, TouchableOpacity, ActivityIndicator } from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import { useSyncStore } from '../../stores/syncStore';
import { formatRelativeDate } from '../../utils/date';

export function SyncIndicator() {
  const { status, lastSync, error } = useSyncStore();
  const isSyncing = status === 'syncing';

  if (isSyncing) {
    return (
      <View className="flex-row items-center px-3 py-1.5 bg-primary-50 dark:bg-primary-900/20 rounded-full">
        <ActivityIndicator size="small" color="#6366f1" />
        <Text className="text-xs text-primary-600 dark:text-primary-400 ml-2">
          Sincronizando...
        </Text>
      </View>
    );
  }

  if (error) {
    return (
      <TouchableOpacity
        onPress={() => useSyncStore.getState().sync()}
        className="flex-row items-center px-3 py-1.5 bg-danger-50 dark:bg-danger-900/20 rounded-full"
      >
        <Ionicons name="alert-circle" size={14} color="#ef4444" />
        <Text className="text-xs text-danger-600 dark:text-danger-400 ml-1.5">
          Erro na sincronização
        </Text>
      </TouchableOpacity>
    );
  }

  if (lastSync) {
    return (
      <TouchableOpacity
        onPress={() => useSyncStore.getState().sync()}
        className="flex-row items-center px-3 py-1.5"
      >
        <Ionicons name="checkmark-circle" size={14} color="#22c55e" />
        <Text className="text-xs text-dark-400 ml-1.5">
          {formatRelativeDate(lastSync)}
        </Text>
      </TouchableOpacity>
    );
  }

  return null;
}
