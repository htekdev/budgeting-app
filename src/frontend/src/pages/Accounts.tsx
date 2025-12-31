import { useQuery } from '@tanstack/react-query';
import { accountsApi } from '../api/accounts';
import './Accounts.css';

function Accounts() {
  const {
    data: accounts,
    isLoading,
    error,
  } = useQuery({
    queryKey: ['accounts'],
    queryFn: () => accountsApi.getAll(),
  });

  if (isLoading) return <div className="page">Loading accounts...</div>;
  if (error) return <div className="page error">Error loading accounts: {error.message}</div>;

  return (
    <div className="accounts-page">
      <div className="page-header">
        <h1>Accounts</h1>
        <button className="btn-primary">+ Add Account</button>
      </div>

      <div className="accounts-grid">
        {accounts?.map(account => (
          <div key={account.id} className="account-card">
            <div className="account-header">
              <div className="account-type">{getAccountIcon(account.type)}</div>
              <div className="account-name">{account.name}</div>
            </div>
            <div className="account-balance">
              {account.currency} {account.balance.toFixed(2)}
            </div>
            <div className="account-type-label">{account.type}</div>
          </div>
        ))}
      </div>

      {(!accounts || accounts.length === 0) && (
        <div className="empty-state">
          <p>No accounts found. Create your first account to get started!</p>
        </div>
      )}
    </div>
  );
}

function getAccountIcon(type: string): string {
  const icons: Record<string, string> = {
    Checking: '🏦',
    Savings: '💰',
    Credit: '💳',
    Investment: '📈',
    Cash: '💵',
  };
  return icons[type] || '💼';
}

export default Accounts;
