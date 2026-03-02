import React, { useState } from 'react';
import { View, Text, ScrollView, KeyboardAvoidingView, Platform, TouchableOpacity } from 'react-native';
import { useRouter } from 'expo-router';
import { SafeAreaView } from 'react-native-safe-area-context';
import { Ionicons } from '@expo/vector-icons';
import { useAuthStore } from '@/stores/authStore';
import { Button } from '@/components/ui/Button';
import { Input } from '@/components/ui/Input';

export default function RegisterScreen() {
  const router = useRouter();
  const { register, isLoading, error, clearError } = useAuthStore();
  const [name, setName] = useState('');
  const [email, setEmail] = useState('');
  const [phone, setPhone] = useState('');
  const [password, setPassword] = useState('');
  const [passwordConfirmation, setPasswordConfirmation] = useState('');
  const [showPassword, setShowPassword] = useState(false);

  const handleRegister = async () => {
    if (!name.trim() || !email.trim() || !password.trim()) return;
    const success = await register({
      name: name.trim(),
      email: email.trim(),
      password,
      password_confirmation: passwordConfirmation,
      phone: phone.trim() || undefined,
    });
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
          contentContainerClassName="flex-grow px-6 py-8"
          keyboardShouldPersistTaps="handled"
          showsVerticalScrollIndicator={false}
        >
          {/* Header */}
          <View className="flex-row items-center mb-8">
            <TouchableOpacity onPress={() => router.back()} hitSlop={12} className="mr-3">
              <Ionicons name="arrow-back" size={24} color="#64748b" />
            </TouchableOpacity>
            <View>
              <Text className="text-2xl font-bold text-dark-900 dark:text-dark-100">
                Criar conta
              </Text>
              <Text className="text-sm text-dark-500 dark:text-dark-400 mt-0.5">
                Preencha seus dados para começar
              </Text>
            </View>
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
              label="Nome completo"
              value={name}
              onChangeText={(text) => { clearError(); setName(text); }}
              placeholder="Seu nome"
              autoCapitalize="words"
              autoComplete="name"
              leftIcon="person-outline"
            />
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
              label="Telefone (opcional)"
              value={phone}
              onChangeText={setPhone}
              placeholder="(00) 00000-0000"
              keyboardType="phone-pad"
              leftIcon="call-outline"
            />
            <Input
              label="Senha"
              value={password}
              onChangeText={(text) => { clearError(); setPassword(text); }}
              placeholder="Mínimo 8 caracteres"
              secureTextEntry={!showPassword}
              autoCapitalize="none"
              leftIcon="lock-closed-outline"
              rightIcon={showPassword ? 'eye-off-outline' : 'eye-outline'}
              onRightIconPress={() => setShowPassword(!showPassword)}
            />
            <Input
              label="Confirmar senha"
              value={passwordConfirmation}
              onChangeText={(text) => { clearError(); setPasswordConfirmation(text); }}
              placeholder="Repita a senha"
              secureTextEntry={!showPassword}
              autoCapitalize="none"
              leftIcon="lock-closed-outline"
            />
          </View>

          {/* Register Button */}
          <Button
            variant="primary"
            size="lg"
            onPress={handleRegister}
            loading={isLoading}
            fullWidth
          >
            Criar conta
          </Button>

          {/* Login Link */}
          <View className="flex-row items-center justify-center mt-6 mb-4">
            <Text className="text-sm text-dark-500 dark:text-dark-400">
              Já tem uma conta?{' '}
            </Text>
            <TouchableOpacity onPress={() => router.back()}>
              <Text className="text-sm font-semibold text-primary-600 dark:text-primary-400">
                Fazer login
              </Text>
            </TouchableOpacity>
          </View>
        </ScrollView>
      </KeyboardAvoidingView>
    </SafeAreaView>
  );
}
