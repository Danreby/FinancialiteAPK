import React, { useEffect, useState, useCallback } from 'react';
import { View, Text, FlatList, RefreshControl, TouchableOpacity, Alert } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { Ionicons } from '@expo/vector-icons';
import { billsApi } from '@/services/api/bills';
import { Header } from '@/components/ui/Header';
import { Loading } from '@/components/ui/Loading';
import { EmptyState } from '@/components/ui/EmptyState';
import { Modal } from '@/components/ui/Modal';
import { Input } from '@/components/ui/Input';
import { Button } from '@/components/ui/Button';
import { MoneyInput } from '@/components/ui/MoneyInput';
import { Select } from '@/components/ui/Select';
import { BillCard } from '@/components/cards/BillCard';
import { formatCurrency } from '@/utils/format';
import type { Bill } from '@/types';

type TabFilter = 'all' | 'pending' | 'paid' | 'overdue';

export default function BillsScreen() {
  const [loading, setLoading] = useState(true);
  const [refreshing, setRefreshing] = useState(false);
  const [bills, setBills] = useState<Bill[]>([]);
  const [upcoming, setUpcoming] = useState<Bill[]>([]);
  const [filter, setFilter] = useState<TabFilter>('all');
  const [showCreate, setShowCreate] = useState(false);
  const [formSaving, setFormSaving] = useState(false);

  // Form
  const [formTitle, setFormTitle] = useState('');
  const [formAmount, setFormAmount] = useState('');
  const [formDueDay, setFormDueDay] = useState('');
  const [formRecurrence, setFormRecurrence] = useState<string>('monthly');

  const loadData = useCallback(async () => {
    try {
      const [billsData, upcomingData] = await Promise.all([
        billsApi.list(),
        billsApi.upcoming(),
      ]);
      setBills(Array.isArray(billsData) ? billsData : (billsData as any)?.data || []);
      setUpcoming(Array.isArray(upcomingData) ? upcomingData : []);
    } catch {}
    setLoading(false);
    setRefreshing(false);
  }, []);

  useEffect(() => { loadData(); }, [loadData]);

  const onRefresh = useCallback(async () => {
    setRefreshing(true);
    await loadData();
  }, [loadData]);

  const handlePay = useCallback(async (bill: Bill) => {
    Alert.alert(
      'Confirmar pagamento',
      `Marcar "${bill.title}" como pago?`,
      [
        { text: 'Cancelar', style: 'cancel' },
        {
          text: 'Confirmar',
          onPress: async () => {
            try {
              await billsApi.markAsPaid(bill.id);
              loadData();
            } catch {}
          },
        },
      ]
    );
  }, [loadData]);

  const handleCreate = useCallback(async () => {
    if (!formTitle.trim() || !formAmount || !formDueDay) return;
    setFormSaving(true);
    try {
      await billsApi.create({
        title: formTitle.trim(),
        amount: parseInt(formAmount, 10) / 100,
        due_day: parseInt(formDueDay, 10),
        recurrence_type: formRecurrence,
      });
      setShowCreate(false);
      resetForm();
      loadData();
    } catch {}
    setFormSaving(false);
  }, [formTitle, formAmount, formDueDay, formRecurrence, loadData]);

  const resetForm = () => {
    setFormTitle('');
    setFormAmount('');
    setFormDueDay('');
    setFormRecurrence('monthly');
  };

  const filteredBills = bills.filter((b) => {
    if (filter === 'all') return true;
    if (filter === 'paid') return b.is_paid === true;
    if (filter === 'pending') return !b.is_paid && !b.is_overdue;
    if (filter === 'overdue') return b.is_overdue === true;
    return true;
  });

  const totalPending = bills
    .filter((b) => !b.is_paid)
    .reduce((sum, b) => sum + (b.amount || 0), 0);

  if (loading) {
    return <Loading fullScreen message="Carregando contas..." />;
  }

  return (
    <SafeAreaView className="flex-1 bg-dark-100 dark:bg-dark-950" edges={['top']}>
      <Header
        title="Contas a Pagar"
        rightAction={{ icon: 'add-circle-outline', onPress: () => setShowCreate(true) }}
      />

      {/* Summary */}
      <View className="px-5 py-3">
        <View className="bg-warning-50 dark:bg-warning-900/20 rounded-2xl p-4 flex-row items-center">
          <View className="w-10 h-10 rounded-full bg-warning-100 dark:bg-warning-800/40 items-center justify-center mr-3">
            <Ionicons name="alert-circle" size={22} color="#f59e0b" />
          </View>
          <View className="flex-1">
            <Text className="text-xs text-warning-600 dark:text-warning-400">Total pendente</Text>
            <Text className="text-lg font-bold text-warning-700 dark:text-warning-300">
              {formatCurrency(totalPending)}
            </Text>
          </View>
          <Text className="text-xs text-warning-600 dark:text-warning-400">
            {bills.filter((b) => !b.is_paid).length} contas
          </Text>
        </View>
      </View>

      {/* Filters */}
      <View className="flex-row px-5 py-2 gap-2">
        {(['all', 'pending', 'paid', 'overdue'] as TabFilter[]).map((f) => {
          const labels: Record<TabFilter, string> = { all: 'Todas', pending: 'Pendentes', paid: 'Pagas', overdue: 'Atrasadas' };
          return (
            <TouchableOpacity
              key={f}
              onPress={() => setFilter(f)}
              className={`px-3 py-2 rounded-full ${
                filter === f ? 'bg-primary-500' : 'bg-white dark:bg-dark-800'
              }`}
            >
              <Text className={`text-xs font-semibold ${
                filter === f ? 'text-white' : 'text-dark-600 dark:text-dark-400'
              }`}>
                {labels[f]}
              </Text>
            </TouchableOpacity>
          );
        })}
      </View>

      {/* Upcoming */}
      {upcoming.length > 0 && filter === 'all' && (
        <View className="px-5 py-2">
          <Text className="text-sm font-bold text-dark-900 dark:text-dark-100 mb-2">
            Próximas a vencer
          </Text>
          {upcoming.slice(0, 3).map((b) => (
            <BillCard key={b.id} bill={b} onPay={() => handlePay(b)} />
          ))}
        </View>
      )}

      <FlatList
        data={filteredBills}
        keyExtractor={(item) => String(item.id)}
        contentContainerClassName="px-5 py-2"
        renderItem={({ item }) => (
          <BillCard bill={item} onPay={() => handlePay(item)} />
        )}
        ListEmptyComponent={
          <EmptyState
            icon="receipt-outline"
            title="Nenhuma conta"
            description="Adicione suas contas fixas para controlar vencimentos"
            actionLabel="Nova conta"
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
        title="Nova conta"
        onClose={() => { setShowCreate(false); resetForm(); }}
        footer={
          <View className="flex-row gap-3">
            <View className="flex-1">
              <Button variant="outline" onPress={() => { setShowCreate(false); resetForm(); }} fullWidth>
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
          label="Título"
          value={formTitle}
          onChangeText={setFormTitle}
          placeholder="Ex: Aluguel, Internet..."
          leftIcon="document-text-outline"
        />
        <MoneyInput label="Valor" value={formAmount} onChangeValue={setFormAmount} />
        <Input
          label="Dia de vencimento"
          value={formDueDay}
          onChangeText={setFormDueDay}
          placeholder="1 a 31"
          keyboardType="numeric"
          leftIcon="calendar-outline"
        />
        <Select
          label="Recorrência"
          value={formRecurrence}
          onChange={(v) => setFormRecurrence(String(v))}
          options={[
            { label: 'Mensal', value: 'monthly' },
            { label: 'Semanal', value: 'weekly' },
            { label: 'Anual', value: 'yearly' },
            { label: 'Única', value: 'once' },
          ]}
        />
      </Modal>
    </SafeAreaView>
  );
}
