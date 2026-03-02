import React, { useEffect, useState, useCallback } from 'react';
import { View, Text, FlatList, RefreshControl, TouchableOpacity } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { Ionicons } from '@expo/vector-icons';
import { transacoesApi } from '@/services/api/transactions';
import { categoriesApi } from '@/services/api/categories';
import { formatCurrency } from '@/utils/format';
import { getCurrentMonthKey } from '@/utils/date';
import { Header } from '@/components/ui/Header';
import { Loading } from '@/components/ui/Loading';
import { EmptyState } from '@/components/ui/EmptyState';
import { Modal } from '@/components/ui/Modal';
import { Input } from '@/components/ui/Input';
import { Button } from '@/components/ui/Button';
import { Select } from '@/components/ui/Select';
import { MoneyInput } from '@/components/ui/MoneyInput';
import { TransactionCard } from '@/components/cards/TransactionCard';
import type { Transacao, Category, PaginatedResponse } from '@/types';

type FilterType = 'all' | 'credit' | 'debit';

export default function TransactionsScreen() {
  const [loading, setLoading] = useState(true);
  const [refreshing, setRefreshing] = useState(false);
  const [transactions, setTransactions] = useState<Transacao[]>([]);
  const [categories, setCategories] = useState<Category[]>([]);
  const [page, setPage] = useState(1);
  const [hasMore, setHasMore] = useState(true);
  const [loadingMore, setLoadingMore] = useState(false);
  const [filter, setFilter] = useState<FilterType>('all');
  const [showCreate, setShowCreate] = useState(false);
  const [stats, setStats] = useState<{ total_credit: number; total_debit: number } | null>(null);

  // Form state
  const [formDescription, setFormDescription] = useState('');
  const [formAmount, setFormAmount] = useState('');
  const [formType, setFormType] = useState<string>('debit');
  const [formCategory, setFormCategory] = useState<string | number | undefined>();
  const [formSaving, setFormSaving] = useState(false);

  const loadData = useCallback(async (pageNum = 1, filterType: FilterType = filter) => {
    try {
      const currentMonth = getCurrentMonthKey();
      const [year, month] = currentMonth.split('-');

      const params: Record<string, string | number> = { page: pageNum, per_page: 20, month, year };
      if (filterType !== 'all') params.type = filterType;

      const response = await transacoesApi.list(params) as PaginatedResponse<Transacao>;

      if (pageNum === 1) {
        setTransactions(response.data);
      } else {
        setTransactions((prev) => [...prev, ...response.data]);
      }
      setHasMore(response.current_page < response.last_page);
      setPage(pageNum);

      if (pageNum === 1) {
        const s = await transacoesApi.stats({ month, year });
        setStats(s);
      }
    } catch {
      // offline - use local data
    } finally {
      setLoading(false);
      setRefreshing(false);
      setLoadingMore(false);
    }
  }, [filter]);

  const loadCategories = useCallback(async () => {
    try {
      const cats = await categoriesApi.list();
      setCategories(Array.isArray(cats) ? cats : []);
    } catch {}
  }, []);

  useEffect(() => {
    loadData(1);
    loadCategories();
  }, []);

  const onRefresh = useCallback(async () => {
    setRefreshing(true);
    await loadData(1);
  }, [loadData]);

  const onLoadMore = useCallback(() => {
    if (!hasMore || loadingMore) return;
    setLoadingMore(true);
    loadData(page + 1);
  }, [hasMore, loadingMore, page, loadData]);

  const onFilterChange = useCallback((newFilter: FilterType) => {
    setFilter(newFilter);
    setLoading(true);
    loadData(1, newFilter);
  }, [loadData]);

  const handleCreate = useCallback(async () => {
    if (!formDescription.trim() || !formAmount) return;
    setFormSaving(true);
    try {
      const numericValue = parseInt(formAmount, 10) / 100;
      await transacoesApi.create({
        title: formDescription.trim(),
        amount: numericValue,
        type: formType as 'credit' | 'debit',
        category_id: formCategory ? Number(formCategory) : undefined,
      });
      setShowCreate(false);
      resetForm();
      loadData(1);
    } catch {}
    setFormSaving(false);
  }, [formDescription, formAmount, formType, formCategory, categories, loadData]);

  const resetForm = () => {
    setFormDescription('');
    setFormAmount('');
    setFormType('debit');
    setFormCategory(undefined);
  };

  const categoryOptions = categories.map((c) => ({
    label: c.name,
    value: c.id,
  }));

  if (loading) {
    return <Loading fullScreen message="Carregando transações..." />;
  }

  return (
    <SafeAreaView className="flex-1 bg-dark-100 dark:bg-dark-950" edges={['top']}>
      <Header
        title="Transações"
        rightAction={{ icon: 'add-circle-outline', onPress: () => setShowCreate(true) }}
      />

      {/* Stats Bar */}
      {stats && (
        <View className="flex-row px-5 py-3 gap-3">
          <View className="flex-1 bg-success-50 dark:bg-success-900/20 rounded-xl p-3">
            <Text className="text-xs text-success-600 dark:text-success-400">Entradas</Text>
            <Text className="text-sm font-bold text-success-700 dark:text-success-300">
              {formatCurrency(stats.total_credit || 0)}
            </Text>
          </View>
          <View className="flex-1 bg-danger-50 dark:bg-danger-900/20 rounded-xl p-3">
            <Text className="text-xs text-danger-600 dark:text-danger-400">Saídas</Text>
            <Text className="text-sm font-bold text-danger-700 dark:text-danger-300">
              {formatCurrency(stats.total_debit || 0)}
            </Text>
          </View>
        </View>
      )}

      {/* Filters */}
      <View className="flex-row px-5 py-2 gap-2">
        {(['all', 'credit', 'debit'] as FilterType[]).map((f) => (
          <TouchableOpacity
            key={f}
            onPress={() => onFilterChange(f)}
            className={`px-4 py-2 rounded-full ${
              filter === f
                ? 'bg-primary-500'
                : 'bg-white dark:bg-dark-800'
            }`}
          >
            <Text className={`text-xs font-semibold ${
              filter === f
                ? 'text-white'
                : 'text-dark-600 dark:text-dark-400'
            }`}>
              {f === 'all' ? 'Todas' : f === 'credit' ? 'Receitas' : 'Despesas'}
            </Text>
          </TouchableOpacity>
        ))}
      </View>

      {/* Transaction List */}
      <FlatList
        data={transactions}
        keyExtractor={(item) => String(item.id)}
        contentContainerClassName="px-5 py-3"
        renderItem={({ item }) => <TransactionCard transaction={item} />}
        ListEmptyComponent={
          <EmptyState
            icon="receipt-outline"
            title="Nenhuma transação"
            description="Suas transações aparecerão aqui"
            actionLabel="Nova transação"
            onAction={() => setShowCreate(true)}
          />
        }
        refreshControl={
          <RefreshControl refreshing={refreshing} onRefresh={onRefresh} tintColor="#6366f1" />
        }
        onEndReached={onLoadMore}
        onEndReachedThreshold={0.3}
        ListFooterComponent={loadingMore ? <Loading size="small" /> : null}
        showsVerticalScrollIndicator={false}
      />

      {/* Create Modal */}
      <Modal
        visible={showCreate}
        title="Nova transação"
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
          label="Descrição"
          value={formDescription}
          onChangeText={setFormDescription}
          placeholder="Ex: Almoço, Salário..."
          leftIcon="create-outline"
        />
        <MoneyInput
          label="Valor"
          value={formAmount}
          onChangeValue={setFormAmount}
        />
        <Select
          label="Tipo"
          value={formType}
          onChange={(v) => setFormType(String(v))}
          options={[
            { label: 'Despesa', value: 'debit', icon: 'arrow-up-circle', color: '#ef4444' },
            { label: 'Receita', value: 'credit', icon: 'arrow-down-circle', color: '#22c55e' },
          ]}
        />
        <Select
          label="Categoria"
          value={formCategory}
          onChange={setFormCategory}
          options={categoryOptions}
          placeholder="Selecione uma categoria"
        />
      </Modal>
    </SafeAreaView>
  );
}
