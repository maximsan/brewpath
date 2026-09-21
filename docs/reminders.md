# BrewPath — the daily reminder

One quiet local notification a day, at one of the design's eight slots, on a
day the learner has not practised yet. iOS only, because iOS is the only
platform this app ships. Nothing is sent from a server and nothing leaves the
device.

## What a learner sees

Settings › Practice carries the two rows the design draws: a **Notifications**
switch, and a **Daily reminder** row showing the slot it arrives at — dim and
reading *Off* while the switch is off, and still pressable, because choosing a
time is how the reminder is turned on.

Turning it on asks iOS. A refusal stores nothing at all: the switch stays off,
the row keeps reading *Off*, and a sheet offers the way to iOS Settings — the
only place a refusal can be undone. If the permission is revoked there later,
the next launch switches the stored preference off, so the switch never shows
on for a reminder that would not arrive.

The notification is titled *BrewPath* and reads *Today's practice keeps your
streak alive.* — no quantity, because any qualifying activity keeps a streak,
not one lesson ([#443](https://github.com/maximsan/brewpath/issues/443)).

## How it fires

The app keeps a rolling fortnight of one-shot notifications pending, one per
day at the chosen slot, leaving out every day already on the qualifying-day set
and every slot already gone by. One-shots rather than one repeating request,
because a repeat cannot skip the day the learner has already practised on; a
fortnight, because iOS keeps at most 64 and the plan is re-filled on every
launch.

`ReminderWatcher` re-fills it on a cold start, a resume, the day turning over,
a completed activity, and a change to either row. The cold start and the resume
are what a reboot, an app upgrade and a timezone change come back through — the
iOS trigger stores the timezone it was built in, so a moved learner is put right
at the next launch rather than at the next midnight.

Every refresh runs through one queue (`ReminderRefresher`). Two that overlapped
could leave the OS holding the older plan, which is a reminder arriving after
it was switched off.

## Where the code is

The interface and its implementations are the source; this doc does not restate
them.

```
lib/services/reminders/
├── reminder_scheduler.dart                       # the seam, and the no-op
├── local_notifications_reminder_scheduler.dart   # iOS, via flutter_local_notifications
└── reminder_provider.dart                        # iOS gets the real one; everywhere else the no-op

lib/features/profile/domain/
├── daily_reminder.dart      # the eight slots, their clock times, and the copy
├── reminder_plan.dart       # pure: which instants to post
├── reminder_sync.dart       # pure: the preference and the permission, as one decision
├── reminder_refresher.dart  # the queue that runs a refresh at a time
└── reminder_actions.dart    # ask, drop, refresh

lib/features/profile/presentation/
├── reminder_watcher.dart           # wraps the app; re-fills the plan
└── settings/reminder_rows.dart     # the two rows, and the refusal sheet
```

## iOS setup

`AppDelegate.swift` sets `UNUserNotificationCenter.current().delegate`, which
is what lets the reminder show while the app is open and a tap be reported.
Nothing goes in `Info.plist` — a local notification needs no entitlement and no
declared capability.

## Seeing it work on a device

`flutter test` runs against the no-op, so the only way to watch a real
notification arrive is a device or simulator:

1. Run the app, turn the switch on, and accept the iOS prompt.
2. Pick the next slot that is still ahead of now.
3. Background the app — iOS shows a banner in the foreground only because the
   delegate above asks it to, and it is easier to trust a banner over the home
   screen.

To see the skip rule, finish a lesson first: the slots for today drop out and
the next reminder is tomorrow's.
