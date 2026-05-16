sealed class AppException implements Exception {
  const AppException(this.message);
  final String message;
}

final class ContentLoadException extends AppException {
  const ContentLoadException(super.message);
}

final class PersistenceException extends AppException {
  const PersistenceException(super.message);
}
