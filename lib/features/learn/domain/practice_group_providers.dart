import 'package:brew_path/features/learn/domain/practice_group.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'practice_group_providers.g.dart';

/// Which practice groups are open on the Today tab.
///
/// Held outside the group's widget because two things move it: the header's
/// tap, and Keep Sharp's Start from the card above. Kept alive so the answer
/// survives the list unmounting a group scrolled far off-screen; never
/// stored, so both groups are shut on every launch, as the design has them.
@Riverpod(keepAlive: true)
class OpenPracticeGroups extends _$OpenPracticeGroups {
  @override
  Set<PracticeGroupKind> build() => const {};

  /// Opens [group], and leaves it open if it already was.
  void open(PracticeGroupKind group) => state = {...state, group};

  /// Shuts [group] if it is open, opens it otherwise.
  void toggle(PracticeGroupKind group) => state = state.contains(group)
      ? {
          for (final open in state)
            if (open != group) open,
        }
      : {...state, group};
}
