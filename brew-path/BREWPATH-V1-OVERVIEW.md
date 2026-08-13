# BrewPath — v1 Design Reference

**This document has moved.** It was split into a navigable set of files at
[`docs/design/`](../docs/design/README.md).

Start at [`docs/design/README.md`](../docs/design/README.md), which carries the
section index, a "start here" table by question type, guidance for using the
reference with an agent, and the command for re-deriving every count from the
prototype source.

| Looking for | Now at |
|---|---|
| File map, deep links | [§0 How to read the prototype](../docs/design/00-reading-the-prototype.md) |
| v1 vs v2 scope | [§2 Scope](../docs/design/02-scope.md) |
| Design tokens + the component index | [§3 Design system](../docs/design/03-design-system.md) |
| Tabs, routes, **the coming-soon modules** | [§4 Information architecture](../docs/design/04-information-architecture.md) |
| Points, mastery, tree, streak, gating | [§5 Mechanics](../docs/design/05-mechanics.md) |
| Course, dictionary, mini-games, Studio | [§6 Content](../docs/design/06-content.md) |
| Component states and options | [§7 Components](../docs/design/07-components.md) |
| What is broken or undecided | [§11 Open items](../docs/design/11-open-items.md) |
| What to build | [§12 Checklist](../docs/design/12-checklist.md) · [§13 Epics](../docs/design/13-epics.md) |

Numbers are re-derived with:

```bash
node docs/design/tools/extract-facts.js
```
