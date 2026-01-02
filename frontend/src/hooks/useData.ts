import { useState, useEffect } from 'react';
import type { Budget, Transaction } from '../types';
import { budgetService, transactionService } from '../services/api';

export function useBudgets(userId?: string) {
  const [budgets, setBudgets] = useState<Budget[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  const fetchBudgets = async () => {
    try {
      setLoading(true);
      const data = await budgetService.getBudgets(userId);
      setBudgets(data);
      setError(null);
    } catch (err) {
      setError(err instanceof Error ? err.message : 'An error occurred');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchBudgets();
  }, [userId]);

  return { budgets, loading, error, refetch: fetchBudgets };
}

export function useTransactions(budgetId?: number) {
  const [transactions, setTransactions] = useState<Transaction[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  const fetchTransactions = async () => {
    try {
      setLoading(true);
      const data = await transactionService.getTransactions(budgetId);
      setTransactions(data);
      setError(null);
    } catch (err) {
      setError(err instanceof Error ? err.message : 'An error occurred');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchTransactions();
  }, [budgetId]);

  return { transactions, loading, error, refetch: fetchTransactions };
}
