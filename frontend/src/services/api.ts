import { Budget, CreateBudgetDto, Transaction, CreateTransactionDto } from '../types';

const API_BASE_URL = import.meta.env.VITE_API_URL || 'http://localhost:5000/api';

export const budgetService = {
  async getBudgets(userId?: string): Promise<Budget[]> {
    const url = userId ? `${API_BASE_URL}/budgets?userId=${userId}` : `${API_BASE_URL}/budgets`;
    const response = await fetch(url);
    if (!response.ok) throw new Error('Failed to fetch budgets');
    return response.json();
  },

  async getBudget(id: number): Promise<Budget> {
    const response = await fetch(`${API_BASE_URL}/budgets/${id}`);
    if (!response.ok) throw new Error('Failed to fetch budget');
    return response.json();
  },

  async createBudget(budget: CreateBudgetDto): Promise<Budget> {
    const response = await fetch(`${API_BASE_URL}/budgets`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(budget),
    });
    if (!response.ok) throw new Error('Failed to create budget');
    return response.json();
  },

  async deleteBudget(id: number): Promise<void> {
    const response = await fetch(`${API_BASE_URL}/budgets/${id}`, {
      method: 'DELETE',
    });
    if (!response.ok) throw new Error('Failed to delete budget');
  },
};

export const transactionService = {
  async getTransactions(budgetId?: number): Promise<Transaction[]> {
    const url = budgetId 
      ? `${API_BASE_URL}/transactions?budgetId=${budgetId}` 
      : `${API_BASE_URL}/transactions`;
    const response = await fetch(url);
    if (!response.ok) throw new Error('Failed to fetch transactions');
    return response.json();
  },

  async createTransaction(transaction: CreateTransactionDto): Promise<Transaction> {
    const response = await fetch(`${API_BASE_URL}/transactions`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(transaction),
    });
    if (!response.ok) throw new Error('Failed to create transaction');
    return response.json();
  },

  async deleteTransaction(id: number): Promise<void> {
    const response = await fetch(`${API_BASE_URL}/transactions/${id}`, {
      method: 'DELETE',
    });
    if (!response.ok) throw new Error('Failed to delete transaction');
  },
};
