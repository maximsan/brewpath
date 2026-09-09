---
name: screenshot
description: Use when a change alters something a learner can see and it needs showing before it is called done — driving the real app on a simulator to a given screen and capturing it. Invoke as `/screenshot <screen or state>`, e.g. `/screenshot the recall payoff on m1l1`. Also use when asked to "show me", "screenshot it", or to verify a UI change in the running app rather than in tests.
---

# Screenshot Skill

Drive the real app to a screen, capture it, show it in the chat.

**A passing test proves the code runs; the picture is what shows it is right.**
Reviewing the recall payoff this way caught a 4px margin that put a space
before a full stop — something every assertion in the suite had missed, because
they all checked colour, state and copy and none could see spacing.

## The rule

- **Every user-visible UI change gets one, before it is called done.**
- **The image is for review and is then thrown away.** Never commit it, never
  embed it in the PR body. The owner does not want screenshots kept.
- Non-UI work — refactors, sweeps, tooling — has nothing to show. Do not
  manufacture one.

GitHub has no API for PR-body attachments; that upload is web-UI only. Do not
go looking for a way around it.

## Steps

### 1. Find the state, and make it worth looking at

Read the content bank for the real authored values rather than inventing a
fixture — `assets/content/generated/*.json`. Pick inputs that show the most:
for the payoff, guessing *wrong* renders both chips where guessing right
renders one.

### 2. Write a throwaway walk

A file under `integration_test/`, deleted before committing. It mounts the
screen, drives it, then **holds** so there is time to capture.

Mount the real thing. `AppBootstrap.initialize()` opens the on-device database,
so a screen pumped after it reads real Drift and real bundled assets:

```dart
await AppBootstrap.initialize();
await tester.pumpWidget(
  ProviderScope(
    child: MaterialApp(
      theme: AppTheme.cupping,
      home: const LessonScreen(lessonId: 'm1l1'),
    ),
  ),
);
```

Three things that will otherwise cost a run each:

- **Carry the smoke suite's `setUpAll` semantics guard**, and give it 20
  seconds rather than 5. Without it the run fails on *"A SemanticsHandle was
  active at the end of the test"* — Xcode's accessibility client attaches at
  the first frame and holds a handle the tester never counted.
- **Never `pumpAndSettle`.** Roasty idles on an infinite animation. Pump in
  real time: `tester.runAsync(() => Future.delayed(const Duration(milliseconds: 40)))`
  then `tester.pump()`, in a loop.
- **Tap hit-testable, and `ensureVisible` first.** Cards scroll; a raw finder
  hands back a widget off-screen and the tap silently misses.

End with `await tester.runAsync(() => Future<void>.delayed(const Duration(seconds: 45)));`

### 3. Build and run

Put `/opt/homebrew/bin` on `PATH`. Never run another `flutter` command between
the build and the test — the SPM platform floor resets to 13.0 and the Firebase
packages refuse to build.

```bash
tool/ci/boot_simulator.sh <udid>          # erases, boots, waits for launchability
flutter build ios --simulator --debug -t integration_test/<walk>.dart
xcodebuild test -workspace ios/Runner.xcworkspace -scheme Runner \
  -configuration Debug -destination "platform=iOS Simulator,id=<udid>" \
  -parallel-testing-enabled NO -derivedDataPath build/ios_shot > /tmp/shot.log 2>&1
```

Shut down any other booted simulator first, or target by UDID — `simctl io
booted` is ambiguous with two up.

### 4. Capture

Wait for the walk to reach the screen, then capture. Timing it by hand wastes
runs; wait on the log and take several:

```bash
until grep -q "<the test name>" /tmp/shot.log; do sleep 4; done
sleep 45
for i in 1 2 3; do
  xcrun simctl io <udid> screenshot "shot-$i.png"; sleep 4
done
```

### 5. Show it, then clean up

Downscale — a raw capture is 2.5 MB, `sips --resampleWidth 700` makes it
~240 KB — and send it with `SendUserFile` (`display: "render"`), captioned with
what state it is in.

Then **delete the walk and its derived data**, and confirm `git status` is clean
of both. The PR records that the change was driven and reviewed; it carries no
image.

## Looking at it

Read the picture against the design, not just for "does it render". What tests
cannot see and a screenshot can: spacing and padding, wrapping, alignment,
truncation, contrast, and anything that only goes wrong at a real text scale or
on a real device width. Report what you find, and fix it in the same change.
