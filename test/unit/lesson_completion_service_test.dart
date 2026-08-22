import 'package:brew_path/core/utils/date_utils.dart';
import 'package:brew_path/features/lessons/domain/lesson_completion_service.dart';
import 'package:brew_path/features/lessons/domain/lesson_finish_result.dart';
import 'package:brew_path/features/progress/domain/mastery.dart';
import 'package:brew_path/features/progress/domain/tree_frames.dart';
import 'package:brew_path/services/analytics/noop_analytics_service.dart';
import 'package:brew_path/shared/models/coffee_card_model.dart';
import 'package:brew_path/shared/repositories/card_repository.dart';
import 'package:brew_path/shared/repositories/content_repository.dart';
import 'package:brew_path/shared/repositories/progress_repository.dart';
import 'package:brew_path/shared/repositories/snapshot_repository.dart';
import 'package:brew_path/shared/storage/app_database.dart';
import 'package:brew_path/shared/storage/snapshot/daily_activity.dart';
import 'package:brew_path/shared/storage/snapshot/snapshot_scopes.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

/// The lessons a module holds, asked of the course rather than restated here —
/// a roster spelled out in a test goes stale the first time content grows.
Future<List<String>> _moduleLessonIds(
  ContentRepository content,
  String moduleId,
) async {
  final modules = await content.getModules();
  return modules.firstWhere((m) => m.id == moduleId).lessonIds;
}

/// The real course with every module's Module Reward card removed from the
/// bank.
class _NoModuleRewardContent extends ContentRepository {
  @override
  Future<List<CoffeeCardModel>> getCards() async =>
      (await super.getCards()).where((card) => card.lessonId != null).toList();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late LessonCompletionService service;
  late ContentRepository content;
  late ProgressRepository progress;
  late CardRepository cards;
  late SnapshotRepository snapshots;

  setUp(() async {
    db = AppDatabase(NativeDatabase.memory());
    AppDatabaseService.instance = db;

    content = ContentRepository();
    progress = ProgressRepository();
    cards = CardRepository();
    snapshots = SnapshotRepository();
    service = LessonCompletionService(
      progressRepository: progress,
      cardRepository: cards,
      contentRepository: content,
      snapshotRepository: snapshots,
      analyticsService: const NoOpAnalyticsService(),
    );
  });

  tearDown(() async {
    await db.close();
  });

  /// What the learner has banked, summed off the completion records the way
  /// the derived total does. Nothing stores a running counter any more, so
  /// this is the whole ledger a lesson leaves behind.
  Future<int> bankedPoints() async => (await progress.getAllCompleted())
      .fold<int>(0, (sum, record) => sum + record.xpEarned);

  /// The snapshot's day set — what the streak is derived from. Nothing stores
  /// a streak count any more, so this is the whole record a completion leaves.
  Future<Set<int>> activeDays() async =>
      (await snapshots.read()).clearedByReset.activeDays;

  Future<Set<String>> entriesOn(DateTime when) async =>
      (await snapshots.read()).clearedByReset.dailyActivity[epochDay(when)] ??
      const {};

  // The defect #188 closes: which path a run takes must come from the progress
  // store, never from the caller. Before this, a finished lesson reached
  // without the replay marker returned before recording anything at all.
  group('the path is derived, not asserted by the caller', () {
    // Pinned, so a run started before midnight and asserted after it cannot
    // fail — the bug class this file already shipped once.
    final at = DateTime(2026, 8, 20, 12);

    test(
      'a finished lesson reached as a fresh run still records its day',
      () async {
        final lesson = (await content.getLessonById('m1l1'))!;
        await service.finishLesson(
          lesson,
          mastery: const MasteryResult(correct: 3, total: 5),
          now: at,
        );
        // Wipe the day set, keeping the completion record: the state a learner
        // is in the day after finishing, opening the lesson again.
        await snapshots.write(
          (await snapshots.read()).copyWith(
            clearedByReset: ClearedByReset.empty,
          ),
        );

        await service.finishLesson(
          lesson,
          mastery: const MasteryResult(correct: 4, total: 5),
          now: at,
        );

        expect(await activeDays(), {epochDay(at)});
      },
    );

    test('and is recorded as a replay, not a first completion', () async {
      final lesson = (await content.getLessonById('m1l1'))!;
      await service.finishLesson(
        lesson,
        mastery: const MasteryResult(correct: 3, total: 5),
        now: at,
      );

      final second = await service.finishLesson(
        lesson,
        mastery: const MasteryResult(correct: 4, total: 5),
        now: at,
      );

      expect(second.isReplay, isTrue);
      expect(
        (await entriesOn(at)).map((e) => parseActivityEntry(e).type),
        containsAll([ActivityType.lesson, ActivityType.replay]),
      );
    });
  });

  group('finishing a lesson for the first time', () {
    test(
      'first completion persists progress, points, card, streak and score',
      () async {
        final at = DateTime(2026, 8, 20, 12);
        final lesson = (await content.getLessonById('m1l1'))!;
        final result = await service.finishLesson(
          lesson,
          mastery: const MasteryResult(correct: 4, total: 5),
          now: at,
        );

        // A lesson pays the flat ten it authors.
        expect(result.pointsEarned, 10);
        expect(result.moduleCompleted, isFalse);
        expect(result.moduleCard, isNull);
        expect(await bankedPoints(), 10);
        expect(await cards.isCardCollected('c1'), isTrue);
        expect(await activeDays(), {epochDay(at)});
        expect(
          (await entriesOn(at)).map((e) => parseActivityEntry(e).type),
          [ActivityType.lesson],
        );

        final record = (await progress.getByLessonId('m1l1'))!;
        expect(record.isCompleted, isTrue);
        expect(record.mastery, const MasteryResult(correct: 4, total: 5));
      },
    );

    test('replaying a completed lesson re-awards nothing', () async {
      final lesson = (await content.getLessonById('m1l1'))!;
      await service.finishLesson(
        lesson,
        mastery: const MasteryResult(correct: 4, total: 5),
      );
      final replay = await service.finishLesson(
        lesson,
        mastery: const MasteryResult(correct: 4, total: 5),
      );

      expect(replay.isReplay, isTrue);
      expect(replay.pointsEarned, 0, reason: 'the lesson pays once, ever');
      expect((await progress.getAllCompleted()).length, 1);
      // Nothing at all. Replays used to pay a once-a-day practice reward,
      // which §5.1's "replays pay 0" never allowed and which was farmable
      // past the whole course's worth in five days (#16).
      expect(await bankedPoints(), 10);
    });

    test(
      'finishing every lesson in a module pays for the lessons and no more',
      () async {
        final ids = await _moduleLessonIds(content, 'm1');
        late LessonFinishResult last;
        for (final id in ids) {
          last = await service.finishLesson(
            (await content.getLessonById(id))!,
            mastery: const MasteryResult(correct: 5, total: 5),
          );
        }

        expect(last.moduleCompleted, isTrue);
        // The lessons, at a flat ten each. The module itself pays nothing —
        // a bonus double-counts lessons already paid, which re-couples points
        // to structure after the design separated them (§5.1, #16).
        expect(await bankedPoints(), ids.length * 10);
      },
    );

    test('finishing a module hands over its Module Reward card', () async {
      final ids = await _moduleLessonIds(content, 'm1');
      late LessonFinishResult last;
      for (final id in ids) {
        last = await service.finishLesson(
          (await content.getLessonById(id))!,
          mastery: const MasteryResult(correct: 5, total: 5),
        );
      }

      final moduleReward = await content.getCardForModule('m1');
      expect(moduleReward, isNotNull);
      expect(last.moduleCard?.id, moduleReward!.id);
      expect(await cards.isCardCollected(moduleReward.id), isTrue);
    });

    test('a module part-finished hands over no Module Reward card', () async {
      final ids = await _moduleLessonIds(content, 'm1');
      final result = await service.finishLesson(
        (await content.getLessonById(ids.first))!,
        mastery: const MasteryResult(correct: 5, total: 5),
      );

      final moduleReward = (await content.getCardForModule('m1'))!;
      expect(result.moduleCard, isNull);
      expect(await cards.isCardCollected(moduleReward.id), isFalse);
    });

    test(
      'a module with no Module Reward card still reads as complete',
      () async {
        // `moduleCompleted` is its own fact, not "a reward was handed over". A
        // content bank missing a module's card must not make the app report the
        // module unfinished — that would silently cost the recap its routing.
        final bare = _NoModuleRewardContent();
        final service = LessonCompletionService(
          progressRepository: progress,
          cardRepository: cards,
          contentRepository: bare,
          snapshotRepository: snapshots,
          analyticsService: const NoOpAnalyticsService(),
        );

        late LessonFinishResult last;
        for (final id in await _moduleLessonIds(bare, 'm1')) {
          last = await service.finishLesson(
            (await bare.getLessonById(id))!,
            mastery: const MasteryResult(correct: 5, total: 5),
          );
        }

        expect(last.moduleCompleted, isTrue);
        expect(last.moduleCard, isNull);
      },
    );

    test('replaying the module-closing lesson re-hands nothing', () async {
      final ids = await _moduleLessonIds(content, 'm1');
      for (final id in ids) {
        await service.finishLesson(
          (await content.getLessonById(id))!,
          mastery: const MasteryResult(correct: 5, total: 5),
        );
      }
      final banked = await bankedPoints();

      final replay = await service.finishLesson(
        (await content.getLessonById(ids.last))!,
        mastery: const MasteryResult(correct: 5, total: 5),
        now: DateTime(2026, 5, 22),
      );

      expect(replay.moduleCompleted, isFalse);
      expect(replay.moduleCard, isNull);
      expect(await bankedPoints(), banked);
    });
  });

  group('finishing a lesson again', () {
    /// Completes every lesson of `m1`, leaving the module fully done and its
    /// Module Reward card already handed over.
    Future<void> completeBeansModule() async {
      for (final id in await _moduleLessonIds(content, 'm1')) {
        await service.finishLesson(
          (await content.getLessonById(id))!,
          mastery: const MasteryResult(correct: 5, total: 5),
        );
      }
    }

    test(
      'review does not reset completion, banked points, or the earned card',
      () async {
        final lesson = (await content.getLessonById('m1l1'))!;
        await service.finishLesson(
          lesson,
          mastery: const MasteryResult(correct: 3, total: 5),
        );
        final before = (await progress.getByLessonId(lesson.id))!;

        await service.finishLesson(
          lesson,
          mastery: const MasteryResult(correct: 4, total: 5),
          now: DateTime(2026, 5, 22),
        );

        final after = (await progress.getByLessonId(lesson.id))!;
        expect(after.isCompleted, isTrue);
        expect(after.xpEarned, before.xpEarned);
        expect(after.completedAt, before.completedAt);
        expect(await cards.isCardCollected('c1'), isTrue);
      },
    );

    test('a completed replay marks its day active (§3)', () async {
      final lesson = (await content.getLessonById('m1l1'))!;
      await service.finishLesson(
        lesson,
        mastery: const MasteryResult(correct: 3, total: 5),
      );
      final replayDay = DateTime(2026, 5, 22, 9);

      await service.finishLesson(
        lesson,
        mastery: const MasteryResult(correct: 4, total: 5),
        now: replayDay,
      );

      expect(await activeDays(), contains(epochDay(replayDay)));
    });

    test('a second replay the same day does not qualify it twice', () async {
      final lesson = (await content.getLessonById('m1l1'))!;
      await service.finishLesson(
        lesson,
        mastery: const MasteryResult(correct: 3, total: 5),
      );
      final replayDay = DateTime(2026, 5, 22, 9);

      for (var round = 0; round < 2; round++) {
        await service.finishLesson(
          lesson,
          mastery: const MasteryResult(correct: 4, total: 5),
          now: replayDay,
        );
      }

      final snapshot = (await snapshots.read()).clearedByReset;
      expect(
        snapshot.dailyActivity[epochDay(replayDay)],
        hasLength(2),
        reason: 'the free allowance counts two completions',
      );
      expect(
        snapshot.activeDays.where((day) => day == epochDay(replayDay)),
        hasLength(1),
        reason: 'a day is a day — the streak advances once (§2)',
      );
    });

    test('review adds nothing to what the lesson banked', () async {
      final lesson = (await content.getLessonById('m1l1'))!;
      await service.finishLesson(
        lesson,
        mastery: const MasteryResult(correct: 2, total: 5),
      );
      final afterCompletion = await bankedPoints(); // the lesson's flat ten

      await service.finishLesson(
        lesson,
        mastery: const MasteryResult(correct: 2, total: 5),
        now: DateTime(2026, 5, 22),
      );

      expect(await bankedPoints(), afterCompletion);
    });

    test('reviewing inside a completed module pays nothing', () async {
      await completeBeansModule();
      final banked = await bankedPoints();

      final lesson = (await content.getLessonById('m1l1'))!;
      await service.finishLesson(
        lesson,
        mastery: const MasteryResult(correct: 5, total: 5),
        now: DateTime(2026, 5, 22),
      );

      expect(await bankedPoints(), banked);
    });

    test('review improves the stored best score', () async {
      final lesson = (await content.getLessonById('m1l1'))!;
      await service.finishLesson(
        lesson,
        mastery: const MasteryResult(correct: 2, total: 5),
      );

      final result = await service.finishLesson(
        lesson,
        mastery: const MasteryResult(correct: 9, total: 10),
        now: DateTime(2026, 5, 22),
      );

      expect(result.mastery, const MasteryResult(correct: 9, total: 10));
      expect(
        (await progress.getByLessonId(lesson.id))!.mastery,
        const MasteryResult(correct: 9, total: 10),
      );
    });

    test('review never lowers the stored best score', () async {
      final lesson = (await content.getLessonById('m1l1'))!;
      await service.finishLesson(
        lesson,
        mastery: const MasteryResult(correct: 9, total: 10),
      );

      final result = await service.finishLesson(
        lesson,
        mastery: const MasteryResult(correct: 1, total: 5),
        now: DateTime(2026, 5, 22),
      );

      expect(result.mastery, const MasteryResult(correct: 9, total: 10));
      expect(
        (await progress.getByLessonId(lesson.id))!.mastery,
        const MasteryResult(correct: 9, total: 10),
      );
    });
  });

  group('the Coffee Tree grows', () {
    Future<int> storedStage() async =>
        (await snapshots.read()).clearedByReset.treeStage;

    test('a fresh install is at seed, with nothing completed', () async {
      expect(await storedStage(), freshTreeStage);
    });

    test('a first completion advances the stored stage', () async {
      final lessons = await content.getLessons();

      await service.finishLesson(
        lessons.first,
        mastery: const MasteryResult(correct: 1, total: 1),
      );

      expect(await storedStage(), greaterThan(freshTreeStage));
    });

    test('a replay grows nothing', () async {
      final lessons = await content.getLessons();
      await service.finishLesson(
        lessons.first,
        mastery: const MasteryResult(correct: 1, total: 1),
      );
      final afterFirst = await storedStage();

      await service.finishLesson(
        lessons.first,
        mastery: const MasteryResult(correct: 1, total: 1),
      );

      expect(await storedStage(), afterFirst);
    });

    test('finishing every lesson reaches the last stage', () async {
      final lessons = await content.getLessons();
      for (final lesson in lessons) {
        await service.finishLesson(
          lesson,
          mastery: const MasteryResult(correct: 1, total: 1),
        );
      }

      expect(await storedStage(), treeStageCount);
    });

    // The stage is stored as the outcome, so a course that grows later cannot
    // walk a learner's tree back down.
    test('a stage already reached is never lowered by a later write', () async {
      final lessons = await content.getLessons();
      final snapshot = await snapshots.read();
      await snapshots.write(
        snapshot.copyWith(
          clearedByReset: snapshot.clearedByReset.withTreeStageAtLeast(
            treeStageCount,
          ),
        ),
      );

      await service.finishLesson(
        lessons.first,
        mastery: const MasteryResult(correct: 1, total: 1),
      );

      expect(await storedStage(), treeStageCount);
    });

    test('the stage survives a restart', () async {
      final lessons = await content.getLessons();
      await service.finishLesson(
        lessons.first,
        mastery: const MasteryResult(correct: 1, total: 1),
      );
      final grown = await storedStage();

      // A new repository over the same store is what a relaunch looks like.
      expect(
        (await SnapshotRepository().read()).clearedByReset.treeStage,
        grown,
      );
    });
  });
}
