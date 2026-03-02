import NetInfo from '@react-native-community/netinfo';
import { localDb } from '@/services/database/repository';
import { transacoesApi } from '@/services/api/transactions';
import { incomesApi } from '@/services/api/incomes';
import { billsApi } from '@/services/api/bills';
import { categoriesApi } from '@/services/api/categories';
import { budgetsApi } from '@/services/api/budgets';
import { savingsApi } from '@/services/api/savings';
import { banksApi } from '@/services/api/banks';
import { notificationsApi } from '@/services/api/notifications';
import { dashboardApi } from '@/services/api/dashboard';
import { SecureStorage } from '@/services/storage/secure';
import { CONFIG } from '@/constants/config';

export type SyncStatus = 'idle' | 'syncing' | 'success' | 'error' | 'offline';

interface SyncCallbacks {
  onStatusChange?: (status: SyncStatus) => void;
  onProgress?: (message: string) => void;
  onError?: (error: string) => void;
}

export async function isOnline(): Promise<boolean> {
  const state = await NetInfo.fetch();
  return state.isConnected === true && state.isInternetReachable !== false;
}

export async function syncAll(callbacks?: SyncCallbacks): Promise<boolean> {
  const online = await isOnline();
  if (!online) {
    callbacks?.onStatusChange?.('offline');
    return false;
  }

  callbacks?.onStatusChange?.('syncing');

  try {
    // 1. Push local changes first
    callbacks?.onProgress?.('Enviando alterações locais...');
    await pushLocalChanges();

    // 2. Pull server data
    callbacks?.onProgress?.('Baixando dados do servidor...');
    await pullServerData();

    // 3. Update last sync timestamp
    await SecureStorage.setLastSync(new Date().toISOString());

    callbacks?.onStatusChange?.('success');
    return true;
  } catch (error) {
    const message = error instanceof Error ? error.message : 'Erro desconhecido na sincronização.';
    callbacks?.onError?.(message);
    callbacks?.onStatusChange?.('error');
    return false;
  }
}

async function pushLocalChanges(): Promise<void> {
  const queue = await localDb.getSyncQueue();

  for (const item of queue) {
    if (item.retries >= CONFIG.MAX_SYNC_RETRIES) {
      await localDb.removeSyncQueueItem(item.id);
      continue;
    }

    try {
      const data = JSON.parse(item.data);
      await processSyncItem(item.entity, item.action, data);
      await localDb.removeSyncQueueItem(item.id);
    } catch (error) {
      const msg = error instanceof Error ? error.message : 'Erro desconhecido';
      await localDb.incrementSyncRetry(item.id, msg);
    }
  }
}

async function processSyncItem(entity: string, action: string, data: Record<string, unknown>): Promise<void> {
  const serverId = data.server_id as number | undefined;

  switch (entity) {
    case 'transacoes':
      if (action === 'create') {
        const result = await transacoesApi.create(data as Parameters<typeof transacoesApi.create>[0]);
        if (data.local_id) await localDb.markSynced('transacoes', data.local_id as number, result.id);
      } else if (action === 'update' && serverId) {
        await transacoesApi.update(serverId, data as Parameters<typeof transacoesApi.update>[1]);
      } else if (action === 'delete' && serverId) {
        await transacoesApi.delete(serverId);
      }
      break;

    case 'incomes':
      if (action === 'create') {
        const result = await incomesApi.create(data as Parameters<typeof incomesApi.create>[0]);
        if (data.local_id) await localDb.markSynced('incomes', data.local_id as number, result.id);
      } else if (action === 'update' && serverId) {
        await incomesApi.update(serverId, data as Parameters<typeof incomesApi.update>[1]);
      } else if (action === 'delete' && serverId) {
        await incomesApi.delete(serverId);
      }
      break;

    case 'bills':
      if (action === 'create') {
        const result = await billsApi.create(data as Parameters<typeof billsApi.create>[0]);
        if (data.local_id) await localDb.markSynced('bills', data.local_id as number, result.id);
      } else if (action === 'update' && serverId) {
        await billsApi.update(serverId, data as Parameters<typeof billsApi.update>[1]);
      } else if (action === 'delete' && serverId) {
        await billsApi.delete(serverId);
      }
      break;

    case 'categories':
      if (action === 'create') {
        const result = await categoriesApi.create(data as Parameters<typeof categoriesApi.create>[0]);
        if (data.local_id) await localDb.markSynced('categories', data.local_id as number, result.id);
      } else if (action === 'update' && serverId) {
        await categoriesApi.update(serverId, data as Parameters<typeof categoriesApi.update>[1]);
      } else if (action === 'delete' && serverId) {
        await categoriesApi.delete(serverId);
      }
      break;

    case 'savings_goals':
      if (action === 'create') {
        const result = await savingsApi.create(data as Parameters<typeof savingsApi.create>[0]);
        if (data.local_id) await localDb.markSynced('savings_goals', data.local_id as number, result.id);
      } else if (action === 'update' && serverId) {
        await savingsApi.update(serverId, data as Parameters<typeof savingsApi.update>[1]);
      } else if (action === 'delete' && serverId) {
        await savingsApi.delete(serverId);
      }
      break;
  }
}

async function pullServerData(): Promise<void> {
  // Pull all data from server and upsert locally
  const [categories, transactions, incomes, bills, budgets, savings, bankAccounts, notifications] = await Promise.all([
    categoriesApi.list().catch(() => []),
    transacoesApi.list({ per_page: 200 }).catch(() => ({ data: [] })),
    incomesApi.list().catch(() => []),
    billsApi.list().catch(() => []),
    budgetsApi.list().catch(() => []),
    savingsApi.list().catch(() => []),
    banksApi.listAccounts().catch(() => []),
    notificationsApi.list(1, 50).catch(() => ({ data: [] })),
  ]);

  // Upsert categories
  for (const cat of categories) {
    await localDb.upsertFromServer('categories', cat.id, {
      name: cat.name,
      color: cat.color,
      icon: cat.icon,
      type: cat.type,
      user_id: cat.user_id,
      created_at: new Date().toISOString(),
      updated_at: new Date().toISOString(),
    });
  }

  // Upsert transactions
  const txData = 'data' in transactions ? transactions.data : [];
  for (const tx of txData) {
    await localDb.upsertFromServer('transacoes', tx.id, {
      title: tx.title,
      description: tx.description,
      amount: parseFloat(tx.amount),
      type: tx.type,
      status: tx.status,
      paid_date: tx.paid_date,
      total_installments: tx.total_installments,
      current_installment: tx.current_installment,
      is_recurring: tx.is_recurring ? 1 : 0,
      user_id: tx.user_id,
      bank_user_id: tx.bank_user_id,
      category_id: tx.category_id,
      created_at: tx.created_at,
      updated_at: tx.updated_at,
    });
  }

  // Upsert incomes
  for (const inc of incomes) {
    await localDb.upsertFromServer('incomes', inc.id, {
      title: inc.title,
      description: inc.description,
      amount: parseFloat(inc.amount),
      type: inc.type,
      payment_day_type: inc.payment_day_type,
      payment_day_value: inc.payment_day_value,
      is_active: inc.is_active ? 1 : 0,
      is_recurring: inc.is_recurring ? 1 : 0,
      received_at: inc.received_at,
      bank_user_id: inc.bank_user_id,
      bank_account_id: inc.bank_account_id,
      user_id: inc.user_id,
      created_at: inc.created_at,
      updated_at: new Date().toISOString(),
    });
  }

  // Upsert bills
  for (const bill of bills) {
    await localDb.upsertFromServer('bills', bill.id, {
      title: bill.title,
      description: bill.description,
      amount: bill.amount,
      recurrence_type: bill.recurrence_type,
      due_day: bill.due_day,
      start_date: bill.start_date,
      end_date: bill.end_date,
      color: bill.color,
      icon: bill.icon,
      status: bill.status,
      category_id: bill.category_id,
      user_id: bill.user_id,
      created_at: new Date().toISOString(),
      updated_at: new Date().toISOString(),
    });
  }

  // Upsert budgets
  for (const budgetItem of budgets) {
    const b = 'budget' in budgetItem ? budgetItem.budget : budgetItem;
    await localDb.upsertFromServer('budgets', b.id, {
      monthly_limit: b.monthly_limit,
      month_year: b.month_year,
      is_active: b.is_active ? 1 : 0,
      user_id: b.user_id,
      created_at: new Date().toISOString(),
      updated_at: new Date().toISOString(),
    });
  }

  // Upsert savings goals
  for (const goal of savings) {
    await localDb.upsertFromServer('savings_goals', goal.id, {
      title: goal.title,
      description: goal.description,
      target_amount: goal.target_amount,
      current_amount: goal.current_amount,
      icon: goal.icon,
      color: goal.color,
      is_active: goal.is_active ? 1 : 0,
      completed_at: goal.completed_at,
      user_id: goal.user_id,
      created_at: goal.created_at,
      updated_at: new Date().toISOString(),
    });
  }

  // Upsert bank accounts
  for (const ba of bankAccounts) {
    await localDb.upsertFromServer('bank_accounts', ba.id, {
      bank_id: ba.bank_id,
      bank_name: ba.name ?? ba.bank?.name ?? 'Banco',
      balance: ba.balance,
      user_id: ba.user_id,
      created_at: new Date().toISOString(),
      updated_at: new Date().toISOString(),
    });
  }

  // Upsert notifications
  const notifData = 'data' in notifications ? notifications.data : [];
  for (const notif of notifData) {
    await localDb.upsertFromServer('notifications', notif.id, {
      title: notif.title,
      message: notif.message,
      type: notif.type,
      is_read: notif.is_read ? 1 : 0,
      read_at: notif.read_at,
      user_id: notif.user_id,
      created_at: notif.created_at,
    });
  }
}

export async function initialSync(callbacks?: SyncCallbacks): Promise<boolean> {
  return syncAll(callbacks);
}
