import { describe, it, expect } from 'vitest';
import { render, screen } from '@testing-library/react';
import { Button } from '@/components/ui/button';

describe('Button Component', () => {
  it('renders with default variant', () => {
    render(<Button>Click me</Button>);
    expect(screen.getByText('Click me')).toBeInTheDocument();
  });

  it('renders with destructive variant', () => {
    render(<Button variant="destructive">Delete</Button>);
    expect(screen.getByText('Delete')).toBeInTheDocument();
  });

  it('handles click events', () => {
    let clicked = false;
    render(<Button onClick={() => (clicked = true)}>Click</Button>);
    screen.getByText('Click').click();
    expect(clicked).toBe(true);
  });

  it('is disabled when disabled prop is true', () => {
    render(<Button disabled>Disabled</Button>);
    expect(screen.getByText('Disabled')).toBeDisabled();
  });
});
