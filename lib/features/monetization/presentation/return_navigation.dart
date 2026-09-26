import 'package:brew_path/core/constants/app_routes.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

/// Leaving a selling route for the screen it was raised on.
extension ReturnNavigation on BuildContext {
  /// Goes to [location], or to Learn when the route named nowhere to return.
  void goBackTo(String? location) {
    if (location == null) {
      goNamed(AppRoutes.learn.name);
    } else {
      go(location);
    }
  }
}
