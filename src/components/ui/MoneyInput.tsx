import React, { useState, useCallback } from 'react';
import { View, Text, TextInput, TouchableOpacity } from 'react-native';

interface MoneyInputProps {
  label?: string;
  value: string;
  onChangeValue: (value: string) => void;
  error?: string;
  placeholder?: string;
  editable?: boolean;
}

export function MoneyInput({
  label,
  value,
  onChangeValue,
  error,
  placeholder = 'R$ 0,00',
  editable = true,
}: MoneyInputProps) {
  const [isFocused, setIsFocused] = useState(false);

  const formatCurrency = useCallback((raw: string) => {
    const digits = raw.replace(/\D/g, '');
    if (!digits) return '';
    const numericValue = parseInt(digits, 10) / 100;
    return numericValue.toLocaleString('pt-BR', {
      style: 'currency',
      currency: 'BRL',
    });
  }, []);

  const handleChangeText = useCallback(
    (text: string) => {
      const digits = text.replace(/\D/g, '');
      onChangeValue(digits);
    },
    [onChangeValue]
  );

  const displayValue = value ? formatCurrency(value) : '';

  return (
    <View className="mb-4">
      {label && (
        <Text className="text-sm font-medium text-dark-700 dark:text-dark-300 mb-1.5">
          {label}
        </Text>
      )}
      <View
        className={`flex-row items-center border rounded-xl px-4 py-3 ${
          error
            ? 'border-danger-500 bg-danger-50 dark:bg-danger-900/20'
            : isFocused
            ? 'border-primary-500 bg-primary-50/50 dark:bg-primary-900/10'
            : 'border-dark-300 dark:border-dark-600 bg-white dark:bg-dark-800'
        }`}
      >
        <Text className="text-lg font-semibold text-dark-500 dark:text-dark-400 mr-1">
          R$
        </Text>
        <TextInput
          className="flex-1 text-lg font-semibold text-dark-900 dark:text-dark-100"
          value={displayValue.replace('R$\u00A0', '').replace('R$ ', '')}
          onChangeText={handleChangeText}
          placeholder={placeholder.replace('R$ ', '')}
          placeholderTextColor="#94a3b8"
          keyboardType="numeric"
          onFocus={() => setIsFocused(true)}
          onBlur={() => setIsFocused(false)}
          editable={editable}
        />
      </View>
      {error && (
        <Text className="text-xs text-danger-500 mt-1">{error}</Text>
      )}
    </View>
  );
}
