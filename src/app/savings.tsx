import React, { useEffect, useState, useCallback } from 'react';
import { View, Text, FlatList, RefreshControl, Alert } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { savingsApi } from '@/services/api/savings';
import { Header } from '@/components/ui/Header';
import { Loading } from '@/components/ui/Loading';
import { EmptyState } from '@/components/ui/EmptyState';
import { Modal } from '@/components/ui/Modal';
import { Input } from '@/components/ui/Input';
import { Button } from '@/components/ui/Button';
import { MoneyInput } from '@/components/ui/MoneyInput';
import { SavingsCard } from '@/components/cards/SavingsCard';
import { formatCurrency } from '@/utils/format';
import type { SavingsGoal } from '@/types';

export default function SavingsScreen() {
  const [loading, setLoading] = useState(true);
  const [refreshing, setRefreshing] = useState(false);
  const [goals, setGoals] = useState<SavingsGoal[]>([]);
  const [showCreate, setShowCreate] = useState(false);
  const [showDeposit, setShowDeposit] = useState<SavingsGoal | null>(null);
  const [formSaving, setFormSaving] = useState(false);

  // Create form
  const [formTitle, setFormTitle] = useState('');
  const [formTarget, setFormTarget] = useState('');
  const [formDate, setFormDate] = useState('');

  // Deposit form
  const [depositAmount, setDepositAmount] = useState('');

  const loadData = useCallback(async () => {
    try {
      const data = await savingsApi.list();
      setGoals(Array.isArray(data) ? data : (data as any)?.data || []);
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
    if (!formTitle.trim() || !formTarget) return;
    setFormSaving(true);
    try {
      await savingsApi.create({
        title: formTitle.trim(),
        target_amount: parseInt(formTarget, 10) / 100,
      });
      setShowCreate(false);
      setFormTitle(''); setFormTarget(''); setFormDate('');
      loadData();
    } catch {}
    setFormSaving(false);
  }, [formTitle, formTarget, formDate, loadData]);

  const handleDeposit = useCallback(async () => {
    if (!showDeposit || !depositAmount) return;
    setFormSaving(true);
    try {
      await savingsApi.deposit(showDeposit.id, parseInt(depositAmount, 10) / 100);
      setShowDeposit(null);
      setDepositAmount('');
      loadData();
    } catch {}
    setFormSaving(false);
  }, [showDeposit, depositAmount, loadData]);

  const handleWithdraw = useCallback(async (goal: SavingsGoal) => {
    Alert.prompt?.(
      'Retirar valor',
      `Quanto deseja retirar de "${goal.title}"?`,
      async (text: string) => {
        const val = parseFloat(text.replace(',', '.'));
        if (!val || val <= 0) return;
        try { await savingsApi.withdraw(goal.id, val); loadData(); } catch {}
      },
      'plain-text',
      '',
      'numeric'
    );
  }, [loadData]);

  if (loading) return <Loading fullScreen message="Carregando metas..." />;

  const totalSaved = goals.reduce((sum, g) => sum + g.current_amount, 0);
  const totalTarget = goals.reduce((sum, g) => sum + g.target_amount, 0);

  return (
    <SafeAreaView className="flex-1 bg-dark-100 dark:bg-dark-950" edges={['top']}>
      <Header
        title="Metas de Economia"
        showBack
        rightAction={{ icon: 'add-circle-outline', onPress: () => setShowCreate(true) }}
      />

      {/* Summary */}
      <View className="px-5 py-3">
        <View className="bg-primary-50 dark:bg-primary-900/20 rounded-2xl p-4">
          <View className="flex-row items-center justify-between mb-3">
            <View>
              <Text className="text-xs text-primary-600 dark:text-primary-400">Total economizado</Text>
              <Text className="text-xl font-bold text-primary-700 dark:text-primary-300">
                {formatCurrency(totalSaved)}
              </Text>
            </View>
            <View className="items-end">
              <Text className="text-xs text-primary-600 dark:text-primary-400">Meta total</Text>
              <Text className="text-sm font-semibold text-primary-600 dark:text-primary-400">
                {formatCurrency(totalTarget)}
              </Text>
            </View>
          </View>
          {totalTarget > 0 && (
            <View className="h-2 bg-primary-200 dark:bg-primary-800 rounded-full overflow-hidden">
              <View
                className="h-full bg-primary-500 rounded-full"
                style={{ width: `${Math.min((totalSaved / totalTarget) * 100, 100)}%` }}
              />
            </View>
          )}
        </View>
      </View>

      <FlatList
        data={goals}
        keyExtractor={(item) => String(item.id)}
        contentContainerClassName="px-5 py-2"
        renderItem={({ item }) => (
          <SavingsCard goal={item} onPress={() => setShowDeposit(item)} />
        )}
        ListEmptyComponent={
          <EmptyState
            icon="flag-outline"
            title="Nenhuma meta"
            description="Defina metas para acompanhar suas economias"
            actionLabel="Nova meta"
            onAction={() => setShowCreate(true)}
          />
        }
        refreshControl={<RefreshControl refreshing={refreshing} onRefresh={onRefresh} tintColor="#6366f1" />}
        showsVerticalScrollIndicator={false}
      />

      {/* Create Modal */}
      <Modal
        visible={showCreate}
        title="Nova meta"
        onClose={() => setShowCreate(false)}
        footer={
          <View className="flex-row gap-3">
            <View className="flex-1">
              <Button variant="outline" onPress={() => setShowCreate(false)} fullWidth>Cancelar</Button>
            </View>
            <View className="flex-1">
              <Button variant="primary" onPress={handleCreate} loading={formSaving} fullWidth>Salvar</Button>
            </View>
          </View>
        }
      >
        <Input label="Nome da meta" value={formTitle} onChangeText={setFormTitle} placeholder="Ex: Viagem, Reserva..." leftIcon="flag-outline" />
        <MoneyInput label="Valor alvo" value={formTarget} onChangeValue={setFormTarget} />
        <Input label="Data limite (opcional)" value={formDate} onChangeText={setFormDate} placeholder="AAAA-MM-DD" leftIcon="calendar-outline" />
      </Modal>

      {/* Deposit Modal */}
      <Modal
        visible={!!showDeposit}
        title={`Depositar em "${showDeposit?.title || ''}"`}
        onClose={() => { setShowDeposit(null); setDepositAmount(''); }}
        footer={
          <View className="flex-row gap-3">
            <View className="flex-1">
              <Button variant="outline" onPress={() => { setShowDeposit(null); setDepositAmount(''); }} fullWidth>Cancelar</Button>
            </View>
            <View className="flex-1">
              <Button variant="primary" onPress={handleDeposit} loading={formSaving} fullWidth>Depositar</Button>
            </View>
          </View>
        }
      >
        <View className="mb-4">
          <Text className="text-sm text-dark-500 dark:text-dark-400">
            Saldo atual: {formatCurrency(showDeposit?.current_amount || 0)}
          </Text>
          <Text className="text-sm text-dark-500 dark:text-dark-400">
            Meta: {formatCurrency(showDeposit?.target_amount || 0)}
          </Text>
        </View>
        <MoneyInput label="Valor do depósito" value={depositAmount} onChangeValue={setDepositAmount} />
      </Modal>
    </SafeAreaView>
  );
}
