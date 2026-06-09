import 'package:flutter/material.dart';

/// Centered error message with an optional retry button.
class ErrorView extends StatelessWidget {
  /// Creates an [ErrorView].
  const ErrorView({required this.message, super.key, this.onRetry});

  /// The error message to display.
  final String message;

  /// Optional retry handler; when non-null a "Retry" button is shown.
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(message, textAlign: TextAlign.center),
          if (onRetry != null) ...[
            const SizedBox(height: 12),
            ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ],
      ),
    );
  }
}
