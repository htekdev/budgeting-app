import { Transaction } from '../types';

interface TransactionListProps {
  transactions: Transaction[];
}

export function TransactionList({ transactions }: TransactionListProps) {
  const sortedTransactions = [...transactions].sort((a, b) => 
    new Date(b.date).getTime() - new Date(a.date).getTime()
  );

  const totalIncome = transactions
    .filter(t => t.type === 'Income')
    .reduce((sum, t) => sum + t.amount, 0);

  const totalExpenses = transactions
    .filter(t => t.type === 'Expense')
    .reduce((sum, t) => sum + t.amount, 0);

  const balance = totalIncome - totalExpenses;

  return (
    <div className="transaction-list">
      <div className="transaction-summary">
        <div className="summary-item income">
          <span>Income:</span>
          <span>${totalIncome.toFixed(2)}</span>
        </div>
        <div className="summary-item expense">
          <span>Expenses:</span>
          <span>${totalExpenses.toFixed(2)}</span>
        </div>
        <div className="summary-item balance">
          <span>Balance:</span>
          <span className={balance >= 0 ? 'positive' : 'negative'}>
            ${balance.toFixed(2)}
          </span>
        </div>
      </div>

      <div className="transactions">
        {sortedTransactions.length === 0 ? (
          <p className="no-transactions">No transactions yet</p>
        ) : (
          sortedTransactions.map(transaction => (
            <div 
              key={transaction.id} 
              className={`transaction-item ${transaction.type.toLowerCase()}`}
            >
              <div className="transaction-info">
                <span className="transaction-description">{transaction.description}</span>
                <span className="transaction-date">
                  {new Date(transaction.date).toLocaleDateString()}
                </span>
              </div>
              <div className="transaction-amount">
                <span className={transaction.type === 'Income' ? 'income' : 'expense'}>
                  {transaction.type === 'Income' ? '+' : '-'}${transaction.amount.toFixed(2)}
                </span>
              </div>
            </div>
          ))
        )}
      </div>
    </div>
  );
}
