import React from 'react';
import { View, Text, type ViewProps } from 'react-native';

interface CardProps extends ViewProps {
  title?: string;
  subtitle?: string;
  headerRight?: React.ReactNode;
  padding?: 'none' | 'sm' | 'md' | 'lg';
  variant?: 'default' | 'elevated' | 'outlined';
}

export function Card({
  title,
  subtitle,
  headerRight,
  padding = 'md',
  variant = 'default',
  children,
  className = '',
  ...props
}: CardProps) {
  const paddingClasses = {
    none: '',
    sm: 'p-3',
    md: 'p-4',
    lg: 'p-5',
  };

  const variantClasses = {
    default: 'bg-white dark:bg-dark-800',
    elevated: 'bg-white dark:bg-dark-800 shadow-md',
    outlined: 'bg-white dark:bg-dark-800 border border-dark-200 dark:border-dark-700',
  };

  return (
    <View
      className={`rounded-2xl ${variantClasses[variant]} ${paddingClasses[padding]} ${className}`}
      {...props}
    >
      {(title || headerRight) && (
        <View className={`flex-row items-center justify-between ${padding === 'none' ? 'px-4 pt-4' : ''} ${children ? 'mb-3' : ''}`}>
          <View className="flex-1">
            {title && (
              <Text className="text-base font-semibold text-dark-900 dark:text-dark-100">
                {title}
              </Text>
            )}
            {subtitle && (
              <Text className="text-sm text-dark-500 dark:text-dark-400 mt-0.5">
                {subtitle}
              </Text>
            )}
          </View>
          {headerRight}
        </View>
      )}
      {children}
    </View>
  );
}
