import type { Budget } from '../types';

interface BudgetCardProps {
  budget: Budget;
  onSelect: (budget: Budget) => void;
}

export function BudgetCard({ budget, onSelect }: BudgetCardProps) {
  const startDate = new Date(budget.startDate).toLocaleDateString();
  const endDate = new Date(budget.endDate).toLocaleDateString();

  return (
    <div 
      className="budget-card"
      onClick={() => onSelect(budget)}
      style={{ cursor: 'pointer' }}
    >
      <h3>{budget.name}</h3>
      <p className="budget-amount">${budget.totalAmount.toFixed(2)}</p>
      <p className="budget-period">{startDate} - {endDate}</p>
      <p className="budget-user">User: {budget.userId}</p>
    </div>
  );
}
