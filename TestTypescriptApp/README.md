# Customer Management App

A modern, responsive React TypeScript application for managing customers, built with Vite, React Query, and Tailwind CSS.

## 🚀 Features

- ✅ **Full CRUD Operations** - Create, Read, Update, Delete customers
- 📊 **Paginated Table View** - Efficient data display with pagination
- 🎴 **Grid Card View** - Alternative card-based layout
- 🔍 **Real-time Search** - Filter customers by name or email
- 🎨 **Dark/Light Theme** - Toggle between themes with persistence
- 📱 **Responsive Design** - Mobile-first, works on all devices
- ⚡ **Optimistic Updates** - Instant UI feedback with React Query
- 🎯 **Form Validation** - Zod schema validation
- 🔔 **Toast Notifications** - User feedback for actions
- 🎭 **Loading States** - Skeleton loaders and spinners
- 🛡️ **Error Handling** - Comprehensive error boundaries
- 🧪 **Type Safety** - Strict TypeScript configuration

## 📋 Prerequisites

- Node.js >= 18.0.0
- npm >= 9.0.0
- Backend API running at `http://localhost:8080` (TestJavaProgrammer)

## 🛠️ Installation

1. **Clone the repository** (if not already done)

2. **Install dependencies**
   ```bash
   cd TestTypescriptApp
   npm install
   ```

3. **Create environment file**
   ```bash
   cp .env.example .env
   ```

4. **Configure environment variables**
   ```env
   VITE_API_BASE_URL=http://localhost:8080/api/v1
   VITE_APP_NAME=Customer Management
   VITE_APP_VERSION=1.0.0
   ```

## 🚀 Running the Application

### Development Mode

```bash
npm run dev
```

The application will start at `http://localhost:3000`

### Production Build

```bash
npm run build
npm run preview
```

## 📁 Project Structure

```
TestTypescriptApp/
├── src/
│   ├── api/                    # API client and endpoints
│   │   ├── client.ts          # Axios configuration
│   │   └── customers.ts       # Customer API calls
│   ├── components/
│   │   ├── ui/                # Reusable UI components
│   │   │   ├── button.tsx
│   │   │   ├── card.tsx
│   │   │   ├── dialog.tsx
│   │   │   ├── input.tsx
│   │   │   ├── loading.tsx
│   │   │   └── error-display.tsx
│   │   ├── customers/         # Customer-specific components
│   │   │   ├── customer-card.tsx
│   │   │   ├── customer-table.tsx
│   │   │   ├── customer-form-dialog.tsx
│   │   │   ├── delete-confirm-dialog.tsx
│   │   │   └── pagination.tsx
│   │   └── layout/            # Layout components
│   │       ├── header.tsx
│   │       └── layout.tsx
│   ├── hooks/                 # Custom React hooks
│   │   ├── use-customers.ts   # Customer data hooks
│   │   └── use-theme.tsx      # Theme management
│   ├── lib/                   # Utilities
│   │   └── utils.ts          # Helper functions
│   ├── pages/                 # Page components
│   │   └── customers-page.tsx
│   ├── types/                 # TypeScript types
│   │   └── customer.types.ts
│   ├── test/                  # Test setup
│   │   └── setup.ts
│   ├── App.tsx               # Main app component
│   ├── main.tsx              # Entry point
│   └── index.css             # Global styles
├── public/                    # Static assets
├── index.html
├── package.json
├── tsconfig.json
├── vite.config.ts
├── tailwind.config.js
└── README.md
```

## 🎨 Tech Stack

### Core
- **React 18** - UI library
- **TypeScript 5** - Type safety
- **Vite** - Build tool and dev server

### State Management & Data Fetching
- **TanStack Query (React Query)** - Server state management
- **Axios** - HTTP client

### UI & Styling
- **Tailwind CSS** - Utility-first CSS framework
- **Lucide React** - Icon library
- **Sonner** - Toast notifications

### Form Management
- **React Hook Form** - Form state management
- **Zod** - Schema validation

### Routing
- **React Router v6** - Client-side routing

### Testing
- **Vitest** - Unit testing framework
- **Testing Library** - Component testing

## 🧪 Available Scripts

```bash
# Development
npm run dev              # Start dev server on port 3000

# Build
npm run build            # TypeScript compilation + Vite build
npm run preview          # Preview production build

# Code Quality
npm run lint             # Run ESLint
npm run format           # Format code with Prettier
npm run type-check       # TypeScript type checking

# Testing
npm run test             # Run tests
npm run test:ui          # Run tests with UI
npm run test:coverage    # Generate coverage report
```

## 🔌 API Integration

The app connects to the TestJavaProgrammer backend API:

### Base URL
```
http://localhost:8080/api/v1
```

### Endpoints Used
- `GET /customers?page={page}&size={size}` - List customers (paginated)
- `GET /customers/{id}` - Get customer by ID
- `POST /customers` - Create customer
- `PUT /customers/{id}` - Update customer
- `DELETE /customers/{id}` - Delete customer

### API Configuration

The API client is configured in `src/api/client.ts` with:
- 10-second timeout
- Request/Response interceptors
- Error handling
- Proxy configuration (in development)

## 🎯 Key Features Explained

### 1. Pagination
- Server-side pagination with configurable page size (10, 20, 50, 100)
- Navigation: First, Previous, Next, Last page buttons
- Shows current range and total count

### 2. Search & Filter
- Client-side filtering by name or email
- Debounced search (300ms delay)
- Real-time results

### 3. View Modes
- **Table View**: Compact, data-dense display
- **Grid View**: Card-based layout for visual appeal

### 4. Theme Support
- Dark and Light modes
- System preference detection
- Theme persistence in localStorage
- Smooth transitions

### 5. Form Validation
- Zod schema validation
- Required field validation
- Email format validation
- Real-time error messages

### 6. Optimistic Updates
- Instant UI feedback
- Automatic cache invalidation
- Error rollback on failure

## 🚦 Getting Started - Quick Guide

1. **Start the backend** (TestJavaProgrammer)
   ```bash
   cd ../TestJavaProgrammer
   mvn spring-boot:run
   ```
   Backend will run on `http://localhost:8080`

2. **Start the frontend** (this app)
   ```bash
   cd TestTypescriptApp
   npm install
   npm run dev
   ```
   Frontend will run on `http://localhost:3000`

3. **Open your browser**
   Navigate to `http://localhost:3000`

## 🛡️ Error Handling

The app handles various error scenarios:
- Network errors (backend down)
- Validation errors (400)
- Not found errors (404)
- Server errors (500)
- Timeout errors

All errors display user-friendly messages with retry options.

## 📱 Responsive Design

Breakpoints:
- **Mobile**: < 640px
- **Tablet**: 640px - 1024px
- **Desktop**: > 1024px

Features adapt based on screen size:
- Stacked layout on mobile
- Optimized table for smaller screens
- Touch-friendly buttons

## 🔒 Security

- No hardcoded credentials
- Environment variables for configuration
- Input sanitization
- XSS prevention through React
- CSRF protection (if needed, configure in backend)

## 🧪 Testing

Run tests:
```bash
npm run test
```

Generate coverage:
```bash
npm run test:coverage
```

Testing includes:
- Component unit tests
- API integration tests
- Hook tests
- Utility function tests

## 🎓 Code Quality

The project enforces:
- **Strict TypeScript** - No `any` types allowed
- **ESLint** - Code linting with recommended rules
- **Prettier** - Code formatting
- **Consistent naming** - camelCase, PascalCase conventions

## 🤝 Contributing

1. Follow TypeScript strict mode
2. Write tests for new features
3. Use semantic commit messages
4. Ensure all tests pass
5. Run linter before committing

## 📄 License

This project is part of the copilotSkills repository.

## 🙏 Acknowledgments

- Built with modern React best practices
- Follows TypeScript/React standards
- Uses industry-standard libraries
- Implements accessible UI patterns

---

**Author**: Customer Management Team  
**Version**: 1.0.0  
**Last Updated**: February 2, 2026
