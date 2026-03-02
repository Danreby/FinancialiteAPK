import React from 'react';
import { View, ActivityIndicator, Text } from 'react-native';

interface LoadingProps {
  message?: string;
  fullScreen?: boolean;
  size?: 'small' | 'large';
  color?: string;
}

export function Loading({
  message,
  fullScreen = false,
  size = 'large',
  color = '#6366f1',
}: LoadingProps) {
  if (fullScreen) {
    return (
      <View className="flex-1 items-center justify-center bg-white dark:bg-dark-900">
        <ActivityIndicator size={size} color={color} />
        {message && (
          <Text className="mt-4 text-sm text-dark-500 dark:text-dark-400">
            {message}
          </Text>
        )}
      </View>
    );
  }

  return (
    <View className="items-center justify-center py-8">
      <ActivityIndicator size={size} color={color} />
      {message && (
        <Text className="mt-3 text-sm text-dark-500 dark:text-dark-400">
          {message}
        </Text>
      )}
    </View>
  );
}
