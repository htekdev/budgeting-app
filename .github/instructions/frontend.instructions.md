---
applyTo:
  - "**/*.ts"
  - "**/*.tsx"
  - "src/frontend/**"
---

# Frontend Instructions (TypeScript/React)

## Component Structure

**Use functional components with hooks**:
```typescript
// Good
export const AccountList: React.FC = () => {
  const { data: accounts, isLoading, error } = useAccounts();
  
  if (isLoading) return <LoadingSpinner />;
  if (error) return <ErrorMessage error={error} />;
  
  return <div>{/* component content */}</div>;
};

// Bad - class component
export class AccountList extends React.Component {
  // ...
}
```

## TypeScript Rules

- **Strict mode enabled**: No implicit any
- **Explicit return types** for functions
- **Interface over type** for object shapes
- **Const assertions** where appropriate

```typescript
// Good
interface Account {
  accountId: number;
  accountName: string;
  balance: number;
}

const getAccounts = async (): Promise<Account[]> => {
  // implementation
};

// Bad
const getAccounts = async () => {
  // implicit any return type
};
```

## State Management

- **React Query** for server state
- **useState** for local component state
- **useContext** for app-wide state (sparingly)

```typescript
// Server state with React Query
const { data, isLoading, error } = useQuery({
  queryKey: ['accounts'],
  queryFn: fetchAccounts
});

// Local state
const [isOpen, setIsOpen] = useState(false);
```

## API Integration

Always use React Query hooks for API calls:

```typescript
export const useAccounts = () => {
  return useQuery({
    queryKey: ['accounts'],
    queryFn: async () => {
      const response = await axios.get<Account[]>('/api/v1/accounts');
      return response.data;
    }
  });
};

export const useCreateAccount = () => {
  const queryClient = useQueryClient();
  
  return useMutation({
    mutationFn: async (data: CreateAccountRequest) => {
      const response = await axios.post('/api/v1/accounts', data);
      return response.data;
    },
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['accounts'] });
    }
  });
};
```

## Forms and Validation

- Controlled components
- Validate on submit
- Show validation errors clearly

```typescript
const [formData, setFormData] = useState<FormData>({
  accountName: '',
  accountType: 'Checking',
  initialBalance: 0
});

const [errors, setErrors] = useState<Record<string, string>>({});

const handleSubmit = async (e: React.FormEvent) => {
  e.preventDefault();
  
  const validationErrors = validateForm(formData);
  if (Object.keys(validationErrors).length > 0) {
    setErrors(validationErrors);
    return;
  }
  
  await createAccount(formData);
};
```

## Error Handling

Always handle loading and error states:

```typescript
const { data, isLoading, error } = useAccounts();

if (isLoading) {
  return <LoadingSpinner />;
}

if (error) {
  return (
    <ErrorMessage 
      title="Failed to load accounts" 
      message={error.message}
    />
  );
}

return <AccountList accounts={data} />;
```

## Styling

- Use consistent naming (BEM or similar)
- Prefer CSS modules or styled-components
- Make components responsive
- Use theme variables for colors

## Testing

- Test user interactions, not implementation details
- Mock API calls
- Test error states
- Test loading states

```typescript
describe('AccountList', () => {
  it('displays accounts when loaded', async () => {
    render(<AccountList />);
    
    await waitFor(() => {
      expect(screen.getByText('Checking Account')).toBeInTheDocument();
    });
  });
  
  it('displays error message on failure', async () => {
    // mock failed API call
    render(<AccountList />);
    
    await waitFor(() => {
      expect(screen.getByText(/failed to load/i)).toBeInTheDocument();
    });
  });
});
```

## Performance

- Use React.memo for expensive components
- Avoid creating functions in render
- Use useCallback and useMemo appropriately
- Lazy load routes and heavy components

## Accessibility

- Use semantic HTML
- Add ARIA labels where needed
- Ensure keyboard navigation works
- Provide alt text for images
