---
name: test-generator
allowed-tools: TodoWrite, Read, Write, Grep, Bash(npm:*), Bash(pytest:*), Bash(jest:*), Bash(go test:*)
description: Automatically generates comprehensive unit tests for functions, classes, and modules with meaningful test cases including edge cases
---

# Test Generator - Automated Unit Test Creation

## Purpose

Automatically generates comprehensive, meaningful unit tests for your code. Analyzes functions, classes, and modules to create test cases that cover normal flows, edge cases, error conditions, and boundary values. Reduces manual test writing by up to 97% while improving test coverage.

## When to Use

- ✅ After implementing new features
- ✅ For legacy code without tests
- ✅ To improve test coverage quickly
- ✅ When practicing TDD (generate test structure)
- ✅ Before refactoring (ensure safety net)

## Usage

```
/test-generator
/test-generator src/auth/login.ts
/test-generator --coverage
```

**Arguments** (optional):
- File path: Generate tests for specific file(s)
- `--coverage`: Show current coverage and gaps
- No arguments: Generate tests for recently changed files

## Supported Testing Frameworks

The plugin auto-detects and generates tests for:

| Language | Frameworks |
|----------|------------|
| **JavaScript/TypeScript** | Jest, Vitest, Mocha, Jasmine |
| **Python** | pytest, unittest, nose2 |
| **Java** | JUnit 5, TestNG, Mockito |
| **Go** | testing, testify |
| **Ruby** | RSpec, Minitest |
| **Rust** | Built-in test framework |

## Test Generation Strategy

### 1. **Analyze Code Structure**

```typescript
// Example function to test
function divide(a: number, b: number): number {
  if (b === 0) {
    throw new Error('Division by zero');
  }
  return a / b;
}
```

Analysis:
- **Inputs**: Two numbers
- **Output**: Number
- **Error Conditions**: Division by zero
- **Edge Cases**: Negative numbers, decimals, large numbers

### 2. **Generate Test Cases**

```typescript
// Generated tests (Jest)
describe('divide', () => {
  describe('Normal Cases', () => {
    test('should divide positive integers', () => {
      expect(divide(10, 2)).toBe(5);
    });

    test('should divide negative numbers', () => {
      expect(divide(-10, 2)).toBe(-5);
      expect(divide(10, -2)).toBe(-5);
      expect(divide(-10, -2)).toBe(5);
    });

    test('should handle decimal results', () => {
      expect(divide(10, 3)).toBeCloseTo(3.333, 3);
    });
  });

  describe('Edge Cases', () => {
    test('should handle division resulting in zero', () => {
      expect(divide(0, 5)).toBe(0);
    });

    test('should handle very small numbers', () => {
      expect(divide(0.0001, 0.0002)).toBeCloseTo(0.5, 4);
    });

    test('should handle very large numbers', () => {
      expect(divide(1e10, 1e5)).toBe(1e5);
    });
  });

  describe('Error Conditions', () => {
    test('should throw error on division by zero', () => {
      expect(() => divide(10, 0)).toThrow('Division by zero');
    });

    test('should throw error on division by zero with negative dividend', () => {
      expect(() => divide(-10, 0)).toThrow('Division by zero');
    });
  });

  describe('Boundary Values', () => {
    test('should handle division by 1', () => {
      expect(divide(10, 1)).toBe(10);
    });

    test('should handle division by -1', () => {
      expect(divide(10, -1)).toBe(-10);
    });
  });
});
```

## Test Categories

### Normal Cases ✅

Tests for expected, typical usage:

```python
# Function to test
def calculate_discount(price: float, discount_percent: float) -> float:
    return price * (1 - discount_percent / 100)

# Generated tests
def test_calculate_discount_standard():
    assert calculate_discount(100, 10) == 90

def test_calculate_discount_no_discount():
    assert calculate_discount(100, 0) == 100

def test_calculate_discount_full_discount():
    assert calculate_discount(100, 100) == 0
```

### Edge Cases 🔍

Tests for unusual but valid inputs:

```python
def test_calculate_discount_very_small_price():
    assert calculate_discount(0.01, 10) == pytest.approx(0.009)

def test_calculate_discount_very_large_price():
    assert calculate_discount(1_000_000, 10) == 900_000

def test_calculate_discount_fractional_percent():
    assert calculate_discount(100, 0.5) == pytest.approx(99.5)
```

### Error Conditions ❌

Tests for invalid inputs and error handling:

```python
def test_calculate_discount_negative_price():
    with pytest.raises(ValueError, match="Price must be positive"):
        calculate_discount(-100, 10)

def test_calculate_discount_invalid_percent():
    with pytest.raises(ValueError, match="Discount must be between 0 and 100"):
        calculate_discount(100, 150)
```

### Boundary Values 📏

Tests for limits and boundaries:

```python
def test_calculate_discount_zero_price():
    assert calculate_discount(0, 10) == 0

def test_calculate_discount_max_percent():
    assert calculate_discount(100, 100) == 0

def test_calculate_discount_min_percent():
    assert calculate_discount(100, 0) == 100
```

### Integration Points 🔗

Tests for interactions with dependencies:

```typescript
// Function with dependencies
class UserService {
  constructor(private db: Database, private cache: Cache) {}

  async getUser(id: string): Promise<User> {
    const cached = await this.cache.get(`user:${id}`);
    if (cached) return cached;

    const user = await this.db.findUser(id);
    await this.cache.set(`user:${id}`, user, 300);
    return user;
  }
}

// Generated tests with mocks
describe('UserService.getUser', () => {
  let userService: UserService;
  let mockDb: jest.Mocked<Database>;
  let mockCache: jest.Mocked<Cache>;

  beforeEach(() => {
    mockDb = {
      findUser: jest.fn()
    } as any;
    mockCache = {
      get: jest.fn(),
      set: jest.fn()
    } as any;
    userService = new UserService(mockDb, mockCache);
  });

  test('should return cached user if available', async () => {
    const cachedUser = { id: '123', name: 'John' };
    mockCache.get.mockResolvedValue(cachedUser);

    const result = await userService.getUser('123');

    expect(result).toEqual(cachedUser);
    expect(mockCache.get).toHaveBeenCalledWith('user:123');
    expect(mockDb.findUser).not.toHaveBeenCalled();
  });

  test('should fetch from database if not cached', async () => {
    const dbUser = { id: '123', name: 'John' };
    mockCache.get.mockResolvedValue(null);
    mockDb.findUser.mockResolvedValue(dbUser);

    const result = await userService.getUser('123');

    expect(result).toEqual(dbUser);
    expect(mockCache.get).toHaveBeenCalledWith('user:123');
    expect(mockDb.findUser).toHaveBeenCalledWith('123');
    expect(mockCache.set).toHaveBeenCalledWith('user:123', dbUser, 300);
  });

  test('should handle database errors gracefully', async () => {
    mockCache.get.mockResolvedValue(null);
    mockDb.findUser.mockRejectedValue(new Error('DB connection failed'));

    await expect(userService.getUser('123')).rejects.toThrow('DB connection failed');
  });
});
```

## Process Flow

### Step 1: Detect Testing Framework

```bash
# Check package.json for JavaScript/TypeScript
Read package.json

# Check for pytest.ini or setup.py for Python
Read pytest.ini
Read setup.py

# Check go.mod for Go
Read go.mod
```

Determine:
- Testing framework (Jest, pytest, etc.)
- Current test structure/patterns
- Mocking library (if any)

### Step 2: Analyze Target Code

```bash
# Read source file
Read src/services/userService.ts
```

Extract:
- Function signatures
- Class methods
- Dependencies (imports)
- Error handling patterns
- Type information

### Step 3: Check Existing Tests

```bash
# Check if tests already exist
Read tests/services/userService.test.ts
# or
Read src/services/__tests__/userService.test.ts
```

Identify:
- What's already tested
- Coverage gaps
- Test file location pattern

### Step 4: Generate Test File

Create comprehensive test file with:
- Proper imports and setup
- Test structure (describe/it blocks)
- Mock setup (if needed)
- All test categories
- Cleanup (afterEach)

### Step 5: Save and Report

```bash
# Save test file
Write tests/services/userService.test.ts

# Run tests to verify
npm test -- userService.test.ts
```

## Output Format

```markdown
# Test Generation Report

## Summary

**Source File**: `src/services/userService.ts`
**Test File**: `tests/services/userService.test.ts`
**Test Cases Generated**: 15
**Coverage Areas**:
- ✅ Normal cases (5 tests)
- ✅ Edge cases (4 tests)
- ✅ Error conditions (3 tests)
- ✅ Integration points (3 tests)

## Generated Tests

### Normal Cases

1. ✅ `should return user when valid ID provided`
2. ✅ `should return all users when no filter applied`
3. ✅ `should filter users by role`
4. ✅ `should update user successfully`
5. ✅ `should delete user successfully`

### Edge Cases

6. ✅ `should handle empty user list`
7. ✅ `should handle user with minimal fields`
8. ✅ `should handle user with all optional fields`
9. ✅ `should handle concurrent updates`

### Error Conditions

10. ✅ `should throw error when user not found`
11. ✅ `should handle database connection errors`
12. ✅ `should validate required fields`

### Integration Points

13. ✅ `should cache user data correctly`
14. ✅ `should invalidate cache on update`
15. ✅ `should handle cache failures gracefully`

## Test File Created

```typescript
// tests/services/userService.test.ts
import { UserService } from '../../src/services/userService';
import { Database } from '../../src/db';
import { Cache } from '../../src/cache';

jest.mock('../../src/db');
jest.mock('../../src/cache');

describe('UserService', () => {
  // ... test implementation
});
```

## Next Steps

1. **Review Generated Tests**: Check test logic and assertions
2. **Run Tests**: `npm test tests/services/userService.test.ts`
3. **Check Coverage**: `npm test -- --coverage`
4. **Refine Tests**: Add domain-specific test cases if needed
5. **Commit**: Include tests with your feature implementation

## Coverage Analysis

**Before**: 45% (src/services/userService.ts)
**After**: 92% (estimated with generated tests)

**Remaining Gaps**:
- Error recovery in edge case (line 78)
- Deprecated method (line 105) - Consider removing

---

**Generated by**: Claude Code - Test Generator Plugin
**Framework**: Jest with TypeScript
**Timestamp**: 2026-01-03 21:00:00
```

## Best Practices

### 1. Generate Early and Often

Best times to generate tests:
- **Immediately** after writing new code
- **Before refactoring** (safety net)
- **For legacy code** (one module at a time)
- **After bug fixes** (regression tests)

### 2. Review and Customize

Generated tests are a starting point:
- ✅ Review test logic
- ✅ Add domain-specific cases
- ✅ Adjust assertions for precision
- ✅ Add meaningful test descriptions

### 3. Combine with Manual Tests

Use generated tests for:
- Basic functionality
- Edge cases
- Error handling

Write manual tests for:
- Complex business logic
- Integration scenarios
- User workflows

### 4. Maintain Test Quality

- Keep tests simple and focused
- One assertion per test (when possible)
- Use descriptive test names
- Avoid testing implementation details

### 5. Run Tests Frequently

```bash
# Run tests on file change
npm test -- --watch

# Run with coverage
npm test -- --coverage

# Run specific test file
npm test userService.test.ts
```

## Integration with Other Commands

### TDD Workflow

```
1. /test-generator     # Generate test structure
2. [Write failing tests]
3. [Implement code]
4. [Tests pass]
5. /code-review        # Check quality
6. /commit             # Commit code + tests
```

### Legacy Code Workflow

```
1. /code-review        # Identify risky areas
2. /test-generator     # Generate tests for safety
3. /refactor           # Refactor with confidence
4. /test-generator     # Generate additional tests
5. /code-review        # Verify improvements
```

## Framework-Specific Features

### Jest/Vitest (JavaScript/TypeScript)

```typescript
// Generates with:
- describe/test blocks
- beforeEach/afterEach setup
- jest.mock() for dependencies
- expect() assertions
- Code coverage configuration
```

### pytest (Python)

```python
# Generates with:
- pytest fixtures
- parametrize for data-driven tests
- pytest.raises for exceptions
- pytest.approx for floats
- conftest.py setup
```

### JUnit 5 (Java)

```java
// Generates with:
- @Test annotations
- @BeforeEach/@AfterEach
- @Mock/@InjectMocks (Mockito)
- assertThat() assertions
- @ParameterizedTest
```

## Advanced Features

### Data-Driven Tests

```python
# Generated parametrized tests
@pytest.mark.parametrize("input,expected", [
    (100, 10, 90),
    (50, 20, 40),
    (200, 5, 190),
    (1000, 0, 1000),
])
def test_calculate_discount(input, percent, expected):
    assert calculate_discount(input, percent) == expected
```

### Snapshot Testing

```typescript
// For complex objects
test('should return user with all fields', () => {
  const user = getUserById('123');
  expect(user).toMatchSnapshot();
});
```

### Property-Based Testing

```typescript
// Using fast-check (advanced)
import * as fc from 'fast-check';

test('division is inverse of multiplication', () => {
  fc.assert(
    fc.property(fc.float(), fc.float({min: 0.1}), (a, b) => {
      expect(divide(a * b, b)).toBeCloseTo(a, 5);
    })
  );
});
```

## Tips

- 💡 Run `/test-generator` before `/commit` to ensure tests included
- 💡 Generate tests for bug fixes to prevent regression
- 💡 Use `--coverage` to find untested code paths
- 💡 Review and customize generated tests for domain logic
- 💡 Combine with `/code-review` to ensure test quality
- 💡 Generate tests incrementally for large files

## Limitations

- **Business Logic**: May not capture complex domain rules
- **Integration Tests**: Focuses on unit tests, not integration
- **UI Tests**: Limited support for component/E2E tests
- **Test Data**: May need real-world test data added
- **Async Complexity**: Complex async patterns need review

## References

Research shows automated test generation:
- Reduces manual test writing by up to 97%
- Improves code coverage by 30-50%
- Catches 60-80% of common bugs
- Speeds up development by 40%

**Sources**:
- [Automated Test Case Generation Tools](https://www.browserstack.com/guide/automated-test-case-generation)
- [Best Practices in Unit Test Generation](https://www.qodo.ai/blog/automatic-java-unit-test-generation-best-practices/)
- [Building AI Agents for Test Creation](https://developer.nvidia.com/blog/building-ai-agents-to-automate-software-test-case-creation/)
