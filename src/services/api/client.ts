import { CONFIG } from '@/constants/config';
import { getToken, removeToken } from '@/services/storage/secure';

interface RequestOptions {
  method?: 'GET' | 'POST' | 'PUT' | 'PATCH' | 'DELETE';
  body?: Record<string, unknown>;
  params?: Record<string, string | number | undefined>;
  timeout?: number;
}

interface ApiResponse<T = unknown> {
  data: T;
  status: number;
  ok: boolean;
}

class ApiClient {
  private baseUrl: string;
  private defaultTimeout: number;

  constructor() {
    this.baseUrl = CONFIG.API_BASE_URL;
    this.defaultTimeout = CONFIG.REQUEST_TIMEOUT;
  }

  private buildUrl(path: string, params?: Record<string, string | number | undefined>): string {
    const url = new URL(`${this.baseUrl}${path}`);
    if (params) {
      Object.entries(params).forEach(([key, value]) => {
        if (value !== undefined) url.searchParams.append(key, String(value));
      });
    }
    return url.toString();
  }

  async request<T>(path: string, options: RequestOptions = {}): Promise<ApiResponse<T>> {
    const { method = 'GET', body, params, timeout = this.defaultTimeout } = options;
    const token = await getToken();

    const headers: Record<string, string> = {
      'Content-Type': 'application/json',
      Accept: 'application/json',
    };

    if (token) {
      headers['Authorization'] = `Bearer ${token}`;
    }

    const controller = new AbortController();
    const timeoutId = setTimeout(() => controller.abort(), timeout);

    try {
      const response = await fetch(this.buildUrl(path, params), {
        method,
        headers,
        body: body ? JSON.stringify(body) : undefined,
        signal: controller.signal,
      });

      clearTimeout(timeoutId);

      if (response.status === 401) {
        await removeToken();
        throw new ApiError('Sessão expirada', 401);
      }

      const data = await response.json().catch(() => null);

      if (!response.ok) {
        throw new ApiError(
          data?.message || data?.error || `Erro ${response.status}`,
          response.status,
          data?.errors
        );
      }

      return { data: data as T, status: response.status, ok: true };
    } catch (error) {
      clearTimeout(timeoutId);
      if (error instanceof ApiError) throw error;
      if (error instanceof Error && error.name === 'AbortError') {
        throw new ApiError('Tempo de requisição esgotado', 408);
      }
      throw new ApiError('Sem conexão com o servidor', 0);
    }
  }

  get<T>(path: string, params?: Record<string, string | number | undefined>): Promise<ApiResponse<T>> {
    return this.request<T>(path, { method: 'GET', params });
  }

  post<T>(path: string, body?: Record<string, unknown>): Promise<ApiResponse<T>> {
    return this.request<T>(path, { method: 'POST', body });
  }

  put<T>(path: string, body?: Record<string, unknown>): Promise<ApiResponse<T>> {
    return this.request<T>(path, { method: 'PUT', body });
  }

  patch<T>(path: string, body?: Record<string, unknown>): Promise<ApiResponse<T>> {
    return this.request<T>(path, { method: 'PATCH', body });
  }

  delete<T>(path: string): Promise<ApiResponse<T>> {
    return this.request<T>(path, { method: 'DELETE' });
  }
}

export class ApiError extends Error {
  constructor(
    message: string,
    public status: number,
    public errors?: Record<string, string[]>
  ) {
    super(message);
    this.name = 'ApiError';
  }

  get isNetworkError(): boolean {
    return this.status === 0;
  }

  get isAuthError(): boolean {
    return this.status === 401;
  }
}

export const apiClient = new ApiClient();
