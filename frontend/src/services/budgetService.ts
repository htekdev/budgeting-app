import { Budget } from '../types';

const API_BASE_URL = import.meta.env.VITE_API_URL || 'http://localhost:5000/api';

export const budgetService = {
  async getAllBudgets(): Promise<Budget[]> {
    const response = await fetch(`${API_BASE_URL}/budgets`);
    if (!response.ok) {
      throw new Error('Failed to fetch budgets');
    }
    return response.json();
  },

  async getBudgetById(id: number): Promise<Budget> {
    const response = await fetch(`${API_BASE_URL}/budgets/${id}`);
    if (!response.ok) {
      throw new Error('Failed to fetch budget');
    }
    return response.json();
  },

  async createBudget(budget: Omit<Budget, 'id'>): Promise<Budget> {
    const response = await fetch(`${API_BASE_URL}/budgets`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(budget),
    });
    if (!response.ok) {
      throw new Error('Failed to create budget');
    }
    return response.json();
  },
};
