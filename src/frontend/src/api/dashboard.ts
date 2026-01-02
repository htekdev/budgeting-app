import api from './client';

export interface TransactionDto {
  id: number;
  description: string;
  amount: number;
  transactionDate: string;
  type: string;
}

export interface DashboardSummary {
  totalBalance: number;
  monthlySpending: number;
  goalsProgress: number;
  activeGoalsCount: number;
  upcomingBills: number;
  recentTransactions: TransactionDto[];
}

export const dashboardApi = {
  getSummary: async (userId: number = 1) => {
    try {
      console.log(`Calling API: /dashboard/summary?userId=${userId}`);
      const response = await api.get<DashboardSummary>(`/dashboard/summary?userId=${userId}`);
      console.log('Dashboard API response:', response.data);
      return response.data;
    } catch (error) {
      console.error('Dashboard API error:', error);
      throw error;
    }
  },
};
