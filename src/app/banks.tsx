import React, { useEffect, useState, useCallback } from 'react';
import { View, Text, FlatList, RefreshControl } from 'react-native';
import { SafeAreaView } from 'react-native-safe-area-context';
import { banksApi } from '@/services/api/banks';
import { Header } from '@/components/ui/Header';
import { Loading } from '@/components/ui/Loading';
import { EmptyState } from '@/components/ui/EmptyState';
import { Modal } from '@/components/ui/Modal';
import { Button } from '@/components/ui/Button';
import { MoneyInput } from '@/components/ui/MoneyInput';
import { Select } from '@/components/ui/Select';
import { BankCard } from '@/components/cards/BankCard';
import { formatCurrency } from '@/utils/format';
import type { BankUser, Bank } from '@/types';

export default function BanksScreen() {
  const [loading, setLoading] = useState(true);
  const [refreshing, setRefreshing] = useState(false);
  const [accounts, setAccounts] = useState<BankUser[]>([]);
  const [availableBanks, setAvailableBanks] = useState<Bank[]>([]);
  const [showCreate, setShowCreate] = useState(false);
  const [showTransfer, setShowTransfer] = useState(false);
  const [formSaving, setFormSaving] = useState(false);

  // Create form
  const [formBank, setFormBank] = useState<string | number | undefined>();
  const [formSaldo, setFormSaldo] = useState('');

  // Transfer form
  const [transferFrom, setTransferFrom] = useState<string | number | undefined>();
  const [transferTo, setTransferTo] = useState<string | number | undefined>();
  const [transferAmount, setTransferAmount] = useState('');

  const loadData = useCallback(async () => {
    try {
      const [accs, banks] = await Promise.all([
        banksApi.listAccounts(),
        banksApi.availableBanks().catch(() => []),
      ]);
      setAccounts(Array.isArray(accs) ? accs : (accs as any)?.data || []);
      setAvailableBanks(Array.isArray(banks) ? banks : []);
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
    if (!formBank || !formSaldo) return;
    setFormSaving(true);
    try {
      await banksApi.create({
        bank_id: Number(formBank),
        balance: parseInt(formSaldo, 10) / 100,
      });
      setShowCreate(false);
      setFormBank(undefined); setFormSaldo('');
      loadData();
    } catch {}
    setFormSaving(false);
  }, [formBank, formSaldo, loadData]);

  const handleTransfer = useCallback(async () => {
    if (!transferFrom || !transferTo || !transferAmount) return;
    if (transferFrom === transferTo) return;
    setFormSaving(true);
    try {
      await banksApi.transfer({
        from_bank_user_id: Number(transferFrom),
        to_bank_user_id: Number(transferTo),
        amount: parseInt(transferAmount, 10) / 100,
      });
      setShowTransfer(false);
      setTransferFrom(undefined); setTransferTo(undefined); setTransferAmount('');
      loadData();
    } catch {}
    setFormSaving(false);
  }, [transferFrom, transferTo, transferAmount, loadData]);

  if (loading) return <Loading fullScreen message="Carregando contas..." />;

  const totalBalance = accounts.reduce((sum, a) => sum + (a.balance || 0), 0);
  const bankOptions = availableBanks.map((b) => ({ label: b.name, value: b.id }));
  const accountOptions = accounts.map((a) => ({
    label: a.bank?.name || a.name || 'Conta',
    value: a.id,
  }));

  return (
    <SafeAreaView className="flex-1 bg-dark-100 dark:bg-dark-950" edges={['top']}>
      <Header
        title="Contas Bancárias"
        showBack
        rightActions={[
          { icon: 'swap-horizontal-outline', onPress: () => setShowTransfer(true) },
          { icon: 'add-circle-outline', onPress: () => setShowCreate(true) },
        ]}
      />

      {/* Total Balance */}
      <View className="px-5 py-3">
        <View className="bg-white dark:bg-dark-800 rounded-2xl p-5">
          <Text className="text-xs text-dark-500 dark:text-dark-400">Saldo total</Text>
          <Text className={`text-2xl font-bold mt-1 ${
            totalBalance >= 0 ? 'text-success-500' : 'text-danger-500'
          }`}>
            {formatCurrency(totalBalance)}
          </Text>
          <Text className="text-xs text-dark-400 mt-1">
            {accounts.length} {accounts.length === 1 ? 'conta' : 'contas'}
          </Text>
        </View>
      </View>

      <FlatList
        data={accounts}
        keyExtractor={(item) => String(item.id)}
        contentContainerClassName="px-5 py-2"
        renderItem={({ item }) => <BankCard bankAccount={item} />}
        ListEmptyComponent={
          <EmptyState
            icon="business-outline"
            title="Nenhuma conta"
            description="Adicione suas contas bancárias"
            actionLabel="Nova conta"
            onAction={() => setShowCreate(true)}
          />
        }
        refreshControl={<RefreshControl refreshing={refreshing} onRefresh={onRefresh} tintColor="#6366f1" />}
        showsVerticalScrollIndicator={false}
      />

      {/* Create Modal */}
      <Modal visible={showCreate} title="Nova conta bancária" onClose={() => setShowCreate(false)}
        footer={
          <View className="flex-row gap-3">
            <View className="flex-1"><Button variant="outline" onPress={() => setShowCreate(false)} fullWidth>Cancelar</Button></View>
            <View className="flex-1"><Button variant="primary" onPress={handleCreate} loading={formSaving} fullWidth>Salvar</Button></View>
          </View>
        }
      >
        <Select label="Banco" value={formBank} onChange={setFormBank} options={bankOptions} placeholder="Selecione o banco" />
        <MoneyInput label="Saldo inicial" value={formSaldo} onChangeValue={setFormSaldo} />
      </Modal>

      {/* Transfer Modal */}
      <Modal visible={showTransfer} title="Transferência" onClose={() => setShowTransfer(false)}
        footer={
          <View className="flex-row gap-3">
            <View className="flex-1"><Button variant="outline" onPress={() => setShowTransfer(false)} fullWidth>Cancelar</Button></View>
            <View className="flex-1"><Button variant="primary" onPress={handleTransfer} loading={formSaving} fullWidth>Transferir</Button></View>
          </View>
        }
      >
        <Select label="Conta de origem" value={transferFrom} onChange={setTransferFrom} options={accountOptions} />
        <Select label="Conta de destino" value={transferTo} onChange={setTransferTo} options={accountOptions} />
        <MoneyInput label="Valor" value={transferAmount} onChangeValue={setTransferAmount} />
      </Modal>
    </SafeAreaView>
  );
}
