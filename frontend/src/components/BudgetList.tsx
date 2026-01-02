import { useEffect, useState } from 'react';
import { Budget } from '../types';
import { budgetService } from '../services/budgetService';

export function BudgetList() {
  const [budgets, setBudgets] = useState<Budget[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    async function loadBudgets() {
      try {
        setLoading(true);
        const data = await budgetService.getAllBudgets();
        setBudgets(data);
        setError(null);
      } catch (err) {
        setError(err instanceof Error ? err.message : 'An error occurred');
      } finally {
        setLoading(false);
      }
    }

    loadBudgets();
  }, []);

  if (loading) {
    return <div className="loading">Loading budgets...</div>;
  }

  if (error) {
    return <div className="error">Error: {error}</div>;
  }

  return (
    <div className="budget-list">
      <h2>My Budgets</h2>
      {budgets.length === 0 ? (
        <p>No budgets found. Create your first budget!</p>
      ) : (
        <ul>
          {budgets.map((budget) => (
            <li key={budget.id} className="budget-item">
              <h3>{budget.name}</h3>
              <p>Amount: ${budget.amount.toFixed(2)}</p>
              <p>Period: {budget.period}</p>
              {budget.category && <p>Category: {budget.category.name}</p>}
            </li>
          ))}
        </ul>
      )}
    </div>
  );
}
