/// Abstract Remote Config accessor. Feature code reads flags through this —
/// never via `FirebaseRemoteConfig.instance` directly.
abstract class RemoteConfigService {
  /// Fetches the latest config and activates it.
  Future<void> fetchAndActivate();

  /// Returns the string value for [key] (empty if unset).
  String getString(String key);

  /// Returns the bool value for [key] (false if unset).
  bool getBool(String key);

  /// Returns the int value for [key] (0 if unset).
  int getInt(String key);

  /// Returns the double value for [key] (0 if unset).
  double getDouble(String key);
}
