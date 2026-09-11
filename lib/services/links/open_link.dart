import 'package:brew_path/services/links/link_provider.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// What a link does, or null when it has nowhere to go yet.
///
/// Null is the whole point: a control handed it is disabled, so a destination
/// that does not exist cannot be drawn live and inert.
VoidCallback? openOr(WidgetRef ref, Uri? target) =>
    target == null ? null : () => ref.read(linkOpenerProvider).open(target);
