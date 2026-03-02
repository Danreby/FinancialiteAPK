import React from 'react';
import { TouchableOpacity, Text, ActivityIndicator, type TouchableOpacityProps, View } from 'react-native';
import { Ionicons } from '@expo/vector-icons';

interface ButtonProps extends TouchableOpacityProps {
  children?: React.ReactNode;
  title?: string;
  variant?: 'primary' | 'secondary' | 'outline' | 'danger' | 'ghost';
  size?: 'sm' | 'md' | 'lg';
  loading?: boolean;
  icon?: keyof typeof Ionicons.glyphMap | React.ReactNode;
  fullWidth?: boolean;
}

export function Button({
  children,
  title,
  variant = 'primary',
  size = 'md',
  loading = false,
  icon,
  fullWidth = false,
  disabled,
  className = '',
  ...props
}: ButtonProps) {
  const baseClasses = 'flex-row items-center justify-center rounded-xl';

  const variantClasses = {
    primary: 'bg-primary-600 active:bg-primary-700',
    secondary: 'bg-dark-700 active:bg-dark-600',
    outline: 'border-2 border-primary-500 bg-transparent active:bg-primary-50',
    danger: 'bg-danger-500 active:bg-danger-600',
    ghost: 'bg-transparent active:bg-dark-100',
  };

  const sizeClasses = {
    sm: 'px-3 py-2',
    md: 'px-5 py-3',
    lg: 'px-6 py-4',
  };

  const textVariantClasses = {
    primary: 'text-white',
    secondary: 'text-white',
    outline: 'text-primary-600',
    danger: 'text-white',
    ghost: 'text-primary-600',
  };

  const textSizeClasses = {
    sm: 'text-sm',
    md: 'text-base',
    lg: 'text-lg',
  };

  const iconColor = variant === 'outline' || variant === 'ghost' ? '#6366f1' : '#ffffff';
  const iconSize = size === 'sm' ? 16 : size === 'lg' ? 22 : 18;

  const isDisabled = disabled || loading;

  const displayText = title || (typeof children === 'string' ? children : null);
  const renderIcon = typeof icon === 'string'
    ? <Ionicons name={icon as keyof typeof Ionicons.glyphMap} size={iconSize} color={iconColor} />
    : icon;

  return (
    <TouchableOpacity
      className={`${baseClasses} ${variantClasses[variant]} ${sizeClasses[size]} ${fullWidth ? 'w-full' : ''} ${isDisabled ? 'opacity-50' : ''} ${className}`}
      disabled={isDisabled}
      activeOpacity={0.7}
      {...props}
    >
      {loading ? (
        <ActivityIndicator
          size="small"
          color={variant === 'outline' || variant === 'ghost' ? '#6366f1' : '#ffffff'}
        />
      ) : (
        <View className="flex-row items-center gap-2">
          {renderIcon}
          {displayText ? (
            <Text className={`font-semibold ${textVariantClasses[variant]} ${textSizeClasses[size]}`}>
              {displayText}
            </Text>
          ) : (
            children
          )}
        </View>
      )}
    </TouchableOpacity>
  );
}
