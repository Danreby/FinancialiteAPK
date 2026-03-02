import React, { useEffect, useState, useCallback } from 'react';
import { View, Text, FlatList, RefreshControl, Alert } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { incomesApi } from '@/services/api/incomes';
import { Header } from '@/components/ui/Header';
import { Loading } from '@/components/ui/Loading';
import { EmptyState } from '@/components/ui/EmptyState';
import { Modal } from '@/components/ui/Modal';
import { Input } from '@/components/ui/Input';
import { Button } from '@/components/ui/Button';
import { MoneyInput } from '@/components/ui/MoneyInput';
import { Select } from '@/components/ui/Select';
import { IncomeCard } from '@/components/cards/IncomeCard';
import { formatCurrency } from '@/utils/format';
import type { Income } from '@/types';

export default function IncomesScreen() {
  const [loading, setLoading] = useState(true);
  const [refreshing, setRefreshing] = useState(false);
  const [incomes, setIncomes] = useState<Income[]>([]);
  const [summary, setSummary] = useState<{ total_monthly_income: number } | null>(null);
  const [showCreate, setShowCreate] = useState(false);
  const [formSaving, setFormSaving] = useState(false);

  // Form
  const [formTitle, setFormTitle] = useState('');
  const [formAmount, setFormAmount] = useState('');
  const [formType, setFormType] = useState<string>('salary');

  const loadData = useCallback(async () => {
    try {
      const [list, sum] = await Promise.all([
        incomesApi.list(),
        incomesApi.summary().catch(() => null),
      ]);
      setIncomes(Array.isArray(list) ? list : (list as any)?.data || []);
      if (sum) setSummary(sum);
    } catch {}
    setLoading(false);
    setRefreshing(false);
  }, []);

  useEffect(() => { loadData(); }, [loadData]);

  const onRefresh = useCallback(async () => {
    setRefreshing(true);
    await loadData();
  }, [loadData]);

  const handleToggle = useCallback(async (income: Income) => {
    try {
      await incomesApi.toggleActive(income.id);
      loadData();
    } catch {}
  }, [loadData]);

  const handleDelete = useCallback(async (income: Income) => {
    Alert.alert('Excluir receita', `Deseja excluir "${income.title}"?`, [
      { text: 'Cancelar', style: 'cancel' },
      {
        text: 'Excluir', style: 'destructive',
        onPress: async () => {
          try { await incomesApi.delete(income.id); loadData(); } catch {}
        },
      },
    ]);
  }, [loadData]);

  const handleCreate = useCallback(async () => {
    if (!formTitle.trim() || !formAmount) return;
    setFormSaving(true);
    try {
      await incomesApi.create({
        title: formTitle.trim(),
        amount: parseInt(formAmount, 10) / 100,
        type: formType,
      });
      setShowCreate(false);
      setFormTitle(''); setFormAmount(''); setFormType('salary');
      loadData();
    } catch {}
    setFormSaving(false);
  }, [formTitle, formAmount, formType, loadData]);

  if (loading) return <Loading fullScreen message="Carregando receitas..." />;

  const totalIncome = incomes
    .filter((i) => i.is_active)
    .reduce((sum, i) => sum + (typeof i.amount === 'string' ? parseFloat(i.amount) : i.amount), 0);

  return (
    <SafeAreaView className="flex-1 bg-dark-100 dark:bg-dark-950" edges={['top']}>
      <Header
        title="Receitas"
        showBack
        rightAction={{ icon: 'add-circle-outline', onPress: () => setShowCreate(true) }}
      />

      {/* Summary */}
      <View className="px-5 py-3">
        <View className="bg-success-50 dark:bg-success-900/20 rounded-2xl p-4 flex-row items-center">
          <View className="flex-1">
            <Text className="text-xs text-success-600 dark:text-success-400">Receita mensal ativa</Text>
            <Text className="text-xl font-bold text-success-700 dark:text-success-300">
              {formatCurrency(totalIncome)}
            </Text>
          </View>
          <Text className="text-xs text-success-600 dark:text-success-400">
            {incomes.filter((i) => i.is_active).length} ativas
          </Text>
        </View>
      </View>

      <FlatList
        data={incomes}
        keyExtractor={(item) => String(item.id)}
        contentContainerClassName="px-5 py-2"
        renderItem={({ item }) => (
          <IncomeCard income={item} onPress={() => handleToggle(item)} />
        )}
        ListEmptyComponent={
          <EmptyState
            icon="trending-up"
            title="Nenhuma receita"
            description="Adicione suas fontes de renda"
            actionLabel="Nova receita"
            onAction={() => setShowCreate(true)}
          />
        }
        refreshControl={<RefreshControl refreshing={refreshing} onRefresh={onRefresh} tintColor="#6366f1" />}
        showsVerticalScrollIndicator={false}
      />

      <Modal
        visible={showCreate}
        title="Nova receita"
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
        <Input label="Título" value={formTitle} onChangeText={setFormTitle} placeholder="Ex: Salário, Freelance..." leftIcon="business-outline" />
        <MoneyInput label="Valor" value={formAmount} onChangeValue={setFormAmount} />
        <Select
          label="Tipo"
          value={formType}
          onChange={(v) => setFormType(String(v))}
          options={[
            { label: 'Salário', value: 'salary' },
            { label: 'Freelance', value: 'freelance' },
            { label: 'Investimento', value: 'investment' },
            { label: 'Aluguel', value: 'rental' },
            { label: 'Bônus', value: 'bonus' },
            { label: 'Outro', value: 'other' },
          ]}
        />
      </Modal>
    </SafeAreaView>
  );
}
