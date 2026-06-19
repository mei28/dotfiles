---
name: doc-gen
allowed-tools: TodoWrite, Read, Write, Grep, Bash(git:*), Bash(npm:*), Bash(npx:*)
description: Generates comprehensive API documentation from code including OpenAPI/Swagger specs, JSDoc/TSDoc comments, and API reference guides
---

# Doc-Gen - API Documentation Generator

## Purpose

Automatically generates comprehensive API documentation from your codebase. Creates OpenAPI/Swagger specifications, JSDoc/TSDoc comments, API reference guides, and usage examples. Transforms code into clear, maintainable documentation that stays in sync with your implementation.

## When to Use

- ✅ After implementing new API endpoints
- ✅ When onboarding new team members
- ✅ Before releasing public APIs
- ✅ To document legacy APIs without docs
- ✅ When updating API contracts

## Usage

```
/doc-gen
/doc-gen src/api/users.ts
/doc-gen --openapi
/doc-gen --jsdoc
```

**Arguments** (optional):
- File path: Generate docs for specific file(s)
- `--openapi`: Generate OpenAPI/Swagger spec
- `--jsdoc`: Add JSDoc/TSDoc comments to code
- No arguments: Generate docs for recently changed API files

## Supported Documentation Types

### 1. OpenAPI/Swagger Specifications

**Generates**:
- Complete OpenAPI 3.0 spec
- Request/response schemas
- Authentication requirements
- Example requests/responses
- Error codes and descriptions

### 2. Code Comments

**Generates**:
- JSDoc comments (JavaScript/TypeScript)
- TSDoc comments (TypeScript)
- Javadoc (Java)
- Python docstrings
- GoDoc comments (Go)
- Rustdoc (Rust)

### 3. API Reference Guides

**Generates**:
- Markdown API documentation
- Endpoint descriptions
- Parameter tables
- Code examples
- Authentication guides

## Documentation Patterns

### REST API Documentation

#### Before: Undocumented Endpoint

```typescript
// src/api/users.ts
export async function getUser(req: Request, res: Response) {
  const { id } = req.params;
  const user = await db.users.findUnique({ where: { id } });

  if (!user) {
    return res.status(404).json({ error: 'User not found' });
  }

  return res.json(user);
}

export async function createUser(req: Request, res: Response) {
  const { email, name, role } = req.body;

  const user = await db.users.create({
    data: { email, name, role }
  });

  return res.status(201).json(user);
}
```

#### After: Comprehensive Documentation

```typescript
/**
 * Get user by ID
 *
 * Retrieves a single user by their unique identifier.
 *
 * @param req - Express request object
 * @param req.params.id - User ID (UUID format)
 * @param res - Express response object
 *
 * @returns {Promise<Response>} User object or 404 error
 *
 * @example
 * // GET /api/users/123e4567-e89b-12d3-a456-426614174000
 * // Response: 200 OK
 * {
 *   "id": "123e4567-e89b-12d3-a456-426614174000",
 *   "email": "john@example.com",
 *   "name": "John Doe",
 *   "role": "user",
 *   "createdAt": "2024-01-15T10:30:00Z"
 * }
 *
 * @throws {404} User not found
 */
export async function getUser(req: Request, res: Response) {
  const { id } = req.params;
  const user = await db.users.findUnique({ where: { id } });

  if (!user) {
    return res.status(404).json({ error: 'User not found' });
  }

  return res.json(user);
}

/**
 * Create new user
 *
 * Creates a new user account with the provided information.
 *
 * @param req - Express request object
 * @param req.body.email - User email (must be unique)
 * @param req.body.name - User's full name
 * @param req.body.role - User role (user|admin|moderator)
 * @param res - Express response object
 *
 * @returns {Promise<Response>} Created user object
 *
 * @example
 * // POST /api/users
 * // Request body:
 * {
 *   "email": "john@example.com",
 *   "name": "John Doe",
 *   "role": "user"
 * }
 * // Response: 201 Created
 * {
 *   "id": "123e4567-e89b-12d3-a456-426614174000",
 *   "email": "john@example.com",
 *   "name": "John Doe",
 *   "role": "user",
 *   "createdAt": "2024-01-15T10:30:00Z"
 * }
 *
 * @throws {400} Invalid email format or missing required fields
 * @throws {409} Email already exists
 */
export async function createUser(req: Request, res: Response) {
  const { email, name, role } = req.body;

  const user = await db.users.create({
    data: { email, name, role }
  });

  return res.status(201).json(user);
}
```

### OpenAPI Specification Generation

```yaml
# Generated: docs/openapi.yaml
openapi: 3.0.0
info:
  title: User Management API
  version: 1.0.0
  description: API for managing user accounts

paths:
  /api/users/{id}:
    get:
      summary: Get user by ID
      description: Retrieves a single user by their unique identifier
      parameters:
        - name: id
          in: path
          required: true
          description: User ID in UUID format
          schema:
            type: string
            format: uuid
            example: "123e4567-e89b-12d3-a456-426614174000"
      responses:
        '200':
          description: Successful response
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/User'
              example:
                id: "123e4567-e89b-12d3-a456-426614174000"
                email: "john@example.com"
                name: "John Doe"
                role: "user"
                createdAt: "2024-01-15T10:30:00Z"
        '404':
          description: User not found
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/Error'
              example:
                error: "User not found"

  /api/users:
    post:
      summary: Create new user
      description: Creates a new user account
      requestBody:
        required: true
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/CreateUserRequest'
            example:
              email: "john@example.com"
              name: "John Doe"
              role: "user"
      responses:
        '201':
          description: User created successfully
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/User'
        '400':
          description: Invalid request data
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/Error'
        '409':
          description: Email already exists
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/Error'

components:
  schemas:
    User:
      type: object
      required:
        - id
        - email
        - name
        - role
        - createdAt
      properties:
        id:
          type: string
          format: uuid
          description: Unique user identifier
        email:
          type: string
          format: email
          description: User email address
        name:
          type: string
          description: User's full name
        role:
          type: string
          enum: [user, admin, moderator]
          description: User role
        createdAt:
          type: string
          format: date-time
          description: Account creation timestamp

    CreateUserRequest:
      type: object
      required:
        - email
        - name
        - role
      properties:
        email:
          type: string
          format: email
        name:
          type: string
          minLength: 2
        role:
          type: string
          enum: [user, admin, moderator]

    Error:
      type: object
      required:
        - error
      properties:
        error:
          type: string
          description: Error message
```

### Markdown API Reference

```markdown
# Generated: docs/API.md

# User Management API

## Endpoints

### Get User by ID

Retrieves a single user by their unique identifier.

**Endpoint**: `GET /api/users/{id}`

**Parameters**:

| Name | Type | Required | Description |
|------|------|----------|-------------|
| id | string (UUID) | Yes | User unique identifier |

**Response** (200 OK):

```json
{
  "id": "123e4567-e89b-12d3-a456-426614174000",
  "email": "john@example.com",
  "name": "John Doe",
  "role": "user",
  "createdAt": "2024-01-15T10:30:00Z"
}
```

**Errors**:

- `404 Not Found`: User with specified ID does not exist

**Example**:

```bash
curl -X GET https://api.example.com/api/users/123e4567-e89b-12d3-a456-426614174000 \
  -H "Authorization: Bearer YOUR_TOKEN"
```

---

### Create User

Creates a new user account.

**Endpoint**: `POST /api/users`

**Request Body**:

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| email | string | Yes | User email (must be unique) |
| name | string | Yes | User's full name (min 2 chars) |
| role | string | Yes | User role (user, admin, moderator) |

**Response** (201 Created):

```json
{
  "id": "123e4567-e89b-12d3-a456-426614174000",
  "email": "john@example.com",
  "name": "John Doe",
  "role": "user",
  "createdAt": "2024-01-15T10:30:00Z"
}
```

**Errors**:

- `400 Bad Request`: Invalid email format or missing required fields
- `409 Conflict`: Email already exists

**Example**:

```bash
curl -X POST https://api.example.com/api/users \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "email": "john@example.com",
    "name": "John Doe",
    "role": "user"
  }'
```
```

## GraphQL Documentation

### Before: Undocumented Schema

```typescript
// src/schema/user.ts
export const userType = new GraphQLObjectType({
  name: 'User',
  fields: {
    id: { type: GraphQLID },
    email: { type: GraphQLString },
    name: { type: GraphQLString },
    posts: {
      type: new GraphQLList(postType),
      resolve: (user) => getPostsByUser(user.id)
    }
  }
});

export const userQueries = {
  user: {
    type: userType,
    args: { id: { type: GraphQLID } },
    resolve: (_, { id }) => getUserById(id)
  }
};
```

### After: Documented Schema

```typescript
/**
 * User GraphQL Type
 *
 * Represents a user in the system with their basic information
 * and associated posts.
 */
export const userType = new GraphQLObjectType({
  name: 'User',
  description: 'A registered user account',
  fields: {
    id: {
      type: GraphQLID,
      description: 'Unique user identifier (UUID)'
    },
    email: {
      type: GraphQLString,
      description: 'User email address'
    },
    name: {
      type: GraphQLString,
      description: 'User full name'
    },
    posts: {
      type: new GraphQLList(postType),
      description: 'All posts created by this user',
      resolve: (user) => getPostsByUser(user.id)
    }
  }
});

/**
 * User Queries
 *
 * Available GraphQL queries for user data retrieval.
 */
export const userQueries = {
  /**
   * Get single user by ID
   *
   * @example
   * query {
   *   user(id: "123") {
   *     id
   *     email
   *     name
   *     posts {
   *       id
   *       title
   *     }
   *   }
   * }
   */
  user: {
    type: userType,
    description: 'Retrieve a single user by their ID',
    args: {
      id: {
        type: GraphQLID,
        description: 'User ID to fetch'
      }
    },
    resolve: (_, { id }) => getUserById(id)
  }
};
```

## Process Flow

### Step 1: Detect API Type and Framework

```bash
# Read package.json or similar config
Read package.json

# Check for API frameworks
- Express/Fastify → REST API
- Apollo/GraphQL → GraphQL API
- NestJS → REST/GraphQL
- FastAPI → Python REST API
- Spring Boot → Java REST API
```

### Step 2: Analyze API Code

```bash
# Find API route files
Grep "router\." --type ts -l
Grep "@Get\|@Post\|@Put\|@Delete" --type ts

# Read API implementation
Read src/api/users.ts
Read src/controllers/userController.ts
```

Extract:
- Endpoints and HTTP methods
- Request/response types
- Query parameters
- Path parameters
- Request body schemas
- Response schemas
- Error handling

### Step 3: Check Existing Documentation

```bash
# Check for existing docs
Read docs/openapi.yaml
Read docs/API.md
Read swagger.json
```

Identify:
- What's already documented
- Documentation format preference
- Coverage gaps

### Step 4: Generate Documentation

Create TodoWrite checklist:

```markdown
## API Documentation Generation

- [x] Analyze API code structure
- [x] Extract endpoint information (12 endpoints found)
- [ ] Generate OpenAPI specification
- [ ] Add JSDoc comments to code
- [ ] Create markdown API reference
- [ ] Generate code examples
- [ ] Add authentication documentation
```

### Step 5: Save and Validate

```bash
# Save OpenAPI spec
Write docs/openapi.yaml

# Validate OpenAPI spec
npx @redocly/cli lint docs/openapi.yaml

# Save markdown docs
Write docs/API.md

# Update code with JSDoc
Edit src/api/users.ts
```

## Output Format

```markdown
# API Documentation Report

## Summary

**API Type**: REST API (Express)
**Endpoints Documented**: 12
**Files Updated**:
- ✅ `docs/openapi.yaml` (OpenAPI 3.0 spec)
- ✅ `docs/API.md` (Markdown reference)
- ✅ `src/api/users.ts` (JSDoc comments added)
- ✅ `src/api/posts.ts` (JSDoc comments added)
- ✅ `src/api/auth.ts` (JSDoc comments added)

## Generated Documentation

### OpenAPI Specification

**Location**: `docs/openapi.yaml`
**Endpoints**: 12
**Schemas**: 8
**Security Schemes**: 1 (Bearer JWT)

**Coverage**:
- ✅ All endpoints documented
- ✅ Request/response schemas defined
- ✅ Authentication requirements specified
- ✅ Error responses documented
- ✅ Example requests/responses included

**Validation**: ✅ Passed (0 errors, 0 warnings)

### Markdown API Reference

**Location**: `docs/API.md`
**Sections**:
- Authentication
- Users API (4 endpoints)
- Posts API (6 endpoints)
- Auth API (2 endpoints)
- Error Codes
- Rate Limiting

### Code Comments

**Files Updated**: 3
**Comments Added**: 47 JSDoc blocks

**Coverage**:
- ✅ All public functions documented
- ✅ Parameter descriptions added
- ✅ Return types specified
- ✅ Error conditions documented
- ✅ Usage examples included

## Documentation Preview

### Swagger UI

You can view the interactive API documentation:

```bash
# Install Swagger UI
npm install -g swagger-ui-watcher

# Start Swagger UI server
swagger-ui-watcher docs/openapi.yaml
```

Open http://localhost:3001 to view interactive docs.

### Redoc

For a cleaner single-page documentation:

```bash
npx @redocly/cli preview-docs docs/openapi.yaml
```

Open http://localhost:8080 to view Redoc documentation.

## Next Steps

1. **Review Documentation**: Check generated docs for accuracy
2. **Add Custom Examples**: Include real-world usage examples
3. **Update Authentication**: Document OAuth/API key requirements if applicable
4. **Add Tutorials**: Create getting started guides
5. **Publish**: Deploy docs to GitHub Pages, ReadTheDocs, or similar

## Integration

### Swagger UI Integration (Express)

Add to your Express app:

```typescript
import swaggerUi from 'swagger-ui-express';
import YAML from 'yamljs';

const swaggerDocument = YAML.load('./docs/openapi.yaml');

app.use('/api-docs', swaggerUi.serve, swaggerUi.setup(swaggerDocument));
```

Access at: http://localhost:3000/api-docs

### TypeScript Type Generation

Generate TypeScript types from OpenAPI spec:

```bash
npx openapi-typescript docs/openapi.yaml --output src/types/api.ts
```

---

**Generated by**: Claude Code - Doc-Gen Plugin
**Timestamp**: 2026-01-03 22:00:00
```

## Best Practices

### 1. Keep Docs in Sync

**Automate documentation**:
- Generate docs in pre-commit hook
- Update docs in CI/CD pipeline
- Use TypeScript types as single source of truth

### 2. Include Real Examples

- Use actual API responses (sanitized)
- Show common use cases
- Include error scenarios
- Demonstrate authentication flow

### 3. Document Changes

- Update docs with code changes
- Add changelog for API versions
- Document breaking changes clearly
- Provide migration guides

### 4. Make Docs Discoverable

- Host docs publicly (if appropriate)
- Include getting started guide
- Add search functionality
- Link from main README

### 5. Validate Generated Docs

```bash
# Validate OpenAPI spec
npx @redocly/cli lint docs/openapi.yaml

# Check for broken links
npx markdown-link-check docs/API.md

# Test code examples
# Extract and run code examples from docs
```

## Integration with Other Commands

### Documentation Workflow

```
1. [Implement feature]
2. /doc-gen              # Generate/update docs
3. /code-review          # Verify doc quality
4. /commit               # Commit code + docs
5. /pr-template          # Include docs in PR description
```

### API Development Workflow

```
1. Design API (OpenAPI spec)
2. Generate types from spec
3. Implement endpoints
4. /doc-gen              # Update docs
5. /test-generator       # Generate API tests
6. /code-review          # Review implementation
```

## Framework-Specific Features

### Express/Fastify (Node.js)

```typescript
// Generates:
- JSDoc comments for route handlers
- OpenAPI 3.0 specification
- Swagger UI integration code
- Request validation schemas
```

### NestJS (Node.js)

```typescript
// Leverages:
- @ApiProperty decorators
- @ApiResponse decorators
- Swagger module integration
- Auto-generated OpenAPI spec
```

### FastAPI (Python)

```python
# Generates:
- Python docstrings
- Pydantic model documentation
- OpenAPI spec (built-in)
- ReDoc integration
```

### Spring Boot (Java)

```java
// Generates:
- Javadoc comments
- Swagger annotations
- OpenAPI 3.0 spec
- Springdoc integration
```

## Advanced Features

### Authentication Documentation

```yaml
# OAuth 2.0
components:
  securitySchemes:
    oauth2:
      type: oauth2
      flows:
        authorizationCode:
          authorizationUrl: https://example.com/oauth/authorize
          tokenUrl: https://example.com/oauth/token
          scopes:
            read:users: Read user information
            write:users: Modify user information

security:
  - oauth2: [read:users, write:users]
```

### Webhooks Documentation

```yaml
webhooks:
  userCreated:
    post:
      summary: User Created Event
      description: Triggered when a new user is created
      requestBody:
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/UserCreatedEvent'
```

### API Versioning

```yaml
paths:
  /v1/users:
    # Version 1 endpoints
  /v2/users:
    # Version 2 endpoints
```

## Tips

- 💡 Run `/doc-gen` after implementing new endpoints
- 💡 Generate OpenAPI spec before implementing (design-first)
- 💡 Keep examples realistic and tested
- 💡 Document error codes with explanations
- 💡 Include rate limiting information
- 💡 Add authentication examples for every endpoint
- 💡 Use `/doc-gen --openapi` for Swagger UI integration

## Limitations

- **Business Logic**: Documentation describes API, not business rules
- **Complex Workflows**: Multi-step processes need manual documentation
- **Real-time APIs**: WebSocket/SSE need custom documentation
- **Private APIs**: May need additional context not in code
- **Domain Knowledge**: Technical docs don't replace domain guides

## References

**API Documentation Best Practices**:
- OpenAPI Specification 3.0
- Swagger/Redoc tools
- API design guidelines (REST, GraphQL)
- JSDoc/TSDoc standards

**Tools**:
- [Swagger Editor](https://editor.swagger.io/)
- [Redocly CLI](https://redocly.com/docs/cli/)
- [OpenAPI Generator](https://openapi-generator.tech/)
- [TypeDoc](https://typedoc.org/) (TypeScript)
