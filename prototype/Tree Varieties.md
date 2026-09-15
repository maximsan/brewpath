# Tree varieties — what shipped

Reconstructed from code after the original proposal page was deleted. This
records the state of the implementation, not the argument that produced it: the
comparison tables and rejected options from *Tree Variety Proposal v2* are gone.

## Where it lives

- `window.TREE_VARIETIES` — `customize.jsx` (three species, top of file)
- `window.GROVE_LIGHT` — `customize.jsx` (four light treatments)
- `window.getVariety` / `getLight` / `groveFilter` / `groveShape` — `customize.jsx`
- `TreeChooserScreen` — `customize.jsx`, the Studio's picker
- `CoffeePersona` — `flavor-wheel.jsx`, applies shape + filter to the stage art
- Stage art — `assets/trees/1.png … 10.png`, shared by all three species

## The three species

| | Arabica | Robusta | Liberica |
|---|---|---|---|
| Latin | *Coffea arabica* | *Coffea canephora* | *Coffea liberica* |
| Share | ~60% | ~35% | <1% |
| Brewed as | Filter & pour-over | Espresso & instant | Local brews in SE Asia |
| Grows | High and cool | Low and warm | Low and humid |
| Cup | Sweet, fruity, delicate | Bold, chocolatey, bitter | Smoky, jackfruit, savoury |
| Silhouette | `none` (baseline) | `scale(1.2, 0.9)` | `scale(1.1, 1.12)` |
| Leaf tone | none | `saturate(1.2) hue-rotate(-8deg) brightness(0.94)` | `saturate(0.95) hue-rotate(6deg) brightness(0.96)` |
| `drop` | launch | launch | later |

**What the transforms encode.** Ship art is meant to be bespoke per plant per
stage; until it exists, each species carries a silhouette transform plus a leaf
tone over the ten shared frames, so the three read apart **without relying on
hue alone**. Robusta is wider and shorter than Arabica — broader, bushier,
larger leaves. Liberica is taller and slightly wider — the tallest of the three,
with enormous leathery leaves.

**Why Liberica is `drop: later`.** `drop` is a rollout note for the art
pipeline, not an entitlement. There is no per-plant gating: the Studio door
itself is behind the paywall, so everything inside it is owned. Liberica is
under 1% of world production, so it was the one to wait for bespoke art.

## Field discipline

One field per idea, one place each — this is the part most likely to drift:

- `share` — prevalence. Spec strip only.
- `use` — what the bean gets brewed as. The same question for all three, and
  **never prevalence in words**. Row subtitle only.
- `cup` — the spec strip's "Tastes like".
- `tell` — what none of the others can carry: the plant's body plus one
  consequence worth remembering (Arabica's fussiness moving the price of your
  cup; Robusta's caffeine and crema; Liberica needing a ladder).

## Light

Four treatments — `Daylight` (unfiltered default), `Golden Hour`, `Moonlit`,
`First Frost`. Light composes **on top of** whichever variety is planted:
`groveFilter()` joins the variety's leaf tone and the light's filter into one
CSS filter, while `groveShape()` stays a separate transform. Enough to change
the mood, not enough to pretend to be a different plant.

`CoffeePersona` holds the shape on a wrapper element rather than the `<img>`,
because the sway animation owns `transform` on the image itself.
