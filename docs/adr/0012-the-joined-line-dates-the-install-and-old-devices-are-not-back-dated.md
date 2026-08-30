# ADR-0012: The joined line dates the install, and old devices are not back-dated

- **Status:** accepted
- **Date:** 2026-08-30

## Context

Profile closes with `Joined {Month Year}`. The app stored no install date, so
the line read the earliest day the learner was active — a month late for anyone
who installed and did not start. Recording the install is a schema change, and
it needs a rule for the devices already out there. Argument:
[#447](https://github.com/maximsan/brewpath/issues/447).

## Decision

**The install stamp is one row in its own table, written by the database's
`onCreate`.** Creating the database is the app's first run, and it is the only
moment that can record an install without guessing. It is not a column on
`user_settings`, whose row deliberately does not exist until the learner
chooses something.

**The v10 → v11 migration creates the table empty.** A device upgrading
installed the app at a time this build cannot know, and the only instant
available is now.

**The line names the earlier of the stamp and the first active day**, not the
stamp in preference to it. An empty table therefore reads as the fallback the
ticket asked for, and a restored snapshot carrying days older than this copy of
the app moves the line earlier rather than later — which is the ticket's own
defect, inverted. The line is absent only when neither is known.

**Reset Progress leaves the stamp; Delete Account restamps it to the wipe.**
What a delete leaves behind is a fresh install in every other respect, so the
account the line dates is the one beginning then.

## Consequences

Every device installed before v11 keeps reading a month late, permanently. The
divergence closes going forward only, and no later change can recover the dates
that were never recorded.

The stamp is device-local and stays out of the progress snapshot. Taking the
minimum is what keeps that survivable: a second device dates its own install,
but any restored day older than it pulls the line back to the truth. If the
stamp itself ever has to move between devices, this is the record to revisit —
it enters the snapshot's delete-only scope and gains merge semantics it does not
have today.

A second writer of the stamp would turn a recorded date into today's;
`InstallRepository.recordInstall` exists for the delete alone.
