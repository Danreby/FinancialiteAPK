import React, { useEffect, useState } from 'react';
import { View, Text, Animated } from 'react-native';
import { Ionicons } from '@expo/vector-icons';
import NetInfo from '@react-native-community/netinfo';

export function NetworkBanner() {
  const [isOffline, setIsOffline] = useState(false);
  const [fadeAnim] = useState(new Animated.Value(0));

  useEffect(() => {
    const unsubscribe = NetInfo.addEventListener((state) => {
      const offline = !(state.isConnected && state.isInternetReachable !== false);
      setIsOffline(offline);
      Animated.timing(fadeAnim, {
        toValue: offline ? 1 : 0,
        duration: 300,
        useNativeDriver: true,
      }).start();
    });

    return () => unsubscribe();
  }, [fadeAnim]);

  if (!isOffline) return null;

  return (
    <Animated.View
      style={{ opacity: fadeAnim }}
      className="bg-warning-500 px-4 py-2 flex-row items-center justify-center"
    >
      <Ionicons name="cloud-offline-outline" size={16} color="#fff" />
      <Text className="text-xs font-semibold text-white ml-2">
        Sem conexão — modo offline ativo
      </Text>
    </Animated.View>
  );
}
