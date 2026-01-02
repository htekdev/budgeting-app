---
description: "Frontend TypeScript/React code patterns for BudgetBuddy"
applyTo: "src/frontend/**/*.{ts,tsx}"
---

# Frontend TypeScript/React Instructions

## Code Style
- Use functional components with React Hooks
- TypeScript strict mode enabled
- Use type imports: `import type { ComponentProps } from 'react'`
- Prefer interfaces for props, types for unions/utilities
- Use const assertions for literal types

## Component Structure
```typescript
interface BudgetCardProps {
  budget: Budget;
  onEdit?: (id: string) => void;
  onDelete?: (id: string) => void;
}

export function BudgetCard({ budget, onEdit, onDelete }: BudgetCardProps) {
  // Component logic
  return (
    // JSX
  );
}
```

## State Management
- Use useState for local component state
- Use useReducer for complex state logic
- Use React Query for server state
- Use Context API for global app state (theme, auth)
- Avoid prop drilling - use composition or context

## API Integration
- NEVER hand-write API client code
- Use generated client from OpenAPI spec
- Wrap API calls in React Query hooks
- Handle loading, error, and success states

```typescript
import { useQuery } from '@tanstack/react-query';
import { api } from './api/client';

export function useBudgets() {
  return useQuery({
    queryKey: ['budgets'],
    queryFn: () => api.budgets.getBudgets(),
  });
}
```

## Styling
- Use CSS Modules for component styles
- Use semantic class names
- Implement responsive design (mobile-first)
- Use CSS custom properties for theming
- Keep styles colocated with components

## Error Handling
- Create ErrorBoundary components
- Display user-friendly error messages
- Log errors to console in development
- Use toast notifications for transient errors
- Provide retry options for failed requests

## Performance
- Use React.memo for expensive components
- Use useMemo for expensive calculations
- Use useCallback for callback props
- Lazy load routes with React.lazy()
- Optimize images and assets

## Forms
- Use controlled components
- Validate on blur and submit
- Show validation errors inline
- Disable submit button during submission
- Reset form after successful submission

## Testing
- Use Vitest for unit tests
- Use React Testing Library for component tests
- Test user interactions, not implementation details
- Mock API calls
- Achieve 70%+ coverage

## File Organization
```
src/
├── api/          # Generated API client
├── components/   # Reusable components
├── hooks/        # Custom React hooks
├── pages/        # Route components
├── types/        # TypeScript types
├── utils/        # Utility functions
└── App.tsx       # Main app component
```

## Common Patterns

### Data Fetching Component
```typescript
export function BudgetList() {
  const { data: budgets, isLoading, error } = useBudgets();

  if (isLoading) return <Loading />;
  if (error) return <ErrorMessage error={error} />;
  if (!budgets?.length) return <EmptyState />;

  return (
    <div>
      {budgets.map(budget => (
        <BudgetCard key={budget.id} budget={budget} />
      ))}
    </div>
  );
}
```

### Form Component
```typescript
export function CreateBudgetForm({ onSuccess }: CreateBudgetFormProps) {
  const [formData, setFormData] = useState<BudgetInput>({
    name: '',
    totalAmount: 0,
  });
  
  const mutation = useMutation({
    mutationFn: (data: BudgetInput) => api.budgets.createBudget(data),
    onSuccess: () => {
      onSuccess();
      setFormData({ name: '', totalAmount: 0 });
    },
  });

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    mutation.mutate(formData);
  };

  return <form onSubmit={handleSubmit}>...</form>;
}
```

## Accessibility
- Use semantic HTML elements
- Add ARIA labels where needed
- Ensure keyboard navigation works
- Maintain proper heading hierarchy
- Test with screen readers
- Support prefers-reduced-motion
