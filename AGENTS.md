# Agent Instructions — UI Redesign

## 1. Project Context

This is an existing application that is already functional.

The current task is a UI/UX redesign.

The application should be treated as an existing production/project codebase, not as a new application.

Before changing code, understand the existing project structure and functionality.

---

## 2. Primary Objective

Redesign the application's UI according to:

`UI_design.md`

The provided design reference images are visual references.

The goal is to create a consistent, modern, polished interface while preserving the existing application behavior.

---

## 3. Critical Rules

### DO

- Inspect the existing code before modifying it.
- Understand the current navigation.
- Understand the existing screens.
- Reuse existing functionality.
- Reuse existing architecture.
- Create reusable UI components.
- Centralize theme/design values where appropriate.
- Keep UI code maintainable.
- Test after meaningful changes.
- Compare implementation against the design direction.

### DO NOT

Do not change the following unless explicitly required and approved:

- API contracts
- API endpoints
- Database structure
- Authentication logic
- Business rules
- Core data flow
- Existing features
- Existing permissions
- Existing user roles
- Backend behavior

Do not rewrite the entire project architecture just because the UI is being redesigned.

Do not replace working functionality with mock data.

Do not remove functionality because it is not visible in a reference screenshot.

Do not assume that the reference screenshot represents the application's complete feature set.

---

# 4. Required Files

Before implementation, read:

`UI_design.md`

Also inspect any screenshots/reference assets provided in the project.

If a design-reference directory exists, inspect it before implementation.

If current screenshots exist, compare them with the code.

---

# 5. Workflow

## Phase 1 — Analyze

Do NOT modify files yet.

Inspect:

- framework
- language
- project structure
- entry points
- routing/navigation
- state management
- theme
- reusable widgets/components
- API/data layer
- screen structure

Then identify:

- all major screens
- reusable components
- existing UI patterns
- inconsistent UI patterns
- screens that require redesign
- potential UI-only refactoring opportunities

---

## Phase 2 — Create a Redesign Plan

Still do NOT modify implementation code.

Create a concise plan containing:

1. Existing UI structure
2. Target visual direction
3. Screen inventory
4. Design-system changes
5. Reusable components that should be created/updated
6. Screen-by-screen redesign order
7. Risks to existing functionality
8. Files likely to be modified

Clearly separate:

### UI Changes
Changes that affect appearance/layout/UX.

### Functional Changes
Changes that affect behavior/data/business logic.

Functional changes should be avoided unless explicitly approved.

At the end of this phase, STOP and present the plan for review.

---

# 6. Phase 3 — Implement Incrementally

After the plan is approved:

Implement one logical group at a time.

Recommended order:

1. Global theme/design tokens
2. Shared components
3. App shell/navigation
4. Main/home screen
5. Important list screens
6. Detail screens
7. Forms
8. Secondary screens
9. Loading/empty/error states
10. Final consistency pass

Do not redesign every screen in one uncontrolled operation.

---

# 7. Design System First

Before duplicating styling across screens, establish reusable values for:

- colors
- typography
- spacing
- border radius
- elevation/shadows
- component heights
- icon sizing

Use the existing project's theme system if one exists.

If there is no suitable theme system, create a lightweight one appropriate for the current architecture.

Do not introduce unnecessary complexity.

---

# 8. Reference Design Rules

The reference design suggests:

- light neutral backgrounds
- dark hero/summary surfaces
- bright lime/green accent
- rounded cards
- strong typography
- generous spacing
- compact quick actions
- clear bottom navigation
- strong selected states

Adapt these principles to the actual application.

Do not copy unrelated content or functionality from the reference.

For example, if the application is not a financial application, do not create financial cards or stock-related sections simply because they appear in the reference.

---

# 9. Handling Missing Reference Screens

Not every screen will have a reference screenshot.

When no direct reference exists:

- infer the layout from the screen's purpose
- reuse the established design system
- use the closest existing reference pattern
- prioritize usability
- preserve the current feature set

Do not invent major functionality.

---

# 10. Code Quality

Prefer reusable widgets/components instead of repeated UI code.

For example, if multiple screens use the same card style, create or reuse a shared component instead of implementing the card independently on every screen.

Avoid giant widgets/files when reasonable.

Do not perform unrelated refactors during UI redesign.

Keep changes scoped to the redesign.

---

# 11. Verification After Each Screen

After implementing a screen:

1. Check compilation/analyzer errors.
2. Check layout overflow.
3. Check navigation.
4. Check interactions.
5. Check loading/error/empty states where applicable.
6. Check different content lengths.
7. Compare visually against the design direction.
8. Confirm existing functionality remains intact.

If the project has tests, run relevant tests.

---

# 12. Visual Review

When screenshots can be generated from the application, use them for comparison.

Check:

- overall hierarchy
- spacing
- alignment
- typography
- card proportions
- button prominence
- icon consistency
- navigation state
- visual density
- empty space
- overflow

Do not optimize for pixel-perfect copying of the reference.

Optimize for a coherent product design.

---

# 13. When You Are Unsure

If a decision affects only visual presentation:

Make a reasonable design decision based on `UI_design.md`.

If a decision affects:

- business logic
- API
- database
- authentication
- navigation behavior
- permissions
- user roles
- existing feature behavior

STOP and ask for approval before changing it.

---

# 14. Change Scope

Every implementation change should be explainable as one of:

- UI redesign
- UX improvement
- UI component reuse
- design-system implementation
- UI-only refactoring
- bug fix directly caused by redesign

Avoid unrelated cleanup.

---

# 15. Final Review

After all screens have been redesigned, perform a consistency pass.

Look for:

- inconsistent spacing
- inconsistent corner radius
- inconsistent typography
- inconsistent button styles
- inconsistent icon sizes
- duplicated components
- inconsistent colors
- inconsistent navigation
- screens that still look like the old UI
- broken states
- overflow
- accidental functional changes

The final result should look like a single design system was applied across the entire application.

---

# 16. First Instruction

When this task starts, your first response should NOT modify code.

First:

1. Read `UI_design.md`.
2. Inspect the project.
3. Inspect available reference/current screenshots.
4. Analyze the existing UI.
5. Produce a redesign plan.
6. Wait for approval.

Only after approval should implementation begin.
