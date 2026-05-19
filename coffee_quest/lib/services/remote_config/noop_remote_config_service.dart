import 'package:coffee_quest/services/remote_config/remote_config_keys.dart';
import 'package:coffee_quest/services/remote_config/remote_config_service.dart';

/// Returns the MVP defaults — the default until Firebase is activated, and the
/// impl used by tests. Mirrors the defaults the Firebase impl seeds.
class NoOpRemoteConfigService implements RemoteConfigService {
  const NoOpRemoteConfigService();

  static const Map<String, Object> _defaults = {
    RemoteConfigKeys.forceUpdateMinVersion: '0.0.0',
    RemoteConfigKeys.dailyLessonGoal: 1,
    RemoteConfigKeys.enableCardAnimations: false,
  };

  @override
  Future<void> fetchAndActivate() async {}

  @override
  String getString(String key) {
    final v = _defaults[key];
    return v is String ? v : '';
  }

  @override
  bool getBool(String key) {
    final v = _defaults[key];
    return v is bool ? v : false;
  }

  @override
  int getInt(String key) {
    final v = _defaults[key];
    return v is int ? v : 0;
  }

  @override
  double getDouble(String key) {
    final v = _defaults[key];
    return v is double ? v : 0;
  }
}
