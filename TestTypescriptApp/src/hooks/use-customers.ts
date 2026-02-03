import { useMutation, useQuery, useQueryClient, UseQueryOptions } from '@tanstack/react-query';
import { customerApi } from '@/api/customers';
import type {
  Customer,
  CustomerInput,
  PaginationParams,
} from '@/types/customer.types';
import { toast } from 'sonner';
import { getErrorMessage } from '@/api/client';

/**
 * Query keys for customer-related queries
 */
export const customerKeys = {
  all: ['customers'] as const,
  lists: () => [...customerKeys.all, 'list'] as const,
  list: (params: Partial<PaginationParams>) => [...customerKeys.lists(), params] as const,
  details: () => [...customerKeys.all, 'detail'] as const,
  detail: (id: string) => [...customerKeys.details(), id] as const,
};

/**
 * Hook to fetch paginated customers
 */
export const useCustomers = (params: Partial<PaginationParams> = {}) => {
  return useQuery({
    queryKey: customerKeys.list(params),
    queryFn: () => customerApi.getAll(params),
    staleTime: 30000, // 30 seconds
  });
};

/**
 * Hook to fetch a single customer by ID
 */
export const useCustomer = (
  id: string,
  options?: Omit<UseQueryOptions<Customer>, 'queryKey' | 'queryFn'>
) => {
  return useQuery({
    queryKey: customerKeys.detail(id),
    queryFn: () => customerApi.getById(id),
    enabled: !!id,
    ...options,
  });
};

/**
 * Hook to create a new customer
 */
export const useCreateCustomer = () => {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: (customer: CustomerInput) => customerApi.create(customer),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: customerKeys.lists() });
      toast.success('Customer created successfully');
    },
    onError: (error) => {
      toast.error(getErrorMessage(error));
    },
  });
};

/**
 * Hook to update an existing customer
 */
export const useUpdateCustomer = () => {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: ({ id, customer }: { id: string; customer: CustomerInput }) =>
      customerApi.update(id, customer),
    onSuccess: (data) => {
      queryClient.invalidateQueries({ queryKey: customerKeys.lists() });
      queryClient.invalidateQueries({ queryKey: customerKeys.detail(data.id) });
      toast.success('Customer updated successfully');
    },
    onError: (error) => {
      toast.error(getErrorMessage(error));
    },
  });
};

/**
 * Hook to delete a customer
 */
export const useDeleteCustomer = () => {
  const queryClient = useQueryClient();

  return useMutation({
    mutationFn: (id: string) => customerApi.delete(id),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: customerKeys.lists() });
      toast.success('Customer deleted successfully');
    },
    onError: (error) => {
      toast.error(getErrorMessage(error));
    },
  });
};
