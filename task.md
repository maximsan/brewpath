Implement completed lesson review and XP rules.

Context:
Completed lessons should be reviewable, but users must not be able to farm full XP or module-completion XP by answering the same questions again.

Requirements:

1. Completed lesson review
   - For completed lessons, show a `Review` button instead of treating the lesson as new.
   - Users must be able to answer the lesson questions again during review.
   - Reviewing a lesson must not reset lesson completion, module progress, unlocks, earned cards, badges, or existing XP.

2. First-completion XP
   - Award full lesson XP only once, on the first successful lesson completion.
   - Store whether full lesson XP has already been awarded for each lesson.
   - Do not award full lesson XP again during review.

3. Module-completion XP
   - Award module-completion XP only once, when the module is completed for the first time.
   - Reviewing lessons inside an already completed module must not award module-completion XP again.
   - Store whether module-completion XP has already been awarded for each module.

4. Review XP
   - By default, review should not give full XP.
   - Optional: allow small practice XP during review, for example `+1` or `+2 XP`.
   - Practice XP must be awarded at most once per lesson per day.
   - Repeating the same review multiple times on the same day must not grant additional XP.
   - Track the last date when practice XP was awarded per lesson.

5. Best score / mastery
   - Track the user’s best score or mastery for each lesson separately from XP.
   - Reviewing a lesson can improve the stored best score/mastery.
   - Reviewing a lesson must never reduce the stored best score/mastery.

Expected behavior:

- New lesson:
  - User completes it for the first time.
  - Full lesson XP is awarded.
  - Lesson is marked as completed.
  - Progress/unlocks are updated if needed.

- Completed lesson:
  - User sees `Review`.
  - User can answer questions again.
  - No full lesson XP is awarded.
  - No module-completion XP is awarded.
  - Best score/mastery can improve.
  - Optional practice XP can be awarded once per lesson per day.

Definition of done:

- Completed lessons display a `Review` action.
- Completed lessons can be answered again.
- Full lesson XP is awarded only once.
- Module-completion XP is awarded only once.
- Review does not reset or corrupt progress.
- Best score/mastery can improve after review.
- Best score/mastery cannot decrease after review.
- Optional practice XP, if enabled, is capped to once per lesson per day.
- Unit tests cover:
  - first lesson completion
  - reviewing a completed lesson
  - preventing duplicate full lesson XP
  - preventing duplicate module XP
  - improving best score during review
  - preventing best score decrease during review
  - practice XP once per lesson per day, if practice XP is implemented
