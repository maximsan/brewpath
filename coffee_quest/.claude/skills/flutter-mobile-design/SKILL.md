---
name: flutter-mobile-design
description: Use when creating, reviewing, or improving Flutter mobile UI/UX, visual design, design systems, widgets, screen layouts, navigation, responsiveness, accessibility, empty states, loading states, error states, or app polish.
---

# Flutter Mobile Design Skill

## Goal

Improve the visual quality, usability, consistency, and production readiness of a Flutter mobile application without breaking existing architecture, state management, routing, persistence, or business logic.

## Default product context

- Platform: iOS-first mobile application.
- Framework: Flutter + Dart.
- Product type: educational mobile app.
- Style direction: clear, playful, structured, beginner-friendly.
- Avoid: generic AI-looking UI, random gradients, inconsistent spacing, fake complexity, unnecessary animations.

## Design principles

Always optimize for:

- Clear visual hierarchy.
- Consistent spacing.
- Reusable widgets.
- Strong empty/loading/error states.
- Touch-friendly layout.
- iOS-safe areas.
- Accessibility.
- Small-screen readability.
- Consistent typography.
- Consistent color usage.
- Smooth but restrained motion.

## Flutter implementation rules

- Use existing project structure and naming conventions.
- Reuse existing widgets before creating new ones.
- Prefer extracting reusable UI components when a pattern appears more than once.
- Do not introduce a new UI package unless explicitly required.
- Do not change business logic unless required for the UI task.
- Do not change persistence, routing, or state architecture unless the task explicitly asks for it.
- Keep widgets small and readable.
- Prefer composition over large monolithic widgets.
- Keep build methods simple.
- Use theme tokens where available.
- If theme tokens are missing, propose them before hardcoding repeated styles.

## UI review checklist

Before editing code, inspect the target screen or widgets and identify:

- Layout issues.
- Spacing inconsistency.
- Typography inconsistency.
- Weak hierarchy.
- Poor contrast.
- Overcrowded elements.
- Missing empty/loading/error states.
- Unclear CTA priority.
- Non-reusable UI patterns.
- Accessibility issues.
- iOS-specific issues.

## Implementation process

1. Understand the screen purpose.
2. Identify the primary user action.
3. Identify current UI problems.
4. Propose a focused redesign direction.
5. Update only the required widgets/files.
6. Extract reusable components only when useful.
7. Run formatting and static analysis.
8. Run relevant tests if available.
9. Summarize what changed and why.

## Definition of done

A design task is complete only when:

- The UI is visually clearer than before.
- Primary and secondary actions are obvious.
- Spacing and typography are consistent.
- The implementation follows existing project architecture.
- No unrelated files were changed.
- No unnecessary dependency was added.
- Flutter formatting passes.
- Static analysis has no new issues.
- Relevant tests pass or required test updates are clearly listed.
