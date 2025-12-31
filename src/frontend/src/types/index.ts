export interface Account {
  id: number;
  userId: number;
  name: string;
  type: 'Checking' | 'Savings' | 'Credit' | 'Investment' | 'Cash';
  balance: number;
  currency: string;
  isActive: boolean;
  createdAt: string;
  updatedAt: string;
}

export interface Category {
  id: number;
  userId: number;
  name: string;
  type: 'Income' | 'Expense';
  parentCategoryId?: number;
  icon?: string;
  color?: string;
  isActive: boolean;
}

export interface Transaction {
  id: number;
  userId: number;
  accountId: number;
  categoryId?: number;
  type: 'Income' | 'Expense' | 'Transfer';
  amount: number;
  description?: string;
  transactionDate: string;
  toAccountId?: number;
  notes?: string;
}

export interface Budget {
  id: number;
  userId: number;
  categoryId: number;
  month: string;
  amount: number;
  notes?: string;
}

export interface Goal {
  id: number;
  userId: number;
  name: string;
  targetAmount: number;
  currentAmount: number;
  targetDate?: string;
  description?: string;
  isCompleted: boolean;
}
