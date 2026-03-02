import React from 'react';
import { View, Text, TouchableOpacity } from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import { formatCurrency, formatPercentage } from '../../utils/format';
import type { BudgetWithSpending } from '../../types';

interface BudgetCardProps {
  budget: BudgetWithSpending;
  onPress?: () => void;
}

export function BudgetCard({ budget, onPress }: BudgetCardProps) {
  const spent = budget.total_spent || 0;
  const limit = budget.budget.monthly_limit;
  const percentage = budget.percentage || (limit > 0 ? (spent / limit) * 100 : 0);
  const remaining = budget.remaining ?? (limit - spent);
  const isOver = remaining < 0;
  const isWarning = percentage >= 80 && percentage < 100;

  const barColor = isOver
    ? 'bg-danger-500'
    : isWarning
    ? 'bg-warning-500'
    : 'bg-primary-500';

  return (
    <TouchableOpacity
      onPress={onPress}
      className="bg-white dark:bg-dark-800 rounded-2xl p-4 mb-2"
      activeOpacity={0.7}
    >
      <View className="flex-row items-center justify-between mb-2">
        <View className="flex-row items-center flex-1">
          <View className="w-8 h-8 rounded-full bg-primary-100 dark:bg-primary-900/20 items-center justify-center mr-2.5">
            <Ionicons name="pie-chart-outline" size={18} color="#6366f1" />
          </View>
          <Text className="text-sm font-semibold text-dark-900 dark:text-dark-100" numberOfLines={1}>
            {budget.budget.month_year || 'Orçamento'}
          </Text>
        </View>
        <Text className={`text-xs font-semibold ${
          isOver ? 'text-danger-500' : isWarning ? 'text-warning-600' : 'text-dark-500'
        }`}>
          {formatPercentage(Math.min(percentage, 100))}
        </Text>
      </View>

      {/* Progress Bar */}
      <View className="h-2 bg-dark-200 dark:bg-dark-700 rounded-full overflow-hidden mb-2">
        <View
          className={`h-full rounded-full ${barColor}`}
          style={{ width: `${Math.min(percentage, 100)}%` }}
        />
      </View>

      <View className="flex-row justify-between">
        <Text className="text-xs text-dark-500 dark:text-dark-400">
          Gasto: {formatCurrency(spent)}
        </Text>
        <Text className={`text-xs font-medium ${isOver ? 'text-danger-500' : 'text-dark-600 dark:text-dark-300'}`}>
          {isOver ? 'Excedido: ' : 'Restante: '}
          {formatCurrency(Math.abs(remaining))}
        </Text>
      </View>
    </TouchableOpacity>
  );
}
