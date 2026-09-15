import 'package:brew_path/core/widgets/smallcaps_label.dart';
import 'package:brew_path/features/saved/domain/saved_shelf.dart';
import 'package:brew_path/features/saved/presentation/saved_row.dart';
import 'package:flutter/material.dart';

/// One heading and its rows.
///
/// The count rides **in** the label — `DICTIONARY TERMS · 6` — rather than
/// following it as a loose digit in a type style of its own. Only built for a
/// non-empty group: "hidden when empty" is a property of the derivation, not
/// a rule this widget remembers.
class SavedGroupSection extends StatelessWidget {
  /// Creates a [SavedGroupSection] for [group].
  const SavedGroupSection({
    required this.group,
    required this.onOpen,
    this.trailing,
    super.key,
  });

  /// The group to draw.
  final SavedGroup group;

  /// Opens the thing a row names.
  final void Function(SavedItem item) onOpen;

  /// A route belonging to this group, right-aligned opposite the label.
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            // The label takes the room and gives first: a fixed-width pill
            // opposite it must never push the row past its edge.
            Expanded(
              child: SmallcapsLabel(
                '${group.label} · ${group.items.length}',
                isHeader: true,
              ),
            ),
            ?trailing,
          ],
        ),
        for (final item in group.items)
          SavedRow(item: item, onOpen: () => onOpen(item)),
      ],
    );
  }
}
