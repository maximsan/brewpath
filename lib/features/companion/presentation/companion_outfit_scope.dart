import 'package:brew_path/shared/storage/snapshot/snapshot_values.dart';
import 'package:flutter/widgets.dart';

/// What Roasty is wearing, handed down the tree the way his colours are.
///
/// Ambient rather than a parameter, for the reason `context.mood` is: every
/// Roasty in the app has to wear it, and a widget that reaches the mascot
/// through three hosts cannot be asked to thread it. The app installs one of
/// these at the root; nothing else does.
class CompanionOutfitScope extends InheritedWidget {
  /// Creates a [CompanionOutfitScope].
  const CompanionOutfitScope({
    required this.outfit,
    required super.child,
    super.key,
  });

  /// The outfit every `Roasty` below this draws itself in.
  final CompanionConfig outfit;

  /// What Roasty wears here — the plain bean where no scope is installed.
  ///
  /// Absent is not an error: a widget test that pumps the mascot on its own
  /// gets the undressed mascot, which is what it has always drawn.
  static CompanionConfig of(BuildContext context) =>
      context
          .dependOnInheritedWidgetOfExactType<CompanionOutfitScope>()
          ?.outfit ??
      CompanionConfig.initial;

  @override
  bool updateShouldNotify(CompanionOutfitScope oldWidget) =>
      oldWidget.outfit != outfit;
}
