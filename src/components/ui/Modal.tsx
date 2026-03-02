import React from 'react';
import { View, Text, Modal as RNModal, TouchableOpacity, ScrollView, type ModalProps as RNModalProps, KeyboardAvoidingView, Platform } from 'react-native';
import { Ionicons } from '@expo/vector-icons';

interface ModalProps extends Omit<RNModalProps, 'children'> {
  title: string;
  onClose: () => void;
  children: React.ReactNode;
  footer?: React.ReactNode;
  size?: 'sm' | 'md' | 'lg' | 'full';
}

export function Modal({
  title,
  onClose,
  children,
  footer,
  size = 'md',
  visible,
  ...props
}: ModalProps) {
  const sizeClasses = {
    sm: 'max-h-[50%]',
    md: 'max-h-[70%]',
    lg: 'max-h-[85%]',
    full: 'max-h-[95%]',
  };

  return (
    <RNModal
      visible={visible}
      transparent
      animationType="slide"
      onRequestClose={onClose}
      statusBarTranslucent
      {...props}
    >
      <KeyboardAvoidingView
        behavior={Platform.OS === 'ios' ? 'padding' : 'height'}
        className="flex-1"
      >
        <TouchableOpacity
          className="flex-1 bg-black/50 justify-end"
          activeOpacity={1}
          onPress={onClose}
        >
          <TouchableOpacity
            activeOpacity={1}
            className={`bg-white dark:bg-dark-900 rounded-t-3xl ${sizeClasses[size]}`}
          >
            {/* Handle */}
            <View className="items-center pt-3 pb-1">
              <View className="w-10 h-1 bg-dark-300 dark:bg-dark-600 rounded-full" />
            </View>

            {/* Header */}
            <View className="flex-row items-center justify-between px-5 py-3 border-b border-dark-200 dark:border-dark-700">
              <Text className="text-lg font-bold text-dark-900 dark:text-dark-100">
                {title}
              </Text>
              <TouchableOpacity onPress={onClose} hitSlop={12}>
                <Ionicons name="close" size={24} color="#94a3b8" />
              </TouchableOpacity>
            </View>

            {/* Content */}
            <ScrollView
              className="px-5 py-4"
              showsVerticalScrollIndicator={false}
              keyboardShouldPersistTaps="handled"
            >
              {children}
            </ScrollView>

            {/* Footer */}
            {footer && (
              <View className="px-5 py-4 border-t border-dark-200 dark:border-dark-700 pb-8">
                {footer}
              </View>
            )}
          </TouchableOpacity>
        </TouchableOpacity>
      </KeyboardAvoidingView>
    </RNModal>
  );
}
