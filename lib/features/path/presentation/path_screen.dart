import 'package:brew_path/app/tab_large_title.dart';
import 'package:brew_path/core/constants/app_routes.dart';
import 'package:brew_path/core/widgets/error_view.dart';
import 'package:brew_path/core/widgets/loading_indicator.dart';
import 'package:brew_path/core/widgets/smallcaps_label.dart';
import 'package:brew_path/features/path/domain/path_density.dart';
import 'package:brew_path/features/path/domain/path_module_view.dart';
import 'package:brew_path/features/path/domain/path_providers.dart';
import 'package:brew_path/features/path/presentation/path_module_section.dart';
import 'package:brew_path/features/path/presentation/reference_section.dart';
import 'package:brew_path/shared/theme/app_spacing.dart';
import 'package:brew_path/shared/theme/off_token.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Path: the whole course on one screen.
///
/// The course lives here and nowhere else — Learn is today's work, and the
/// module screen this tab used to push is gone (#394). Each module draws at
/// the density its state earns ([PathModuleDensity]); the tab carries its own
/// large title, as every tab root does, with the tally stacked under it.
class PathScreen extends ConsumerStatefulWidget {
  /// Creates a [PathScreen].
  const PathScreen({super.key});

  @override
  ConsumerState<PathScreen> createState() => _PathScreenState();
}

class _PathScreenState extends ConsumerState<PathScreen> {
  /// Which finished modules the learner has opened.
  ///
  /// View state, not progress: it is a reading position, it means nothing on
  /// the next launch, and storing it would put a UI preference in the progress
  /// database. Only completed modules can be in here — the other two densities
  /// are fixed open or shut and have nothing to remember.
  final _expanded = <String>{};

  void _toggle(String moduleId) {
    setState(() {
      if (!_expanded.remove(moduleId)) _expanded.add(moduleId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final modules = ref.watch(pathModulesProvider);

    return Scaffold(
      body: modules.when(
        loading: () => const LoadingIndicator(),
        error: (error, _) => ErrorView(message: '$error'),
        data: (list) => ListView(
          // No room at the top: `TabLargeTitle` leaves it.
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            0,
            AppSpacing.md,
            AppSpacing.md,
          ),
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            TabLargeTitle(
              AppRoutes.path,
              topGap: OffTokens.tabTitleClearOfEntries.value,
            ),
            // The design sets 8 here and on the Cards tab: one stacked label
            // rather than two blocks, so both take the hairline pair's stop.
            const SizedBox(height: AppSpacing.xs),
            _CourseTally(modules: list),
            const SizedBox(height: AppSpacing.lg),
            for (var i = 0; i < list.length; i++)
              PathModuleSection(
                module: list[i],
                isExpanded: _expanded.contains(list[i].id),
                onToggle: () => _toggle(list[i].id),
                previousTitle: i == 0 ? null : list[i - 1].item.module.title,
              ),
            // Last on Path: the course's own appendix, at the end of the thing
            // it summarises, at the design's `marginTop: 12`.
            const SizedBox(height: AppSpacing.sm),
            const ReferenceSection(),
          ],
        ),
      ),
    );
  }
}

/// `{done} of {unlocked} lessons complete`, in smallcaps above the trail.
///
/// No progress bar: the design's Path header has none, because the trail below
/// it already is the progress — a bar would say the same thing twice, less
/// precisely.
class _CourseTally extends StatelessWidget {
  const _CourseTally({required this.modules});

  final List<PathModule> modules;

  @override
  Widget build(BuildContext context) {
    final summary = pathCourseSummary([
      for (final module in modules) module.item,
    ]);

    return SmallcapsLabel(summary.label);
  }
}
