import * as React from 'react';
import { Grid, List, Plus, RefreshCw, Search } from 'lucide-react';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Loading } from '@/components/ui/loading';
import { ErrorDisplay } from '@/components/ui/error-display';
import { CustomerTable } from '@/components/customers/customer-table';
import { CustomerCard } from '@/components/customers/customer-card';
import { CustomerFormDialog } from '@/components/customers/customer-form-dialog';
import { DeleteConfirmDialog } from '@/components/customers/delete-confirm-dialog';
import { Pagination } from '@/components/customers/pagination';
import {
  useCustomers,
  useCreateCustomer,
  useUpdateCustomer,
  useDeleteCustomer,
} from '@/hooks/use-customers';
import type { Customer, CustomerInput } from '@/types/customer.types';
import { debounce } from '@/lib/utils';

type ViewMode = 'table' | 'grid';

export const CustomersPage: React.FC = () => {
  const [page, setPage] = React.useState(0);
  const [size, setSize] = React.useState(20);
  const [searchQuery, setSearchQuery] = React.useState('');
  const [viewMode, setViewMode] = React.useState<ViewMode>('table');
  const [isFormOpen, setIsFormOpen] = React.useState(false);
  const [isDeleteOpen, setIsDeleteOpen] = React.useState(false);
  const [selectedCustomer, setSelectedCustomer] = React.useState<Customer | null>(null);

  // Queries and mutations
  const { data, isLoading, error, refetch } = useCustomers({ page, size });
  const createMutation = useCreateCustomer();
  const updateMutation = useUpdateCustomer();
  const deleteMutation = useDeleteCustomer();

  // Filter customers based on search
  const filteredCustomers = React.useMemo(() => {
    if (!data?.content) return [];
    if (!searchQuery) return data.content;

    const query = searchQuery.toLowerCase();
    return data.content.filter(
      (customer) =>
        customer.name.toLowerCase().includes(query) ||
        customer.email.toLowerCase().includes(query)
    );
  }, [data?.content, searchQuery]);

  const handleSearch = debounce((value: unknown) => {
    setSearchQuery(String(value));
    setPage(0);
  }, 300);

  const handleCreateClick = () => {
    setSelectedCustomer(null);
    setIsFormOpen(true);
  };

  const handleEditClick = (customer: Customer) => {
    setSelectedCustomer(customer);
    setIsFormOpen(true);
  };

  const handleDeleteClick = (customer: Customer) => {
    setSelectedCustomer(customer);
    setIsDeleteOpen(true);
  };

  const handleFormSubmit = async (data: CustomerInput) => {
    if (selectedCustomer) {
      await updateMutation.mutateAsync({
        id: selectedCustomer.id,
        customer: data,
      });
    } else {
      await createMutation.mutateAsync(data);
    }
  };

  const handleDeleteConfirm = async () => {
    if (selectedCustomer) {
      await deleteMutation.mutateAsync(selectedCustomer.id);
    }
  };

  const handlePageChange = (newPage: number) => {
    setPage(newPage);
  };

  const handlePageSizeChange = (newSize: number) => {
    setSize(newSize);
    setPage(0);
  };

  if (isLoading) {
    return <Loading text="Loading customers..." />;
  }

  if (error) {
    return (
      <ErrorDisplay
        message="Failed to load customers. Please check your connection and try again."
        onRetry={() => refetch()}
      />
    );
  }

  return (
    <div className="space-y-6">
      {/* Header */}
      <div className="flex flex-col sm:flex-row justify-between items-start sm:items-center gap-4">
        <div>
          <h1 className="text-3xl font-bold tracking-tight">Customers</h1>
          <p className="text-muted-foreground">
            Manage your customer database
          </p>
        </div>
        <Button onClick={handleCreateClick}>
          <Plus className="mr-2 h-4 w-4" />
          Add Customer
        </Button>
      </div>

      {/* Filters and Actions */}
      <div className="flex flex-col sm:flex-row gap-4">
        <div className="relative flex-1">
          <Search className="absolute left-3 top-1/2 h-4 w-4 -translate-y-1/2 text-muted-foreground" />
          <Input
            placeholder="Search by name or email..."
            className="pl-10"
            onChange={(e) => handleSearch(e.target.value)}
          />
        </div>
        <div className="flex gap-2">
          <Button
            variant="outline"
            size="icon"
            onClick={() => setViewMode('table')}
            aria-label="Table view"
            className={viewMode === 'table' ? 'bg-accent' : ''}
          >
            <List className="h-4 w-4" />
          </Button>
          <Button
            variant="outline"
            size="icon"
            onClick={() => setViewMode('grid')}
            aria-label="Grid view"
            className={viewMode === 'grid' ? 'bg-accent' : ''}
          >
            <Grid className="h-4 w-4" />
          </Button>
          <Button variant="outline" size="icon" onClick={() => refetch()} aria-label="Refresh">
            <RefreshCw className="h-4 w-4" />
          </Button>
        </div>
      </div>

      {/* Content */}
      {viewMode === 'table' ? (
        <CustomerTable
          customers={filteredCustomers}
          onEdit={handleEditClick}
          onDelete={handleDeleteClick}
        />
      ) : (
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
          {filteredCustomers.map((customer) => (
            <CustomerCard
              key={customer.id}
              customer={customer}
              onEdit={handleEditClick}
              onDelete={handleDeleteClick}
            />
          ))}
        </div>
      )}

      {/* Pagination */}
      {data && data.totalPages > 0 && (
        <Pagination
          currentPage={page}
          totalPages={data.totalPages}
          pageSize={size}
          totalElements={data.totalElements}
          onPageChange={handlePageChange}
          onPageSizeChange={handlePageSizeChange}
        />
      )}

      {/* Dialogs */}
      <CustomerFormDialog
        open={isFormOpen}
        onOpenChange={setIsFormOpen}
        onSubmit={handleFormSubmit}
        customer={selectedCustomer}
        title={selectedCustomer ? 'Edit Customer' : 'Create Customer'}
        description={
          selectedCustomer
            ? 'Update the customer information below.'
            : 'Add a new customer to your database.'
        }
      />

      <DeleteConfirmDialog
        open={isDeleteOpen}
        onOpenChange={setIsDeleteOpen}
        onConfirm={handleDeleteConfirm}
        customerName={selectedCustomer?.name || ''}
      />
    </div>
  );
};
