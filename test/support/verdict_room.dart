import 'package:brew_path/core/widgets/answer_feedback.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// The room the verdict block leaves above itself, which it owns rather than
/// its host. Its outermost widget is that padding, so the first one down.
double roomAboveVerdict(WidgetTester tester) => tester
    .widget<Padding>(
      find
          .descendant(
            of: find.byType(AnswerFeedback),
            matching: find.byType(Padding),
          )
          .first,
    )
    .padding
    .resolve(TextDirection.ltr)
    .top;
