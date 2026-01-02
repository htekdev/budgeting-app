export interface Budget {
  id: number;
  name: string;
  totalAmount: number;
  startDate: string;
  endDate: string;
  userId: string;
  createdAt: string;
  updatedAt: string;
}

export interface CreateBudgetDto {
  name: string;
  totalAmount: number;
  startDate: string;
  endDate: string;
  userId: string;
}

export interface Transaction {
  id: number;
  description: string;
  amount: number;
  date: string;
  type: 'Income' | 'Expense';
  budgetId: number;
  categoryId?: number;
  createdAt: string;
}

export interface CreateTransactionDto {
  description: string;
  amount: number;
  date: string;
  type: 'Income' | 'Expense';
  budgetId: number;
  categoryId?: number;
}

export interface Category {
  id: number;
  name: string;
  allocatedAmount: number;
  color: string;
  budgetId: number;
}
