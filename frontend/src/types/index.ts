export interface Budget {
  id: number;
  name: string;
  amount: number;
  categoryId: number;
  startDate: string;
  endDate: string;
  period: string;
  userId: number;
  category?: Category;
}

export interface Category {
  id: number;
  name: string;
  type: string;
  userId: number;
}

export interface Transaction {
  id: number;
  amount: number;
  description: string;
  date: string;
  type: string;
  categoryId: number;
  userId: number;
  category?: Category;
}
