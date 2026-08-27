import 'package:brew_path/core/widgets/smallcaps_label.dart';
import 'package:flutter/material.dart';

/// The smallcaps label that introduces a list section.
///
/// A name for the role, not a second type rule: the lettering is
/// [SmallcapsLabel]'s. This exists so the four screens that raise a section —
/// Learn, Cards, module detail and dictionary home — say *section header*
/// rather than each reaching for the label widget directly, and so a section
/// can later gain spacing or a trailing count in one place.
class SectionHeader extends StatelessWidget {
  /// Creates a [SectionHeader].
  const SectionHeader(this.title, {super.key});

  /// The section heading text. Rendered uppercase, like every smallcaps.
  final String title;

  @override
  Widget build(BuildContext context) => SmallcapsLabel(title);
}
