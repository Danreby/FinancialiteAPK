import { create } from 'zustand';
import { syncAll, isOnline, type SyncStatus } from '@/services/sync/engine';
import { CONFIG } from '@/constants/config';

interface SyncState {
  status: SyncStatus;
  lastSync: string | null;
  isOnline: boolean;
  message: string | null;
  error: string | null;

  checkConnection: () => Promise<void>;
  sync: () => Promise<boolean>;
  setStatus: (status: SyncStatus) => void;
  setSyncMessage: (message: string | null) => void;
}

export const useSyncStore = create<SyncState>((set, get) => ({
  status: 'idle',
  lastSync: null,
  isOnline: true,
  message: null,
  error: null,

  checkConnection: async () => {
    const online = await isOnline();
    set({ isOnline: online });
    if (!online) set({ status: 'offline' });
  },

  sync: async () => {
    if (get().status === 'syncing') return false;

    const result = await syncAll({
      onStatusChange: (status) => set({ status }),
      onProgress: (message) => set({ message }),
      onError: (error) => set({ error }),
    });

    if (result) {
      set({ lastSync: new Date().toISOString(), message: null });
    }

    return result;
  },

  setStatus: (status) => set({ status }),
  setSyncMessage: (message) => set({ message }),
}));

let syncInterval: ReturnType<typeof setInterval> | null = null;

export function startAutoSync(): void {
  if (syncInterval) return;
  syncInterval = setInterval(() => {
    const { sync, isOnline } = useSyncStore.getState();
    if (isOnline) {
      sync();
    }
  }, CONFIG.SYNC_INTERVAL_MS);
}

export function stopAutoSync(): void {
  if (syncInterval) {
    clearInterval(syncInterval);
    syncInterval = null;
  }
}
