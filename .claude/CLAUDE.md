# Development Standards & Coding Conventions

## Top-Level Rules

- To maximize efficiency, **if you need to execute multiple independent processes, invoke those tools concurrently, not sequentially**.
- **You must think exclusively in English**. However, you are required to **respond in Japanese**.
- To understand how to use a library, **always use the Contex7 MCP or lsmcp ** to retrieve the latest information.
- For temporary notes for design, create a markdown in `.tmp` and save it.
- **After using Write or Edit tools, ALWAYS verify the actual file contents using the Read tool**, regardless of what the system-reminder says. The system-reminder may incorrectly show "(no content)" even when the file has been successfully written.
- Please respond critically and without pandering to my opinions, but please don't be forceful in your criticism.

## File and Directory Structure
- **Prioritize maintainability**: Split files and directories appropriately for code clarity
- **Functional separation**: Organize directories by related features
- **Separation of concerns**: Follow single responsibility principle - one file, one clear role

## Function and Module Design
- **Function decomposition**: Break down long functions into smaller, readable units
- **Reusability**: Modularize common operations to avoid duplication
- **Naming conventions**: Use clear, purpose-driven names for functions and classes

## Code Quality
- **Readability first**: Write code that other developers can easily understand
- **Meaningful comments**: Add comments for complex logic (Japanese comments acceptable for domain-specific terms)
- **Error handling**: Implement proper exception handling

## Documentation Philosophy
- **Code shows HOW**: Implementation details
- **Tests show WHAT**: Clear test objectives
- **Commits show WHY**: Rationale for changes
- **Comments show WHY NOT**: Reasoning for alternative approaches not taken

## Design Principles
- **YAGNI (You Aren't Gonna Need It)**: Don't build features not currently needed
- **DRY (Don't Repeat Yourself)**: Avoid code duplication
- **KISS (Keep It Simple Stupid)**: Maintain simplicity

## TDD Workflow (t-wada style)

### Core Process
- 🔴 Red: Write failing test
- 🟢 Green: Minimal implementation to pass
- 🔵 Refactor: Improve code structure
- Take small steps
- Start with fake implementation
- Triangulate to generalize
- Direct implementation when obvious
- Continuously update test list
- Test uncertain areas first

### TDD Best Practices
1. **First test**: Start with failing test (compile errors OK)
2. **Fake implementation**: Hardcoded returns acceptable (`return 42`)
3. **Triangulation**: Generalize with 2nd/3rd test cases
4. **Refactoring**: Clean up after tests pass
5. **TODO list**: Immediately add new ideas
6. **One at a time**: Don't write multiple tests simultaneously
7. **Frequent commits**: Commit when tests pass

### Commit Convention
- 🔴 Test written: `test: add failing test for [feature]`
- 🟢 Test passing: `feat: implement [feature] to pass test`
- 🔵 Refactored: `refactor: [description]`
- Small, atomic commits (one feature per commit)

## AI Collaboration: Trust-Based Approach

### Core Philosophy
This project embraces AI partnership through trust rather than constraints. We maximize AI capabilities to co-create value with users.

### Thinking Process
Execute tasks through quality-assured analysis:

**[ANALYSIS START] Pre-execution Review**
- **Why-Why-Why Analysis**: Three levels of root cause exploration
- **Triple Perspective**: Technical, User, Operational viewpoints
- **Quality Self-Score**: Execute only with 4+ points (5-point scale)

### Quality Criteria (5 items)
1. **Purpose Alignment**: Addresses true user needs
2. **Technical Validity**: Appropriate, maintainable implementation
3. **User Experience**: Intuitive, user-friendly design
4. **Operational Feasibility**: Production-ready functionality
5. **Value Creation**: Delivers new value

### Autonomous Initiative
- Proactively identify and propose improvements
- Anticipate potential issues before they arise
- Suggest superior implementation patterns independently

### Partnership Practice
- Deeply understand user intent, exceed expectations
- Share technical decisions with clear reasoning
- Embrace failure as learning opportunity

## Task Management
- **Task Runner**: Use `just` for all project commands
- **Command Centralization**: Define all build, test, deploy commands in justfile
- **Reproducibility**: Ensure consistent execution across team members
- **Reusability**: Document recurring commands as just recipes

## Technical Writing Guidelines

### Avoid AI-style List Formatting
Don't use emphasis prefixes or emoji decorators in lists:
- Avoid: `**Important**:`, `✅`, `💡`, `🔥`, `🚀`, etc.
- Use clean, undecorated list items

### Avoid Hyperbolic Expressions

#### Absoluteness
- Replace "revolutionary" → describe specific transformation
- Replace "game-changer" → explain significant impact
- Replace "ultimate" → provide measurable performance metrics
- Replace "completely/all" → specify scope ("many", "major")

#### Abstract/Sensational
- Replace "magical" → describe smooth operation
- Replace "unleash potential" → explain new opportunities
- Replace "democratize AI" → describe accessibility improvements
- Replace "supercharge" → specify efficiency gains

#### Authoritative/Prophetic
- Replace "redefine industry" → explain new perspectives
- Replace "change the future" → describe specific impacts
- Replace "paradigm shift" → detail the transformation
- Replace "inevitable change" → explain why change matters

### Writing Clarity

#### Conciseness
- "first and foremost" → "first" or "foremost"
- "be able to" → "can"
- "need to" → imperative form
- "make changes to" → "change"

#### Active Voice
- Prefer active over passive constructions
- Use direct subject-verb-object structure

#### Specificity
- "fast" → "under 50ms"
- "significantly" → "200% improvement"
- "efficient" → "30% memory reduction"

#### Consistency
- Unify terminology for same concepts
- Standardize UI element names
- Maintain consistent tone throughout

#### Structure
- One idea per sentence
- Target ~50 characters per sentence
- Remove unnecessary connectives

## Git Workflow

### Pre-execution Confirmation Rules
- **Before commit**: Always request user confirmation
- **Before push**: Always request user confirmation
- **Before PR creation**: Always request user confirmation
- **Confirmation content**: Present clear summary of changes and impact scope

### Commit Message Convention
- **No CLAUDE CODE signatures in commits**
- **Required prefixes** (Angular.js guidelines):
  - **feat**: New feature
  - **fix**: Bug fix
  - **docs**: Documentation only
  - **style**: Formatting (no code change)
  - **refactor**: Code restructuring (no behavior change)
  - **perf**: Performance improvements
  - **test**: Test additions/modifications
  - **chore**: Build process/tooling changes
- **Include rationale, context, and purpose**
