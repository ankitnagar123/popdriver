/// Firebase Cloud Messaging keys (web push / iOS).
class FirebaseMessagingConfig {
  FirebaseMessagingConfig._();

  /// Web push certificate (Firebase Console → Cloud Messaging → Web).
  static const String webVapidKey =
      'BHreBQojx9IS-mVa2InbgNXqmHCBBUgJH-SnUsiChrum_J_QwvSI0A-Im3W40ge7rIO70PTiARVxE6cOQol10PA';

  /// iOS APNs web push key (existing).
  static const String iosVapidKey =
      'BMnb7_ZxdnVb55eNi0sJRzxoI2QdFGUZrMBgIiL2tlPLcB4NYT4OAnhcJW3BY2F7g0gs-AKFQ-omjP0x5sk7UMc';
}
