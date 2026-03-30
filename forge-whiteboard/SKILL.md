---
name: forge-whiteboard
description: Create visual whiteboards and diagrams using Excalidraw. Use when the user wants a visual diagram, whiteboard, brainstorm board, user flow, wireframe, or any free-form visual artifact. Triggers on "whiteboard", "excalidraw", "draw this", "sketch", "wireframe", "visual diagram", "user flow diagram".
argument-hint: [what to draw — e.g. "user onboarding flow", "system overview", "feature brainstorm"]
---

# Forge Whiteboard — Excalidraw Visual Diagrams

Create visual diagrams and whiteboards as Excalidraw files that can be viewed and edited in VS Code (with the Excalidraw extension) or at excalidraw.com.

## Input

The user provides: `$ARGUMENTS`

If no arguments, ask: "What do you want to draw? (e.g. user flow, system overview, brainstorm)"

## Process

### 1. Understand the Request
Determine what type of visual is needed:
- **Architecture overview** — boxes for services, lines for connections
- **User flow** — step-by-step screens/actions
- **Wireframe** — rough UI layout
- **Brainstorm** — mind map of ideas
- **Process flow** — steps with decision points
- **Data flow** — how data moves through the system

### 2. Read Context
- Read `.forge/kb/` for project context
- Scan codebase if diagram is about code structure
- Read existing specs if diagramming a feature

### 3. Generate Excalidraw File

Create a `.excalidraw` file at `.forge/kb/diagrams/{slug}.excalidraw`.

The Excalidraw JSON format uses elements with these types:
- `rectangle` — boxes/containers
- `ellipse` — circles/ovals
- `diamond` — decision points
- `arrow` — connections
- `text` — labels
- `line` — simple lines

Each element needs: `id`, `type`, `x`, `y`, `width`, `height`, `strokeColor`, `backgroundColor`, `text` (for text elements).

### 4. Color Coding
Use consistent colors:
- **Blue (#4A90D9)** — Frontend/UI components
- **Green (#4CAF50)** — Backend/API services
- **Orange (#FF9800)** — Databases/storage
- **Purple (#9C27B0)** — External services/APIs
- **Red (#F44336)** — Critical/alert items
- **Gray (#9E9E9E)** — Infrastructure/utilities

### 5. Generate the File

Create the Excalidraw JSON file with well-positioned elements. Use a grid layout:
- **Left to right** for flows
- **Top to bottom** for hierarchies
- **Clustered** for related components
- **Spacing** of ~200px between elements

```json
{
  "type": "excalidraw",
  "version": 2,
  "source": "forge",
  "elements": [
    {
      "id": "elem1",
      "type": "rectangle",
      "x": 100,
      "y": 100,
      "width": 200,
      "height": 80,
      "strokeColor": "#4A90D9",
      "backgroundColor": "#E3F2FD",
      "fillStyle": "solid",
      "strokeWidth": 2,
      "roundness": { "type": 3 },
      "text": "Frontend"
    }
  ],
  "appState": {
    "viewBackgroundColor": "#ffffff",
    "gridSize": 20
  }
}
```

### 6. Save and Open

Save to `.forge/kb/diagrams/{slug}.excalidraw` and tell the user:
- Install "Excalidraw" VS Code extension to view/edit inline
- Or open at excalidraw.com by importing the file
- The file is version-controlled with the project

## Diagram Templates

### System Architecture
```
[Frontend] --HTTP--> [API Gateway] --gRPC--> [Service A]
                                   --gRPC--> [Service B]
                     [API Gateway] --SQL--> [(Database)]
                                   --Redis--> [(Cache)]
```

### User Flow
```
[Landing Page] --> [Sign Up] --> [Verify Email] --> [Onboarding] --> [Dashboard]
                                       |
                                  [Resend Email]
```

### Feature Brainstorm
```
          [Core Feature]
         /      |       \
   [Sub A]  [Sub B]   [Sub C]
    /   \      |
[A1]  [A2]   [B1]
```

## Rules

- **Make it readable.** Don't cram too many elements. Max ~15-20 per diagram.
- **Use consistent spacing.** Grid-aligned, ~200px gaps.
- **Color code by domain.** Same color = same system boundary.
- **Label connections.** Arrows should say what flows through them.
- **Save in KB.** Diagrams are project context, not throwaway.
- **Create separate files** for different aspects (don't put everything in one).
