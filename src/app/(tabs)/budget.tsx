import React, { useEffect, useState, useCallback } from 'react';
import { View, Text, FlatList, RefreshControl, TouchableOpacity } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { Ionicons } from '@expo/vector-icons';
import { budgetsApi } from '@/services/api/budgets';
import { Header } from '@/components/ui/Header';
import { Loading } from '@/components/ui/Loading';
import { EmptyState } from '@/components/ui/EmptyState';
import { Modal } from '@/components/ui/Modal';
import { Input } from '@/components/ui/Input';
import { Button } from '@/components/ui/Button';
import { MoneyInput } from '@/components/ui/MoneyInput';
import { BudgetCard } from '@/components/cards/BudgetCard';
import { formatCurrency, formatPercentage } from '@/utils/format';
import type { BudgetWithSpending } from '@/types';

export default function BudgetScreen() {
  const [loading, setLoading] = useState(true);
  const [refreshing, setRefreshing] = useState(false);
  const [budgets, setBudgets] = useState<BudgetWithSpending[]>([]);
  const [currentBudget, setCurrentBudget] = useState<BudgetWithSpending | null>(null);
  const [showCreate, setShowCreate] = useState(false);
  const [formSaving, setFormSaving] = useState(false);

  // Form
  const [formMonthYear, setFormMonthYear] = useState('');  
  const [formAmount, setFormAmount] = useState('');

  const loadData = useCallback(async () => {
    try {
      const [list, current] = await Promise.all([
        budgetsApi.list(),
        budgetsApi.current().catch(() => null),
      ]);
      setBudgets(Array.isArray(list) ? list : []);
      setCurrentBudget(current);
    } catch {}
    setLoading(false);
    setRefreshing(false);
  }, []);

  useEffect(() => { loadData(); }, [loadData]);

  const onRefresh = useCallback(async () => {
    setRefreshing(true);
    await loadData();
  }, [loadData]);

  const handleCreate = useCallback(async () => {
    if (!formMonthYear.trim() || !formAmount) return;
    setFormSaving(true);
    try {
      await budgetsApi.create({
        monthly_limit: parseInt(formAmount, 10) / 100,
        month_year: formMonthYear.trim(),
      });
      setShowCreate(false);
      setFormMonthYear('');
      setFormAmount('');
      loadData();
    } catch {}
    setFormSaving(false);
  }, [formMonthYear, formAmount, loadData]);

  if (loading) {
    return <Loading fullScreen message="Carregando orçamentos..." />;
  }

  const totalBudget = budgets.reduce((sum, b) => sum + (b.budget?.monthly_limit || 0), 0);
  const totalSpent = budgets.reduce((sum, b) => sum + (b.total_spent || 0), 0);
  const overallPercentage = totalBudget > 0 ? (totalSpent / totalBudget) * 100 : 0;

  return (
    <SafeAreaView className="flex-1 bg-dark-100 dark:bg-dark-950" edges={['top']}>
      <Header
        title="Orçamento"
        rightAction={{ icon: 'add-circle-outline', onPress: () => setShowCreate(true) }}
      />

      {/* Overall Summary */}
      <View className="px-5 py-3">
        <View className="bg-white dark:bg-dark-800 rounded-2xl p-5">
          <View className="flex-row items-center justify-between mb-3">
            <View>
              <Text className="text-xs text-dark-500 dark:text-dark-400">Orçamento total</Text>
              <Text className="text-xl font-bold text-dark-900 dark:text-dark-100">
                {formatCurrency(totalBudget)}
              </Text>
            </View>
            <View className="items-end">
              <Text className="text-xs text-dark-500 dark:text-dark-400">Utilizado</Text>
              <Text className={`text-lg font-bold ${
                overallPercentage > 100 ? 'text-danger-500' : overallPercentage > 80 ? 'text-warning-500' : 'text-primary-500'
              }`}>
                {formatPercentage(Math.min(overallPercentage, 100))}
              </Text>
            </View>
          </View>
          <View className="h-3 bg-dark-200 dark:bg-dark-700 rounded-full overflow-hidden">
            <View
              className={`h-full rounded-full ${
                overallPercentage > 100 ? 'bg-danger-500' : overallPercentage > 80 ? 'bg-warning-500' : 'bg-primary-500'
              }`}
              style={{ width: `${Math.min(overallPercentage, 100)}%` }}
            />
          </View>
          <View className="flex-row justify-between mt-2">
            <Text className="text-xs text-dark-500 dark:text-dark-400">
              Gasto: {formatCurrency(totalSpent)}
            </Text>
            <Text className="text-xs text-dark-500 dark:text-dark-400">
              Restante: {formatCurrency(Math.max(totalBudget - totalSpent, 0))}
            </Text>
          </View>
        </View>
      </View>

      <FlatList
        data={budgets}
        keyExtractor={(item) => String(item.budget?.id || Math.random())}
        contentContainerClassName="px-5 py-2"
        renderItem={({ item }) => <BudgetCard budget={item} />}
        ListHeaderComponent={
          budgets.length > 0 ? (
            <Text className="text-sm font-bold text-dark-900 dark:text-dark-100 mb-3">
              Orçamentos ativos
            </Text>
          ) : null
        }
        ListEmptyComponent={
          <EmptyState
            icon="pie-chart-outline"
            title="Nenhum orçamento"
            description="Crie orçamentos para controlar seus gastos mensais"
            actionLabel="Criar orçamento"
            onAction={() => setShowCreate(true)}
          />
        }
        refreshControl={
          <RefreshControl refreshing={refreshing} onRefresh={onRefresh} tintColor="#6366f1" />
        }
        showsVerticalScrollIndicator={false}
      />

      {/* Create Modal */}
      <Modal
        visible={showCreate}
        title="Novo orçamento"
        onClose={() => { setShowCreate(false); setFormMonthYear(''); setFormAmount(''); }}
        footer={
          <View className="flex-row gap-3">
            <View className="flex-1">
              <Button variant="outline" onPress={() => { setShowCreate(false); setFormMonthYear(''); setFormAmount(''); }} fullWidth>
                Cancelar
              </Button>
            </View>
            <View className="flex-1">
              <Button variant="primary" onPress={handleCreate} loading={formSaving} fullWidth>
                Salvar
              </Button>
            </View>
          </View>
        }
      >
        <Input
          label="Mês/Ano"
          value={formMonthYear}
          onChangeText={setFormMonthYear}
          placeholder="Ex: 2025-01"
          leftIcon="calendar-outline"
        />
        <MoneyInput label="Limite mensal" value={formAmount} onChangeValue={setFormAmount} />
      </Modal>
    </SafeAreaView>
  );
}
