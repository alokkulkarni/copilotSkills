import { apiClient } from './client';
import type {
  Customer,
  CustomerInput,
  PageResponse,
  PaginationParams,
} from '@/types/customer.types';

/**
 * Customer API endpoints
 */
const CUSTOMERS_ENDPOINT = '/customers';

/**
 * Customer API service
 */
export const customerApi = {
  /**
   * Get paginated list of customers
   */
  getAll: async (params: Partial<PaginationParams> = {}): Promise<PageResponse<Customer>> => {
    const { page = 0, size = 20 } = params;
    const response = await apiClient.get<PageResponse<Customer>>(CUSTOMERS_ENDPOINT, {
      params: { page, size },
    });
    return response.data;
  },

  /**
   * Get a single customer by ID
   */
  getById: async (id: string): Promise<Customer> => {
    const response = await apiClient.get<Customer>(`${CUSTOMERS_ENDPOINT}/${id}`);
    return response.data;
  },

  /**
   * Create a new customer
   */
  create: async (customer: CustomerInput): Promise<Customer> => {
    const response = await apiClient.post<Customer>(CUSTOMERS_ENDPOINT, customer);
    return response.data;
  },

  /**
   * Update an existing customer
   */
  update: async (id: string, customer: CustomerInput): Promise<Customer> => {
    const response = await apiClient.put<Customer>(`${CUSTOMERS_ENDPOINT}/${id}`, customer);
    return response.data;
  },

  /**
   * Delete a customer
   */
  delete: async (id: string): Promise<void> => {
    await apiClient.delete(`${CUSTOMERS_ENDPOINT}/${id}`);
  },
};
