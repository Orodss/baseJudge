# Code Convention

This document outlines the coding conventions and best practices followed in this project to ensure code quality, maintainability, and consistency across the codebase.

## Context Handling

- **Always pass `context.Context`** as the first parameter to functions that interact with external systems (database, S3, HTTP requests)
- **Never use `context.TODO()`** in production code - always propagate context from the caller
- Use `context.Background()` only for background goroutines that are decoupled from the request lifecycle

## Receiver Naming

- Use **consistent short abbreviations** (2-3 letters) based on the struct type name
- Receivers should be **lowercase abbreviations**, not single letters
- Use the same receiver name throughout a type's methods


## Database Field Naming

- Use **`db`** for database connections (*sqlx.DB), not `conn`
- Be consistent across all repositories

## Variable Naming Standards

- **Validation errors**: Use `valErr` consistently
- **General errors**: Use `err`
- **Avoid shadowing**: Don't reuse variable names in nested scopes
- **Use descriptive names** for variables representing entities, e.g., `shortURL`, `userRepo`, `fileService`

## Naming Conventions
- Follow **PascalCase** for:
	- Struct names
	- Interface names
	- Method names
	- Constants
- Follow **camelCase** for:
	- Variable names
	- Function names
	- Package-level variables
	- Struct that are implementing contracts in internal directory
- Follow **snake_case** for:
	- Database table names
	- Database column names
	- Filenames

## Transaction Handling

- Repositories that modify data should implement transaction support
- Add `Begin(ctx context.Context) error`, `Commit() error`, and `Rollback() error` methods
- Services should handle transaction lifecycle (begin, commit, rollback on error)

## Middleware Patterns

- Use **middleware for cross-cutting concerns**: authentication, authorization, rate limiting, audit logging, etc.
- Middleware should be **chainable** and follow the Fiber/HTTP middleware pattern
- Keep middleware **focused** on a single responsibility

Common middleware:
- `RequireAuth()` - JWT authentication
- `Limit(max int, duration string)` - Rate limiting
- `AuditLog(action, entity string)` - Audit trail
- Custom validation middleware

## Error Handling

- Use **domain-specific errors** from `domain/errx` package
- Add **context with `.WithDetails()`** for debugging
- Add **location with `.WithLocation()`** to track error origin
- **Propagate errors** up to controllers, don't swallow them

## Resource Cleanup

- **Always clean up resources** (S3 files, temporary files) when operations fail
- Use **defer** for cleanup when appropriate
- Implement **rollback logic** for multi-step operations

## Code Organization

- Keep **controllers thin** - only handle HTTP concerns (parsing, validation, response)
- Put **business logic in services** - core application logic
- Keep **repositories focused** on data access only
- Use **dependency injection** via constructors
- Follow **clean architecture** layers: domain → application → infrastructure

## Testing Standards

- Write **unit tests for services**
- Use **mocking for external dependencies** (database, S3, etc.)
- Follow **Arrange-Act-Assert** pattern in tests
- Aim for **high code coverage** (>80%) on critical components

## Logging Practices

- Use structured logging with key-value pairs
- Log at appropriate levels: Info, Warn, Error
- Avoid logging sensitive information (passwords, tokens)
- Include **contextual information** (user ID, request ID)

# Commit Message Convention

This website follows [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/)

Commit message will be checked using husky and commit lint, you can't commit if not using the proper convention below.

## Format

`<type>(optional scope): <description>`
Example: `feat(pre-event): add speakers section`

### 1. Type

Available types are:

- feat → Changes about addition or removal of a feature. Ex: `feat: add table on landing page`, `feat: remove table from landing page`
- fix → Bug fixing, followed by the bug. Ex: `fix: illustration overflows in mobile view`
- docs → Update documentation (README.md)
- style → Updating style, and not changing any logic in the code (reorder imports, fix whitespace, remove comments)
- chore → Installing new dependencies, or bumping deps
- refactor → Changes in code, same output, but different approach
- ci → Update github workflows, husky
- test → Update testing suite, cypress files
- revert → when reverting commits
- perf → Fixing something regarding performance (deriving state, using memo, callback)
- vercel → Blank commit to trigger vercel deployment. Ex: `vercel: trigger deployment`

### 2. Optional Scope

Labels per page Ex: `feat(pre-event): add date label`

\*If there is no scope needed, you don't need to write it

### 3. Description

Description must fully explain what is being done.

Add BREAKING CHANGE in the description if there is a significant change.

**If there are multiple changes, then commit one by one**

- After colon, there are a single space Ex: `feat: add something`
- When using `fix` type, state the issue Ex: `fix: file size limiter not working`
- Use imperative, and present tense: "change" not "changed" or "changes"
- Don't use capitals in front of the sentence
- Don't add full stop (.) at the end of the sentence

# API Naming Convention

For API naming conventions, refer to the following guide: [API Naming Convention](https://restfulapi.net/resource-naming/) and prefix all endpoints with ```/api/v1```

# Pushing Changes

After committing your changes, push them to your personal branch first. Your personal branch name should be your nickname. Subsequently, you can submit a pull request to the dev branch. The owner will merge the dev branch into the master branch once it passes all unit tests and is ready for deployment on VPS.

# References
- [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/)
- [Theodorus Clarence's Conventional Commit Readme](https://theodorusclarence.com/shorts/conventional-commit-readme)