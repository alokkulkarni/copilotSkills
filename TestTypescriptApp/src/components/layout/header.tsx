import * as React from 'react';
import { Link, useLocation } from 'react-router-dom';
import { Moon, Sun, Users } from 'lucide-react';
import { Button } from '@/components/ui/button';
import { useTheme } from '@/hooks/use-theme';

export const Header: React.FC = () => {
  const { theme, toggleTheme } = useTheme();
  const location = useLocation();

  return (
    <header className="sticky top-0 z-40 w-full border-b bg-background/95 backdrop-blur supports-[backdrop-filter]:bg-background/60">
      <div className="container flex h-16 items-center">
        <div className="flex items-center space-x-4 flex-1">
          <Link to="/" className="flex items-center space-x-2">
            <Users className="h-6 w-6 text-primary" />
            <span className="font-bold text-xl">Customer Manager</span>
          </Link>
        </div>

        <nav className="flex items-center space-x-2">
          <Link to="/">
            <Button
              variant={location.pathname === '/' ? 'default' : 'ghost'}
              size="sm"
            >
              Customers
            </Button>
          </Link>
          <Button
            variant="ghost"
            size="icon"
            onClick={toggleTheme}
            aria-label="Toggle theme"
          >
            {theme === 'dark' ? (
              <Sun className="h-5 w-5" />
            ) : (
              <Moon className="h-5 w-5" />
            )}
          </Button>
        </nav>
      </div>
    </header>
  );
};
