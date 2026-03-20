import NetInfo from '@react-native-community/netinfo';
import { v4 as uuidv4 } from 'uuid';
import { CONFIG } from '@/constants/config';
import { apiClient, ApiError } from '@/services/api/client';
import { SyncQueueRepository } from '@/services/database/repositories';
import {
  TransactionRepository,
  BankUserRepository,
  CardUserRepository,
  CategoryRepository,
  IncomeRepository,
  BillRepository,
  BillPaymentRepository,
  BudgetRepository,
  BudgetCategoryRepository,
  SavingsGoalRepository,
  NotificationRepository,
  BankRepository,
  CardRepository,
  BankTransferRepository,
  FaturaRepository,
} from '@/services/database/repositories';

type SyncStatus = 'idle' | 'syncing' | 'error' | 'offline';
type SyncListener = (status: SyncStatus, pendingCount: number) => void;

const ENTITY_API_MAP: Record<string, string> = {
  transacoes: '/transacoes',
  incomes: '/incomes',
  bills: '/bills',
  budgets: '/budgets',
  savings_goals: '/savings',
  categories: '/categories',
  bank_accounts: '/bank-accounts',
  cards: '/cards',
  notifications: '/notifications',
};

class SyncEngine {
  private syncQueue = new SyncQueueRepository();
  private intervalId: ReturnType<typeof setInterval> | null = null;
  private listeners: Set<SyncListener> = new Set();
  private status: SyncStatus = 'idle';
  private isSyncing = false;

  private repos = {
    transactions: new TransactionRepository(),
    bankUsers: new BankUserRepository(),
    cardUsers: new CardUserRepository(),
    categories: new CategoryRepository(),
    incomes: new IncomeRepository(),
    bills: new BillRepository(),
    billPayments: new BillPaymentRepository(),
    budgets: new BudgetRepository(),
    budgetCategories: new BudgetCategoryRepository(),
    savings: new SavingsGoalRepository(),
    notifications: new NotificationRepository(),
    banks: new BankRepository(),
    cards: new CardRepository(),
    transfers: new BankTransferRepository(),
    faturas: new FaturaRepository(),
  };

  subscribe(listener: SyncListener): () => void {
    this.listeners.add(listener);
    return () => this.listeners.delete(listener);
  }

  private notify(): void {
    this.syncQueue.count().then((count) => {
      this.listeners.forEach((listener) => listener(this.status, count));
    });
  }

  private setStatus(status: SyncStatus): void {
    this.status = status;
    this.notify();
  }

  async enqueue(entity: string, action: 'create' | 'update' | 'delete', data: Record<string, unknown>): Promise<void> {
    const id = uuidv4();
    await this.syncQueue.add(id, entity, action, data);
    this.notify();
    this.trySync();
  }

  async start(): Promise<void> {
    if (this.intervalId) return;

    this.intervalId = setInterval(() => {
      this.trySync();
    }, CONFIG.SYNC_INTERVAL);

    NetInfo.addEventListener((state) => {
      if (state.isConnected) {
        this.trySync();
      } else {
        this.setStatus('offline');
      }
    });

    await this.trySync();
  }

  stop(): void {
    if (this.intervalId) {
      clearInterval(this.intervalId);
      this.intervalId = null;
    }
  }

  async trySync(): Promise<void> {
    if (this.isSyncing) return;

    const netState = await NetInfo.fetch();
    if (!netState.isConnected) {
      this.setStatus('offline');
      return;
    }

    this.isSyncing = true;
    this.setStatus('syncing');

    try {
      await this.pushPendingOperations();
      await this.pullFromServer();
      this.setStatus('idle');
    } catch {
      this.setStatus('error');
    } finally {
      this.isSyncing = false;
    }
  }

  private async pushPendingOperations(): Promise<void> {
    const queue = await this.syncQueue.getAll();

    for (const item of queue) {
      if (item.retries >= CONFIG.MAX_SYNC_RETRIES) {
        await this.syncQueue.remove(item.id);
        continue;
      }

      try {
        const data = JSON.parse(item.data);
        const basePath = ENTITY_API_MAP[item.entity];
        if (!basePath) {
          await this.syncQueue.remove(item.id);
          continue;
        }

        switch (item.action) {
          case 'create':
            await apiClient.post(basePath, data);
            break;
          case 'update':
            await apiClient.put(`${basePath}/${data.id}`, data);
            break;
          case 'delete':
            await apiClient.delete(`${basePath}/${data.id}`);
            break;
        }

        await this.syncQueue.remove(item.id);
      } catch (error) {
        if (error instanceof ApiError && error.isAuthError) {
          return;
        }
        await this.syncQueue.incrementRetries(item.id);
      }
    }
  }

  async pullFromServer(): Promise<void> {
    try {
      const [
        transactionsRes,
        banksRes,
        bankAccountsRes,
        categoriesRes,
        incomesRes,
        billsRes,
        budgetsRes,
        savingsRes,
        notificationsRes,
        cardsRes,
        cardUsersRes,
      ] = await Promise.allSettled([
        apiClient.get<{ data?: unknown[]; [key: string]: unknown }>('/transacoes'),
        apiClient.get<unknown[]>('/bank-accounts/banks'),
        apiClient.get<unknown[]>('/bank-accounts'),
        apiClient.get<unknown[]>('/categories'),
        apiClient.get<unknown[]>('/incomes'),
        apiClient.get<unknown[]>('/bills'),
        apiClient.get<unknown[]>('/budgets'),
        apiClient.get<unknown[]>('/savings'),
        apiClient.get<unknown[]>('/notifications'),
        apiClient.get<unknown[]>('/cards/available'),
        apiClient.get<unknown[]>('/cards'),
      ]);

      if (transactionsRes.status === 'fulfilled') {
        const items = Array.isArray(transactionsRes.value.data)
          ? transactionsRes.value.data
          : (transactionsRes.value.data as { data?: unknown[] })?.data ?? [];
        if (Array.isArray(items)) {
          await this.repos.transactions.bulkUpsert(items as { id: number }[]);
        }
      }

      if (banksRes.status === 'fulfilled' && Array.isArray(banksRes.value.data)) {
        await this.repos.banks.bulkUpsert(banksRes.value.data as { id: number }[]);
      }

      if (bankAccountsRes.status === 'fulfilled' && Array.isArray(bankAccountsRes.value.data)) {
        await this.repos.bankUsers.bulkUpsert(bankAccountsRes.value.data as { id: number }[]);
      }

      if (categoriesRes.status === 'fulfilled' && Array.isArray(categoriesRes.value.data)) {
        await this.repos.categories.bulkUpsert(categoriesRes.value.data as { id: number }[]);
      }

      if (incomesRes.status === 'fulfilled' && Array.isArray(incomesRes.value.data)) {
        await this.repos.incomes.bulkUpsert(incomesRes.value.data as { id: number }[]);
      }

      if (billsRes.status === 'fulfilled' && Array.isArray(billsRes.value.data)) {
        await this.repos.bills.bulkUpsert(billsRes.value.data as { id: number }[]);
      }

      if (budgetsRes.status === 'fulfilled' && Array.isArray(budgetsRes.value.data)) {
        await this.repos.budgets.bulkUpsert(budgetsRes.value.data as { id: number }[]);
      }

      if (savingsRes.status === 'fulfilled' && Array.isArray(savingsRes.value.data)) {
        await this.repos.savings.bulkUpsert(savingsRes.value.data as { id: number }[]);
      }

      if (notificationsRes.status === 'fulfilled' && Array.isArray(notificationsRes.value.data)) {
        await this.repos.notifications.bulkUpsert(notificationsRes.value.data as { id: number }[]);
      }

      if (cardsRes.status === 'fulfilled' && Array.isArray(cardsRes.value.data)) {
        await this.repos.cards.bulkUpsert(cardsRes.value.data as { id: number }[]);
      }

      if (cardUsersRes.status === 'fulfilled' && Array.isArray(cardUsersRes.value.data)) {
        await this.repos.cardUsers.bulkUpsert(cardUsersRes.value.data as { id: number }[]);
      }
    } catch {
      // Silent fail on pull - offline data is still valid
    }
  }

  async getPendingCount(): Promise<number> {
    return this.syncQueue.count();
  }

  getStatus(): SyncStatus {
    return this.status;
  }
}

export const syncEngine = new SyncEngine();
