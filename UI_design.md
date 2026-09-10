# UI Design & Redesign Direction

## 1. Purpose

This document defines the visual and UX direction for redesigning the existing application.

The application is already functional. The primary objective is to modernize and improve the UI/UX while preserving existing functionality.

The provided reference image is a **visual reference**, not a complete specification of the application.

Reference design characteristics:
- Modern mobile-first interface
- Clean light background
- Strong black/dark surfaces used for important information
- Bright lime/green accent color
- Rounded cards and containers
- Generous spacing
- Clear typography hierarchy
- Compact but readable information density
- Subtle decorative elements
- Bottom navigation with a strong active state
- Clear primary actions
- Financial/dashboard-style visual hierarchy

Do not copy the reference literally if its content does not match this application's domain. Adapt its design language to the existing application.

---

## 2. Main Goal

Redesign the existing screens so the entire application feels like one coherent product.

The redesign should improve:

- Visual hierarchy
- Readability
- Spacing
- Component consistency
- Navigation clarity
- Information grouping
- Button hierarchy
- Form usability
- Empty/loading/error states
- Overall perceived quality

The result should feel intentional and production-ready rather than like a collection of individually redesigned screens.

---

## 3. Design Principles

### 3.1 Modern but Practical

Use modern UI patterns without adding decoration just for appearance.

Prefer:
- Clear hierarchy
- Simple layouts
- Strong typography
- Rounded surfaces
- Meaningful accent colors
- Consistent spacing
- Reusable components

Avoid:
- Excessive gradients
- Excessive shadows
- Too many colors
- Random icons
- Unnecessary animations
- Decorative elements that compete with content
- Extremely dense layouts
- Extremely empty/minimal layouts

### 3.2 Content First

The application's real content and functionality must remain the priority.

A visual redesign must never make important information harder to find.

### 3.3 Consistency Over Individual Screens

When a reference design exists for only some screens, use it to establish the design language.

Screens without references should follow the same:
- spacing system
- typography
- colors
- radius
- component shapes
- icon treatment
- interaction patterns
- navigation patterns

---

## 4. Visual Direction

### Background

Use a soft/light neutral background for most screens.

Avoid pure white everywhere if a slightly tinted neutral background creates better separation between the page and cards.

### Surfaces

Cards and content surfaces should generally:
- have rounded corners
- have comfortable internal padding
- use subtle borders or elevation only when useful
- clearly separate grouped information

### Dark Surfaces

Dark/black surfaces may be used for high-priority sections such as:
- hero cards
- summaries
- important status information
- prominent actions

Do not make every component dark.

### Accent Color

Use a bright lime/green accent inspired by the reference design.

The accent should be used intentionally for:
- primary actions
- selected navigation state
- positive/high-priority status
- important highlights
- key values

Do not use the accent on every element.

If the existing product already has an established brand color, preserve the brand identity where appropriate and adapt the lime/green concept instead of blindly replacing the brand color.

---

## 5. Typography

Typography should have a clear hierarchy.

Recommended hierarchy:

- Screen title: strong/bold
- Section title: semibold/bold
- Primary value: large and prominent
- Body text: regular and highly readable
- Secondary text: muted
- Caption/metadata: smaller and visually subordinate

Do not use too many font sizes.

Prefer a small, consistent type scale.

---

## 6. Spacing

Use a consistent spacing system.

Recommended base unit:

4 px

Common values:
- 4
- 8
- 12
- 16
- 20
- 24
- 32

Typical screen padding:
- 16–24 px depending on screen density and content

Cards should have enough internal padding to avoid feeling crowded.

---

## 7. Border Radius

Use rounded corners consistently.

Suggested values:
- Small controls: 8–12 px
- Inputs/buttons: 12–16 px
- Cards: 16–24 px
- Hero/prominent surfaces: 20–28 px

Do not use a different radius for every component.

---

## 8. Buttons

Buttons should have clear hierarchy.

### Primary

Use the accent color or strongest brand color.

Primary buttons should:
- be visually prominent
- have clear text
- have sufficient height
- have rounded corners
- provide clear pressed/disabled states

### Secondary

Use a neutral surface, outline, or subtle background.

### Destructive

Use a clearly recognizable destructive treatment, but do not overuse red.

Avoid icon-only buttons when text would make the action clearer.

---

## 9. Cards

Cards should represent logical groups of information.

A card should not exist merely because cards look modern.

Prefer:
- clear title
- supporting information
- meaningful action
- consistent padding
- predictable hierarchy

Avoid deeply nesting cards inside cards unless there is a strong information-architecture reason.

---

## 10. Icons

Icons should be consistent in:
- visual style
- size
- stroke/weight
- alignment

Use icons to support understanding, not as decoration.

Do not introduce large numbers of unrelated icons simply to make the interface look more interesting.

---

## 11. Navigation

Use the application's existing navigation structure unless the redesign clearly benefits from a change.

If bottom navigation exists:
- keep labels understandable
- make the active state obvious
- use consistent icon sizing
- avoid excessive decoration

The reference design demonstrates a strong active navigation state. This can be adapted to the application.

Do not change navigation/business flow without explicit approval.

---

## 12. Forms

Forms should prioritize usability.

Each form should have:
- clear field labels
- appropriate input types
- visible validation
- clear error messages
- sufficient spacing
- obvious primary action

Avoid placing too many fields in one dense block.

Group related fields logically.

---

## 13. Lists

List screens should have strong visual scanning.

Each item should clearly communicate:
- primary information
- secondary information
- status when relevant
- available action

Use dividers, spacing, cards, or subtle surfaces consistently.

Avoid excessive borders.

---

## 14. Detail Screens

Detail pages should establish a clear hierarchy:

1. Page/header
2. Main/important information
3. Supporting information
4. Related information
5. Actions

Important information should be visually stronger than metadata.

---

## 15. States

Every relevant screen should consider:

### Loading
Use a polished loading state or skeleton where appropriate.

### Empty
Explain what is empty and, when appropriate, provide a useful next action.

### Error
Clearly explain that something went wrong and provide retry/recovery where possible.

### Success
Give appropriate feedback without excessive decoration.

### Disabled
Make disabled controls visually understandable while maintaining accessibility.

Do not redesign these states in a way that changes application logic.

---

## 16. Reference Interpretation

The provided reference contains several useful patterns.

### Pattern A — Hero Summary

Large information can be presented in a prominent rounded dark surface.

Adapt this pattern when the application has:
- balances
- totals
- summaries
- important metrics
- primary status

### Pattern B — Quick Actions

A grouped action area can present frequently used actions in a compact, easy-to-scan format.

Use this only where the application's existing functionality supports it.

### Pattern C — Section Cards

Small cards can separate related metrics or categories.

Use cards when they improve scanning and hierarchy.

### Pattern D — Search

The reference uses a large, simple search field.

For applicable screens, search should be:
- easy to locate
- visually clear
- comfortable to tap
- visually consistent with the rest of the design

### Pattern E — Strong Primary Action

Important actions can use the accent color to create a clear call to action.

---

## 17. Responsive and Device Considerations

The UI must work on the application's supported mobile screen sizes.

Do not hardcode layouts around one screenshot size.

Consider:
- small phones
- large phones
- text scaling
- safe areas
- keyboard appearance
- long content
- dynamic data lengths

Avoid overflow and clipped content.

---

## 18. Flutter Implementation Direction

Prefer reusable UI components.

If the existing architecture already provides reusable widgets or theme definitions, extend them instead of creating duplicates.

Prefer:
- centralized theme values
- reusable buttons
- reusable cards
- reusable input components
- reusable spacing
- reusable text styles
- reusable status components

Do not introduce a new architecture solely for the redesign.

Keep business logic separate from UI.

Do not move API/business logic into widgets just to make redesign implementation easier.

---

## 19. What the Agent Should Do When a Reference Is Missing

A reference screenshot may not exist for every screen.

When there is no direct reference:

1. Inspect the existing screen.
2. Identify its purpose and information hierarchy.
3. Identify the closest reference pattern.
4. Apply the same visual language.
5. Preserve the existing functionality.
6. Make the screen consistent with redesigned screens.
7. Do not invent major product features.

The agent may make reasonable UI decisions, but should avoid changing product behavior without approval.

---

## 20. Design Decision Priority

When making a design decision, prioritize in this order:

1. Existing product requirements
2. Existing functionality
3. Usability
4. Consistency across the application
5. Reference design language
6. Visual polish
7. Decorative details

A beautiful UI that breaks functionality is considered a failure.

---

## 21. Acceptance Criteria

A redesign is successful when:

- Existing core functionality still works.
- Existing API behavior remains compatible.
- No important feature is accidentally removed.
- Screens share a consistent visual language.
- Spacing is consistent.
- Typography hierarchy is clear.
- Primary actions are obvious.
- Components are reusable.
- Loading/empty/error states are considered.
- UI works on supported screen sizes.
- The result feels like one coherent application rather than unrelated redesigned pages.

---

## 22. Important Constraint

The reference image is inspiration for the visual system.

It is NOT permission to:
- copy unrelated features
- copy financial terminology
- copy business logic
- change the application's product concept
- invent screens
- remove existing functionality

Translate the visual language into the application's actual domain.
