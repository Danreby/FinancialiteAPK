import React from 'react';
import { View, Text, TouchableOpacity, StatusBar, Platform } from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import { useRouter } from 'expo-router';

interface HeaderProps {
  title: string;
  subtitle?: string;
  showBack?: boolean;
  rightAction?: {
    icon: keyof typeof Ionicons.glyphMap;
    onPress: () => void;
    badge?: number;
  };
  rightActions?: Array<{
    icon: keyof typeof Ionicons.glyphMap;
    onPress: () => void;
    badge?: number;
  }>;
  transparent?: boolean;
}

export function Header({
  title,
  subtitle,
  showBack = false,
  rightAction,
  rightActions,
  transparent = false,
}: HeaderProps) {
  const router = useRouter();
  const actions = rightActions || (rightAction ? [rightAction] : []);

  return (
    <View
      className={`${
        transparent ? '' : 'bg-white dark:bg-dark-900 border-b border-dark-200 dark:border-dark-700'
      }`}
      style={{ paddingTop: Platform.OS === 'ios' ? (StatusBar.currentHeight || 44) + 4 : 8 }}
    >
      <View className="flex-row items-center justify-between px-4 py-3">
        {/* Left */}
        <View className="flex-row items-center flex-1">
          {showBack && (
            <TouchableOpacity
              onPress={() => router.back()}
              className="mr-3 -ml-1"
              hitSlop={12}
            >
              <Ionicons name="arrow-back" size={24} color="#64748b" />
            </TouchableOpacity>
          )}
          <View className="flex-1">
            <Text
              className="text-xl font-bold text-dark-900 dark:text-dark-100"
              numberOfLines={1}
            >
              {title}
            </Text>
            {subtitle && (
              <Text className="text-xs text-dark-500 dark:text-dark-400 mt-0.5">
                {subtitle}
              </Text>
            )}
          </View>
        </View>

        {/* Right Actions */}
        {actions.length > 0 && (
          <View className="flex-row items-center gap-2 ml-3">
            {actions.map((action, index) => (
              <TouchableOpacity
                key={index}
                onPress={action.onPress}
                className="relative p-2"
                hitSlop={8}
              >
                <Ionicons name={action.icon} size={22} color="#64748b" />
                {action.badge !== undefined && action.badge > 0 && (
                  <View className="absolute -top-0.5 -right-0.5 bg-danger-500 rounded-full min-w-[18px] h-[18px] items-center justify-center px-1">
                    <Text className="text-[10px] font-bold text-white">
                      {action.badge > 99 ? '99+' : action.badge}
                    </Text>
                  </View>
                )}
              </TouchableOpacity>
            ))}
          </View>
        )}
      </View>
    </View>
  );
}
