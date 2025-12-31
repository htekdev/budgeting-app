import api from './client';
import type { Account } from '../types';

export const accountsApi = {
  getAll: async (userId: number = 1) => {
    const response = await api.get<Account[]>(`/accounts?userId=${userId}`);
    return response.data;
  },

  getById: async (id: number, userId: number = 1) => {
    const response = await api.get<Account>(`/accounts/${id}?userId=${userId}`);
    return response.data;
  },

  create: async (account: Omit<Account, 'id' | 'createdAt' | 'updatedAt'>) => {
    const response = await api.post<Account>('/accounts', account);
    return response.data;
  },

  update: async (id: number, account: Partial<Account>, userId: number = 1) => {
    const response = await api.put<void>(`/accounts/${id}?userId=${userId}`, {
      ...account,
      id,
    });
    return response.data;
  },

  delete: async (id: number, userId: number = 1) => {
    const response = await api.delete<void>(`/accounts/${id}?userId=${userId}`);
    return response.data;
  },
};
