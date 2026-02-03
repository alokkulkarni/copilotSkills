/**
 * Customer entity matching the backend API structure
 */
export interface Customer {
  id: string;
  name: string;
  email: string;
}

/**
 * Customer input for create/update operations (id is optional)
 */
export interface CustomerInput {
  id?: string;
  name: string;
  email: string;
}

/**
 * Paginated response structure from the API
 */
export interface PageResponse<T> {
  content: T[];
  page: number;
  size: number;
  totalElements: number;
  totalPages: number;
}

/**
 * API error response structure
 */
export interface ErrorResponse {
  timestamp: string;
  status: number;
  error: string;
  message: string;
  path: string;
  errors?: FieldError[];
}

/**
 * Field validation error
 */
export interface FieldError {
  field: string;
  message: string;
}

/**
 * Pagination parameters
 */
export interface PaginationParams {
  page: number;
  size: number;
}

/**
 * API query parameters
 */
export interface QueryParams extends Partial<PaginationParams> {
  [key: string]: string | number | boolean | undefined;
}
