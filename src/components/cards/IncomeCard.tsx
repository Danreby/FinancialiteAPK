import React from 'react';
import { View, Text, TouchableOpacity } from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import { formatCurrency } from '../../utils/format';
import { Badge } from '../ui/Badge';
import type { Income } from '../../types';

interface IncomeCardProps {
  income: Income;
  onPress?: () => void;
}

export function IncomeCard({ income, onPress }: IncomeCardProps) {
  const typeLabels: Record<string, string> = {
    salary: 'Salário',
    freelance: 'Freelance',
    investment: 'Investimento',
    rental: 'Aluguel',
    bonus: 'Bônus',
    other: 'Outro',
  };

  return (
    <TouchableOpacity
      onPress={onPress}
      className="bg-white dark:bg-dark-800 rounded-2xl p-4 mb-2"
      activeOpacity={0.7}
    >
      <View className="flex-row items-center">
        <View className="w-10 h-10 rounded-full bg-success-100 dark:bg-success-900/20 items-center justify-center mr-3">
          <Ionicons name="trending-up" size={20} color="#22c55e" />
        </View>
        <View className="flex-1">
          <Text className="text-sm font-semibold text-dark-900 dark:text-dark-100" numberOfLines={1}>
            {income.title}
          </Text>
          <View className="flex-row items-center mt-0.5 gap-2">
            <Text className="text-xs text-dark-500 dark:text-dark-400">
              {typeLabels[income.type] || income.type}
            </Text>
            <Badge
              variant={income.is_active ? 'success' : 'default'}
              size="sm"
            >
              {income.is_active ? 'Ativo' : 'Inativo'}
            </Badge>
          </View>
        </View>
        <Text className="text-sm font-bold text-success-500 ml-2">
          {formatCurrency(typeof income.amount === 'string' ? parseFloat(income.amount) : income.amount)}
        </Text>
      </View>
    </TouchableOpacity>
  );
}
