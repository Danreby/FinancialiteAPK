import React from 'react';
import { View, Text, TouchableOpacity } from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import { formatCurrency } from '../../utils/format';
import { formatDate } from '../../utils/date';
import type { Transacao } from '../../types';

interface TransactionCardProps {
  transaction: Transacao;
  onPress?: () => void;
}

export function TransactionCard({ transaction, onPress }: TransactionCardProps) {
  const isCredit = transaction.type === 'credit';
  const icon = isCredit ? 'arrow-down-circle' : 'arrow-up-circle';
  const colorClass = isCredit
    ? 'text-success-500'
    : 'text-danger-500';
  const bgClass = isCredit
    ? 'bg-success-100 dark:bg-success-900/20'
    : 'bg-danger-100 dark:bg-danger-900/20';

  const amount = typeof transaction.amount === 'string'
    ? parseFloat(transaction.amount)
    : transaction.amount;

  return (
    <TouchableOpacity
      onPress={onPress}
      className="flex-row items-center bg-white dark:bg-dark-800 rounded-2xl p-4 mb-2"
      activeOpacity={0.7}
    >
      <View className={`w-10 h-10 rounded-full ${bgClass} items-center justify-center mr-3`}>
        <Ionicons
          name={icon}
          size={22}
          color={isCredit ? '#22c55e' : '#ef4444'}
        />
      </View>
      <View className="flex-1">
        <Text className="text-sm font-semibold text-dark-900 dark:text-dark-100" numberOfLines={1}>
          {transaction.title}
        </Text>
        <Text className="text-xs text-dark-500 dark:text-dark-400 mt-0.5">
          {transaction.category?.name || 'Sem categoria'} • {formatDate(transaction.created_at)}
        </Text>
      </View>
      <View className="items-end ml-2">
        <Text className={`text-sm font-bold ${colorClass}`}>
          {isCredit ? '+' : '-'} {formatCurrency(amount)}
        </Text>
        {transaction.current_installment && transaction.total_installments && (
          <Text className="text-[10px] text-dark-400 mt-0.5">
            {transaction.current_installment}/{transaction.total_installments}
          </Text>
        )}
      </View>
    </TouchableOpacity>
  );
}
