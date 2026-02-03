import * as React from 'react';
import { Edit, Mail, Trash2, User } from 'lucide-react';
import { Button } from '@/components/ui/button';
import type { Customer } from '@/types/customer.types';

interface CustomerTableProps {
  customers: Customer[];
  onEdit: (customer: Customer) => void;
  onDelete: (customer: Customer) => void;
}

export const CustomerTable: React.FC<CustomerTableProps> = ({ customers, onEdit, onDelete }) => {
  return (
    <div className="rounded-md border">
      <div className="overflow-x-auto">
        <table className="w-full caption-bottom text-sm">
          <thead className="[&_tr]:border-b">
            <tr className="border-b transition-colors hover:bg-muted/50">
              <th className="h-12 px-4 text-left align-middle font-medium text-muted-foreground">
                <div className="flex items-center space-x-2">
                  <User className="h-4 w-4" />
                  <span>Customer</span>
                </div>
              </th>
              <th className="h-12 px-4 text-left align-middle font-medium text-muted-foreground">
                <div className="flex items-center space-x-2">
                  <Mail className="h-4 w-4" />
                  <span>Email</span>
                </div>
              </th>
              <th className="h-12 px-4 text-left align-middle font-medium text-muted-foreground">
                ID
              </th>
              <th className="h-12 px-4 text-right align-middle font-medium text-muted-foreground">
                Actions
              </th>
            </tr>
          </thead>
          <tbody className="[&_tr:last-child]:border-0">
            {customers.length === 0 ? (
              <tr>
                <td colSpan={4} className="h-24 text-center text-muted-foreground">
                  No customers found.
                </td>
              </tr>
            ) : (
              customers.map((customer) => (
                <tr
                  key={customer.id}
                  className="border-b transition-colors hover:bg-muted/50"
                >
                  <td className="p-4 align-middle font-medium">{customer.name}</td>
                  <td className="p-4 align-middle">{customer.email}</td>
                  <td className="p-4 align-middle text-xs text-muted-foreground">
                    {customer.id}
                  </td>
                  <td className="p-4 align-middle text-right">
                    <div className="flex justify-end space-x-2">
                      <Button
                        variant="ghost"
                        size="sm"
                        onClick={() => onEdit(customer)}
                        aria-label={`Edit ${customer.name}`}
                      >
                        <Edit className="h-4 w-4" />
                      </Button>
                      <Button
                        variant="ghost"
                        size="sm"
                        onClick={() => onDelete(customer)}
                        aria-label={`Delete ${customer.name}`}
                        className="text-destructive hover:text-destructive"
                      >
                        <Trash2 className="h-4 w-4" />
                      </Button>
                    </div>
                  </td>
                </tr>
              ))
            )}
          </tbody>
        </table>
      </div>
    </div>
  );
};
