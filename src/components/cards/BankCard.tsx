import React from 'react';
import { View, Text, TouchableOpacity } from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import { formatCurrency } from '../../utils/format';
import type { BankUser } from '../../types';

interface BankCardProps {
  bankAccount: BankUser;
  onPress?: () => void;
}

export function BankCard({ bankAccount, onPress }: BankCardProps) {
  const balance = bankAccount.balance || 0;
  const isNegative = balance < 0;

  return (
    <TouchableOpacity
      onPress={onPress}
      className="bg-white dark:bg-dark-800 rounded-2xl p-4 mb-2"
      activeOpacity={0.7}
    >
      <View className="flex-row items-center">
        <View className="w-12 h-12 rounded-xl bg-primary-100 dark:bg-primary-900/20 items-center justify-center mr-3">
          <Ionicons name="business-outline" size={24} color="#6366f1" />
        </View>
        <View className="flex-1">
          <Text className="text-sm font-semibold text-dark-900 dark:text-dark-100" numberOfLines={1}>
            {bankAccount.bank?.name || bankAccount.name || 'Banco'}
          </Text>
          <Text className="text-xs text-dark-500 dark:text-dark-400 mt-0.5">
            Conta bancária
          </Text>
        </View>
        <View className="items-end">
          <Text className={`text-sm font-bold ${
            isNegative ? 'text-danger-500' : 'text-success-500'
          }`}>
            {formatCurrency(balance)}
          </Text>
        </View>
      </View>
    </TouchableOpacity>
  );
}
