import './Dashboard.css';

function Dashboard() {
  return (
    <div className="dashboard">
      <h1>Dashboard</h1>
      <div className="dashboard-grid">
        <div className="dashboard-card">
          <h3>Total Balance</h3>
          <p className="amount">$19,200.00</p>
          <span className="change positive">+5.2% from last month</span>
        </div>

        <div className="dashboard-card">
          <h3>Monthly Spending</h3>
          <p className="amount">$2,564.50</p>
          <span className="change negative">85% of budget used</span>
        </div>

        <div className="dashboard-card">
          <h3>Goals Progress</h3>
          <p className="amount">67%</p>
          <span className="change">3 active goals</span>
        </div>

        <div className="dashboard-card">
          <h3>Upcoming Bills</h3>
          <p className="amount">$1,635.99</p>
          <span className="change">Due in next 7 days</span>
        </div>
      </div>

      <div className="recent-section">
        <h2>Recent Transactions</h2>
        <div className="transaction-list">
          <div className="transaction-item">
            <div className="transaction-icon expense">🛒</div>
            <div className="transaction-details">
              <div className="transaction-name">Grocery Shopping</div>
              <div className="transaction-date">Today, 2:30 PM</div>
            </div>
            <div className="transaction-amount expense">-$78.00</div>
          </div>
          <div className="transaction-item">
            <div className="transaction-icon income">💼</div>
            <div className="transaction-details">
              <div className="transaction-name">Monthly Salary</div>
              <div className="transaction-date">Dec 25, 2025</div>
            </div>
            <div className="transaction-amount income">+$5,000.00</div>
          </div>
          <div className="transaction-item">
            <div className="transaction-icon expense">🏠</div>
            <div className="transaction-details">
              <div className="transaction-name">Rent Payment</div>
              <div className="transaction-date">Dec 24, 2025</div>
            </div>
            <div className="transaction-amount expense">-$1,500.00</div>
          </div>
        </div>
      </div>
    </div>
  );
}

export default Dashboard;
