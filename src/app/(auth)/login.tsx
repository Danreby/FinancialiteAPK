import React, { useState } from 'react';
import { View, Text, ScrollView, KeyboardAvoidingView, Platform, TouchableOpacity, Image } from 'react-native';
import { useRouter } from 'expo-router';
import { SafeAreaView } from 'react-native-safe-area-context';
import { Ionicons } from '@expo/vector-icons';
import { useAuthStore } from '@/stores/authStore';
import { Button } from '@/components/ui/Button';
import { Input } from '@/components/ui/Input';

export default function LoginScreen() {
  const router = useRouter();
  const { login, isLoading, error, clearError } = useAuthStore();
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [showPassword, setShowPassword] = useState(false);

  const handleLogin = async () => {
    if (!email.trim() || !password.trim()) return;
    const success = await login(email.trim(), password);
    if (success) {
      router.replace('/(tabs)');
    }
  };

  return (
    <SafeAreaView className="flex-1 bg-white dark:bg-dark-900">
      <KeyboardAvoidingView
        behavior={Platform.OS === 'ios' ? 'padding' : 'height'}
        className="flex-1"
      >
        <ScrollView
          className="flex-1"
          contentContainerClassName="flex-grow justify-center px-6 py-8"
          keyboardShouldPersistTaps="handled"
          showsVerticalScrollIndicator={false}
        >
          {/* Logo & Header */}
          <View className="items-center mb-10">
            <View className="w-20 h-20 rounded-2xl bg-primary-500 items-center justify-center mb-4">
              <Ionicons name="wallet" size={40} color="#ffffff" />
            </View>
            <Text className="text-3xl font-bold text-dark-900 dark:text-dark-100">
              Financialite
            </Text>
            <Text className="text-base text-dark-500 dark:text-dark-400 mt-1">
              Controle financeiro inteligente
            </Text>
          </View>

          {/* Error */}
          {error && (
            <TouchableOpacity
              onPress={clearError}
              className="bg-danger-50 dark:bg-danger-900/20 border border-danger-200 dark:border-danger-800 rounded-xl p-4 mb-6"
            >
              <View className="flex-row items-center">
                <Ionicons name="alert-circle" size={20} color="#ef4444" />
                <Text className="flex-1 text-sm text-danger-700 dark:text-danger-400 ml-2">
                  {error}
                </Text>
                <Ionicons name="close" size={16} color="#ef4444" />
              </View>
            </TouchableOpacity>
          )}

          {/* Form */}
          <View className="mb-6">
            <Input
              label="E-mail"
              value={email}
              onChangeText={(text) => { clearError(); setEmail(text); }}
              placeholder="seu@email.com"
              keyboardType="email-address"
              autoCapitalize="none"
              autoComplete="email"
              leftIcon="mail-outline"
            />
            <Input
              label="Senha"
              value={password}
              onChangeText={(text) => { clearError(); setPassword(text); }}
              placeholder="Sua senha"
              secureTextEntry={!showPassword}
              autoCapitalize="none"
              leftIcon="lock-closed-outline"
              rightIcon={showPassword ? 'eye-off-outline' : 'eye-outline'}
              onRightIconPress={() => setShowPassword(!showPassword)}
            />
          </View>

          {/* Login Button */}
          <Button
            variant="primary"
            size="lg"
            onPress={handleLogin}
            loading={isLoading}
            fullWidth
          >
            Entrar
          </Button>

          {/* Register Link */}
          <View className="flex-row items-center justify-center mt-6">
            <Text className="text-sm text-dark-500 dark:text-dark-400">
              Não tem uma conta?{' '}
            </Text>
            <TouchableOpacity onPress={() => router.push('/(auth)/register')}>
              <Text className="text-sm font-semibold text-primary-600 dark:text-primary-400">
                Criar conta
              </Text>
            </TouchableOpacity>
          </View>
        </ScrollView>
      </KeyboardAvoidingView>
    </SafeAreaView>
  );
}
