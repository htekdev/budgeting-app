---
applyTo:
  - "**/*.ts"
  - "**/*.tsx"
  - "**/*.js"
  - "**/*.jsx"
  - "**/src/frontend/**"
---

# Frontend Development Instructions

## TypeScript & React Best Practices

### Component Structure

- Use **functional components** exclusively
- Implement hooks for state and side effects
- Keep components focused on a single responsibility
- Extract complex logic into custom hooks

### Type Safety

- Always define explicit types for props
- Use TypeScript's strict mode
- Avoid `any` type - use `unknown` if type is truly unknown
- Define interfaces for API response shapes in `src/types/`

### React Query Usage

```typescript
// DO: Use React Query for server state
const { data, isLoading, error } = useQuery({
  queryKey: ['accounts'],
  queryFn: () => accountsApi.getAll(),
});

// DON'T: Use useState for server state
const [accounts, setAccounts] = useState([]);
```

### Error Handling

- Always handle loading and error states in components
- Display user-friendly error messages
- Log errors to console for debugging

### Styling

- Use scoped CSS files per component
- Follow BEM naming convention or similar
- Keep styles modular and reusable
- Use CSS variables for theme consistency

### API Integration

- All API calls go through `src/api/` modules
- Use axios instance from `src/api/client.ts`
- Define types for request/response in `src/types/`
- Handle errors in API client, not in components

### Testing (When Added)

- Write unit tests for utility functions
- Write integration tests for components with API calls
- Mock API responses using MSW or similar
- Test loading and error states

## Validation Commands

```bash
cd src/frontend

# Type checking
npx tsc --noEmit

# Linting
npm run lint

# Fix linting issues
npm run lint --fix

# Build
npm run build
```

## Code Review Checklist

- [ ] TypeScript strict mode enabled and types defined
- [ ] React Query used for server state
- [ ] Loading and error states handled
- [ ] Responsive design considered
- [ ] Accessibility attributes added (aria-labels, etc.)
- [ ] No console errors in browser
- [ ] Code formatted with Prettier
