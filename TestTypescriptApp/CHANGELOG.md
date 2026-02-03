# Changelog

All notable changes to the Customer Management App will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2026-02-02

### Added
- Initial release of Customer Management Application
- Full CRUD operations for customers
- Paginated customer list with configurable page sizes (10, 20, 50, 100)
- Real-time search and filter functionality
- Table and Grid view modes
- Dark/Light theme support with system preference detection
- Responsive design for mobile, tablet, and desktop
- Form validation with Zod schema
- Toast notifications for user feedback
- Loading states and error handling
- React Query for optimistic updates and cache management
- Comprehensive TypeScript types (strict mode)
- ESLint and Prettier configuration
- Vitest testing setup
- Component tests for UI elements
- Hook tests for custom React hooks
- Utility function tests

### Technical Stack
- React 18.2.0 with TypeScript 5.3.3
- Vite 5.1.0 for build and dev server
- Tailwind CSS 3.4.1 for styling
- TanStack Query 5.20.0 for server state
- React Hook Form 7.50.0 for forms
- Zod 3.22.4 for validation
- Axios 1.6.7 for HTTP requests
- React Router 6.22.0 for routing
- Lucide React 0.323.0 for icons
- Sonner 1.4.0 for notifications

### API Integration
- Connected to TestJavaProgrammer backend (Spring Boot 3.4.1)
- Base URL: http://localhost:8080/api/v1
- Endpoints: GET/POST/PUT/DELETE /customers
- Pagination support with page and size parameters
- Error handling with field-level validation errors

### Documentation
- Comprehensive README.md
- QUICKSTART.md for rapid setup
- Inline JSDoc comments
- Component prop documentation
- API client documentation

[1.0.0]: https://github.com/alokkulkarni/copilotSkills/releases/tag/v1.0.0
