# Assets

> Part of the [BrewPath v1 design reference](README.md). All source paths are relative to `prototype/`.


| Location | Count | Contents |
|---|---|---|
| `assets/trees/1–10.png` | 10 | The coffee-tree growth-stage illustrations (~1.7 MB). |
| `assets/modules/m1–m5.png` | 5 | The module pictures Today's card carries under the lesson title, and the dictionary's *Where you'll learn it* row shows as a 48pt square. The design source keeps them lossless at 1254×1254, ~11.7 MB together; the app bundles them re-encoded as 1100×1100 JPEGs, **~0.84 MB together** ([#540](https://github.com/maximsan/brewpath/issues/540)). The extractor rewrites the extension when it writes the modules bank, so the bank names what actually ships and the design source is never edited for a shipping concern. Both stay square — `artPos` anchors a crop of the whole picture. **With the trees, the only production raster assets.** |
| `uploads/` | 84 | Reference images: onboarding screen refs, tree concepts, Duolingo iOS reference screenshots, streak refs, `Flowerpot_seed_to.mp4` |
| `explorations/` | 12 | **New.** Design-exploration captures whose filenames record the decision: `compact-1-bordered` / `-2-noborder` / `-3-noglyph` / `-4-tight-chosen`, `ds-icons-1..3-chosen`, `ds-lessonrow-1..2-chosen`, `hover-unified-1` / `-2-chosen` / `hover-whole-row`. The `-chosen` suffix marks the variant that shipped — treat these as the visual record for the coming-soon node, the icon weight, the lesson row and the hover treatment. |
| `scraps/` | 21 | Working/review captures — not production assets |

`screenshots/` and `scratch/` (previously 70 and 98 captures) were removed in `aa065bb` and were never tracked in git.

Everything else — Roasty, all icons, all card art, the cherry cross-section, the world map, all glyphs — is **inline SVG in code**. No icon font, no image sprites.

**Web fonts** loaded from Google Fonts: Fraunces (variable), IBM Plex Sans (400/500/600), IBM Plex Mono (400/500). A native build must bundle these.

---

← [Deferred features — v2 detail](09-deferred-v2.md) · [Contents](README.md)
