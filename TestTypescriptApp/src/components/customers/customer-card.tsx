import * as React from 'react';
import { Edit, Mail, MoreVertical, Trash2, User } from 'lucide-react';
import { Button } from '@/components/ui/button';
import {
  Card,
  CardContent,
  CardDescription,
  CardHeader,
  CardTitle,
} from '@/components/ui/card';
import type { Customer } from '@/types/customer.types';

interface CustomerCardProps {
  customer: Customer;
  onEdit: (customer: Customer) => void;
  onDelete: (customer: Customer) => void;
}

export const CustomerCard: React.FC<CustomerCardProps> = ({ customer, onEdit, onDelete }) => {
  const [showActions, setShowActions] = React.useState(false);

  return (
    <Card className="hover:shadow-md transition-shadow">
      <CardHeader className="flex flex-row items-start justify-between space-y-0">
        <div className="flex items-center space-x-3">
          <div className="h-10 w-10 rounded-full bg-primary/10 flex items-center justify-center">
            <User className="h-5 w-5 text-primary" />
          </div>
          <div>
            <CardTitle className="text-base">{customer.name}</CardTitle>
            <CardDescription className="flex items-center mt-1">
              <Mail className="h-3 w-3 mr-1" />
              {customer.email}
            </CardDescription>
          </div>
        </div>
        <div className="relative">
          <Button
            variant="ghost"
            size="icon"
            onClick={() => setShowActions(!showActions)}
            className="h-8 w-8"
          >
            <MoreVertical className="h-4 w-4" />
          </Button>
          {showActions && (
            <>
              <div
                className="fixed inset-0 z-10"
                onClick={() => setShowActions(false)}
              />
              <div className="absolute right-0 top-8 z-20 w-48 rounded-md border bg-popover p-1 shadow-md">
                <Button
                  variant="ghost"
                  className="w-full justify-start"
                  onClick={() => {
                    onEdit(customer);
                    setShowActions(false);
                  }}
                >
                  <Edit className="mr-2 h-4 w-4" />
                  Edit
                </Button>
                <Button
                  variant="ghost"
                  className="w-full justify-start text-destructive hover:text-destructive"
                  onClick={() => {
                    onDelete(customer);
                    setShowActions(false);
                  }}
                >
                  <Trash2 className="mr-2 h-4 w-4" />
                  Delete
                </Button>
              </div>
            </>
          )}
        </div>
      </CardHeader>
      <CardContent>
        <div className="text-xs text-muted-foreground">
          ID: {customer.id}
        </div>
      </CardContent>
    </Card>
  );
};
