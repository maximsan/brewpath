import 'package:flutter/material.dart';

/// What a free learner is told when they try the Studio door.
///
/// **One call site, deliberately** — the same shape as `saved_gate.dart`, and
/// for the same reason. The Plus gate sheet is specified and ticketed
/// ([#89](https://github.com/maximsan/brewpath/issues/89)) but not built;
/// until it is, the refusal has to say something rather than nothing, because
/// a tap that silently fails is a mystery. When the sheet lands it replaces
/// the body of this function and nothing else in the feature changes.
///
/// Copy reads as an offer, not an error: the grove exists, and Plus opens it.
void showStudioLocked(BuildContext context) {
  ScaffoldMessenger.maybeOf(context)
    ?..hideCurrentSnackBar()
    ..showSnackBar(const SnackBar(content: Text(studioLockedMessage)));
}

/// The refusal, named so a test can assert it without re-spelling it.
const String studioLockedMessage =
    'Your grove is part of BrewPath Plus. Three plants, four lights.';
