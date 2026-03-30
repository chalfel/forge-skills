---
name: forge-diagram
description: Generate architecture diagrams in Mermaid from the codebase or KB. Use when the user says "diagram", "architecture diagram", "draw the system", "show me the flow", "visualize", or wants a technical diagram. Outputs Mermaid blocks that render in markdown.
argument-hint: [what to diagram — e.g. "system architecture", "auth flow", "database schema"]
---

# Forge Diagram — Mermaid Architecture Diagrams

Generate technical diagrams in Mermaid syntax based on the codebase and KB.

## Input

The user provides: `$ARGUMENTS`

If no arguments, ask: "What do you want to diagram? (e.g. system architecture, auth flow, data model)"

## Diagram Types

### 1. System Architecture (`flowchart`)
High-level view of services, databases, external APIs.
```mermaid
flowchart LR
  Client --> API[API Server]
  API --> DB[(PostgreSQL)]
  API --> Cache[(Redis)]
  API --> S3[S3 Storage]
```

### 2. Request Flow (`sequenceDiagram`)
How a request flows through the system.
```mermaid
sequenceDiagram
  User->>Frontend: Click login
  Frontend->>API: POST /auth/login
  API->>DB: Query user
  DB-->>API: User record
  API-->>Frontend: JWT token
```

### 3. Data Model (`erDiagram`)
Database schema and relationships.
```mermaid
erDiagram
  USER ||--o{ POST : creates
  POST ||--o{ COMMENT : has
  USER ||--o{ COMMENT : writes
```

### 4. Module Dependencies (`flowchart`)
How code modules relate to each other.

### 5. State Machine (`stateDiagram-v2`)
Task/spec lifecycle, user states, order states.

### 6. Deployment (`flowchart`)
CI/CD pipeline, infrastructure.

## Process

### 1. Read Context
- Read `.forge/kb/architecture.md` for stack info
- Scan codebase structure with Glob
- Read key files (models, routes, config) with Grep

### 2. Generate Diagram
- Choose the right Mermaid diagram type for what was requested
- Keep it readable — max ~20 nodes per diagram
- Use clear labels, not file paths
- Group related nodes with subgraphs

### 3. Save to KB
Write the diagram to `.forge/kb/architecture.md` under a `## Diagrams` section, or create a dedicated `.forge/kb/diagrams.md` if there are multiple.

Format:
````markdown
## System Architecture

```mermaid
flowchart LR
  ...
```
````

### 4. Offer Variants
After generating, offer:
- "Want me to add a sequence diagram for a specific flow?"
- "Should I diagram the database schema too?"

## Rules

- **Scan the real code.** Don't invent services that don't exist.
- **Keep diagrams focused.** One concept per diagram.
- **Use subgraphs** for grouping (Frontend, Backend, Infrastructure).
- **Label edges** with what flows through them (HTTP, events, queries).
- **Save to KB** so diagrams are part of the project context.
