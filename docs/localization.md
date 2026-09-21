# Localization — how a language is made

Everything about putting the app in another language, in one place. The
rulings behind it are ADRs and are linked, not restated; this file is the
hands-on: where things live, what you run, what you will see.

## The model in one paragraph

English is the master. A language is a **folder** of translated files laid
over the English banks entry by entry, plus one `.arb` file for the interface
strings ([ADR-0008](adr/0008-a-language-is-a-folder.md)). It ships **whole**:
the app offers a language only when every piece of reader-facing prose is
present, and a native speaker reads it afterwards, piece by piece
([ADR-0026](adr/0026-a-language-ships-once-complete-and-native-review-follows.md)).
When the English changes later, the old translation stays on screen until it
is redone ([ADR-0027](adr/0027-a-stale-translation-stays-until-it-is-retranslated.md)).

## Where things live

| What | Where | Committed |
|---|---|---|
| The English original of every bank | `assets/content/generated/<bank>.json` — the extractor's output, never hand-edited | yes |
| Course text — lessons, terms, games, Roasty's lines, everything a learner studies | `assets/content/l10n/<code>/<bank>.json`, the same bank name and ids as the English file, holding only the translated fields | yes |
| Interface text — buttons, titles, screen copy | `lib/l10n/app_<code>.arb`, beside `app_en.arb` — `lib/l10n/pending/` while the language is still a draft | yes |
| The to-do list while drafting | `build/l10n/<code>.queue.json` | no — regenerated |
| The tool | `tool/draft_language.js` and `tool/draft_language/` | yes |
| Which languages the app offers | `lib/shared/content/content_language.dart` | yes |

Two formats because Flutter fixes one of them: `gen_l10n` reads every
`lib/l10n/app_<code>.arb` on each build (`l10n.yaml`, `generate: true`) and
generates the Dart that picks the string for the phone's locale. Course text
is ours, so it takes the folder shape.

**An `.arb` in `lib/l10n/` is the app offering that language**, whatever the
course folder holds: `gen_l10n` puts the locale in `supportedLocales`, and a
phone set to it gets a translated interface over English lessons — the mixed
app ADR-0008 forbids. A course folder left out of `pubspec.yaml` is a draft
Flutter never ships; an `.arb` has no such off switch, so a draft language's
`.arb` waits in `lib/l10n/pending/`, which `gen_l10n` does not read. **`apply`
writes to `lib/l10n/`, so move the file back down after drafting** until the
language is complete and `content_language.dart` names it.

**Moving a screen's strings into the `.arb`.** Interface text is migrated
screen by screen: its strings go into `app_en.arb` and the screen reads them
as `context.strings`. A migrated screen keeps no `*_copy.dart` — the `.arb`
is the only home, or `plan` cannot see the strings and no language can reach
them. Only the onboarding name step has moved so far.

## The loop

```bash
node tool/draft_language.js plan  be    # what is still owed → build/l10n/be.queue.json
#  …fill each item's "text" in that file…
node tool/draft_language.js apply be    # writes the folder and the .arb from the queue
node tool/draft_language.js check be    # exit 0 when the language is complete
```

**The queue is a to-do list, not a record.** Every `plan` throws it away and
writes a fresh one holding only what the folder still lacks. After `apply`,
the pieces you filled are in the folder and gone from the queue. To see what
has been translated, open the folder; to see what is left, open the queue.

You do not fill 4,600 pieces before applying. Fill some, `apply`, `plan`
again; the rhythm is bank by bank, and nothing is lost between rounds.

**The words are agent-drafted.** The tool does the bookkeeping; an agent
writes the Belarusian. A person reviews afterwards (see *After it ships*).

### What a queue entry wants

Each entry shows the English and an empty `text`. Three kinds:

- **Prose** — most entries: `"text": "Што такое кава на самай справе"`.
- **Search keys** (`"searchKeys": true`, a term's `aliases`) — a **list** of
  the word's inflected forms, `"text": ["кава", "кавы", "каве", "каву"]`,
  because whole-word matching is what decides which terms a lesson teaches
  ([ADR-0025](adr/0025-a-language-ships-with-term-matching-search-and-voice-may-lag.md)).
  A language sets its own length here; review holds these, not `check`.
- **Optional** (`"optional": true`, a term's `pron` respelling) — may stay
  empty. A language that supplies none is still complete.

Never fill an answer by hand: a card whose answer is one of its options
(`answer`, a predict card's `a`, `fill[].a`) takes whatever its option became.
Ids, enum keys, colours and asset paths are never queued at all; the register
that decides this is `tool/draft_language/fields.js`, and a test fails when
the banks grow a string it has not classified.

`"bank": "app.arb"` in the queue means the interface strings. They land in
`lib/l10n/app_<code>.arb`, not in the folder.

### What the files carry

Every translated field carries two marks, per field, never per entry
([ADR-0026](adr/0026-a-language-ships-once-complete-and-native-review-follows.md)):

- `translatedFrom` — a fingerprint of the English it was made from. When the
  English changes, it stops matching and `plan` queues that field as `stale`,
  holding the words it has.
- `nativeReviewed` — set by hand once a native speaker has read it. A fresh
  draft clears it; re-applying the same words does not.

In the `.arb` the first mark rides as `x-translatedFrom` under `@key`. The
app strips both marks before any record reaches a model; nothing on a device
can read one.

**A bank with no prose is written as its ids alone** — today that is
`collectibles`, whose card copy lives on the lessons' and modules' `reward`.
The app reads a folder file for every bank and refuses a missing one, so a
forgotten `pubspec.yaml` line fails loudly instead of silently showing
English. That file is "present, nothing to say", and it never grows.

## Making a language available

`check` green is the bar. Then three things, none of which the tool does:

1. `pubspec.yaml`: `- assets/content/l10n/<code>/` under `assets:`. A
   directory entry does not bundle its subdirectories; `apply` reminds you.
2. `content_language.dart`: a `ContentLanguage` value with the folder `code`
   and the `speechTag` the platform voice is asked for.
3. A way for a reader to pick it — the Settings row is
   [#628](https://github.com/maximsan/brewpath/issues/628). Until it lands,
   `activeContentLanguage` is a constant pinned to English.

Two tests hold the line: `language_folders_complete_test.dart` re-runs
`check` over every folder `pubspec.yaml` bundles — a folder in the tree that
is not bundled is a draft Flutter never ships, so it is left alone, and a
half-drafted language can sit on `main` without a red build until its
`pubspec.yaml` line goes in — and `content_language_guard_test.dart` refuses
to offer a language whose course text is missing.

## After it ships

- **Review** is a queue that drains: read a piece, set its `nativeReviewed`
  in the folder. What nobody has read is whatever lacks the mark.
- **An English edit** makes that one field stale; `plan` queues it, the
  reader keeps the old translation meanwhile.
- **To pull a translation, delete the field.** It falls back to English at
  once, with no flag ([ADR-0027](adr/0027-a-stale-translation-stays-until-it-is-retranslated.md)).
- **New English course text** reads in English until translated; complete is
  the bar for offering a language, not a freeze on the course.

## What stays English, by rule

- The words drawn into card artwork ([ADR-0019](adr/0019-the-card-art-keeps-its-english-words.md)).
- Latin binomials and ids — the register lists each with its reason.
- Roasty's lines are translated, but a language ships the same **number** of
  them as English, one record per line ([ADR-0029](adr/0029-a-language-ships-the-same-number-of-roastys-lines-as-english.md)).

## Per language

- **Belarusian (`be`)** — no platform voice exists on iOS or Android; the
  pronounce control asks `canSpeak` and hides itself, which is a ruling, not a
  gap ([ADR-0025](adr/0025-a-language-ships-with-term-matching-search-and-voice-may-lag.md),
  [ADR-0012](adr/0012-the-pronunciation-voice-is-the-platforms-through-stts.md)).
  Cyrillic word boundaries are handled. Search does not fold Cyrillic, which
  is stricter, never wrong.
- **Polish (`pl`)** — search does not fold `ł ą ę ś ź ż ć ń`; a query needs
  its diacritics typed. Aliases run long because Polish inflects.

## Where the code is

- `tool/draft_language.js` — the three commands; `tool/draft_language/fields.js`
  the register; `folder.js` the per-bank plan/apply/check; `fingerprint.js`
  the mark.
- `lib/shared/repositories/language_overlay.dart` — how a folder lands on the
  master; `bank_envelope.dart` what a bank file must carry; `bank_loader.dart`
  reads master and folder off the bundle.
- `lib/shared/content/content_language.dart` — the languages and their paths.
- `l10n.yaml` — the interface-string half.
- Tests: `test/unit/tool/` (the tool, the register, completeness) and
  `test/unit/shared/repositories/language_overlay_test.dart`.
