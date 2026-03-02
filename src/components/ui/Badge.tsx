import React from 'react';
import { View, Text } from 'react-native';

interface BadgeProps {
  label?: string;
  children?: React.ReactNode;
  variant?: 'default' | 'success' | 'warning' | 'danger' | 'info' | 'primary';
  size?: 'sm' | 'md';
}

export function Badge({ label, children, variant = 'default', size = 'sm' }: BadgeProps) {
  const variantClasses = {
    default: 'bg-dark-200 dark:bg-dark-600',
    success: 'bg-success-50 dark:bg-green-900/30',
    warning: 'bg-warning-50 dark:bg-yellow-900/30',
    danger: 'bg-danger-50 dark:bg-red-900/30',
    info: 'bg-blue-50 dark:bg-blue-900/30',
    primary: 'bg-primary-100 dark:bg-primary-900/30',
  };

  const textClasses = {
    default: 'text-dark-700 dark:text-dark-300',
    success: 'text-green-700 dark:text-green-400',
    warning: 'text-yellow-700 dark:text-yellow-400',
    danger: 'text-red-700 dark:text-red-400',
    info: 'text-blue-700 dark:text-blue-400',
    primary: 'text-primary-700 dark:text-primary-400',
  };

  const sizeClasses = {
    sm: 'px-2 py-0.5',
    md: 'px-3 py-1',
  };

  const textSize = size === 'sm' ? 'text-xs' : 'text-sm';

  return (
    <View className={`rounded-full ${variantClasses[variant]} ${sizeClasses[size]}`}>
      <Text className={`font-medium ${textClasses[variant]} ${textSize}`}>
        {children || label}
      </Text>
    </View>
  );
}
