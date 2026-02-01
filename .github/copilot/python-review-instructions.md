# Python-Specific Code Review Guidelines

## Purpose
This document provides comprehensive Python-specific code review guidelines to ensure adherence to Python best practices, language features, PEPs (Python Enhancement Proposals), frameworks, and ecosystem standards.

---

## 1. Python Language Standards and Best Practices

### 1.1 Python Version and Features
- **Current Python Version**: Verify project uses supported Python version (3.8+ minimum, 3.10+ recommended)
- **Modern Python Features**: Encourage use of modern Python features
  - Python 3.6+: f-strings, type hints, async/await
  - Python 3.7+: Data classes, postponed evaluation of annotations
  - Python 3.8+: Walrus operator (`:=`), positional-only parameters
  - Python 3.9+: Type hints improvements, dict merge operators
  - Python 3.10+: Structural pattern matching, union types with `|`
  - Python 3.11+: Exception groups, improved error messages
  - Python 3.12+: Type parameter syntax, improved f-strings
- **End-of-Life**: Avoid Python 2.7 and Python 3.5 or earlier
- **Future Annotations**: Use `from __future__ import annotations` for better type hints

### 1.2 PEP Standards
- **PEP 8**: Style Guide for Python Code (mandatory)
- **PEP 20**: The Zen of Python (philosophy)
- **PEP 257**: Docstring Conventions
- **PEP 484**: Type Hints
- **PEP 526**: Syntax for Variable Annotations
- **PEP 585**: Type Hinting Generics in Standard Collections (3.9+)
- **PEP 604**: Union Types with `|` (3.10+)

### 1.3 Code Structure and Organization
- **Module Organization**:
  1. Shebang line (if executable)
  2. Module docstring
  3. `__all__` definition (if needed)
  4. Imports (standard library, third-party, local)
  5. Module-level constants
  6. Module-level functions and classes
  7. `if __name__ == "__main__":` block
- **Package Structure**: Use `__init__.py` for package initialization
- **Relative Imports**: Use explicit relative imports within packages
- **Import Order**: Follow PEP 8 (standard library, third-party, local)

### 1.4 Naming Conventions (PEP 8)
- **Modules**: `lowercase_with_underscores.py`
- **Packages**: `lowercasewithoutunderscores` (short names)
- **Classes**: `PascalCase` (`UserProfile`, `PaymentProcessor`)
- **Exceptions**: `PascalCase` ending with `Error` or `Exception`
- **Functions/Methods**: `lowercase_with_underscores()` (`get_user_by_id()`)
- **Variables**: `lowercase_with_underscores` (`user_name`, `total_count`)
- **Constants**: `UPPER_CASE_WITH_UNDERSCORES` (`MAX_CONNECTIONS`, `DEFAULT_TIMEOUT`)
- **Private**: Single leading underscore `_internal_method()`
- **Name Mangling**: Double leading underscore `__private` (use sparingly)
- **Magic Methods**: Double leading and trailing `__init__`, `__str__`

---

## 2. Python Core Language Features

### 2.1 Type Hints (PEP 484)
- **Use Type Hints**: For function signatures and class attributes
- **Modern Syntax**: Use built-in types for generics (Python 3.9+)
  ```python
  # Python 3.9+
  def process_items(items: list[str]) -> dict[str, int]:
      pass
  
  # Python 3.10+
  def get_value() -> str | None:
      pass
  
  # Earlier versions
  from typing import List, Dict, Optional
  def process_items(items: List[str]) -> Dict[str, int]:
      pass
  ```
- **Type Aliases**: Use for complex types
  ```python
  UserId = int
  UserData = dict[str, str | int]
  ```
- **TypeVar**: For generic functions
  ```python
  from typing import TypeVar
  T = TypeVar('T')
  
  def first(items: list[T]) -> T:
      return items[0]
  ```
- **Protocol**: For structural subtyping (duck typing)
- **Literal**: For specific literal values
- **Final**: For constants that shouldn't be reassigned

### 2.2 The Zen of Python (PEP 20)
**Key Principles**:
- Beautiful is better than ugly
- Explicit is better than implicit
- Simple is better than complex
- Complex is better than complicated
- Flat is better than nested
- Sparse is better than dense
- Readability counts
- Special cases aren't special enough to break the rules
- Errors should never pass silently
- There should be one-- and preferably only one --obvious way to do it

### 2.3 Pythonic Code

**List Comprehensions**:
```python
# Good: Concise and readable
squares = [x**2 for x in range(10)]
even_squares = [x**2 for x in range(10) if x % 2 == 0]

# Bad: Verbose
squares = []
for x in range(10):
    squares.append(x**2)
```

**Generator Expressions**:
```python
# Good: Memory efficient for large sequences
sum_of_squares = sum(x**2 for x in range(10000))

# Bad: Creates unnecessary list
sum_of_squares = sum([x**2 for x in range(10000)])
```

**Dictionary Comprehensions**:
```python
# Good: Concise dictionary creation
user_dict = {user.id: user for user in users}

# Python 3.9+ dict merge
merged = dict1 | dict2
```

**Context Managers**:
```python
# Good: Automatic resource cleanup
with open('file.txt', 'r') as f:
    content = f.read()

# Bad: Manual cleanup, error-prone
f = open('file.txt', 'r')
try:
    content = f.read()
finally:
    f.close()
```

**Unpacking**:
```python
# Good: Elegant unpacking
first, *middle, last = [1, 2, 3, 4, 5]
a, b = b, a  # Swap

# Dictionary unpacking
merged = {**default_config, **user_config}
```

**Enumerate and Zip**:
```python
# Good: Use enumerate for index and value
for i, item in enumerate(items):
    print(f"{i}: {item}")

# Good: Use zip for parallel iteration
for name, age in zip(names, ages):
    print(f"{name} is {age} years old")
```

### 2.4 Data Classes (Python 3.7+)
```python
from dataclasses import dataclass, field

@dataclass
class User:
    id: int
    name: str
    email: str
    active: bool = True
    tags: list[str] = field(default_factory=list)
    
    def __post_init__(self):
        # Validation after initialization
        if not self.email:
            raise ValueError("Email required")
```

**When to Use**:
- Simple data containers
- Immutable data (`@dataclass(frozen=True)`)
- Classes primarily holding data

**Dataclass Features**:
- `@dataclass(frozen=True)`: Immutable
- `@dataclass(order=True)`: Comparable
- `field()`: Advanced field configuration
- `__post_init__`: Custom initialization

### 2.5 Properties and Descriptors

**Properties**:
```python
class User:
    def __init__(self, name: str):
        self._name = name
    
    @property
    def name(self) -> str:
        """User's name."""
        return self._name
    
    @name.setter
    def name(self, value: str) -> None:
        if not value:
            raise ValueError("Name cannot be empty")
        self._name = value
    
    @property
    def display_name(self) -> str:
        """Computed property."""
        return self._name.title()
```

**When to Use Properties**:
- Computed values
- Validation on setting
- Backwards compatibility
- Logging/debugging access

### 2.6 Decorators

**Built-in Decorators**:
```python
class MyClass:
    @classmethod
    def from_dict(cls, data: dict) -> 'MyClass':
        """Alternative constructor."""
        return cls(**data)
    
    @staticmethod
    def validate(value: str) -> bool:
        """Utility function."""
        return bool(value)
    
    @property
    def computed_value(self) -> int:
        """Computed property."""
        return self._value * 2
```

**Custom Decorators**:
```python
from functools import wraps
import time

def timing_decorator(func):
    @wraps(func)
    def wrapper(*args, **kwargs):
        start = time.time()
        result = func(*args, **kwargs)
        end = time.time()
        print(f"{func.__name__} took {end - start:.2f}s")
        return result
    return wrapper

@timing_decorator
def slow_function():
    time.sleep(1)
```

**Best Practices**:
- Use `@wraps` to preserve function metadata
- Return wrapper function
- Handle `*args` and `**kwargs` properly
- Consider using decorator libraries (e.g., `functools`)

---

## 3. Exception Handling

### 3.1 Python Exception Hierarchy
- **BaseException**: Root of exception hierarchy
  - **Exception**: User exceptions should inherit from this
    - **ValueError**: Invalid value
    - **TypeError**: Wrong type
    - **KeyError**: Missing dictionary key
    - **IndexError**: Index out of range
    - **AttributeError**: Missing attribute
    - **FileNotFoundError**: File doesn't exist
    - **IOError**: I/O operation failed

### 3.2 Exception Best Practices

**Specific Exceptions**:
```python
# Good: Catch specific exceptions
try:
    value = int(user_input)
except ValueError as e:
    print(f"Invalid number: {e}")
except KeyError as e:
    print(f"Missing key: {e}")

# Bad: Bare except catches everything
try:
    value = int(user_input)
except:  # Bad!
    pass
```

**Custom Exceptions**:
```python
class ValidationError(Exception):
    """Raised when validation fails."""
    pass

class DatabaseError(Exception):
    """Raised when database operation fails."""
    
    def __init__(self, message: str, original_error: Exception):
        super().__init__(message)
        self.original_error = original_error
```

**EAFP vs LBYL**:
```python
# EAFP (Easier to Ask for Forgiveness than Permission) - Pythonic
try:
    value = data[key]
except KeyError:
    value = default

# LBYL (Look Before You Leap) - Less Pythonic
if key in data:
    value = data[key]
else:
    value = default

# Use EAFP when operation is expected to succeed
# Use LBYL when checking is cheaper than exception
```

**Context Managers for Cleanup**:
```python
from contextlib import contextmanager

@contextmanager
def database_connection():
    conn = connect_to_database()
    try:
        yield conn
    finally:
        conn.close()

with database_connection() as conn:
    conn.execute("SELECT * FROM users")
```

### 3.3 Exception Chaining
```python
# Good: Preserve exception context
try:
    process_data()
except ValueError as e:
    raise ProcessingError("Failed to process") from e

# Python 3.11+ Exception Groups
try:
    operation()
except* ValueError as e:
    handle_value_errors(e.exceptions)
except* TypeError as e:
    handle_type_errors(e.exceptions)
```

---

## 4. Object-Oriented Programming

### 4.1 Class Design

**Simple Class**:
```python
class User:
    """Represents a user in the system."""
    
    def __init__(self, name: str, email: str):
        self.name = name
        self.email = email
    
    def __repr__(self) -> str:
        return f"User(name={self.name!r}, email={self.email!r})"
    
    def __str__(self) -> str:
        return f"{self.name} <{self.email}>"
```

**Magic Methods** (Dunder Methods):
```python
class Account:
    def __init__(self, balance: float = 0):
        self.balance = balance
    
    def __repr__(self) -> str:
        """Developer representation."""
        return f"Account(balance={self.balance})"
    
    def __str__(self) -> str:
        """User-friendly representation."""
        return f"${self.balance:.2f}"
    
    def __eq__(self, other: object) -> bool:
        """Equality comparison."""
        if not isinstance(other, Account):
            return NotImplemented
        return self.balance == other.balance
    
    def __lt__(self, other: 'Account') -> bool:
        """Less than comparison."""
        return self.balance < other.balance
    
    def __add__(self, amount: float) -> 'Account':
        """Addition operator."""
        return Account(self.balance + amount)
```

### 4.2 Inheritance

**Single Inheritance**:
```python
class Animal:
    def __init__(self, name: str):
        self.name = name
    
    def speak(self) -> str:
        raise NotImplementedError("Subclasses must implement")

class Dog(Animal):
    def speak(self) -> str:
        return f"{self.name} says Woof!"
```

**Multiple Inheritance (Use Carefully)**:
```python
from abc import ABC, abstractmethod

class Flyable(ABC):
    @abstractmethod
    def fly(self) -> str:
        pass

class Swimmable(ABC):
    @abstractmethod
    def swim(self) -> str:
        pass

class Duck(Animal, Flyable, Swimmable):
    def fly(self) -> str:
        return f"{self.name} is flying"
    
    def swim(self) -> str:
        return f"{self.name} is swimming"
```

**Composition Over Inheritance**:
```python
# Good: Composition
class Engine:
    def start(self):
        return "Engine started"

class Car:
    def __init__(self):
        self.engine = Engine()
    
    def start(self):
        return self.engine.start()

# Bad: Unnecessary inheritance
class Car(Engine):
    pass
```

### 4.3 Abstract Base Classes

```python
from abc import ABC, abstractmethod

class Repository(ABC):
    """Abstract repository interface."""
    
    @abstractmethod
    def save(self, entity: object) -> None:
        """Save entity to storage."""
        pass
    
    @abstractmethod
    def find_by_id(self, id: int) -> object | None:
        """Find entity by ID."""
        pass

class UserRepository(Repository):
    def save(self, entity: User) -> None:
        # Implementation
        pass
    
    def find_by_id(self, id: int) -> User | None:
        # Implementation
        pass
```

### 4.4 Mixins

```python
class TimestampMixin:
    """Add timestamp functionality to classes."""
    
    def __init__(self, *args, **kwargs):
        super().__init__(*args, **kwargs)
        self.created_at = datetime.now()
        self.updated_at = datetime.now()
    
    def touch(self):
        """Update the timestamp."""
        self.updated_at = datetime.now()

class User(TimestampMixin):
    def __init__(self, name: str):
        super().__init__()
        self.name = name
```

---

## 5. Functional Programming

### 5.1 Functions as First-Class Citizens

**Lambda Functions**:
```python
# Good: Simple transformations
square = lambda x: x**2
sorted_users = sorted(users, key=lambda u: u.age)

# Bad: Complex logic in lambda (use def)
complex = lambda x, y: (x + y) * 2 if x > 0 else (x - y) / 2
```

**Higher-Order Functions**:
```python
def apply_twice(func, value):
    """Apply function twice."""
    return func(func(value))

def add_one(x):
    return x + 1

result = apply_twice(add_one, 5)  # 7
```

### 5.2 Built-in Functional Tools

**map, filter, reduce**:
```python
from functools import reduce

# map - transformation
squares = list(map(lambda x: x**2, range(10)))

# filter - selection
evens = list(filter(lambda x: x % 2 == 0, range(10)))

# reduce - aggregation
total = reduce(lambda x, y: x + y, range(10))

# Prefer comprehensions for readability
squares = [x**2 for x in range(10)]
evens = [x for x in range(10) if x % 2 == 0]
total = sum(range(10))
```

**functools utilities**:
```python
from functools import partial, lru_cache, singledispatch

# partial - partial application
from_base_ten = partial(int, base=10)
result = from_base_ten("42")

# lru_cache - memoization
@lru_cache(maxsize=128)
def fibonacci(n: int) -> int:
    if n < 2:
        return n
    return fibonacci(n-1) + fibonacci(n-2)

# singledispatch - function overloading
@singledispatch
def process(value):
    raise NotImplementedError(f"Cannot process {type(value)}")

@process.register(int)
def _(value: int):
    return value * 2

@process.register(str)
def _(value: str):
    return value.upper()
```

### 5.3 Itertools

```python
from itertools import (
    chain, combinations, cycle, groupby, 
    islice, product, zip_longest
)

# chain - concatenate iterables
combined = list(chain([1, 2], [3, 4], [5, 6]))

# combinations - all combinations
pairs = list(combinations([1, 2, 3], 2))

# groupby - group by key
data = [('a', 1), ('a', 2), ('b', 3)]
for key, group in groupby(data, key=lambda x: x[0]):
    print(key, list(group))

# islice - slice iterator
first_five = list(islice(range(100), 5))
```

---

## 6. Asynchronous Programming

### 6.1 Asyncio Basics

**Async Functions**:
```python
import asyncio

async def fetch_user(user_id: int) -> User:
    """Async database query."""
    await asyncio.sleep(1)  # Simulate I/O
    return User(id=user_id, name="John")

async def main():
    user = await fetch_user(1)
    print(user)

# Run
asyncio.run(main())
```

**Concurrent Execution**:
```python
async def fetch_multiple_users(user_ids: list[int]) -> list[User]:
    """Fetch multiple users concurrently."""
    tasks = [fetch_user(user_id) for user_id in user_ids]
    return await asyncio.gather(*tasks)
```

### 6.2 Async Context Managers

```python
class AsyncDatabase:
    async def __aenter__(self):
        self.conn = await connect_async()
        return self.conn
    
    async def __aexit__(self, exc_type, exc_val, exc_tb):
        await self.conn.close()

async with AsyncDatabase() as db:
    await db.execute("SELECT * FROM users")
```

### 6.3 Async Iterators

```python
class AsyncRange:
    def __init__(self, n: int):
        self.n = n
        self.i = 0
    
    def __aiter__(self):
        return self
    
    async def __anext__(self):
        if self.i >= self.n:
            raise StopAsyncIteration
        await asyncio.sleep(0.1)
        self.i += 1
        return self.i

async for i in AsyncRange(5):
    print(i)
```

### 6.4 Async Best Practices

**Do's**:
- Use `asyncio.gather()` for concurrent execution
- Use `async with` for async context managers
- Use `async for` for async iterators
- Handle cancellation gracefully
- Use `asyncio.create_task()` for background tasks

**Don'ts**:
- Don't mix blocking and async code
- Don't use `time.sleep()` (use `asyncio.sleep()`)
- Don't use synchronous I/O in async functions
- Don't forget to `await` coroutines

---

## 7. Standard Library Usage

### 7.1 Collections Module

```python
from collections import (
    defaultdict, Counter, deque, 
    namedtuple, OrderedDict, ChainMap
)

# defaultdict - default values
word_count = defaultdict(int)
word_count['hello'] += 1

# Counter - counting
counts = Counter(['a', 'b', 'a', 'c', 'b', 'a'])
most_common = counts.most_common(2)

# deque - efficient queue
queue = deque([1, 2, 3])
queue.append(4)
queue.popleft()

# namedtuple - lightweight objects
Point = namedtuple('Point', ['x', 'y'])
p = Point(1, 2)
```

### 7.2 Pathlib (Modern File Handling)

```python
from pathlib import Path

# Good: Use pathlib
path = Path('data') / 'users' / 'user.json'
if path.exists():
    content = path.read_text()

# Bad: String manipulation
import os
path = os.path.join('data', 'users', 'user.json')
if os.path.exists(path):
    with open(path) as f:
        content = f.read()
```

**Pathlib Operations**:
```python
# Navigation
home = Path.home()
cwd = Path.cwd()
parent = path.parent
name = path.name
stem = path.stem
suffix = path.suffix

# Operations
path.mkdir(parents=True, exist_ok=True)
path.write_text("content")
content = path.read_text()
path.unlink()  # Delete

# Globbing
for py_file in Path('.').glob('**/*.py'):
    print(py_file)
```

### 7.3 Datetime

```python
from datetime import datetime, date, time, timedelta, timezone

# Creation
now = datetime.now()
today = date.today()
utc_now = datetime.now(timezone.utc)

# Parsing and formatting
parsed = datetime.strptime("2026-01-31", "%Y-%m-%d")
formatted = now.strftime("%Y-%m-%d %H:%M:%S")

# Arithmetic
tomorrow = now + timedelta(days=1)
week_ago = now - timedelta(weeks=1)

# Timezone-aware (preferred)
from zoneinfo import ZoneInfo
eastern = datetime.now(ZoneInfo("America/New_York"))
```

### 7.4 Enum

```python
from enum import Enum, auto, IntEnum, Flag

class Status(Enum):
    """String enum."""
    PENDING = "pending"
    APPROVED = "approved"
    REJECTED = "rejected"

class Permission(IntEnum):
    """Integer enum."""
    READ = 1
    WRITE = 2
    EXECUTE = 4

class Color(Enum):
    """Auto-valued enum."""
    RED = auto()
    GREEN = auto()
    BLUE = auto()

# Usage
status = Status.PENDING
if status == Status.PENDING:
    print("Waiting approval")
```

---

## 8. Testing in Python

### 8.1 Unittest (Built-in)

```python
import unittest

class TestUserService(unittest.TestCase):
    def setUp(self):
        """Set up test fixtures."""
        self.service = UserService()
    
    def tearDown(self):
        """Clean up after tests."""
        self.service.close()
    
    def test_create_user(self):
        """Test user creation."""
        user = self.service.create_user("John", "john@example.com")
        self.assertEqual(user.name, "John")
        self.assertIsNotNone(user.id)
    
    def test_invalid_email_raises_error(self):
        """Test email validation."""
        with self.assertRaises(ValueError):
            self.service.create_user("John", "invalid-email")

if __name__ == '__main__':
    unittest.main()
```

### 8.2 Pytest (Recommended)

```python
import pytest

@pytest.fixture
def user_service():
    """Fixture for user service."""
    service = UserService()
    yield service
    service.close()

def test_create_user(user_service):
    """Test user creation."""
    user = user_service.create_user("John", "john@example.com")
    assert user.name == "John"
    assert user.id is not None

def test_invalid_email_raises_error(user_service):
    """Test email validation."""
    with pytest.raises(ValueError, match="Invalid email"):
        user_service.create_user("John", "invalid-email")

@pytest.mark.parametrize("email,valid", [
    ("user@example.com", True),
    ("invalid", False),
    ("", False),
])
def test_email_validation(email, valid):
    """Test email validation with multiple inputs."""
    if valid:
        assert validate_email(email)
    else:
        assert not validate_email(email)
```

### 8.3 Mocking

```python
from unittest.mock import Mock, patch, MagicMock

# Mock objects
mock_db = Mock()
mock_db.query.return_value = [User(id=1, name="John")]

# Patching
with patch('module.database.connect') as mock_connect:
    mock_connect.return_value = mock_db
    # Test code that uses database.connect()

# Decorator patching
@patch('module.external_api.call')
def test_api_integration(mock_api_call):
    mock_api_call.return_value = {"status": "success"}
    result = process_api_data()
    assert result["status"] == "success"
    mock_api_call.assert_called_once()
```

### 8.4 Test Organization

**Structure**:
```
project/
├── src/
│   └── mypackage/
│       ├── __init__.py
│       └── module.py
└── tests/
    ├── __init__.py
    ├── conftest.py          # Shared fixtures
    ├── test_module.py
    └── integration/
        └── test_api.py
```

**Test Naming**:
- Test files: `test_*.py` or `*_test.py`
- Test classes: `Test*`
- Test functions: `test_*`

---

## 9. Python Web Frameworks

### 9.1 Flask (Micro Framework)

```python
from flask import Flask, request, jsonify

app = Flask(__name__)

@app.route('/users', methods=['GET'])
def get_users():
    """Get all users."""
    users = user_service.get_all()
    return jsonify([u.to_dict() for u in users])

@app.route('/users/<int:user_id>', methods=['GET'])
def get_user(user_id: int):
    """Get user by ID."""
    user = user_service.get_by_id(user_id)
    if not user:
        return jsonify({"error": "User not found"}), 404
    return jsonify(user.to_dict())

@app.route('/users', methods=['POST'])
def create_user():
    """Create new user."""
    data = request.get_json()
    user = user_service.create(data)
    return jsonify(user.to_dict()), 201

if __name__ == '__main__':
    app.run(debug=True)
```

### 9.2 FastAPI (Modern, Async)

```python
from fastapi import FastAPI, HTTPException, Depends
from pydantic import BaseModel

app = FastAPI()

class UserCreate(BaseModel):
    name: str
    email: str

class UserResponse(BaseModel):
    id: int
    name: str
    email: str

@app.get("/users", response_model=list[UserResponse])
async def get_users():
    """Get all users."""
    return await user_service.get_all()

@app.get("/users/{user_id}", response_model=UserResponse)
async def get_user(user_id: int):
    """Get user by ID."""
    user = await user_service.get_by_id(user_id)
    if not user:
        raise HTTPException(status_code=404, detail="User not found")
    return user

@app.post("/users", response_model=UserResponse, status_code=201)
async def create_user(user: UserCreate):
    """Create new user."""
    return await user_service.create(user)
```

### 9.3 Django (Full Stack)

```python
# models.py
from django.db import models

class User(models.Model):
    name = models.CharField(max_length=100)
    email = models.EmailField(unique=True)
    created_at = models.DateTimeField(auto_now_add=True)
    
    class Meta:
        db_table = 'users'
        ordering = ['-created_at']
    
    def __str__(self):
        return self.name

# views.py
from django.http import JsonResponse
from django.views import View

class UserListView(View):
    def get(self, request):
        users = User.objects.all()
        return JsonResponse({
            'users': [{'id': u.id, 'name': u.name} for u in users]
        })

# Or use Django REST Framework
from rest_framework import viewsets
from rest_framework.response import Response

class UserViewSet(viewsets.ModelViewSet):
    queryset = User.objects.all()
    serializer_class = UserSerializer
```

---

## 10. Database and ORM

### 10.1 SQLAlchemy (ORM)

```python
from sqlalchemy import Column, Integer, String, create_engine
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker

Base = declarative_base()

class User(Base):
    __tablename__ = 'users'
    
    id = Column(Integer, primary_key=True)
    name = Column(String(100), nullable=False)
    email = Column(String(100), unique=True, nullable=False)
    
    def __repr__(self):
        return f"User(id={self.id}, name={self.name!r})"

# Connection
engine = create_engine('postgresql://user:pass@localhost/db')
Session = sessionmaker(bind=engine)

# Usage
session = Session()
try:
    user = User(name="John", email="john@example.com")
    session.add(user)
    session.commit()
    
    # Query
    users = session.query(User).filter_by(name="John").all()
finally:
    session.close()
```

### 10.2 Database Connection Management

```python
from contextlib import contextmanager

@contextmanager
def get_db_session():
    """Context manager for database sessions."""
    session = Session()
    try:
        yield session
        session.commit()
    except Exception:
        session.rollback()
        raise
    finally:
        session.close()

# Usage
with get_db_session() as session:
    user = session.query(User).first()
```

---

## 11. Package Management and Virtual Environments

### 11.1 Virtual Environments

**venv (Built-in)**:
```bash
# Create
python -m venv venv

# Activate (Unix)
source venv/bin/activate

# Activate (Windows)
venv\Scripts\activate

# Deactivate
deactivate
```

**Poetry (Modern)**:
```bash
# Initialize
poetry init

# Install dependencies
poetry install

# Add dependency
poetry add requests

# Run in venv
poetry run python script.py
```

### 11.2 Requirements Management

**requirements.txt**:
```txt
# Production dependencies
requests==2.31.0
flask==3.0.0
sqlalchemy==2.0.0

# Development dependencies (requirements-dev.txt)
pytest==7.4.0
black==23.10.0
mypy==1.6.0
```

**pyproject.toml (Modern)**:
```toml
[tool.poetry]
name = "myproject"
version = "0.1.0"
description = ""
authors = ["Your Name <you@example.com>"]

[tool.poetry.dependencies]
python = "^3.10"
requests = "^2.31.0"
flask = "^3.0.0"

[tool.poetry.dev-dependencies]
pytest = "^7.4.0"
black = "^23.10.0"
mypy = "^1.6.0"
```

### 11.3 Dependency Pinning

**Best Practices**:
- Pin exact versions in production (`==`)
- Use flexible versions in libraries (`^`, `~`)
- Keep dependencies up-to-date
- Use `pip-audit` or `safety` for security checks
- Document why specific versions are pinned

---

## 12. Code Quality Tools

### 12.1 Linters and Formatters

**Black (Formatter)**:
```bash
# Format code
black .

# Check without formatting
black --check .

# Configuration in pyproject.toml
[tool.black]
line-length = 100
target-version = ['py310']
```

**Flake8 (Linter)**:
```bash
# Check code
flake8 .

# Configuration in .flake8 or setup.cfg
[flake8]
max-line-length = 100
exclude = .git,__pycache__,venv
ignore = E203,W503
```

**Pylint (Comprehensive Linter)**:
```bash
# Check code
pylint mypackage

# Configuration in .pylintrc
[MASTER]
max-line-length=100

[MESSAGES CONTROL]
disable=C0111,C0103
```

**isort (Import Sorter)**:
```bash
# Sort imports
isort .

# Configuration in pyproject.toml
[tool.isort]
profile = "black"
line_length = 100
```

### 12.2 Type Checking

**mypy**:
```bash
# Type check
mypy .

# Configuration in mypy.ini or pyproject.toml
[mypy]
python_version = 3.10
warn_return_any = True
warn_unused_configs = True
disallow_untyped_defs = True
```

**pyright**:
```bash
# Type check
pyright

# Configuration in pyrightconfig.json
{
  "pythonVersion": "3.10",
  "typeCheckingMode": "strict"
}
```

### 12.3 Security Tools

**bandit (Security Linter)**:
```bash
# Check for security issues
bandit -r mypackage

# Common issues detected:
# - Use of assert
# - Hardcoded passwords
# - SQL injection risks
# - Use of exec/eval
```

**safety (Dependency Checker)**:
```bash
# Check for known vulnerabilities
safety check

# Check requirements file
safety check -r requirements.txt
```

---

## 13. Documentation

### 13.1 Docstrings (PEP 257)

**Module Docstring**:
```python
"""
User management module.

This module provides functionality for creating, updating, and
deleting users in the system.

Example:
    >>> from mypackage import user_service
    >>> user = user_service.create_user("John", "john@example.com")
"""
```

**Function Docstring** (Google Style):
```python
def create_user(name: str, email: str, age: int | None = None) -> User:
    """Create a new user in the system.
    
    Creates a new user with the given name and email. Age is optional
    and defaults to None if not provided.
    
    Args:
        name: The user's full name.
        email: The user's email address. Must be valid format.
        age: The user's age. Must be positive if provided.
    
    Returns:
        A User object representing the created user.
    
    Raises:
        ValueError: If email format is invalid or age is negative.
        DatabaseError: If database operation fails.
    
    Example:
        >>> user = create_user("John Doe", "john@example.com", 30)
        >>> print(user.name)
        John Doe
    """
    pass
```

**Function Docstring** (NumPy Style):
```python
def calculate_statistics(data: list[float]) -> dict[str, float]:
    """
    Calculate statistical measures for a dataset.
    
    Parameters
    ----------
    data : list[float]
        List of numeric values to analyze.
    
    Returns
    -------
    dict[str, float]
        Dictionary containing 'mean', 'median', and 'stddev'.
    
    Raises
    ------
    ValueError
        If data is empty.
    
    Examples
    --------
    >>> stats = calculate_statistics([1.0, 2.0, 3.0, 4.0, 5.0])
    >>> print(stats['mean'])
    3.0
    """
    pass
```

**Class Docstring**:
```python
class UserRepository:
    """Repository for user data operations.
    
    This class provides methods for CRUD operations on user entities.
    It handles database connections and transaction management.
    
    Attributes:
        connection: Database connection object.
        cache: Optional cache for frequently accessed users.
    
    Example:
        >>> repo = UserRepository(db_connection)
        >>> user = repo.find_by_id(1)
        >>> print(user.name)
    """
    
    def __init__(self, connection: Connection):
        """Initialize repository with database connection."""
        self.connection = connection
```

### 13.2 Type Hints in Documentation

```python
from typing import TypedDict, Protocol

class UserDict(TypedDict):
    """Type definition for user dictionary.
    
    Attributes:
        id: Unique user identifier.
        name: User's full name.
        email: User's email address.
    """
    id: int
    name: str
    email: str

class Serializable(Protocol):
    """Protocol for objects that can be serialized."""
    
    def to_dict(self) -> dict:
        """Convert object to dictionary."""
        ...
```

### 13.3 Sphinx Documentation

```python
def process_data(input_data: str, format: str = "json") -> dict:
    """
    Process input data and return structured output.
    
    :param input_data: Raw input data as string
    :type input_data: str
    :param format: Output format ('json' or 'xml')
    :type format: str
    :return: Processed data as dictionary
    :rtype: dict
    :raises ValueError: If format is not supported
    
    .. note::
        This function performs input validation.
    
    .. warning::
        Large input data may cause memory issues.
    """
    pass
```

---

## 14. Performance and Optimization

### 14.1 Profiling

**cProfile**:
```python
import cProfile
import pstats

# Profile function
profiler = cProfile.Profile()
profiler.enable()

# Code to profile
expensive_function()

profiler.disable()
stats = pstats.Stats(profiler)
stats.sort_stats('cumulative')
stats.print_stats(10)
```

**line_profiler**:
```python
from line_profiler import LineProfiler

@profile
def expensive_function():
    result = []
    for i in range(1000):
        result.append(i ** 2)
    return result

# Run with: kernprof -l -v script.py
```

### 14.2 Memory Optimization

**Generators vs Lists**:
```python
# Good: Generator (memory efficient)
def read_large_file(file_path):
    with open(file_path) as f:
        for line in f:
            yield line.strip()

# Bad: List (loads everything in memory)
def read_large_file(file_path):
    with open(file_path) as f:
        return [line.strip() for line in f]
```

**__slots__**:
```python
# Good: Reduce memory with __slots__
class Point:
    __slots__ = ['x', 'y']
    
    def __init__(self, x: float, y: float):
        self.x = x
        self.y = y

# Saves memory for millions of instances
```

### 14.3 Performance Best Practices

**String Concatenation**:
```python
# Good: Join for multiple strings
result = ''.join(strings)
result = ' '.join(words)

# Bad: Repeated concatenation
result = ''
for s in strings:
    result += s  # Creates new string each time
```

**List Operations**:
```python
# Good: List comprehension (faster)
squares = [x**2 for x in range(1000)]

# Bad: Append in loop (slower)
squares = []
for x in range(1000):
    squares.append(x**2)

# Good: extend for multiple items
result.extend(items)

# Bad: Repeated append
for item in items:
    result.append(item)
```

---

## 15. Security Best Practices

### 15.1 Input Validation

```python
import re
from html import escape

def validate_email(email: str) -> bool:
    """Validate email format."""
    pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
    return bool(re.match(pattern, email))

def sanitize_input(user_input: str) -> str:
    """Sanitize user input for display."""
    return escape(user_input)
```

### 15.2 SQL Injection Prevention

```python
# Good: Parameterized queries
cursor.execute(
    "SELECT * FROM users WHERE email = %s",
    (email,)
)

# Bad: String formatting (SQL injection risk)
cursor.execute(
    f"SELECT * FROM users WHERE email = '{email}'"
)
```

### 15.3 Secrets Management

```python
import os
from pathlib import Path

# Good: Environment variables
API_KEY = os.getenv('API_KEY')
if not API_KEY:
    raise ValueError("API_KEY not set")

# Good: Secret files (not in version control)
secret_file = Path('.secrets/api_key.txt')
if secret_file.exists():
    API_KEY = secret_file.read_text().strip()

# Bad: Hardcoded secrets
API_KEY = "sk-1234567890abcdef"  # Never do this!
```

### 15.4 Cryptography

```python
from cryptography.fernet import Fernet
import hashlib

# Password hashing (use bcrypt or argon2)
import bcrypt

def hash_password(password: str) -> str:
    """Hash password using bcrypt."""
    salt = bcrypt.gensalt()
    return bcrypt.hashpw(password.encode(), salt).decode()

def verify_password(password: str, hashed: str) -> bool:
    """Verify password against hash."""
    return bcrypt.checkpw(password.encode(), hashed.encode())

# Encryption
def encrypt_data(data: str, key: bytes) -> bytes:
    """Encrypt data using Fernet."""
    f = Fernet(key)
    return f.encrypt(data.encode())

def decrypt_data(encrypted: bytes, key: bytes) -> str:
    """Decrypt data using Fernet."""
    f = Fernet(key)
    return f.decrypt(encrypted).decode()
```

---

## 16. Python-Specific Anti-Patterns

### 16.1 Common Anti-Patterns

**Mutable Default Arguments**:
```python
# Bad: Mutable default (shared across calls)
def append_to_list(item, items=[]):
    items.append(item)
    return items

# Good: None as default
def append_to_list(item, items=None):
    if items is None:
        items = []
    items.append(item)
    return items
```

**Catching Too Broad Exceptions**:
```python
# Bad: Bare except
try:
    risky_operation()
except:
    pass

# Good: Specific exceptions
try:
    risky_operation()
except ValueError as e:
    logger.error(f"Invalid value: {e}")
except ConnectionError as e:
    logger.error(f"Connection failed: {e}")
```

**Not Using Context Managers**:
```python
# Bad: Manual resource management
f = open('file.txt')
try:
    content = f.read()
finally:
    f.close()

# Good: Context manager
with open('file.txt') as f:
    content = f.read()
```

**String Formatting Issues**:
```python
# Bad: Old style
message = "Hello %s, you have %d messages" % (name, count)

# Bad: .format()
message = "Hello {}, you have {} messages".format(name, count)

# Good: f-strings (Python 3.6+)
message = f"Hello {name}, you have {count} messages"
```

**Unnecessary List/Dict Conversions**:
```python
# Bad: Unnecessary conversion
for item in list(items):
    process(item)

# Good: Direct iteration
for item in items:
    process(item)
```

### 16.2 Code Smells

**God Objects**:
- Classes that do too much
- Split into focused, single-responsibility classes

**Long Functions**:
- Functions over 50 lines
- Extract helper functions

**Deep Nesting**:
- More than 3-4 levels of nesting
- Use early returns, extract functions

**Magic Numbers**:
- Unexplained numeric literals
- Use named constants

---

## 17. Python Code Review Checklist

### 17.1 Critical (Must Fix)
- [ ] No hardcoded secrets or credentials
- [ ] No SQL injection vulnerabilities (use parameterized queries)
- [ ] No use of `exec()` or `eval()` without strong justification
- [ ] No bare `except:` clauses (catch specific exceptions)
- [ ] All file operations use context managers (`with` statement)
- [ ] No mutable default arguments
- [ ] Type hints for public APIs
- [ ] No relative imports outside package

### 17.2 High Priority (Should Fix)
- [ ] Follows PEP 8 style guidelines
- [ ] Docstrings for all public functions/classes
- [ ] Uses pathlib for file operations (not os.path)
- [ ] Modern string formatting (f-strings)
- [ ] List/dict comprehensions instead of loops where appropriate
- [ ] Generators for large sequences
- [ ] Proper exception handling (specific exceptions)
- [ ] No circular imports
- [ ] Type hints consistent across codebase
- [ ] Uses `is` for None comparisons, not `==`

### 17.3 Medium Priority (Consider Fixing)
- [ ] Use dataclasses for data containers
- [ ] Use `pathlib.Path` instead of string paths
- [ ] Use `enumerate()` instead of `range(len())`
- [ ] Use `zip()` for parallel iteration
- [ ] Context managers for resource management
- [ ] Property decorators for computed attributes
- [ ] Consistent import organization
- [ ] Avoid wildcard imports (`from module import *`)
- [ ] Use `_` prefix for private methods/attributes

### 17.4 Low Priority (Nice to Have)
- [ ] Type hints for all functions (not just public)
- [ ] Comprehensive docstrings with examples
- [ ] Use protocols for duck typing
- [ ] Consider using `@lru_cache` for expensive computations
- [ ] Use `functools.partial` for partial application
- [ ] Consider using `itertools` for complex iterations
- [ ] Black/isort formatting applied
- [ ] All imports sorted and grouped

---

## 18. Python Project Structure

### 18.1 Recommended Structure

```
myproject/
├── .github/
│   └── workflows/
│       └── ci.yml
├── docs/
│   ├── conf.py
│   └── index.rst
├── src/
│   └── mypackage/
│       ├── __init__.py
│       ├── __main__.py
│       ├── core/
│       │   ├── __init__.py
│       │   └── module.py
│       └── utils/
│           ├── __init__.py
│           └── helpers.py
├── tests/
│   ├── __init__.py
│   ├── conftest.py
│   ├── test_core.py
│   └── integration/
│       └── test_api.py
├── .gitignore
├── .pre-commit-config.yaml
├── pyproject.toml
├── README.md
├── requirements.txt
├── requirements-dev.txt
└── setup.py
```

### 18.2 Configuration Files

**pyproject.toml**:
```toml
[build-system]
requires = ["setuptools>=45", "wheel"]
build-backend = "setuptools.build_meta"

[project]
name = "mypackage"
version = "0.1.0"
description = "A sample Python package"
readme = "README.md"
requires-python = ">=3.10"
dependencies = [
    "requests>=2.31.0",
]

[project.optional-dependencies]
dev = [
    "pytest>=7.4.0",
    "black>=23.10.0",
    "mypy>=1.6.0",
]

[tool.black]
line-length = 100
target-version = ['py310']

[tool.mypy]
python_version = "3.10"
warn_return_any = true
disallow_untyped_defs = true

[tool.pytest.ini_options]
testpaths = ["tests"]
python_files = "test_*.py"
```

---

## 19. CI/CD and Automation

### 19.1 GitHub Actions Example

```yaml
name: CI

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        python-version: [3.9, 3.10, 3.11]
    
    steps:
    - uses: actions/checkout@v3
    
    - name: Set up Python
      uses: actions/setup-python@v4
      with:
        python-version: ${{ matrix.python-version }}
    
    - name: Install dependencies
      run: |
        python -m pip install --upgrade pip
        pip install -r requirements.txt
        pip install -r requirements-dev.txt
    
    - name: Lint with flake8
      run: flake8 src tests
    
    - name: Type check with mypy
      run: mypy src
    
    - name: Test with pytest
      run: pytest --cov=src --cov-report=xml
    
    - name: Upload coverage
      uses: codecov/codecov-action@v3
```

### 19.2 Pre-commit Hooks

```yaml
# .pre-commit-config.yaml
repos:
  - repo: https://github.com/psf/black
    rev: 23.10.0
    hooks:
      - id: black
  
  - repo: https://github.com/pycqa/isort
    rev: 5.12.0
    hooks:
      - id: isort
  
  - repo: https://github.com/pycqa/flake8
    rev: 6.1.0
    hooks:
      - id: flake8
  
  - repo: https://github.com/pre-commit/mirrors-mypy
    rev: v1.6.0
    hooks:
      - id: mypy
        additional_dependencies: [types-requests]
```

---

## 20. Modern Python Patterns

### 20.1 Structural Pattern Matching (Python 3.10+)

```python
def process_command(command: dict):
    match command:
        case {"action": "create", "user": user}:
            return create_user(user)
        case {"action": "delete", "id": user_id}:
            return delete_user(user_id)
        case {"action": "update", "id": user_id, "data": data}:
            return update_user(user_id, data)
        case _:
            raise ValueError(f"Unknown command: {command}")
```

### 20.2 Context Variables (Thread-safe globals)

```python
from contextvars import ContextVar

request_id: ContextVar[str] = ContextVar('request_id', default='')

def log_message(message: str):
    """Log message with request ID."""
    req_id = request_id.get()
    print(f"[{req_id}] {message}")

# Set context
request_id.set("req-12345")
log_message("Processing request")
```

### 20.3 Protocol Classes (Structural Subtyping)

```python
from typing import Protocol

class Drawable(Protocol):
    """Protocol for objects that can be drawn."""
    
    def draw(self) -> None:
        """Draw the object."""
        ...

class Circle:
    def draw(self) -> None:
        print("Drawing circle")

class Square:
    def draw(self) -> None:
        print("Drawing square")

def render(shape: Drawable) -> None:
    """Render any drawable object."""
    shape.draw()

# Works without explicit inheritance
render(Circle())
render(Square())
```

---

## Conclusion

Python's philosophy emphasizes readability, simplicity, and explicit code. By following these guidelines, teams can create maintainable, efficient, and Pythonic code that leverages the language's strengths while avoiding common pitfalls.

**Key Python Principles**:
1. **PEP 8**: Follow style guide religiously
2. **PEP 20**: Embrace the Zen of Python
3. **Type Hints**: Use for better tooling and documentation
4. **Pythonic Code**: Use idiomatic patterns (comprehensions, context managers)
5. **Testing**: Write comprehensive tests with pytest
6. **Documentation**: Clear docstrings following PEP 257
7. **Modern Features**: Use Python 3.10+ features when possible
8. **Performance**: Profile before optimizing
9. **Security**: Validate inputs, use parameterized queries, manage secrets properly

**Remember**: "There should be one-- and preferably only one --obvious way to do it." (The Zen of Python)

---

**Version**: 1.0  
**Last Updated**: 2026-01-31  
**Target Python Version**: 3.10+  
**Assumes**: Modern Python development practices and tooling
