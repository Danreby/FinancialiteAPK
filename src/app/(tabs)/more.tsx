import React from 'react';
import { View, Text, ScrollView, TouchableOpacity } from 'react-native';
import { useRouter } from 'expo-router';
import { SafeAreaView } from 'react-native-safe-area-context';
import { Ionicons } from '@expo/vector-icons';
import { useAuthStore } from '@/stores/authStore';
import { Header } from '@/components/ui/Header';

interface MenuItem {
  icon: keyof typeof Ionicons.glyphMap;
  label: string;
  description: string;
  route: string;
  color: string;
  bg: string;
}

const menuItems: MenuItem[] = [
  {
    icon: 'trending-up',
    label: 'Receitas',
    description: 'Gerencie suas fontes de renda',
    route: '/incomes',
    color: '#22c55e',
    bg: 'bg-success-100 dark:bg-success-900/20',
  },
  {
    icon: 'flag',
    label: 'Metas de economia',
    description: 'Acompanhe seus objetivos financeiros',
    route: '/savings',
    color: '#6366f1',
    bg: 'bg-primary-100 dark:bg-primary-900/20',
  },
  {
    icon: 'business',
    label: 'Contas bancárias',
    description: 'Gerencie suas contas e saldos',
    route: '/banks',
    color: '#3b82f6',
    bg: 'bg-blue-100 dark:bg-blue-900/20',
  },
  {
    icon: 'notifications',
    label: 'Notificações',
    description: 'Alertas e lembretes',
    route: '/notifications',
    color: '#f59e0b',
    bg: 'bg-warning-100 dark:bg-warning-900/20',
  },
  {
    icon: 'person',
    label: 'Perfil',
    description: 'Dados pessoais e preferências',
    route: '/profile',
    color: '#8b5cf6',
    bg: 'bg-purple-100 dark:bg-purple-900/20',
  },
  {
    icon: 'settings',
    label: 'Configurações',
    description: 'Tema, segurança e dados',
    route: '/settings',
    color: '#64748b',
    bg: 'bg-dark-200 dark:bg-dark-700',
  },
];

export default function MoreScreen() {
  const router = useRouter();
  const { user, logout } = useAuthStore();

  const handleLogout = async () => {
    await logout();
    router.replace('/(auth)/login');
  };

  return (
    <SafeAreaView className="flex-1 bg-dark-100 dark:bg-dark-950" edges={['top']}>
      <Header title="Mais" />
      <ScrollView className="flex-1" showsVerticalScrollIndicator={false}>
        {/* User Info */}
        <View className="px-5 py-4">
          <TouchableOpacity
            onPress={() => router.push('/profile')}
            className="bg-white dark:bg-dark-800 rounded-2xl p-4 flex-row items-center"
            activeOpacity={0.7}
          >
            <View className="w-14 h-14 rounded-full bg-primary-500 items-center justify-center mr-4">
              <Text className="text-xl font-bold text-white">
                {user?.name?.charAt(0)?.toUpperCase() || 'U'}
              </Text>
            </View>
            <View className="flex-1">
              <Text className="text-base font-bold text-dark-900 dark:text-dark-100">
                {user?.name || 'Usuário'}
              </Text>
              <Text className="text-sm text-dark-500 dark:text-dark-400">
                {user?.email || ''}
              </Text>
            </View>
            <Ionicons name="chevron-forward" size={20} color="#94a3b8" />
          </TouchableOpacity>
        </View>

        {/* Menu Items */}
        <View className="px-5">
          {menuItems.map((item, index) => (
            <TouchableOpacity
              key={index}
              onPress={() => router.push(item.route as any)}
              className="flex-row items-center bg-white dark:bg-dark-800 rounded-2xl p-4 mb-2"
              activeOpacity={0.7}
            >
              <View className={`w-10 h-10 rounded-xl ${item.bg} items-center justify-center mr-3`}>
                <Ionicons name={item.icon} size={22} color={item.color} />
              </View>
              <View className="flex-1">
                <Text className="text-sm font-semibold text-dark-900 dark:text-dark-100">
                  {item.label}
                </Text>
                <Text className="text-xs text-dark-500 dark:text-dark-400 mt-0.5">
                  {item.description}
                </Text>
              </View>
              <Ionicons name="chevron-forward" size={18} color="#94a3b8" />
            </TouchableOpacity>
          ))}
        </View>

        {/* Logout */}
        <View className="px-5 py-6">
          <TouchableOpacity
            onPress={handleLogout}
            className="flex-row items-center justify-center bg-danger-50 dark:bg-danger-900/20 rounded-2xl p-4"
            activeOpacity={0.7}
          >
            <Ionicons name="log-out-outline" size={20} color="#ef4444" />
            <Text className="text-sm font-semibold text-danger-600 dark:text-danger-400 ml-2">
              Sair da conta
            </Text>
          </TouchableOpacity>
        </View>

        <View className="items-center pb-8">
          <Text className="text-xs text-dark-400">Financialite v1.0.0</Text>
        </View>
      </ScrollView>
    </SafeAreaView>
  );
}
