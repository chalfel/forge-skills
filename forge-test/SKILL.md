---
name: forge-test
description: Generate tests and set up test infrastructure for a project. Use when the user wants to create unit tests, integration tests, e2e tests, set up a test framework, or add test coverage. Triggers on "create tests", "add tests", "test setup", "forge test", "e2e test", or when working with test files.
argument-hint: [what to test — feature, module, spec name, or "setup" for initial config]
---

# Forge Test Generator

You generate tests and set up test infrastructure. You detect the project's stack, choose the right framework, and produce tests that match existing patterns — or bootstrap the setup from scratch.

## Input

The user provides: `$ARGUMENTS`

If no arguments, ask: "What do you want to test? A specific feature, a module, or do you need the full test setup?"

## Process

### 1. Detect the Stack

Scan the project to determine:
- **Language/runtime** — TypeScript, JavaScript, Python, Go, etc.
- **Framework** — Next.js, Express, FastAPI, etc.
- **Existing test setup** — look for config files and test directories:
  - `jest.config.*`, `vitest.config.*`, `playwright.config.*`, `cypress.config.*`
  - `pytest.ini`, `pyproject.toml [tool.pytest]`, `setup.cfg`
  - `go test` conventions (`*_test.go`)
  - `test/`, `tests/`, `__tests__/`, `e2e/`, `spec/` directories
- **Existing test patterns** — read 1-2 existing test files to understand conventions (imports, helpers, fixtures, naming)
- **Package manager** — npm, pnpm, yarn, pip, go modules

### 2. Read Context

If a Forge spec is referenced:
- Read `.forge/specs/{spec}.md` for done-when criteria — these become test assertions
- Read `.forge/kb/*.md` for architecture constraints

If a module/feature is referenced:
- Read the source code to understand the public API, inputs/outputs, edge cases

### 3. Determine Test Types Needed

Based on what was asked and what exists, decide which test types to generate:

| Type | When to use |
|------|-------------|
| **Unit** | Pure functions, services, utils, business logic |
| **Integration** | API routes, database queries, service interactions |
| **E2E** | User-facing flows, multi-step interactions, critical paths |
| **Component** | UI components with user interactions (React, Vue, etc.) |

If the user said `setup`, skip to step 4. Otherwise, skip to step 5.

### 4. Bootstrap Test Infrastructure

If no test setup exists, create it. Pick the framework based on the stack:

#### Frontend / Full-stack TypeScript
- **Unit/Integration** → Vitest (preferred) or Jest
- **E2E** → Playwright
- **Component** → Vitest + Testing Library

#### Backend TypeScript/Node
- **Unit/Integration** → Vitest (preferred) or Jest
- **Integration (API)** → Vitest + Supertest + Testcontainers (if user approves)
- **E2E (API)** → Vitest + Supertest

#### Python
- **Unit/Integration** → pytest
- **Integration (API)** → pytest + Testcontainers (if user approves)
- **E2E** → Playwright for Python or pytest + httpx

#### Go
- **Unit/Integration** → built-in `testing` package
- **Integration (API)** → built-in `testing` + Testcontainers (if user approves)
- **E2E** → built-in `testing` + `net/http/httptest`

**Setup checklist:**

1. **Install dependencies** — generate the install command (don't run it, print it for the user)
2. **Create config file** — framework config at project root
3. **Create test directory structure** — matching the project's source structure
4. **Create a sample test** — one working test to validate the setup
5. **Add test scripts** — add to `package.json`, `Makefile`, or equivalent

#### Playwright E2E Setup

When setting up Playwright, always include video recording:

```typescript
// playwright.config.ts
import { defineConfig, devices } from '@playwright/test';

export default defineConfig({
  testDir: './e2e',
  retries: process.env.CI ? 2 : 0,
  use: {
    baseURL: 'http://localhost:3000',
    video: 'retain-on-failure',
    screenshot: 'only-on-failure',
    trace: 'retain-on-failure',
  },
  projects: [
    { name: 'chromium', use: { ...devices['Desktop Chrome'] } },
  ],
  webServer: {
    command: 'npm run dev',
    port: 3000,
    reuseExistingServer: !process.env.CI,
  },
});
```

```typescript
// e2e/example.spec.ts
import { test, expect } from '@playwright/test';

test('home page loads', async ({ page }) => {
  await page.goto('/');
  await expect(page).toHaveTitle(/.+/);
});
```

#### Vitest Setup

```typescript
// vitest.config.ts
import { defineConfig } from 'vitest/config';

export default defineConfig({
  test: {
    globals: true,
    environment: 'node', // or 'jsdom' for frontend
    include: ['**/*.test.ts', '**/*.spec.ts'],
    coverage: {
      provider: 'v8',
      reporter: ['text', 'html'],
    },
  },
});
```

#### API-Only Integration Tests (Testcontainers)

When the project is **API-only (no UI)**, integration tests should use a **real database** instead of mocking it. Before setting up Testcontainers, **ask the user**: "Your project has no UI — I'd recommend using Testcontainers to spin up a real database for integration tests. Want me to set that up?"

If the user approves, configure Testcontainers for the detected database:

```typescript
// tests/setup/testcontainers.ts
import { PostgreSqlContainer, StartedPostgreSqlContainer } from '@testcontainers/postgresql';

let container: StartedPostgreSqlContainer;

export async function setupTestDB() {
  container = await new PostgreSqlContainer()
    .withDatabase('test_db')
    .start();

  return {
    host: container.getHost(),
    port: container.getMappedPort(5432),
    database: container.getDatabase(),
    user: container.getUsername(),
    password: container.getPassword(),
    connectionString: container.getConnectionUri(),
  };
}

export async function teardownTestDB() {
  await container?.stop();
}
```

```typescript
// tests/integration/users.api.test.ts
import { describe, it, expect, beforeAll, afterAll } from 'vitest';
import { setupTestDB, teardownTestDB } from '../setup/testcontainers';
import { createApp } from '../../src/app';
import request from 'supertest';

describe('Users API', () => {
  let app: Express;

  beforeAll(async () => {
    const dbConfig = await setupTestDB();
    app = createApp({ database: dbConfig });
  });

  afterAll(async () => {
    await teardownTestDB();
  });

  it('should create a user and persist to database', async () => {
    const res = await request(app)
      .post('/api/users')
      .send({ name: 'Maria Silva', email: 'maria@example.com' });

    expect(res.status).toBe(201);
    expect(res.body).toMatchObject({ name: 'Maria Silva' });

    // Verify it was actually persisted
    const getRes = await request(app).get(`/api/users/${res.body.id}`);
    expect(getRes.body.email).toBe('maria@example.com');
  });
});
```

**Testcontainers packages by database:**
- PostgreSQL → `@testcontainers/postgresql` / `testcontainers[postgresql]`
- MySQL → `@testcontainers/mysql` / `testcontainers[mysql]`
- MongoDB → `@testcontainers/mongodb` / `testcontainers[mongodb]`
- Redis → `@testcontainers/redis` / `testcontainers[redis]`

**Mocking strategy for API integration tests:**
- **Database → NEVER mock.** Use Testcontainers with a real instance. This is the default unless the user explicitly overrides it in `.forge/kb/architecture.md`.
- **External providers (payment gateways, email services, third-party APIs) → ALWAYS mock.** Create thin adapter interfaces and mock those.
- **Message queues, caches → use Testcontainers** if available, otherwise mock.

If the user has defined a different strategy in `.forge/kb/architecture.md` (e.g., "mock database in tests"), respect that instead.

### 5. Generate Tests

For each piece of functionality to test:

1. **Identify test cases** from:
   - Done-when criteria (if from a spec)
   - Public API surface (functions, endpoints, components)
   - Edge cases (null, empty, invalid input, error states)
   - Happy path + failure path

2. **Write the test file** following existing project patterns. If no patterns exist, use this structure:

```typescript
describe('[Module/Feature name]', () => {
  describe('[function/method name]', () => {
    it('should [expected behavior] when [condition]', () => {
      // Arrange
      // Act
      // Assert
    });
  });
});
```

3. **For E2E tests with Playwright**, always enable video per-file:

```typescript
import { test, expect } from '@playwright/test';

test.use({
  video: {
    mode: 'retain-on-failure',
    size: { width: 1280, height: 720 },
  },
});

test.describe('[Feature name]', () => {
  test('[user action and expected result]', async ({ page }) => {
    // Navigate
    await page.goto('/path');

    // Act — use user-visible locators
    await page.getByRole('button', { name: 'Submit' }).click();

    // Assert — verify user-visible outcomes
    await expect(page.getByText('Success')).toBeVisible();
  });
});
```

4. **Place test files** according to project conventions:
   - Co-located: `src/auth/auth.service.test.ts` (next to source)
   - Separate: `tests/unit/auth.service.test.ts` (mirror structure)
   - E2E: `e2e/[feature].spec.ts` (always separate)

### 6. Verify

After generating tests:
- Run the tests to confirm they pass (or explain what needs to be running first, like a dev server)
- Report coverage if available
- List any tests that are intentionally pending/skipped and why

## Rules

- **Match existing patterns.** If the project has tests, follow their style exactly — imports, naming, file placement, helpers.
- **Don't test implementation details.** Test behavior and outputs, not internal state.
- **Use realistic data.** No `"test"`, `"foo"`, `"bar"` — use data that represents the domain.
- **One assertion per concept.** A test can have multiple `expect` calls, but they should verify one logical outcome.
- **Name tests as behavior.** `"should return 404 when user not found"` not `"test getUserById error"`.
- **E2E tests use user-visible locators.** `getByRole`, `getByText`, `getByLabel` — not CSS selectors or test-ids (unless no better option).
- **Playwright E2E must have video.** Always configure `retain-on-failure` so failures produce a debugging video in `test-results/`.
- **Don't mock what you don't own.** Mock your own abstractions (adapter interfaces), not third-party SDKs directly.
- **Never mock the database.** Use Testcontainers for integration tests — real DB, real queries, real constraints. Only skip this if the user explicitly says otherwise in KB architecture.
- **Always mock external providers.** Payment gateways, email services, SMS, third-party APIs — mock them via adapter interfaces.
- **Ask before adding Testcontainers.** It requires Docker. Always ask the user before adding it to the project.
- **Keep tests fast.** Unit tests < 100ms each. Use mocks for I/O. Integration tests with Testcontainers are slower — that's expected.
- **Generate the install command, don't run it.** Print the command for the user to approve.
