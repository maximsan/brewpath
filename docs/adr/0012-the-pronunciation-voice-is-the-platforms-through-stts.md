# ADR-0012: The pronunciation voice is the platform's, reached through `stts`

- **Status:** accepted
- **Date:** 2026-08-31

## Context

`SpeakButton` (`prototype/dictionary.jsx:23`) speaks a term through the
browser's `speechSynthesis`. Flutter's SDK has no equivalent, and the iOS
project is **SPM-only with no Podfile** — so the popular `flutter_tts`, which
ships a podspec and no `Package.swift`, would put CocoaPods back into the build
weeks before its registry goes read-only. Argument and evidence:
[#456](https://github.com/maximsan/brewpath/issues/456).

## Decision

The voice is **the platform's own** — `AVSpeechSynthesizer`, offline, no
network and no account — reached through **`stts`**, which is SPM-native and
carries no dependencies of its own.

It sits behind a `SpeechService` abstraction, as every third-party service in
`lib/services/` does. Feature code never names the package.

**The language is the content's, not the device's.** A French phone reading an
English course must not pronounce *doppio* with a French voice. Today that is
English, because English is the master (ADR-0008); a language folder brings its
own tag with it.

**A second press restarts rather than queues**, matching the design's
`speechSynthesis.cancel()` before every `speak()`.

**Where the platform offers no voice for the language, no button is drawn** —
a speaker that cannot speak is the dead control
[#355](https://github.com/maximsan/brewpath/issues/355) cleared.

## Consequences

`stts` is young — 36 likes against `flutter_tts`'s 1.6k. The exit is bounded:
BSD-3 with no dependencies, so vendoring its ~200 lines of Swift is the fallback
if it is abandoned.

We ship a speech-**to**-text half we never call. It is inert, but a future
caller of `Stt()` gets a runtime crash rather than a compile error, because the
`Info.plist` keys it needs are deliberately absent.

Android will need the same package when that folder is generated; `stts`
supports it, so this record covers it rather than being revisited.
