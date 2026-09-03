import 'package:uuid/uuid.dart';

import 'shared_preferences.dart';

/// Stable UUID for this app install / browser profile (not FCM token).
class DeviceUtils {
  DeviceUtils._();

  static final DeviceUtils instance = DeviceUtils._();

  final Uuid _uuid = const Uuid();
  final SharedPreferencesCrDriver _sp = SharedPreferencesCrDriver();

  Future<String> getInstallationId() async {
    final existing = await _sp.getStringValue(_sp.INSTALLATION_ID) ?? '';
    if (existing.isNotEmpty) return existing;

    final created = _uuid.v4();
    await _sp.setStringValue(_sp.INSTALLATION_ID, created);
    return created;
  }
}
