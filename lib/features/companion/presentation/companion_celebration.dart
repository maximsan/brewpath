import 'package:brew_path/features/companion/application/companion_providers.dart';
import 'package:brew_path/features/companion/domain/companion_reaction.dart';
import 'package:brew_path/features/companion/presentation/companion.dart';
import 'package:brew_path/features/companion/presentation/companion_bubble.dart';
import 'package:brew_path/features/companion/presentation/companion_handle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Lays out a celebrating companion and the line it is saying.
///
/// [line] is null until the authored lines load, and for a reaction none are
/// written for.
typedef CompanionCelebrationBuilder =
    Widget Function(BuildContext context, Widget companion, String? line);

/// A companion that plays [reaction] once, says its line, and cleans up after
/// itself.
///
/// Five surfaces wanted the same four things — a handle to own and dispose, a
/// reaction fired exactly once after the first frame, a speech line resolved
/// once, and a widget to show — and each had written them out again. Only the
/// layout ever really differed, which is what [builder] is for.
///
/// The reaction fires once per mount, not once per [reaction] value: a moment
/// that remounts (a fresh mini-game run, say) celebrates again, which is the
/// behaviour every call site already had.
class CompanionCelebration extends ConsumerStatefulWidget {
  /// Creates a [CompanionCelebration].
  const CompanionCelebration({
    required this.reaction,
    this.builder,
    this.size,
    super.key,
  });

  /// The one-shot the companion plays when this mounts.
  final CompanionReaction reaction;

  /// How to arrange the companion and its line. Defaults to the companion in
  /// its speech bubble, which is what most moments want; a surface that lays
  /// them out differently — or wants no bubble at all — passes its own.
  final CompanionCelebrationBuilder? builder;

  /// Rendered size, forwarded to the companion.
  final double? size;

  @override
  ConsumerState<CompanionCelebration> createState() =>
      _CompanionCelebrationState();
}

class _CompanionCelebrationState extends ConsumerState<CompanionCelebration> {
  final CompanionHandle _handle = CompanionHandle();
  String? _line;
  bool _reacted = false;

  @override
  void dispose() {
    _handle.dispose();
    super.dispose();
  }

  /// After the first frame, so the companion is mounted and can schedule its
  /// own revert back to the ambient mood.
  void _reactOnce() {
    if (_reacted) return;
    _reacted = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _handle.react(widget.reaction);
    });
  }

  @override
  Widget build(BuildContext context) {
    // Held once resolved: re-reading on every build would re-roll the random
    // variant and change the line mid-moment.
    _line ??= ref
        .watch(companionLinesProvider)
        .asData
        ?.value
        .lineFor(widget.reaction);
    _reactOnce();

    final companion = widget.size == null
        ? Companion(handle: _handle)
        : Companion(handle: _handle, size: widget.size!);
    final builder = widget.builder ?? _bubbled;
    return builder(context, companion, _line);
  }

  static Widget _bubbled(
    BuildContext context,
    Widget companion,
    String? line,
  ) => line == null ? companion : CompanionBubble(text: line, child: companion);
}
