import { describe, it, expect } from 'vitest';
import { cn, formatDate, truncate, isValidEmail, debounce } from '@/lib/utils';

describe('Utility Functions', () => {
  describe('cn', () => {
    it('merges class names correctly', () => {
      const result = cn('px-4', 'py-2', 'bg-blue-500');
      expect(result).toContain('px-4');
      expect(result).toContain('py-2');
    });

    it('handles conditional classes', () => {
      const result = cn('base-class', false && 'hidden', true && 'visible');
      expect(result).toContain('base-class');
      expect(result).toContain('visible');
      expect(result).not.toContain('hidden');
    });
  });

  describe('formatDate', () => {
    it('formats date string correctly', () => {
      const date = '2024-01-15T10:30:00Z';
      const result = formatDate(date);
      expect(result).toContain('2024');
    });

    it('formats Date object correctly', () => {
      const date = new Date('2024-01-15');
      const result = formatDate(date);
      expect(result).toContain('Jan');
    });
  });

  describe('truncate', () => {
    it('truncates long text', () => {
      const text = 'This is a very long text that needs truncation';
      const result = truncate(text, 20);
      expect(result).toHaveLength(23); // 20 + '...'
      expect(result).toContain('...');
    });

    it('does not truncate short text', () => {
      const text = 'Short text';
      const result = truncate(text, 20);
      expect(result).toBe(text);
      expect(result).not.toContain('...');
    });
  });

  describe('isValidEmail', () => {
    it('validates correct email', () => {
      expect(isValidEmail('test@example.com')).toBe(true);
      expect(isValidEmail('user.name@domain.co.uk')).toBe(true);
    });

    it('invalidates incorrect email', () => {
      expect(isValidEmail('invalid')).toBe(false);
      expect(isValidEmail('test@')).toBe(false);
      expect(isValidEmail('@example.com')).toBe(false);
    });
  });

  describe('debounce', () => {
    it('debounces function calls', async () => {
      let count = 0;
      const increment = () => count++;
      const debouncedIncrement = debounce(increment, 100);

      debouncedIncrement();
      debouncedIncrement();
      debouncedIncrement();

      expect(count).toBe(0);

      await new Promise((resolve) => setTimeout(resolve, 150));
      expect(count).toBe(1);
    });
  });
});
