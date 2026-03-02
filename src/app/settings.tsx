import React, { useState, useCallback } from 'react';
import { View, Text, ScrollView, TouchableOpacity, Alert, useColorScheme, Switch } from 'react-native';
import { useRouter } from 'expo-router';
import { SafeAreaView } from 'react-native-safe-area-context';
import { Ionicons } from '@expo/vector-icons';
import { useAuthStore } from '@/stores/authStore';
import { useSyncStore } from '@/stores/syncStore';
import { clearDatabase } from '@/services/database';
import { Header } from '@/components/ui/Header';
import { Button } from '@/components/ui/Button';

interface SettingItem {
  icon: keyof typeof Ionicons.glyphMap;
  label: string;
  description?: string;
  onPress?: () => void;
  rightContent?: React.ReactNode;
  color?: string;
  danger?: boolean;
}

export default function SettingsScreen() {
  const router = useRouter();
  const colorScheme = useColorScheme();
  const { logout } = useAuthStore();
  const { sync, lastSync, isOnline: online } = useSyncStore();
  const [syncing, setSyncing] = useState(false);

  const handleSyncNow = useCallback(async () => {
    setSyncing(true);
    await sync();
    setSyncing(false);
    Alert.alert('Sincronização', 'Dados sincronizados com sucesso!');
  }, [sync]);

  const handleClearCache = useCallback(() => {
    Alert.alert(
      'Limpar cache',
      'Isso removerá os dados locais. Seus dados no servidor não serão afetados.',
      [
        { text: 'Cancelar', style: 'cancel' },
        {
          text: 'Limpar',
          style: 'destructive',
          onPress: async () => {
            await clearDatabase();
            Alert.alert('Sucesso', 'Cache limpo. Os dados serão sincronizados novamente.');
          },
        },
      ]
    );
  }, []);

  const handleLogout = useCallback(async () => {
    Alert.alert('Sair', 'Deseja realmente sair?', [
      { text: 'Cancelar', style: 'cancel' },
      {
        text: 'Sair',
        onPress: async () => {
          await logout();
          router.replace('/(auth)/login');
        },
      },
    ]);
  }, [logout, router]);

  const sections: { title: string; items: SettingItem[] }[] = [
    {
      title: 'Conta',
      items: [
        {
          icon: 'person-outline',
          label: 'Perfil',
          description: 'Dados pessoais e foto',
          onPress: () => router.push('/profile'),
          color: '#6366f1',
        },
        {
          icon: 'key-outline',
          label: 'Segurança',
          description: 'Senha e autenticação',
          onPress: () => router.push('/profile'),
          color: '#f59e0b',
        },
      ],
    },
    {
      title: 'Aparência',
      items: [
        {
          icon: colorScheme === 'dark' ? 'moon' : 'sunny',
          label: 'Tema',
          description: colorScheme === 'dark' ? 'Escuro' : 'Claro',
          color: colorScheme === 'dark' ? '#8b5cf6' : '#f59e0b',
          rightContent: (
            <Text className="text-xs text-dark-500 dark:text-dark-400">
              Seguindo o sistema
            </Text>
          ),
        },
      ],
    },
    {
      title: 'Dados',
      items: [
        {
          icon: 'sync-outline',
          label: 'Sincronizar agora',
          description: online ? 'Conectado' : 'Offline',
          onPress: handleSyncNow,
          color: '#22c55e',
          rightContent: syncing ? (
            <Text className="text-xs text-primary-500">Sincronizando...</Text>
          ) : lastSync ? (
            <Text className="text-xs text-dark-400">
              {new Date(lastSync).toLocaleString('pt-BR', { hour: '2-digit', minute: '2-digit' })}
            </Text>
          ) : null,
        },
        {
          icon: 'trash-bin-outline',
          label: 'Limpar cache local',
          description: 'Remove dados armazenados localmente',
          onPress: handleClearCache,
          color: '#f97316',
        },
      ],
    },
    {
      title: 'Sobre',
      items: [
        {
          icon: 'information-circle-outline',
          label: 'Versão',
          color: '#64748b',
          rightContent: <Text className="text-xs text-dark-400">1.0.0</Text>,
        },
      ],
    },
  ];

  return (
    <SafeAreaView className="flex-1 bg-dark-100 dark:bg-dark-950" edges={['top']}>
      <Header title="Configurações" showBack />

      <ScrollView className="flex-1" showsVerticalScrollIndicator={false}>
        {sections.map((section) => (
          <View key={section.title} className="mb-4">
            <Text className="text-xs font-semibold text-dark-500 dark:text-dark-400 px-5 py-2 uppercase tracking-wider">
              {section.title}
            </Text>
            <View className="px-5">
              {section.items.map((item, index) => (
                <TouchableOpacity
                  key={index}
                  onPress={item.onPress}
                  disabled={!item.onPress}
                  className="flex-row items-center bg-white dark:bg-dark-800 rounded-2xl p-4 mb-1"
                  activeOpacity={item.onPress ? 0.7 : 1}
                >
                  <View className={`w-9 h-9 rounded-xl items-center justify-center mr-3`}
                    style={{ backgroundColor: `${item.color || '#6366f1'}15` }}
                  >
                    <Ionicons name={item.icon} size={20} color={item.color || '#6366f1'} />
                  </View>
                  <View className="flex-1">
                    <Text className={`text-sm font-medium ${
                      item.danger ? 'text-danger-600' : 'text-dark-900 dark:text-dark-100'
                    }`}>
                      {item.label}
                    </Text>
                    {item.description && (
                      <Text className="text-xs text-dark-500 dark:text-dark-400 mt-0.5">
                        {item.description}
                      </Text>
                    )}
                  </View>
                  {item.rightContent || (item.onPress && (
                    <Ionicons name="chevron-forward" size={18} color="#94a3b8" />
                  ))}
                </TouchableOpacity>
              ))}
            </View>
          </View>
        ))}

        {/* Logout */}
        <View className="px-5 py-4">
          <Button variant="danger" onPress={handleLogout} fullWidth icon="log-out-outline">
            Sair da conta
          </Button>
        </View>

        <View className="items-center pb-8">
          <Text className="text-xs text-dark-400">Financialite © 2025</Text>
        </View>
      </ScrollView>
    </SafeAreaView>
  );
}
