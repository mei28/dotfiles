---
name: dig
description: Identifies ambiguities in requirements and architecture through structured questions, helping clarify implementation plans before coding begins
---

# Dig - Requirements Clarification Tool

## Purpose

Before starting implementation, systematically identify ambiguities in requirements, architecture, and design through structured questions across multiple categories. This prevents wasted effort from unclear specifications.

## When to Use

- Starting a new feature implementation
- Requirements seem vague or incomplete
- Multiple implementation approaches are possible
- Before entering plan mode for complex tasks
- When stakeholder alignment is needed

## Workflow

### Step 1: Load Context Files

Automatically read project context files to understand standards and conventions:

```bash
# Read project documentation and standards
Read CLAUDE.md
Read README.md
Read docs/architecture.md
Read docs/api-standards.md
```

### Step 2: Understand Current Request

Analyze the user's request to identify what information is present and what's missing.

### Step 3: Categorize Ambiguities

Identify unclear points across these categories:

1. **Architecture & Design**
2. **Data & State Management**
3. **API & Integration**
4. **UI/UX & User Interface**
5. **Testing & Quality**
6. **Security & Authorization**
7. **Performance & Scalability**
8. **Deployment & Operations**

### Step 4: Generate Structured Questions

For each identified ambiguity, formulate specific questions with:
- **Context**: Why this matters
- **Options**: Possible approaches (if applicable)
- **Impact**: How this affects implementation
- **Recommendation**: Suggested approach based on project standards (if clear)

### Step 5: Present Findings

Present all questions organized by category for user to address.

## Analysis Categories

### 1. Architecture & Design

Questions about system structure and design patterns:

- Which architectural pattern to use? (MVC, Clean Architecture, Hexagonal, etc.)
- How should components be organized?
- What are the module boundaries?
- Should this be a service, utility, or helper?
- How does this fit into existing architecture?

**Example Questions**:
```markdown
#### Architecture: Service Layer Structure

**Context**: The user authentication feature needs to interact with the database and external OAuth providers.

**Ambiguity**: How should the authentication service be structured?

**Options**:
1. Single AuthService with all logic
2. Separate services: AuthService, OAuthService, TokenService
3. Repository pattern with domain services

**Impact**: Affects testability, maintainability, and future extensibility

**Recommendation**: Based on CLAUDE.md preference for clean architecture, option 2 (separate services) is suggested for better separation of concerns.

**Question**: Which service structure do you prefer for the authentication feature?
```

### 2. Data & State Management

Questions about data flow and state:

- How should state be managed? (Redux, Context, Zustand, etc.)
- What's the data model structure?
- Where should data validation occur?
- How to handle data persistence?
- What's the caching strategy?

**Example Questions**:
```markdown
#### Data: User Session State

**Context**: User authentication state needs to be accessible across the application.

**Ambiguity**: How should user session state be managed?

**Options**:
1. React Context API
2. Redux store
3. Zustand lightweight store
4. localStorage with custom hook

**Impact**: Affects bundle size, complexity, and developer experience

**Question**: What state management approach do you want for user sessions?
```

### 3. API & Integration

Questions about API design and external integrations:

- REST, GraphQL, or RPC?
- API endpoint naming convention?
- Request/response format?
- Error handling strategy?
- Rate limiting approach?
- Authentication method?

**Example Questions**:
```markdown
#### API: Endpoint Design

**Context**: New user profile update functionality needed.

**Ambiguity**: What should the API endpoint structure be?

**Options**:
1. PATCH /api/users/:id (partial update)
2. PUT /api/users/:id (full replacement)
3. POST /api/users/:id/update (RPC-style)
4. Multiple specific endpoints (e.g., /api/users/:id/email, /api/users/:id/name)

**Impact**: Affects API consistency and client implementation

**Recommendation**: Based on existing API using RESTful conventions, option 1 (PATCH) is most consistent.

**Question**: Should we follow the existing PATCH pattern or use a different approach?
```

### 4. UI/UX & User Interface

Questions about user interface and experience:

- Which UI component library to use?
- What's the user flow?
- How should errors be displayed?
- What loading states are needed?
- Accessibility requirements?
- Responsive design breakpoints?

**Example Questions**:
```markdown
#### UI/UX: Error Display

**Context**: Form validation errors need to be shown to users.

**Ambiguity**: How should validation errors be displayed?

**Options**:
1. Inline below each field
2. Toast notification
3. Modal dialog
4. Summary at top of form

**Impact**: Affects user experience and accessibility

**Question**: What error display pattern do you prefer? (Consider existing patterns in the app)
```

### 5. Testing & Quality

Questions about testing strategy:

- What level of test coverage expected?
- Unit, integration, or e2e tests?
- Which testing framework?
- What should be mocked?
- Performance benchmarks?

### 6. Security & Authorization

Questions about security and access control:

- Who can access this feature?
- How to handle sensitive data?
- What encryption is needed?
- Rate limiting requirements?
- Audit logging needed?

### 7. Performance & Scalability

Questions about performance requirements:

- Expected load/traffic?
- Response time requirements?
- Caching strategy?
- Database query optimization needed?
- Pagination approach?

### 8. Deployment & Operations

Questions about deployment and monitoring:

- Feature flags needed?
- Migration strategy?
- Rollback plan?
- Monitoring/alerting requirements?
- Backward compatibility needed?

## Output Format

Present findings in this structured format:

```markdown
# Dig Analysis Report

## Summary
- Request: [User's original request]
- Context Files Read: CLAUDE.md, README.md, architecture.md
- Ambiguities Found: [Number] across [Number] categories
- Recommendations: [Number] based on existing standards

## Questions by Category

### Architecture & Design ([Number] questions)

#### 1. [Question Title]
**Context**: [Why this matters]
**Ambiguity**: [What's unclear]
**Options**:
1. [Option 1]
2. [Option 2]
...
**Impact**: [How this affects implementation]
**Recommendation**: [Suggested approach if clear from standards]
**Question**: [Specific question for user]

---

### Data & State Management ([Number] questions)

[Similar structure]

---

[Continue for all relevant categories]

## Next Steps

Once these questions are answered, I can:
1. Create a detailed implementation plan
2. Identify specific files to modify
3. Outline test requirements
4. Estimate implementation scope

Please answer the questions above, or let me know if you'd like to discuss any category in more detail.
```

## Best Practices

1. **Read Context First**: Always read CLAUDE.md and relevant docs before asking questions
2. **Prioritize Impact**: Ask high-impact questions first
3. **Offer Options**: Provide 2-4 concrete options when possible
4. **Reference Standards**: Point to existing patterns and conventions
5. **Be Specific**: Avoid vague questions like "How should this work?"
6. **Group Related Questions**: Organize by category for clarity
7. **Suggest Defaults**: Recommend approaches based on project standards

## Integration with Other Commands

**Before Planning**:
```
User: Add user authentication
Assistant: Let me use /dig to clarify requirements first
[Runs dig analysis]
[User answers questions]
Assistant: Now entering plan mode with clear requirements
```

**With EnterPlanMode**:
```
1. Run /dig to clarify ambiguities
2. User provides answers
3. Use EnterPlanMode with complete context
4. Implement with confidence
```

## Example Session

**User**: "Add a dark mode toggle to the application"

**Dig Analysis**:

```markdown
# Dig Analysis Report

## Summary
- Request: Add dark mode toggle to application
- Context Files Read: CLAUDE.md, README.md, src/styles/theme.ts
- Ambiguities Found: 8 across 4 categories
- Recommendations: 3 based on existing theme system

## Questions by Category

### Architecture & Design (3 questions)

#### 1. Theme Management Architecture
**Context**: Application uses styled-components with a theme provider.
**Ambiguity**: How should dark mode be integrated with existing theme system?
**Options**:
1. Extend existing theme with dark variants
2. Create separate dark theme object
3. Use CSS variables for dynamic switching
**Impact**: Affects theme consistency and switching performance
**Recommendation**: Option 1 extends existing pattern in src/styles/theme.ts
**Question**: Should we extend the existing theme or create a separate dark theme?

#### 2. Persistence Location
**Context**: User preferences need to be saved.
**Ambiguity**: Where should dark mode preference be stored?
**Options**:
1. localStorage (client-side only)
2. User profile in database (synced across devices)
3. Both (localStorage with backend sync)
**Impact**: Affects user experience across devices
**Question**: Should dark mode preference sync across user's devices?

### UI/UX & User Interface (3 questions)

#### 3. Toggle Placement
**Context**: Application has a top navigation bar and settings page.
**Ambiguity**: Where should the dark mode toggle be located?
**Options**:
1. Top navigation bar (always visible)
2. Settings page only
3. Both locations
**Impact**: Affects discoverability and user convenience
**Question**: Where should users access the dark mode toggle?

#### 4. Transition Animation
**Context**: Instant theme switches can be jarring.
**Ambiguity**: Should there be a transition animation when switching modes?
**Options**:
1. Instant switch (no animation)
2. Fade transition (200-300ms)
3. Color transition on all elements
**Impact**: Affects perceived polish and performance
**Recommendation**: Existing animations use 200ms transitions
**Question**: Should mode switching be animated?

### Implementation Details (2 questions)

#### 5. Default Mode
**Context**: First-time users haven't set a preference.
**Ambiguity**: What should be the default theme mode?
**Options**:
1. Always light mode
2. Respect system preference (prefers-color-scheme)
3. Auto-detect based on time of day
**Impact**: Affects first impression for new users
**Recommendation**: Modern best practice is option 2 (system preference)
**Question**: Should we respect system dark mode preference by default?

## Next Steps

Once these questions are answered, I can:
1. Create implementation plan for theme system extension
2. Identify files to modify (theme.ts, ThemeProvider, etc.)
3. Design toggle component
4. Plan persistence implementation
5. Outline test cases

Please answer the questions above to proceed with implementation.
```

## Anti-Patterns to Avoid

❌ **Don't**:
- Ask questions without reading context files first
- Present too many questions (>15) - prioritize
- Ask vague questions like "How should this work?"
- Forget to offer concrete options
- Ignore existing project patterns

✅ **Do**:
- Read CLAUDE.md and relevant docs first
- Focus on high-impact ambiguities
- Provide 2-4 specific options per question
- Reference existing patterns when suggesting options
- Organize questions by category
- Offer recommendations based on project standards

## Related Commands

- `EnterPlanMode`: Use after dig analysis to create detailed plan
- `/review`: Code review after implementation
- `AskUserQuestion`: Can be used during dig analysis for immediate clarification

## Tips

- **For simple tasks**: Dig may be overkill - use judgment
- **For complex features**: Always run dig before planning
- **For team projects**: Dig output can be shared with stakeholders
- **For solo projects**: Helps clarify your own thinking

## References

- Requirements Engineering Best Practices
- The Importance of Asking Questions Before Coding
- Ambiguity Detection in Software Requirements
