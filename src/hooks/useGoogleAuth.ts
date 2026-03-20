import { useCallback, useEffect, useState } from 'react';
import * as AuthSession from 'expo-auth-session';
import * as WebBrowser from 'expo-web-browser';
import { CONFIG } from '@/constants/config';
import { useAuthStore } from '@/stores/authStore';

WebBrowser.maybeCompleteAuthSession();

const discovery = {
  authorizationEndpoint: 'https://accounts.google.com/o/oauth2/v2/auth',
  tokenEndpoint: 'https://oauth2.googleapis.com/token',
};

export function useGoogleAuth() {
  const googleLogin = useAuthStore((s) => s.googleLogin);
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const [request, response, promptAsync] = AuthSession.useAuthRequest(
    {
      clientId: CONFIG.GOOGLE_WEB_CLIENT_ID,
      scopes: ['openid', 'profile', 'email'],
      responseType: AuthSession.ResponseType.IdToken,
      redirectUri: AuthSession.makeRedirectUri({ scheme: 'financialite' }),
    },
    discovery
  );

  const signIn = useCallback(async () => {
    setError(null);
    setIsLoading(true);
    try {
      await promptAsync();
    } catch {
      setIsLoading(false);
      setError('Erro ao iniciar login com Google');
    }
  }, [promptAsync]);

  useEffect(() => {
    if (response?.type === 'success') {
      const idToken = response.params?.id_token;
      if (idToken) {
        googleLogin(idToken)
          .catch((err) => {
            setError(err instanceof Error ? err.message : 'Erro ao fazer login com Google');
          })
          .finally(() => setIsLoading(false));
      } else {
        setIsLoading(false);
        setError('Token do Google não recebido');
      }
    } else if (response?.type === 'error') {
      setIsLoading(false);
      setError(response.error?.message || 'Erro na autenticação Google');
    } else if (response?.type === 'dismiss') {
      setIsLoading(false);
    }
  }, [response, googleLogin]);

  return {
    signIn,
    isLoading,
    error,
    isReady: !!request,
  };
}
