import { describe, it, expect, vi } from 'vitest';
import { renderHook, waitFor } from '@testing-library/react';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { useCustomers } from '@/hooks/use-customers';
import * as customerApi from '@/api/customers';

const createWrapper = () => {
  const queryClient = new QueryClient({
    defaultOptions: {
      queries: { retry: false },
    },
  });
  return ({ children }: { children: React.ReactNode }) => (
    <QueryClientProvider client={queryClient}>{children}</QueryClientProvider>
  );
};

describe('useCustomers Hook', () => {
  it('should fetch customers successfully', async () => {
    const mockData = {
      content: [
        { id: '1', name: 'John Doe', email: 'john@example.com' },
        { id: '2', name: 'Jane Doe', email: 'jane@example.com' },
      ],
      page: 0,
      size: 20,
      totalElements: 2,
      totalPages: 1,
    };

    vi.spyOn(customerApi.customerApi, 'getAll').mockResolvedValue(mockData);

    const { result } = renderHook(() => useCustomers({ page: 0, size: 20 }), {
      wrapper: createWrapper(),
    });

    await waitFor(() => expect(result.current.isSuccess).toBe(true));
    expect(result.current.data).toEqual(mockData);
  });

  it('should handle errors', async () => {
    vi.spyOn(customerApi.customerApi, 'getAll').mockRejectedValue(
      new Error('Network error')
    );

    const { result } = renderHook(() => useCustomers(), {
      wrapper: createWrapper(),
    });

    await waitFor(() => expect(result.current.isError).toBe(true));
    expect(result.current.error).toBeDefined();
  });
});
