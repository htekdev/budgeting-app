import { useState } from 'react';
import type { Budget } from './types';
import { useBudgets, useTransactions } from './hooks/useData';
import { BudgetCard } from './components/BudgetCard';
import { TransactionList } from './components/TransactionList';
import { AddTransactionForm } from './components/AddTransactionForm';
import './App.css';

function App() {
  const [selectedBudget, setSelectedBudget] = useState<Budget | null>(null);
  const { budgets, loading: budgetsLoading, error: budgetsError } = useBudgets('demo-user');
  const { transactions, loading: transactionsLoading, error: transactionsError, refetch: refetchTransactions } = useTransactions(selectedBudget?.id);

  const handleBudgetSelect = (budget: Budget) => {
    setSelectedBudget(budget);
  };

  const handleTransactionAdded = () => {
    refetchTransactions();
  };

  if (budgetsLoading) {
    return <div className="loading">Loading budgets...</div>;
  }

  if (budgetsError) {
    return <div className="error">Error: {budgetsError}</div>;
  }

  return (
    <div className="app">
      <header className="app-header">
        <h1>💰 BudgetBuddy</h1>
        <p>Manage your finances with ease</p>
      </header>

      <div className="app-content">
        <section className="budgets-section">
          <h2>Your Budgets</h2>
          <div className="budgets-grid">
            {budgets.length === 0 ? (
              <p>No budgets found. Create one to get started!</p>
            ) : (
              budgets.map(budget => (
                <BudgetCard
                  key={budget.id}
                  budget={budget}
                  onSelect={handleBudgetSelect}
                />
              ))
            )}
          </div>
        </section>

        {selectedBudget && (
          <section className="transactions-section">
            <div className="section-header">
              <h2>Transactions for {selectedBudget.name}</h2>
              <button onClick={() => setSelectedBudget(null)} className="close-button">
                ✕ Close
              </button>
            </div>

            <div className="transactions-content">
              <div className="transactions-main">
                {transactionsLoading ? (
                  <div className="loading">Loading transactions...</div>
                ) : transactionsError ? (
                  <div className="error">Error: {transactionsError}</div>
                ) : (
                  <TransactionList transactions={transactions} />
                )}
              </div>

              <div className="transactions-sidebar">
                <AddTransactionForm
                  budgetId={selectedBudget.id}
                  onTransactionAdded={handleTransactionAdded}
                />
              </div>
            </div>
          </section>
        )}
      </div>
    </div>
  );
}

export default App;

