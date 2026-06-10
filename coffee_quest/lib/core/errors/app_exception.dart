/// Base type for app-domain exceptions.
sealed class AppException implements Exception {
  /// Creates an [AppException] with a human-readable [message].
  const AppException(this.message);

  /// Human-readable error message.
  final String message;
}

/// Thrown when bundled content fails to load or parse.
final class ContentLoadException extends AppException {
  /// Creates a [ContentLoadException].
  const ContentLoadException(super.message);
}

/// Thrown when a persistence (Drift) operation fails.
final class PersistenceException extends AppException {
  /// Creates a [PersistenceException].
  const PersistenceException(super.message);
}
