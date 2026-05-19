/// Abstract Remote Config accessor. Feature code reads flags through this —
/// never via `FirebaseRemoteConfig.instance` directly.
abstract class RemoteConfigService {
  Future<void> fetchAndActivate();
  String getString(String key);
  bool getBool(String key);
  int getInt(String key);
  double getDouble(String key);
}
