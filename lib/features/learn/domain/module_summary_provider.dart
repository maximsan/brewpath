import 'package:brew_path/shared/models/coffee_card_model.dart';
import 'package:brew_path/shared/models/module_model.dart';
import 'package:brew_path/shared/repositories/content_repository.dart';
import 'package:brew_path/shared/repositories/repository_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'module_summary_provider.g.dart';

/// What the module ending needs: the module, the card it paid out, and where
/// the learner goes next.
///
/// **No points total.** It used to carry the module's summed lesson points plus
/// a completion bonus, and the recap screen led with that number. The module
/// pays nothing (§5.1, #16), and the number it showed double-counted lessons
/// already paid — so the field is gone rather than computed and ignored.
class ModuleSummary {
  /// Creates a [ModuleSummary].
  const ModuleSummary({
    required this.module,
    this.moduleReward,
    this.nextLessonId,
  });

  /// The completed module.
  final ModuleModel module;

  /// The module's own Module Reward card — the recap's reward — or null when it
  /// has not been collected.
  final CoffeeCardModel? moduleReward;

  /// The first lesson of the module that follows, or null at the end of the
  /// course.
  ///
  /// It is the id rather than a flag because the ending's action both *reads*
  /// *Begin next module* and **goes there** — a label naming a destination the
  /// code does not open is worse than the plain one it replaced.
  ///
  /// Whether that lesson is actually open to this learner is the router's
  /// question, not this screen's: the redirect owns gate→destination.
  final String? nextLessonId;

  /// Whether a module follows this one — the ending's action reads *Begin next
  /// module* where one does and *Back to Path* where none does
  /// (`rewards.jsx:340`).
  bool get hasNextModule => nextLessonId != null;
}

/// Builds the [ModuleSummary] for [moduleId] by joining content (module +
/// cards) with persisted progress (collected cards).
@riverpod
Future<ModuleSummary> moduleSummary(Ref ref, String moduleId) async {
  // Every watch resolved before the first await: a rebuild mid-flight must not
  // find a watch on the far side of an async gap.
  final content = ref.watch(contentRepositoryProvider);
  final snapshots = ref.watch(snapshotRepositoryProvider);
  final modules = await content.getModules();
  final module = modules.firstWhere((m) => m.id == moduleId);

  // Position, not list order: the course is numbered, and a bank that ever
  // ships out of order must not decide what "next" means.
  final later = modules.where((m) => m.n > module.n).toList()
    ..sort((a, b) => a.n.compareTo(b.n));
  final nextLessonId = later.firstOrNull?.lessonIds.firstOrNull;

  final collectedIds =
      (await snapshots.read()).clearedByReset.ownedCollectibles;
  final moduleReward = await content.getCardForModule(moduleId);

  return ModuleSummary(
    module: module,
    nextLessonId: nextLessonId,
    moduleReward: moduleReward != null && collectedIds.contains(moduleReward.id)
        ? moduleReward
        : null,
  );
}

/// What the run that closed the module paid out.
///
/// The design branches on a module's last lesson, so that lesson's own ending
/// never plays (#458) — and the lesson still paid its points. This is what the
/// module ending reports on its behalf.
///
/// **Points only.** The closing lesson's own collectible used to travel here
/// too, and the ending listed it. The restyled ending has no list: it reports
/// the points and the freeze, and its one card is the module's, on the other
/// face.
///
/// That leaves the lesson's own card earned and never shown — five times
/// across the course, once per module. It is still collected, and still on the
/// Cards tab; what is missing is the beat. Deliberate rather than overlooked:
/// the design has no slot for it, and the app is not inventing a second
/// answer. Written down at
/// [#504](https://github.com/maximsan/brewpath/issues/504), which is blocked
/// on the design source.
typedef ModuleEndingRun = ({int pointsEarned});

/// A run that paid nothing, for a module ending opened outside the flow — a
/// review, or a deep link. It claims nothing about a run that did not happen.
const ModuleEndingRun noModuleEndingRun = (pointsEarned: 0);

/// What [lessonId] paid, for the module ending to report.
///
/// Content only: the lesson's authored points.
@riverpod
Future<ModuleEndingRun> moduleEndingRun(Ref ref, String? lessonId) async {
  if (lessonId == null) return noModuleEndingRun;
  final content = ref.watch(contentRepositoryProvider);
  final lesson = await content.getLessonById(lessonId);
  if (lesson == null) return noModuleEndingRun;
  return (pointsEarned: lesson.points);
}
