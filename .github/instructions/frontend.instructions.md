---
applyTo:
  - "frontend/**/*.ts"
  - "frontend/**/*.tsx"
  - "frontend/**/*.jsx"
---

# Frontend-Specific Instructions

## React + TypeScript Development

### Component Structure
- One component per file
- Export component as default
- Define interfaces at top of file
- Keep components under 200 lines

### TypeScript Usage
- Enable strict mode
- Define explicit types for all props
- Use interfaces for object types
- Use type for unions/intersections
- Avoid 'any' type - use 'unknown' if needed

### Hooks
- Use useState for component state
- Use useEffect for side effects
- Always specify dependency arrays
- Extract complex logic to custom hooks
- Name custom hooks with 'use' prefix

### Props
- Define PropTypes with TypeScript interfaces
- Use destructuring in function parameters
- Provide default values where appropriate
- Document complex props with JSDoc

### State Management
- Keep state as local as possible
- Lift state only when necessary
- Use Context for global state
- Consider React Query for server state

### API Calls
- Create separate API service files
- Use axios or fetch consistently
- Implement loading and error states
- Handle all error cases
- Use async/await syntax

### Styling
- Use CSS Modules or styled-components
- Follow BEM naming if using CSS
- Mobile-first responsive design
- Use CSS variables for themes

### Accessibility
- Use semantic HTML elements
- Include ARIA labels where needed
- Support keyboard navigation
- Test with screen readers
- Maintain proper heading hierarchy

### Performance
- Use React.memo for pure components
- Implement useCallback for functions passed as props
- Use useMemo for expensive calculations
- Lazy load routes and heavy components
- Optimize images and assets

### Forms
- Use controlled components
- Validate on submit and blur
- Show inline validation errors
- Disable submit during submission
- Clear form on success

### Testing
- Use React Testing Library
- Test user behavior not implementation
- Mock API calls in tests
- Test accessibility
- Aim for high coverage on critical paths
