import React, { useState } from 'react';
import { View, TextInput, Text, type TextInputProps, TouchableOpacity } from 'react-native';
import { Ionicons } from '@expo/vector-icons';

interface InputProps extends TextInputProps {
  label?: string;
  error?: string;
  hint?: string;
  leftIcon?: keyof typeof Ionicons.glyphMap;
  rightIcon?: keyof typeof Ionicons.glyphMap;
  onRightIconPress?: () => void;
  containerClassName?: string;
}

export function Input({
  label,
  error,
  hint,
  leftIcon,
  rightIcon,
  onRightIconPress,
  containerClassName = '',
  secureTextEntry,
  ...props
}: InputProps) {
  const [isSecure, setIsSecure] = useState(secureTextEntry);
  const [isFocused, setIsFocused] = useState(false);

  const borderColor = error
    ? 'border-danger-500'
    : isFocused
      ? 'border-primary-500'
      : 'border-dark-300 dark:border-dark-600';

  return (
    <View className={`mb-4 ${containerClassName}`}>
      {label && (
        <Text className="text-sm font-medium text-dark-700 dark:text-dark-200 mb-1.5">
          {label}
        </Text>
      )}

      <View
        className={`flex-row items-center bg-dark-50 dark:bg-dark-800 border rounded-xl px-3 ${borderColor}`}
      >
        {leftIcon && (
          <Ionicons
            name={leftIcon}
            size={20}
            color={isFocused ? '#3b82f6' : '#94a3b8'}
            style={{ marginRight: 8 }}
          />
        )}

        <TextInput
          className="flex-1 py-3 text-base text-dark-900 dark:text-dark-100"
          placeholderTextColor="#94a3b8"
          secureTextEntry={isSecure}
          onFocus={() => setIsFocused(true)}
          onBlur={() => setIsFocused(false)}
          autoCapitalize="none"
          {...props}
        />

        {secureTextEntry && (
          <TouchableOpacity onPress={() => setIsSecure(!isSecure)} hitSlop={8}>
            <Ionicons
              name={isSecure ? 'eye-off-outline' : 'eye-outline'}
              size={20}
              color="#94a3b8"
            />
          </TouchableOpacity>
        )}

        {rightIcon && !secureTextEntry && (
          <TouchableOpacity onPress={onRightIconPress} hitSlop={8}>
            <Ionicons name={rightIcon} size={20} color="#94a3b8" />
          </TouchableOpacity>
        )}
      </View>

      {error && (
        <Text className="text-xs text-danger-500 mt-1">{error}</Text>
      )}

      {hint && !error && (
        <Text className="text-xs text-dark-400 mt-1">{hint}</Text>
      )}
    </View>
  );
}
