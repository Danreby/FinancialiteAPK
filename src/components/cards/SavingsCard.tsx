import React from 'react';
import { View, Text, TouchableOpacity } from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import { formatCurrency, formatPercentage } from '../../utils/format';
import type { SavingsGoal } from '../../types';

interface SavingsCardProps {
  goal: SavingsGoal;
  onPress?: () => void;
}

export function SavingsCard({ goal, onPress }: SavingsCardProps) {
  const progress = goal.target_amount > 0
    ? (goal.current_amount / goal.target_amount) * 100
    : 0;
  const progressClamped = Math.min(progress, 100);
  const isCompleted = progress >= 100;

  return (
    <TouchableOpacity
      onPress={onPress}
      className="bg-white dark:bg-dark-800 rounded-2xl p-4 mb-2"
      activeOpacity={0.7}
    >
      <View className="flex-row items-center mb-3">
        <View className={`w-10 h-10 rounded-full items-center justify-center mr-3 ${
          isCompleted ? 'bg-success-100 dark:bg-success-900/20' : 'bg-primary-100 dark:bg-primary-900/20'
        }`}>
          <Ionicons
            name={isCompleted ? 'checkmark-circle' : 'flag-outline'}
            size={22}
            color={isCompleted ? '#22c55e' : '#6366f1'}
          />
        </View>
        <View className="flex-1">
          <Text className="text-sm font-semibold text-dark-900 dark:text-dark-100" numberOfLines={1}>
            {goal.title}
          </Text>
          <Text className="text-xs text-dark-500 dark:text-dark-400 mt-0.5">
            {formatCurrency(goal.current_amount)} de {formatCurrency(goal.target_amount)}
          </Text>
        </View>
        <Text className={`text-sm font-bold ${isCompleted ? 'text-success-500' : 'text-primary-500'}`}>
          {formatPercentage(progressClamped)}
        </Text>
      </View>

      {/* Progress Bar */}
      <View className="h-2 bg-dark-200 dark:bg-dark-700 rounded-full overflow-hidden">
        <View
          className={`h-full rounded-full ${isCompleted ? 'bg-success-500' : 'bg-primary-500'}`}
          style={{ width: `${progressClamped}%` }}
        />
      </View>

      {goal.completed_at && (
        <Text className="text-[10px] text-dark-400 mt-2">
          Concluído: {new Date(goal.completed_at).toLocaleDateString('pt-BR')}
        </Text>
      )}
    </TouchableOpacity>
  );
}
