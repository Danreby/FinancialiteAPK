import React, { useEffect, useState, useCallback } from 'react';
import { View, Text, ScrollView, RefreshControl, TouchableOpacity, useColorScheme } from 'react-native';
import { useRouter } from 'expo-router';
import { SafeAreaView } from 'react-native-safe-area-context';
import { Ionicons } from '@expo/vector-icons';
import { useAuthStore } from '@/stores/authStore';
import { useSyncStore } from '@/stores/syncStore';
import { dashboardApi } from '@/services/api/dashboard';
import { formatCurrency } from '@/utils/format';
import { formatMonthYear, getCurrentMonthKey } from '@/utils/date';
import { Card } from '@/components/ui/Card';
import { Loading } from '@/components/ui/Loading';
import { SyncIndicator } from '@/components/common/SyncIndicator';
import { TransactionCard } from '@/components/cards/TransactionCard';
import type { DashboardData, DashboardStats, FinancialInsights, Transacao, BankUser, Category } from '@/types';

export default function DashboardScreen() {
  const router = useRouter();
  const colorScheme = useColorScheme();
  const { user } = useAuthStore();
  const { sync } = useSyncStore();
  const [loading, setLoading] = useState(true);
  const [refreshing, setRefreshing] = useState(false);
  const [showBalance, setShowBalance] = useState(true);
  const [stats, setStats] = useState<DashboardStats | null>(null);
  const [insights, setInsights] = useState<FinancialInsights | null>(null);
  const [transactions, setTransactions] = useState<Transacao[]>([]);
  const [bankAccounts, setBankAccounts] = useState<BankUser[]>([]);

  const loadData = useCallback(async () => {
    try {
      const currentMonth = getCurrentMonthKey();
      const [year, month] = currentMonth.split('-');
      const data = await dashboardApi.getData({ month, year });

      if (data.stats) setStats(data.stats);
      if (data.insights) setInsights(data.insights);
      if (data.transactions?.data) setTransactions(data.transactions.data.slice(0, 5));
      if (data.bankAccounts) setBankAccounts(data.bankAccounts);
    } catch {
      // Fallback to local data
    } finally {
      setLoading(false);
    }
  }, []);

  const onRefresh = useCallback(async () => {
    setRefreshing(true);
    await sync();
    await loadData();
    setRefreshing(false);
  }, [sync, loadData]);

  useEffect(() => {
    loadData();
  }, [loadData]);

  if (loading) {
    return <Loading fullScreen message="Carregando dados..." />;
  }

  const totalBalance = bankAccounts.reduce((sum, acc) => sum + (acc.balance || 0), 0);
  const firstName = user?.name?.split(' ')[0] || 'Usuário';

  return (
    <SafeAreaView className="flex-1 bg-dark-100 dark:bg-dark-950" edges={['top']}>
      <ScrollView
        className="flex-1"
        showsVerticalScrollIndicator={false}
        refreshControl={
          <RefreshControl refreshing={refreshing} onRefresh={onRefresh} tintColor="#6366f1" />
        }
      >
        {/* Header */}
        <View className="bg-primary-600 dark:bg-primary-800 px-5 pt-4 pb-8 rounded-b-3xl">
          <View className="flex-row items-center justify-between mb-5">
            <View>
              <Text className="text-sm text-primary-200">Olá,</Text>
              <Text className="text-xl font-bold text-white">{firstName} 👋</Text>
            </View>
            <View className="flex-row items-center gap-2">
              <SyncIndicator />
              <TouchableOpacity
                onPress={() => router.push('/notifications')}
                className="p-2"
                hitSlop={8}
              >
                <Ionicons name="notifications-outline" size={22} color="#fff" />
              </TouchableOpacity>
            </View>
          </View>

          {/* Balance Card */}
          <View className="bg-white/15 rounded-2xl p-4">
            <View className="flex-row items-center justify-between mb-2">
              <Text className="text-sm text-primary-200">Saldo total</Text>
              <TouchableOpacity onPress={() => setShowBalance(!showBalance)}>
                <Ionicons
                  name={showBalance ? 'eye-outline' : 'eye-off-outline'}
                  size={20}
                  color="#c7d2fe"
                />
              </TouchableOpacity>
            </View>
            <Text className="text-2xl font-bold text-white">
              {showBalance ? formatCurrency(totalBalance) : '••••••'}
            </Text>
            <Text className="text-xs text-primary-200 mt-1">
              {formatMonthYear(new Date())}
            </Text>
          </View>
        </View>

        <View className="px-5 -mt-4">
          {/* Quick Stats */}
          <View className="flex-row gap-3 mb-5">
            <View className="flex-1 bg-white dark:bg-dark-800 rounded-2xl p-4">
              <View className="flex-row items-center mb-2">
                <View className="w-8 h-8 rounded-full bg-success-100 dark:bg-success-900/20 items-center justify-center">
                  <Ionicons name="trending-up" size={16} color="#22c55e" />
                </View>
              </View>
              <Text className="text-xs text-dark-500 dark:text-dark-400">Receitas</Text>
              <Text className="text-base font-bold text-success-500 mt-0.5">
                {showBalance ? formatCurrency(stats?.total_credit || 0) : '••••'}
              </Text>
            </View>
            <View className="flex-1 bg-white dark:bg-dark-800 rounded-2xl p-4">
              <View className="flex-row items-center mb-2">
                <View className="w-8 h-8 rounded-full bg-danger-100 dark:bg-danger-900/20 items-center justify-center">
                  <Ionicons name="trending-down" size={16} color="#ef4444" />
                </View>
              </View>
              <Text className="text-xs text-dark-500 dark:text-dark-400">Despesas</Text>
              <Text className="text-base font-bold text-danger-500 mt-0.5">
                {showBalance ? formatCurrency(stats?.total_debit || 0) : '••••'}
              </Text>
            </View>
          </View>

          {/* Financial Health */}
          {insights && (
            <Card title="Saúde Financeira" className="mb-4">
              <View className="flex-row items-center justify-between">
                <View className="flex-row items-center">
                  <View className={`w-12 h-12 rounded-full items-center justify-center ${
                    (insights.health_score || 0) >= 70
                      ? 'bg-success-100 dark:bg-success-900/20'
                      : (insights.health_score || 0) >= 40
                      ? 'bg-warning-100 dark:bg-warning-900/20'
                      : 'bg-danger-100 dark:bg-danger-900/20'
                  }`}>
                    <Text className={`text-lg font-bold ${
                      (insights.health_score || 0) >= 70
                        ? 'text-success-600'
                        : (insights.health_score || 0) >= 40
                        ? 'text-warning-600'
                        : 'text-danger-600'
                    }`}>
                      {insights.health_score || 0}
                    </Text>
                  </View>
                  <View className="ml-3">
                    <Text className="text-sm font-semibold text-dark-800 dark:text-dark-200">
                      {(insights.health_score || 0) >= 70
                        ? 'Excelente'
                        : (insights.health_score || 0) >= 40
                        ? 'Atenção'
                        : 'Crítico'}
                    </Text>
                    <Text className="text-xs text-dark-500 dark:text-dark-400">
                      Pontuação financeira
                    </Text>
                  </View>
                </View>
                <View className="items-end">
                  <Text className="text-xs text-dark-500 dark:text-dark-400">Economia</Text>
                  <Text className="text-sm font-bold text-dark-800 dark:text-dark-200">
                    {insights.savings_rate ? `${insights.savings_rate.toFixed(0)}%` : '0%'}
                  </Text>
                </View>
              </View>
            </Card>
          )}

          {/* Recent Transactions */}
          <View className="mb-4">
            <View className="flex-row items-center justify-between mb-3">
              <Text className="text-base font-bold text-dark-900 dark:text-dark-100">
                Últimas transações
              </Text>
              <TouchableOpacity onPress={() => router.push('/(tabs)/transactions')}>
                <Text className="text-sm text-primary-600 dark:text-primary-400">
                  Ver todas
                </Text>
              </TouchableOpacity>
            </View>
            {transactions.length > 0 ? (
              transactions.map((t) => (
                <TransactionCard key={t.id} transaction={t} />
              ))
            ) : (
              <View className="bg-white dark:bg-dark-800 rounded-2xl p-6 items-center">
                <Ionicons name="receipt-outline" size={32} color="#94a3b8" />
                <Text className="text-sm text-dark-500 dark:text-dark-400 mt-2">
                  Nenhuma transação este mês
                </Text>
              </View>
            )}
          </View>

          {/* Bank Accounts */}
          {bankAccounts.length > 0 && (
            <View className="mb-8">
              <View className="flex-row items-center justify-between mb-3">
                <Text className="text-base font-bold text-dark-900 dark:text-dark-100">
                  Contas bancárias
                </Text>
                <TouchableOpacity onPress={() => router.push('/banks')}>
                  <Text className="text-sm text-primary-600 dark:text-primary-400">
                    Ver todas
                  </Text>
                </TouchableOpacity>
              </View>
              {bankAccounts.slice(0, 3).map((acc) => (
                <View key={acc.id} className="flex-row items-center bg-white dark:bg-dark-800 rounded-2xl p-4 mb-2">
                  <View className="w-10 h-10 rounded-xl bg-primary-100 dark:bg-primary-900/20 items-center justify-center mr-3">
                    <Ionicons name="business-outline" size={20} color="#6366f1" />
                  </View>
                  <View className="flex-1">
                    <Text className="text-sm font-semibold text-dark-900 dark:text-dark-100">
                      {acc.bank?.name || 'Banco'}
                    </Text>
                    <Text className="text-xs text-dark-500 dark:text-dark-400">
                      {acc.name || 'Conta'}
                    </Text>
                  </View>
                  <Text className={`text-sm font-bold ${
                    (acc.balance || 0) >= 0 ? 'text-success-500' : 'text-danger-500'
                  }`}>
                    {showBalance ? formatCurrency(acc.balance || 0) : '••••'}
                  </Text>
                </View>
              ))}
            </View>
          )}
        </View>
      </ScrollView>
    </SafeAreaView>
  );
}
