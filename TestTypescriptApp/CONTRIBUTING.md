# Contributing to Customer Management App

Thank you for considering contributing to the Customer Management App! This document provides guidelines and instructions for contributing.

## 🚀 Getting Started

1. Fork the repository
2. Clone your fork: `git clone https://github.com/YOUR_USERNAME/copilotSkills.git`
3. Navigate to the project: `cd copilotSkills/TestTypescriptApp`
4. Install dependencies: `npm install`
5. Create a branch: `git checkout -b feature/your-feature-name`

## 💻 Development Setup

### Prerequisites
- Node.js >= 18.0.0
- npm >= 9.0.0
- Backend API running (TestJavaProgrammer)

### Environment Setup
1. Copy `.env.example` to `.env`
2. Configure environment variables if needed
3. Start the backend: `cd ../TestJavaProgrammer && mvn spring-boot:run`
4. Start the dev server: `npm run dev`

## 📋 Development Guidelines

### Code Style
- Follow TypeScript strict mode (no `any` types)
- Use functional components with hooks
- Use meaningful variable and function names
- Add JSDoc comments for public APIs
- Format code with Prettier before committing
- Run ESLint and fix all warnings

### Commit Messages
Follow conventional commits format:
```
type(scope): subject

body (optional)

footer (optional)
```

Types:
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes (formatting, etc.)
- `refactor`: Code refactoring
- `test`: Adding or updating tests
- `chore`: Maintenance tasks

Examples:
```
feat(customers): add export to CSV functionality
fix(pagination): correct total pages calculation
docs(readme): update installation instructions
```

### Branch Naming
- `feature/description` - New features
- `fix/description` - Bug fixes
- `docs/description` - Documentation updates
- `refactor/description` - Code refactoring
- `test/description` - Test additions/updates

## 🧪 Testing

### Running Tests
```bash
npm run test           # Run all tests
npm run test:ui        # Run tests with UI
npm run test:coverage  # Generate coverage report
```

### Writing Tests
- Write tests for new features
- Maintain minimum 80% code coverage
- Use descriptive test names
- Follow Arrange-Act-Assert pattern
- Mock external dependencies

Example:
```typescript
describe('CustomerCard', () => {
  it('should render customer name and email', () => {
    // Arrange
    const customer = { id: '1', name: 'John Doe', email: 'john@example.com' };
    
    // Act
    render(<CustomerCard customer={customer} />);
    
    // Assert
    expect(screen.getByText('John Doe')).toBeInTheDocument();
    expect(screen.getByText('john@example.com')).toBeInTheDocument();
  });
});
```

## 🎨 UI/UX Guidelines

### Component Design
- Use existing UI components from `components/ui/`
- Follow responsive design principles (mobile-first)
- Ensure accessibility (ARIA labels, keyboard navigation)
- Support both dark and light themes
- Add loading and error states

### Styling
- Use Tailwind CSS utility classes
- Follow existing color palette and spacing
- Maintain consistency with existing components
- Test on multiple screen sizes

## 🔧 Pull Request Process

1. **Before submitting:**
   - Ensure all tests pass: `npm test`
   - Run type checking: `npm run type-check`
   - Run linter: `npm run lint`
   - Format code: `npm run format`
   - Update documentation if needed
   - Add tests for new features

2. **PR Description:**
   - Describe what changes you made
   - Reference related issues (Fixes #123)
   - Include screenshots for UI changes
   - List breaking changes (if any)

3. **Review Process:**
   - Address all review comments
   - Keep commits focused and atomic
   - Rebase on main if needed
   - Ensure CI passes

## 🐛 Bug Reports

When reporting bugs, include:
- Clear description of the issue
- Steps to reproduce
- Expected vs actual behavior
- Environment details (OS, Node version, browser)
- Screenshots or error messages
- Relevant code snippets

## 💡 Feature Requests

When requesting features, include:
- Clear description of the feature
- Use case and benefits
- Proposed implementation (optional)
- Mockups or examples (if applicable)

## 📝 Documentation

- Update README.md for user-facing changes
- Add JSDoc comments for new functions/components
- Update CHANGELOG.md following semantic versioning
- Include inline comments for complex logic

## ✅ Definition of Done

A contribution is considered complete when:
- [ ] Code follows project conventions
- [ ] All tests pass (existing + new)
- [ ] Code coverage maintained or improved
- [ ] TypeScript compilation succeeds (no errors)
- [ ] ESLint passes with no warnings
- [ ] Code is formatted with Prettier
- [ ] Documentation is updated
- [ ] PR description is complete
- [ ] Review comments addressed

## 🤝 Code of Conduct

### Our Standards
- Be respectful and inclusive
- Accept constructive criticism
- Focus on what's best for the community
- Show empathy towards others

### Unacceptable Behavior
- Harassment or discriminatory language
- Trolling or insulting comments
- Public or private harassment
- Publishing others' private information

## 📞 Questions?

- Open an issue for questions
- Tag maintainers for urgent issues
- Check existing issues before creating new ones

## 🙏 Thank You!

Your contributions make this project better. We appreciate your time and effort!

---

**Happy Coding!** 🚀
