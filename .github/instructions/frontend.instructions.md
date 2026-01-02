---
applyTo:
  - 'frontend/**/*.{ts,tsx}'
---

# TypeScript Frontend Instructions

## React Best Practices
- Use functional components exclusively
- Use hooks (useState, useEffect, useCallback, useMemo)
- Create custom hooks for reusable logic
- Use React.memo for performance optimization when needed
- Implement proper error boundaries

## TypeScript Guidelines
- Enable strict mode in tsconfig.json
- Define explicit types for function parameters and return values
- Use interfaces for object shapes
- Use type for unions and intersections
- Avoid 'any' type - use 'unknown' if type is truly unknown
- Use const assertions where appropriate

## State Management
- Use useState for local component state
- Use useContext for shared state when appropriate
- Consider using a state management library for complex state
- Keep state as close to where it's used as possible

## API Integration
- Create service files for API calls
- Use async/await for all API calls
- Implement proper error handling
- Use TypeScript types for API responses
- Show loading states during API calls

## Styling
- Use CSS modules or styled-components
- Follow BEM naming convention if using regular CSS
- Keep styles close to components
- Use CSS variables for theming

## Performance
- Use React.lazy and Suspense for code splitting
- Implement proper memoization
- Avoid unnecessary re-renders
- Optimize bundle size

## Example Component Pattern
```typescript
interface ExampleProps {
  title: string;
  onSubmit: (data: FormData) => Promise<void>;
}

export function Example({ title, onSubmit }: ExampleProps) {
  const [data, setData] = useState<FormData | null>(null);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    setError(null);
    
    try {
      await onSubmit(data);
    } catch (err) {
      setError(err instanceof Error ? err.message : 'An error occurred');
    } finally {
      setLoading(false);
    }
  };

  return (
    <div>
      <h2>{title}</h2>
      {error && <div className="error">{error}</div>}
      {/* Component content */}
    </div>
  );
}
```
