import { useState } from 'react';
import type { CreateTransactionDto } from '../types';
import { transactionService } from '../services/api';

interface AddTransactionFormProps {
  budgetId: number;
  onTransactionAdded: () => void;
}

export function AddTransactionForm({ budgetId, onTransactionAdded }: AddTransactionFormProps) {
  const [description, setDescription] = useState('');
  const [amount, setAmount] = useState('');
  const [type, setType] = useState<'Income' | 'Expense'>('Expense');
  const [date, setDate] = useState(new Date().toISOString().split('T')[0]);
  const [isSubmitting, setIsSubmitting] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError(null);
    setIsSubmitting(true);

    try {
      const transaction: CreateTransactionDto = {
        description,
        amount: parseFloat(amount),
        date,
        type,
        budgetId,
      };

      await transactionService.createTransaction(transaction);
      
      // Reset form
      setDescription('');
      setAmount('');
      setType('Expense');
      setDate(new Date().toISOString().split('T')[0]);
      
      onTransactionAdded();
    } catch (err) {
      setError(err instanceof Error ? err.message : 'Failed to add transaction');
    } finally {
      setIsSubmitting(false);
    }
  };

  return (
    <form className="add-transaction-form" onSubmit={handleSubmit}>
      <h3>Add Transaction</h3>
      
      {error && <div className="error-message">{error}</div>}
      
      <div className="form-group">
        <label htmlFor="description">Description</label>
        <input
          id="description"
          type="text"
          value={description}
          onChange={(e) => setDescription(e.target.value)}
          required
          placeholder="Enter description"
        />
      </div>

      <div className="form-group">
        <label htmlFor="amount">Amount</label>
        <input
          id="amount"
          type="number"
          step="0.01"
          min="0"
          value={amount}
          onChange={(e) => setAmount(e.target.value)}
          required
          placeholder="0.00"
        />
      </div>

      <div className="form-group">
        <label htmlFor="type">Type</label>
        <select
          id="type"
          value={type}
          onChange={(e) => setType(e.target.value as 'Income' | 'Expense')}
        >
          <option value="Expense">Expense</option>
          <option value="Income">Income</option>
        </select>
      </div>

      <div className="form-group">
        <label htmlFor="date">Date</label>
        <input
          id="date"
          type="date"
          value={date}
          onChange={(e) => setDate(e.target.value)}
          required
        />
      </div>

      <button type="submit" disabled={isSubmitting}>
        {isSubmitting ? 'Adding...' : 'Add Transaction'}
      </button>
    </form>
  );
}
