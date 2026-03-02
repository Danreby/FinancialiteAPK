import React, { useState } from 'react';
import { View, Text, TouchableOpacity, ScrollView, Modal } from 'react-native';
import { Ionicons } from '@expo/vector-icons';

interface SelectOption {
  label: string;
  value: string | number;
  icon?: keyof typeof Ionicons.glyphMap;
  color?: string;
}

interface SelectProps {
  label?: string;
  placeholder?: string;
  value: string | number | undefined;
  options: SelectOption[];
  onChange: (value: string | number) => void;
  error?: string;
  disabled?: boolean;
}

export function Select({
  label,
  placeholder = 'Selecione...',
  value,
  options,
  onChange,
  error,
  disabled = false,
}: SelectProps) {
  const [open, setOpen] = useState(false);
  const selected = options.find((opt) => opt.value === value);

  return (
    <View className="mb-4">
      {label && (
        <Text className="text-sm font-medium text-dark-700 dark:text-dark-300 mb-1.5">
          {label}
        </Text>
      )}
      <TouchableOpacity
        onPress={() => !disabled && setOpen(true)}
        className={`flex-row items-center border rounded-xl px-4 py-3.5 ${
          error
            ? 'border-danger-500 bg-danger-50 dark:bg-danger-900/20'
            : 'border-dark-300 dark:border-dark-600 bg-white dark:bg-dark-800'
        } ${disabled ? 'opacity-50' : ''}`}
        disabled={disabled}
        activeOpacity={0.7}
      >
        {selected?.icon && (
          <Ionicons
            name={selected.icon}
            size={18}
            color={selected.color || '#6366f1'}
            style={{ marginRight: 8 }}
          />
        )}
        <Text
          className={`flex-1 text-base ${
            selected
              ? 'text-dark-900 dark:text-dark-100'
              : 'text-dark-400 dark:text-dark-500'
          }`}
        >
          {selected?.label || placeholder}
        </Text>
        <Ionicons name="chevron-down" size={18} color="#94a3b8" />
      </TouchableOpacity>
      {error && (
        <Text className="text-xs text-danger-500 mt-1">{error}</Text>
      )}

      <Modal
        visible={open}
        transparent
        animationType="fade"
        onRequestClose={() => setOpen(false)}
      >
        <TouchableOpacity
          className="flex-1 bg-black/50 justify-end"
          activeOpacity={1}
          onPress={() => setOpen(false)}
        >
          <View className="bg-white dark:bg-dark-900 rounded-t-3xl max-h-[60%]">
            <View className="items-center pt-3 pb-1">
              <View className="w-10 h-1 bg-dark-300 dark:bg-dark-600 rounded-full" />
            </View>
            {label && (
              <View className="px-5 py-3 border-b border-dark-200 dark:border-dark-700">
                <Text className="text-lg font-bold text-dark-900 dark:text-dark-100">
                  {label}
                </Text>
              </View>
            )}
            <ScrollView className="px-2 py-2" showsVerticalScrollIndicator={false}>
              {options.map((option) => {
                const isSelected = option.value === value;
                return (
                  <TouchableOpacity
                    key={String(option.value)}
                    onPress={() => {
                      onChange(option.value);
                      setOpen(false);
                    }}
                    className={`flex-row items-center px-4 py-3.5 mx-1 rounded-xl mb-1 ${
                      isSelected ? 'bg-primary-50 dark:bg-primary-900/20' : ''
                    }`}
                    activeOpacity={0.6}
                  >
                    {option.icon && (
                      <Ionicons
                        name={option.icon}
                        size={20}
                        color={option.color || (isSelected ? '#6366f1' : '#64748b')}
                        style={{ marginRight: 12 }}
                      />
                    )}
                    <Text
                      className={`flex-1 text-base ${
                        isSelected
                          ? 'text-primary-600 dark:text-primary-400 font-semibold'
                          : 'text-dark-800 dark:text-dark-200'
                      }`}
                    >
                      {option.label}
                    </Text>
                    {isSelected && (
                      <Ionicons name="checkmark-circle" size={22} color="#6366f1" />
                    )}
                  </TouchableOpacity>
                );
              })}
            </ScrollView>
            <View className="h-8" />
          </View>
        </TouchableOpacity>
      </Modal>
    </View>
  );
}
