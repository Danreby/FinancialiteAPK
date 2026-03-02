import { API_URL } from '@/constants/config';
import { SecureStorage } from '@/services/storage/secure';

interface RequestConfig extends RequestInit {
  params?: Record<string, string | number | boolean | undefined | null>;
}

class ApiClientError extends Error {
  status: number;
  data: unknown;

  constructor(message: string, status: number, data?: unknown) {
    super(message);
    this.name = 'ApiClientError';
    this.status = status;
    this.data = data;
  }
}

async function getHeaders(contentType = 'application/json'): Promise<HeadersInit> {
  const token = await SecureStorage.getToken();
  const headers: HeadersInit = {
    Accept: 'application/json',
  };

  if (contentType) {
    headers['Content-Type'] = contentType;
  }

  if (token) {
    headers['Authorization'] = `Bearer ${token}`;
  }

  return headers;
}

function buildUrl(endpoint: string, params?: Record<string, string | number | boolean | undefined | null>): string {
  const url = `${API_URL}${endpoint}`;

  if (!params) return url;

  const searchParams = new URLSearchParams();
  Object.entries(params).forEach(([key, value]) => {
    if (value !== undefined && value !== null && value !== '') {
      searchParams.append(key, String(value));
    }
  });

  const queryString = searchParams.toString();
  return queryString ? `${url}?${queryString}` : url;
}

async function handleResponse<T>(response: Response): Promise<T> {
  if (response.status === 401) {
    await SecureStorage.removeToken();
    await SecureStorage.removeUserData();
    throw new ApiClientError('Sessão expirada. Faça login novamente.', 401);
  }

  const data = await response.json().catch(() => null);

  if (!response.ok) {
    const message = data?.error || data?.message || `Erro ${response.status}`;
    throw new ApiClientError(message, response.status, data);
  }

  return data as T;
}

export const apiClient = {
  async get<T>(endpoint: string, config?: RequestConfig): Promise<T> {
    const url = buildUrl(endpoint, config?.params);
    const headers = await getHeaders();
    const response = await fetch(url, { method: 'GET', headers, ...config });
    return handleResponse<T>(response);
  },

  async post<T>(endpoint: string, body?: unknown, config?: RequestConfig): Promise<T> {
    const url = buildUrl(endpoint, config?.params);
    const headers = await getHeaders();
    const response = await fetch(url, {
      method: 'POST',
      headers,
      body: body ? JSON.stringify(body) : undefined,
      ...config,
    });
    return handleResponse<T>(response);
  },

  async put<T>(endpoint: string, body?: unknown, config?: RequestConfig): Promise<T> {
    const url = buildUrl(endpoint, config?.params);
    const headers = await getHeaders();
    const response = await fetch(url, {
      method: 'PUT',
      headers,
      body: body ? JSON.stringify(body) : undefined,
      ...config,
    });
    return handleResponse<T>(response);
  },

  async patch<T>(endpoint: string, body?: unknown, config?: RequestConfig): Promise<T> {
    const url = buildUrl(endpoint, config?.params);
    const headers = await getHeaders();
    const response = await fetch(url, {
      method: 'PATCH',
      headers,
      body: body ? JSON.stringify(body) : undefined,
      ...config,
    });
    return handleResponse<T>(response);
  },

  async delete<T>(endpoint: string, body?: unknown, config?: RequestConfig): Promise<T> {
    const url = buildUrl(endpoint, config?.params);
    const headers = await getHeaders();
    const response = await fetch(url, {
      method: 'DELETE',
      headers,
      body: body ? JSON.stringify(body) : undefined,
      ...config,
    });
    return handleResponse<T>(response);
  },
};

export { ApiClientError };
