import './Dashboard.css';
import { useQuery } from '@tanstack/react-query';
import { dashboardApi } from '../api/dashboard';

function Dashboard() {
  const {
    data: summary,
    isLoading,
    error,
  } = useQuery({
    queryKey: ['dashboard'],
    queryFn: () => dashboardApi.getSummary(),
  });

  if (isLoading) return <div className="page">Loading dashboard...</div>;
  if (error) return <div className="page error">Error loading dashboard: {error.message}</div>;
  if (!summary) return <div className="page">No data available</div>;

  // Log the response to debug
  console.log('Dashboard summary data:', summary);

  // Provide defaults for undefined values
  const totalBalance = summary.totalBalance ?? 0;
  const monthlySpending = summary.monthlySpending ?? 0;
  const goalsProgress = summary.goalsProgress ?? 0;
  const activeGoalsCount = summary.activeGoalsCount ?? 0;
  const upcomingBills = summary.upcomingBills ?? 0;

  // Calculate budget percentage
  const budgetPercentage = monthlySpending > 0 ? Math.round((monthlySpending / (monthlySpending * 1.2)) * 100) : 0;

  // Get previous month's balance for comparison (mock for now)
  const previousBalance = totalBalance * 0.95;
  const balanceChange = previousBalance > 0 ? ((totalBalance - previousBalance) / previousBalance * 100).toFixed(1) : '0';

  return (
    <div className="dashboard">
      <h1>Dashboard</h1>
      <div className="dashboard-grid">
        <div className="dashboard-card">
          <h3>Total Balance</h3>
          <p className="amount">${totalBalance.toFixed(2)}</p>
          <span className={`change ${parseFloat(balanceChange) >= 0 ? 'positive' : 'negative'}`}>
            {parseFloat(balanceChange) >= 0 ? '+' : ''}{balanceChange}% from last month
          </span>
        </div>

        <div className="dashboard-card">
          <h3>Monthly Spending</h3>
          <p className="amount">${monthlySpending.toFixed(2)}</p>
          <span className={`change ${budgetPercentage > 80 ? 'negative' : 'positive'}`}>
            {budgetPercentage}% of budget used
          </span>
        </div>

        <div className="dashboard-card">
          <h3>Goals Progress</h3>
          <p className="amount">{Math.round(goalsProgress)}%</p>
          <span className="change">
            {activeGoalsCount} active {activeGoalsCount === 1 ? 'goal' : 'goals'}
          </span>
        </div>

        <div className="dashboard-card">
          <h3>Upcoming Bills</h3>
          <p className="amount">${upcomingBills.toFixed(2)}</p>
          <span className="change">Due in next 7 days</span>
        </div>
      </div>

      <div className="recent-section">
        <h2>Recent Transactions</h2>
        <div className="transaction-list">
          {summary.recentTransactions && summary.recentTransactions.length > 0 ? (
            summary.recentTransactions.map(transaction => {
              const isIncome = transaction.type === 'Income' || transaction.amount > 0;
              const icon = isIncome ? '💼' : '🛒';

              return (
                <div key={transaction.id} className="transaction-item">
                  <div className={`transaction-icon ${isIncome ? 'income' : 'expense'}`}>
                    {icon}
                  </div>
                  <div className="transaction-details">
                    <div className="transaction-name">{transaction.description}</div>
                    <div className="transaction-date">
                      {new Date(transaction.transactionDate).toLocaleDateString('en-US', {
                        month: 'short',
                        day: 'numeric',
                        year: 'numeric',
                      })}
                    </div>
                  </div>
                  <div className={`transaction-amount ${isIncome ? 'income' : 'expense'}`}>
                    {isIncome ? '+' : '-'}${Math.abs(transaction.amount).toFixed(2)}
                  </div>
                </div>
              );
            })
          ) : (
            <div className="empty-state">No transactions yet</div>
          )}
        </div>
      </div>
    </div>
  );
}

export default Dashboard;
