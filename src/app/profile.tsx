import React, { useState, useCallback } from 'react';
import { View, Text, ScrollView, TouchableOpacity, Alert } from 'react-native';
import { useRouter } from 'expo-router';
import { SafeAreaView } from 'react-native-safe-area-context';
import { Ionicons } from '@expo/vector-icons';
import { useAuthStore } from '@/stores/authStore';
import { profileApi } from '@/services/api/profile';
import { Header } from '@/components/ui/Header';
import { Input } from '@/components/ui/Input';
import { Button } from '@/components/ui/Button';
import { Modal } from '@/components/ui/Modal';

export default function ProfileScreen() {
  const router = useRouter();
  const { user, updateUser, logout } = useAuthStore();
  const [editing, setEditing] = useState(false);
  const [saving, setSaving] = useState(false);
  const [showPasswordModal, setShowPasswordModal] = useState(false);

  // Edit form
  const [name, setName] = useState(user?.name || '');
  const [email, setEmail] = useState(user?.email || '');
  const [phone, setPhone] = useState(user?.phone || '');

  // Password form
  const [currentPassword, setCurrentPassword] = useState('');
  const [newPassword, setNewPassword] = useState('');
  const [confirmPassword, setConfirmPassword] = useState('');
  const [passwordSaving, setPasswordSaving] = useState(false);

  const handleSave = useCallback(async () => {
    if (!name.trim()) return;
    setSaving(true);
    try {
      const updated = await profileApi.update({ name: name.trim(), email: email.trim(), phone: phone.trim() });
      updateUser(updated);
      setEditing(false);
      Alert.alert('Sucesso', 'Perfil atualizado com sucesso!');
    } catch {
      Alert.alert('Erro', 'Não foi possível atualizar o perfil.');
    }
    setSaving(false);
  }, [name, email, phone, updateUser]);

  const handlePasswordChange = useCallback(async () => {
    if (!currentPassword || !newPassword || newPassword !== confirmPassword) {
      Alert.alert('Erro', 'Verifique as senhas informadas.');
      return;
    }
    setPasswordSaving(true);
    try {
      await profileApi.updatePassword({
        current_password: currentPassword,
        password: newPassword,
        password_confirmation: confirmPassword,
      });
      setShowPasswordModal(false);
      setCurrentPassword(''); setNewPassword(''); setConfirmPassword('');
      Alert.alert('Sucesso', 'Senha alterada com sucesso!');
    } catch {
      Alert.alert('Erro', 'Não foi possível alterar a senha. Verifique a senha atual.');
    }
    setPasswordSaving(false);
  }, [currentPassword, newPassword, confirmPassword]);

  const handleDeleteAccount = useCallback(() => {
    Alert.alert(
      'Excluir conta',
      'Tem certeza? Esta ação é irreversível e todos os seus dados serão perdidos.',
      [
        { text: 'Cancelar', style: 'cancel' },
        {
          text: 'Excluir',
          style: 'destructive',
          onPress: async () => {
            try {
              await profileApi.deleteAccount();
              await logout();
              router.replace('/(auth)/login');
            } catch {
              Alert.alert('Erro', 'Não foi possível excluir a conta.');
            }
          },
        },
      ]
    );
  }, [logout, router]);

  return (
    <SafeAreaView className="flex-1 bg-dark-100 dark:bg-dark-950" edges={['top']}>
      <Header
        title="Perfil"
        showBack
        rightAction={
          editing
            ? undefined
            : { icon: 'create-outline', onPress: () => setEditing(true) }
        }
      />

      <ScrollView className="flex-1 px-5 py-4" showsVerticalScrollIndicator={false}>
        {/* Avatar */}
        <View className="items-center mb-6">
          <View className="w-24 h-24 rounded-full bg-primary-500 items-center justify-center mb-3">
            <Text className="text-3xl font-bold text-white">
              {user?.name?.charAt(0)?.toUpperCase() || 'U'}
            </Text>
          </View>
          {!editing && (
            <>
              <Text className="text-xl font-bold text-dark-900 dark:text-dark-100">
                {user?.name}
              </Text>
              <Text className="text-sm text-dark-500 dark:text-dark-400">
                {user?.email}
              </Text>
            </>
          )}
        </View>

        {editing ? (
          <View>
            <Input label="Nome" value={name} onChangeText={setName} leftIcon="person-outline" />
            <Input label="E-mail" value={email} onChangeText={setEmail} keyboardType="email-address" autoCapitalize="none" leftIcon="mail-outline" />
            <Input label="Telefone" value={phone} onChangeText={setPhone} keyboardType="phone-pad" leftIcon="call-outline" />

            <View className="flex-row gap-3 mt-4">
              <View className="flex-1">
                <Button variant="outline" onPress={() => { setEditing(false); setName(user?.name || ''); setEmail(user?.email || ''); setPhone(user?.phone || ''); }} fullWidth>
                  Cancelar
                </Button>
              </View>
              <View className="flex-1">
                <Button variant="primary" onPress={handleSave} loading={saving} fullWidth>
                  Salvar
                </Button>
              </View>
            </View>
          </View>
        ) : (
          <View>
            {/* Info Cards */}
            <View className="bg-white dark:bg-dark-800 rounded-2xl p-4 mb-2">
              <View className="flex-row items-center py-2">
                <Ionicons name="person-outline" size={18} color="#6366f1" />
                <Text className="text-sm text-dark-500 dark:text-dark-400 ml-3 w-20">Nome</Text>
                <Text className="flex-1 text-sm font-medium text-dark-900 dark:text-dark-100">
                  {user?.name}
                </Text>
              </View>
              <View className="flex-row items-center py-2 border-t border-dark-100 dark:border-dark-700">
                <Ionicons name="mail-outline" size={18} color="#6366f1" />
                <Text className="text-sm text-dark-500 dark:text-dark-400 ml-3 w-20">E-mail</Text>
                <Text className="flex-1 text-sm font-medium text-dark-900 dark:text-dark-100">
                  {user?.email}
                </Text>
              </View>
              {user?.phone && (
                <View className="flex-row items-center py-2 border-t border-dark-100 dark:border-dark-700">
                  <Ionicons name="call-outline" size={18} color="#6366f1" />
                  <Text className="text-sm text-dark-500 dark:text-dark-400 ml-3 w-20">Fone</Text>
                  <Text className="flex-1 text-sm font-medium text-dark-900 dark:text-dark-100">
                    {user.phone}
                  </Text>
                </View>
              )}
            </View>

            {/* Actions */}
            <TouchableOpacity
              onPress={() => setShowPasswordModal(true)}
              className="flex-row items-center bg-white dark:bg-dark-800 rounded-2xl p-4 mb-2 mt-4"
              activeOpacity={0.7}
            >
              <View className="w-10 h-10 rounded-xl bg-warning-100 dark:bg-warning-900/20 items-center justify-center mr-3">
                <Ionicons name="key-outline" size={20} color="#f59e0b" />
              </View>
              <View className="flex-1">
                <Text className="text-sm font-semibold text-dark-900 dark:text-dark-100">Alterar senha</Text>
                <Text className="text-xs text-dark-500 dark:text-dark-400">Atualize sua senha de acesso</Text>
              </View>
              <Ionicons name="chevron-forward" size={18} color="#94a3b8" />
            </TouchableOpacity>

            <TouchableOpacity
              onPress={handleDeleteAccount}
              className="flex-row items-center bg-danger-50 dark:bg-danger-900/20 rounded-2xl p-4 mt-6"
              activeOpacity={0.7}
            >
              <View className="w-10 h-10 rounded-xl bg-danger-100 dark:bg-danger-800/40 items-center justify-center mr-3">
                <Ionicons name="trash-outline" size={20} color="#ef4444" />
              </View>
              <View className="flex-1">
                <Text className="text-sm font-semibold text-danger-600 dark:text-danger-400">Excluir conta</Text>
                <Text className="text-xs text-danger-500 dark:text-danger-500">Esta ação é irreversível</Text>
              </View>
            </TouchableOpacity>
          </View>
        )}
      </ScrollView>

      {/* Password Modal */}
      <Modal
        visible={showPasswordModal}
        title="Alterar senha"
        onClose={() => { setShowPasswordModal(false); setCurrentPassword(''); setNewPassword(''); setConfirmPassword(''); }}
        footer={
          <View className="flex-row gap-3">
            <View className="flex-1">
              <Button variant="outline" onPress={() => setShowPasswordModal(false)} fullWidth>Cancelar</Button>
            </View>
            <View className="flex-1">
              <Button variant="primary" onPress={handlePasswordChange} loading={passwordSaving} fullWidth>Alterar</Button>
            </View>
          </View>
        }
      >
        <Input label="Senha atual" value={currentPassword} onChangeText={setCurrentPassword} secureTextEntry autoCapitalize="none" leftIcon="lock-closed-outline" />
        <Input label="Nova senha" value={newPassword} onChangeText={setNewPassword} secureTextEntry autoCapitalize="none" leftIcon="lock-open-outline" />
        <Input label="Confirmar nova senha" value={confirmPassword} onChangeText={setConfirmPassword} secureTextEntry autoCapitalize="none" leftIcon="lock-open-outline" />
      </Modal>
    </SafeAreaView>
  );
}
