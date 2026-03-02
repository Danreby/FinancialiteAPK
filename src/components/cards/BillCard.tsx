import React from 'react';
import { View, Text, TouchableOpacity } from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import { formatCurrency } from '../../utils/format';
import { Badge } from '../ui/Badge';
import type { Bill } from '../../types';

interface BillCardProps {
  bill: Bill;
  onPress?: () => void;
  onPay?: () => void;
}

export function BillCard({ bill, onPress, onPay }: BillCardProps) {
  const daysUntil = bill.days_until_due ?? 999;
  const isOverdue = bill.is_overdue ?? daysUntil < 0;
  const isDueSoon = !isOverdue && daysUntil >= 0 && daysUntil <= 3;

  const statusVariant = bill.is_paid
    ? 'success'
    : isOverdue
    ? 'danger'
    : isDueSoon
    ? 'warning'
    : 'default';

  const statusLabel = bill.is_paid
    ? 'Pago'
    : isOverdue
    ? 'Atrasada'
    : isDueSoon
    ? `Vence em ${daysUntil}d`
    : 'Pendente';

  return (
    <TouchableOpacity
      onPress={onPress}
      className="bg-white dark:bg-dark-800 rounded-2xl p-4 mb-2"
      activeOpacity={0.7}
    >
      <View className="flex-row items-center">
        <View className={`w-10 h-10 rounded-full items-center justify-center mr-3 ${
          isOverdue ? 'bg-danger-100 dark:bg-danger-900/20' : 'bg-primary-100 dark:bg-primary-900/20'
        }`}>
          <Ionicons
            name="receipt-outline"
            size={20}
            color={isOverdue ? '#ef4444' : '#6366f1'}
          />
        </View>
        <View className="flex-1">
          <Text className="text-sm font-semibold text-dark-900 dark:text-dark-100" numberOfLines={1}>
            {bill.title}
          </Text>
          <View className="flex-row items-center mt-0.5 gap-2">
            <Text className="text-xs text-dark-500 dark:text-dark-400">
              Dia {bill.due_day}
            </Text>
            <Badge variant={statusVariant} size="sm">
              {statusLabel}
            </Badge>
          </View>
        </View>
        <View className="items-end ml-2">
          <Text className="text-sm font-bold text-dark-900 dark:text-dark-100">
            {formatCurrency(bill.amount || 0)}
          </Text>
          {!bill.is_paid && onPay && (
            <TouchableOpacity
              onPress={(e) => {
                e.stopPropagation?.();
                onPay();
              }}
              className="mt-1 bg-success-500 px-3 py-1 rounded-full"
            >
              <Text className="text-[10px] font-semibold text-white">Pagar</Text>
            </TouchableOpacity>
          )}
        </View>
      </View>
    </TouchableOpacity>
  );
}
