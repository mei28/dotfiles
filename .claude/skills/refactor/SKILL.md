---
name: refactor
allowed-tools: TodoWrite, Read, Write, Grep, Bash(git:*)
description: Suggests and applies code refactoring improvements including complexity reduction, code smell removal, and pattern improvements based on static analysis
---

# Refactor - Code Quality Improvement Tool

## Purpose

Analyzes code to identify refactoring opportunities and suggests improvements to reduce complexity, remove code smells, and enhance maintainability. Provides actionable refactoring recommendations with before/after examples.

## When to Use

- ✅ When code becomes hard to understand
- ✅ Before adding new features to complex code
- ✅ After receiving code review feedback
- ✅ When test coverage is low (hard to test = needs refactoring)
- ✅ Periodically for technical debt reduction

## Usage

```
/refactor
/refactor src/services/orderService.ts
/refactor --suggest
/refactor --apply
```

**Arguments** (optional):
- File path: Refactor specific file(s)
- `--suggest`: Only show suggestions (no changes)
- `--apply`: Apply automatic refactorings
- No arguments: Analyze recent changes

## Refactoring Categories

### 1. **Complexity Reduction** 🔻

#### High Cyclomatic Complexity

**Problem**: Too many decision points (if/else, switch, loops)

```typescript
// ❌ Before: Complexity 15
function calculatePrice(item, user, promotion) {
  let price = item.basePrice;

  if (user.isPremium) {
    if (user.loyaltyYears > 5) {
      price *= 0.85;
    } else if (user.loyaltyYears > 2) {
      price *= 0.9;
    } else {
      price *= 0.95;
    }
  }

  if (promotion) {
    if (promotion.type === 'percentage') {
      price *= (1 - promotion.value / 100);
    } else if (promotion.type === 'fixed') {
      price -= promotion.value;
    } else if (promotion.type === 'bogo') {
      if (item.quantity > 1) {
        price = price * 0.5 * item.quantity;
      }
    }
  }

  if (item.category === 'electronics') {
    if (item.warranty) {
      price += 49.99;
    }
  }

  return price;
}

// ✅ After: Complexity 4
function calculatePrice(item, user, promotion) {
  let price = item.basePrice;
  price = applyUserDiscount(price, user);
  price = applyPromotion(price, promotion, item);
  price = addWarranty(price, item);
  return price;
}

function applyUserDiscount(price, user) {
  if (!user.isPremium) return price;

  const discounts = {
    5: 0.85,
    2: 0.9,
    0: 0.95
  };

  const discount = Object.entries(discounts)
    .find(([years]) => user.loyaltyYears >= Number(years))?.[1] ?? 1;

  return price * discount;
}

function applyPromotion(price, promotion, item) {
  if (!promotion) return price;

  const strategies = {
    percentage: (p, promo) => p * (1 - promo.value / 100),
    fixed: (p, promo) => p - promo.value,
    bogo: (p, promo, itm) => itm.quantity > 1 ? p * 0.5 * itm.quantity : p
  };

  return strategies[promotion.type]?.(price, promotion, item) ?? price;
}

function addWarranty(price, item) {
  return item.category === 'electronics' && item.warranty
    ? price + 49.99
    : price;
}
```

**Benefits**:
- Cyclomatic complexity: 15 → 4
- Easier to test (small functions)
- Easier to extend (add new discount tiers)
- Each function has single responsibility

---

### 2. **Extract Method** 🔨

**Problem**: Long methods doing multiple things

```python
# ❌ Before: 45 lines
def process_order(order_data):
    # Validate order
    if not order_data.get('customer_id'):
        raise ValueError('Missing customer ID')
    if not order_data.get('items'):
        raise ValueError('No items in order')
    for item in order_data['items']:
        if item['quantity'] <= 0:
            raise ValueError('Invalid quantity')

    # Calculate totals
    subtotal = 0
    for item in order_data['items']:
        subtotal += item['price'] * item['quantity']

    tax = subtotal * 0.08
    shipping = 0
    if subtotal < 50:
        shipping = 10
    total = subtotal + tax + shipping

    # Save to database
    cursor = db.cursor()
    cursor.execute(
        'INSERT INTO orders (customer_id, total) VALUES (?, ?)',
        (order_data['customer_id'], total)
    )
    order_id = cursor.lastrowid

    for item in order_data['items']:
        cursor.execute(
            'INSERT INTO order_items (order_id, product_id, quantity) VALUES (?, ?, ?)',
            (order_id, item['product_id'], item['quantity'])
        )

    db.commit()
    return order_id

# ✅ After: Each function < 10 lines
def process_order(order_data):
    validate_order(order_data)
    totals = calculate_totals(order_data)
    order_id = save_order(order_data, totals)
    return order_id

def validate_order(order_data):
    if not order_data.get('customer_id'):
        raise ValueError('Missing customer ID')
    if not order_data.get('items'):
        raise ValueError('No items in order')
    for item in order_data['items']:
        if item['quantity'] <= 0:
            raise ValueError('Invalid quantity')

def calculate_totals(order_data):
    subtotal = sum(item['price'] * item['quantity'] for item in order_data['items'])
    tax = subtotal * 0.08
    shipping = 10 if subtotal < 50 else 0
    return {'subtotal': subtotal, 'tax': tax, 'shipping': shipping, 'total': subtotal + tax + shipping}

def save_order(order_data, totals):
    order_id = insert_order(order_data['customer_id'], totals['total'])
    insert_order_items(order_id, order_data['items'])
    db.commit()
    return order_id

def insert_order(customer_id, total):
    cursor = db.cursor()
    cursor.execute('INSERT INTO orders (customer_id, total) VALUES (?, ?)', (customer_id, total))
    return cursor.lastrowid

def insert_order_items(order_id, items):
    cursor = db.cursor()
    for item in items:
        cursor.execute(
            'INSERT INTO order_items (order_id, product_id, quantity) VALUES (?, ?, ?)',
            (order_id, item['product_id'], item['quantity'])
        )
```

---

### 3. **Remove Code Duplication** 🔄

**Problem**: Same logic repeated in multiple places

```javascript
// ❌ Before: Duplicated validation
function createUser(userData) {
  if (!userData.email || !/@/.test(userData.email)) {
    throw new Error('Invalid email');
  }
  if (!userData.name || userData.name.length < 2) {
    throw new Error('Invalid name');
  }
  // ... create user
}

function updateUser(userId, userData) {
  if (!userData.email || !/@/.test(userData.email)) {
    throw new Error('Invalid email');
  }
  if (!userData.name || userData.name.length < 2) {
    throw new Error('Invalid name');
  }
  // ... update user
}

// ✅ After: Extracted validation
function validateUserData(userData) {
  const validators = {
    email: (email) => email && /@/.test(email),
    name: (name) => name && name.length >= 2
  };

  for (const [field, validator] of Object.entries(validators)) {
    if (!validator(userData[field])) {
      throw new Error(`Invalid ${field}`);
    }
  }
}

function createUser(userData) {
  validateUserData(userData);
  // ... create user
}

function updateUser(userId, userData) {
  validateUserData(userData);
  // ... update user
}
```

---

### 4. **Replace Conditional with Polymorphism** 🎭

**Problem**: Type checking with if/else or switch

```java
// ❌ Before: Type checking
class PaymentProcessor {
    public void processPayment(Payment payment) {
        if (payment.getType().equals("CREDIT_CARD")) {
            processCreditCard(payment);
        } else if (payment.getType().equals("PAYPAL")) {
            processPayPal(payment);
        } else if (payment.getType().equals("BANK_TRANSFER")) {
            processBankTransfer(payment);
        }
    }
}

// ✅ After: Polymorphism
interface Payment {
    void process();
}

class CreditCardPayment implements Payment {
    public void process() {
        // Credit card specific logic
    }
}

class PayPalPayment implements Payment {
    public void process() {
        // PayPal specific logic
    }
}

class BankTransferPayment implements Payment {
    public void process() {
        // Bank transfer specific logic
    }
}

class PaymentProcessor {
    public void processPayment(Payment payment) {
        payment.process();
    }
}
```

---

### 5. **Introduce Parameter Object** 📦

**Problem**: Long parameter lists

```typescript
// ❌ Before: 8 parameters
function createInvoice(
  customerId: string,
  customerName: string,
  customerEmail: string,
  items: Item[],
  subtotal: number,
  tax: number,
  shipping: number,
  discount: number
): Invoice {
  // ...
}

// ✅ After: Parameter object
interface InvoiceData {
  customer: {
    id: string;
    name: string;
    email: string;
  };
  items: Item[];
  amounts: {
    subtotal: number;
    tax: number;
    shipping: number;
    discount: number;
  };
}

function createInvoice(data: InvoiceData): Invoice {
  // ...
}

// Usage
createInvoice({
  customer: { id: '123', name: 'John', email: 'john@example.com' },
  items: [/* ... */],
  amounts: { subtotal: 100, tax: 8, shipping: 10, discount: 5 }
});
```

---

### 6. **Replace Magic Numbers with Constants** 🔢

```python
# ❌ Before: Magic numbers
def calculate_shipping(weight):
    if weight < 5:
        return 10
    elif weight < 20:
        return 15
    else:
        return 25

# ✅ After: Named constants
LIGHT_WEIGHT_THRESHOLD = 5
MEDIUM_WEIGHT_THRESHOLD = 20
LIGHT_PACKAGE_COST = 10
MEDIUM_PACKAGE_COST = 15
HEAVY_PACKAGE_COST = 25

def calculate_shipping(weight):
    if weight < LIGHT_WEIGHT_THRESHOLD:
        return LIGHT_PACKAGE_COST
    elif weight < MEDIUM_WEIGHT_THRESHOLD:
        return MEDIUM_PACKAGE_COST
    else:
        return HEAVY_PACKAGE_COST
```

---

## Process Flow

### Step 1: Analyze Code

```bash
# Read file to refactor
Read src/services/orderService.ts

# Calculate metrics
- Cyclomatic complexity
- Function length
- Code duplication percentage
- Nesting depth
```

### Step 2: Identify Refactoring Opportunities

Create TodoWrite checklist:

```markdown
## Refactoring Analysis

- [x] Read and analyze code
- [x] Identify refactoring opportunities (5 found)
- [ ] High complexity function (line 45-120)
- [ ] Duplicated validation logic (lines 30, 78, 145)
- [ ] Magic numbers (lines 55, 89, 92)
- [ ] Long parameter list (line 12)
- [ ] Nested conditions (lines 200-250)
```

### Step 3: Generate Refactoring Suggestions

For each issue:
- Explain the problem
- Show current code
- Suggest refactoring pattern
- Show improved code
- Explain benefits

### Step 4: Apply Refactorings (if --apply)

Apply safe, automated refactorings:
- Extract constants
- Rename variables
- Extract methods (simple cases)
- Format code

Skip complex refactorings requiring human judgment.

## Output Format

```markdown
# Refactoring Report

## Summary

**File**: `src/services/orderService.ts`
**Refactoring Opportunities**: 5
**Estimated Improvement**:
- Complexity: 45 → 18 (-60%)
- Maintainability Index: 52 → 78 (+50%)
- Test Coverage Potential: 45% → 85%

## Recommendations

### 🔴 HIGH PRIORITY

#### 1. Reduce Complexity in `processOrder` (Lines 45-120)

**Current Complexity**: 18 (High)
**Target Complexity**: < 10

**Problem**: Function has too many responsibilities and decision points

**Suggestion**: Extract Method + Strategy Pattern

[Before/After code examples as shown above]

**Benefits**:
- Easier to test (4 small functions vs 1 large function)
- Easier to extend (add new discount types)
- Easier to understand (each function has single purpose)

**Effort**: Medium (30-45 minutes)

---

#### 2. Remove Duplicated Validation (Lines 30, 78, 145)

**Duplication**: 15 lines repeated 3 times

**Suggestion**: Extract validation function

[Before/After code]

**Benefits**:
- DRY principle
- Single source of truth for validation rules
- Easier to maintain (change once, not three times)

**Effort**: Low (10-15 minutes)

---

### 🟡 MEDIUM PRIORITY

#### 3. Replace Magic Numbers (Lines 55, 89, 92)

**Suggestion**: Extract constants

[Before/After code]

**Benefits**:
- Self-documenting code
- Easy to modify thresholds
- Consistent values across codebase

**Effort**: Low (5 minutes)

---

#### 4. Simplify Parameter List (Line 12)

**Current**: 8 parameters
**Target**: 1-3 parameters

**Suggestion**: Introduce Parameter Object

[Before/After code]

**Benefits**:
- Easier to call function
- Easier to add new parameters
- More maintainable

**Effort**: Medium (20-30 minutes)

---

### ⚪ LOW PRIORITY

#### 5. Reduce Nesting Depth (Lines 200-250)

**Current Depth**: 5 levels
**Target Depth**: < 3 levels

**Suggestion**: Guard Clauses + Early Returns

**Effort**: Medium (25-35 minutes)

---

## Automated Refactorings Available

The following can be applied automatically with `--apply`:

- ✅ Extract constants for magic numbers
- ✅ Rename variables to follow conventions
- ✅ Format code (indentation, spacing)
- ✅ Remove unused imports

Would you like to apply these? Run: `/refactor --apply`

## Manual Refactorings Required

These require human judgment and testing:

- ⚠️ Extract methods (need to determine boundaries)
- ⚠️ Introduce polymorphism (need to understand business logic)
- ⚠️ Restructure classes (architectural decision)

## Next Steps

1. **Fix High Priority Issues**: Start with complexity reduction
2. **Write Tests**: Before refactoring, ensure test coverage
3. **Refactor Incrementally**: One issue at a time
4. **Run Tests**: After each refactoring
5. **Commit**: Small, focused commits per refactoring

**Recommended Order**:
```
1. /test-generator    # Ensure safety net
2. Run existing tests
3. Refactor #2 (easiest)
4. Run tests
5. Commit
6. Refactor #3
7. Run tests
8. Commit
9. Refactor #1 (most complex)
10. Run tests
11. Commit
```

---

**Generated by**: Claude Code - Refactor Plugin
**Timestamp**: 2026-01-03 21:15:00
```

## Best Practices

### 1. Test Before Refactoring

```
/test-generator → Run tests → /refactor
```

Safety net ensures refactoring doesn't break functionality.

### 2. Refactor in Small Steps

- One refactoring at a time
- Run tests after each change
- Commit frequently

### 3. Keep Under 200 Lines

Research shows changes under 200 lines:
- Get reviewed 60% faster
- Have fewer bugs
- Are easier to understand

### 4. Measure Improvements

Track metrics:
- Cyclomatic complexity
- Code duplication
- Test coverage
- Maintainability index

### 5. Refactor Proactively

Don't wait for problems:
- Refactor when adding features
- Refactor after code review feedback
- Schedule regular refactoring time

## Integration with Other Commands

### Quality Improvement Workflow

```
/code-review → /refactor → /test-generator → /code-review
```

1. Identify issues with code review
2. Plan refactorings
3. Add tests for safety
4. Verify improvements

### Pre-Feature Workflow

```
/refactor → /test-generator → [Implement feature]
```

Clean up before adding complexity.

## Tips

- 💡 Run `/code-review` first to identify what needs refactoring
- 💡 Always have tests before refactoring
- 💡 Use `--suggest` to learn refactoring patterns
- 💡 Refactor incrementally, not all at once
- 💡 Commit after each successful refactoring
- 💡 Focus on high-impact, low-effort refactorings first

## References

**Sources**:
- [AI Code Refactoring Best Practices](https://www.augmentcode.com/guides/ai-code-refactoring-tools-tactics-and-best-practices)
- [Static Code Analysis](https://www.oligo.security/academy/static-code-analysis)
- [Code Refactoring Tools](https://graphite.com/guides/refactoring-code-best-practices)
