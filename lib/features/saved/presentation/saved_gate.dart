import 'package:brew_path/features/saved/domain/saved_cap.dart';
import 'package:flutter/material.dart';

/// What a free learner is told when their shelf is full.
///
/// **One call site, deliberately.** The Plus gate sheet is specified and
/// ticketed (#89) but not built; until it is, the refusal has to say something
/// rather than nothing — a tap that silently fails is a mystery, and this is
/// the only place a free learner meets the paywall's concrete pitch. When the
/// sheet lands it replaces the body of this function and nothing else in the
/// feature changes.
///
/// Copy reads as an offer, not an error: the shelf is full, and Plus makes it
/// unlimited.
void showSavedCapReached(BuildContext context) {
  ScaffoldMessenger.maybeOf(context)?.showSnackBar(
    const SnackBar(content: Text(savedCapMessage)),
  );
}

/// The refusal, named so a test can assert it without re-spelling it.
const String savedCapMessage =
    'Your shelf is full at $savedFreeMax. BrewPath Plus makes it unlimited.';
