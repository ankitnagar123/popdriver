import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesCrDriver{

  String LOGIN_KEY = "LOGIN_KEY";
  String USER_ID  = "USER_ID";
  String ON_BOARDING_KEY = "ON_BOARDING_KEY";
  String UU_ID = "UU_ID";
  String LANGUAGE = "LANGUAGE";
  String USER_NAME = "USER_NAME";
  String INVITE_CODE = "INVITE_CODE";
  String ACCESS_TOKEN = "ACCESS_TOKEN";
  String LOGIN_DEVICE_KEY = "LOGIN_DEVICE_KEY";
  String DRIVER_ONLINE_STATUS = "DRIVER_ONLINE_STATUS";
  String Token = "Token";

  String MOBILE_NO = "MOBILE_NO";
  String PASSWORD = "PASSWORD";
  String FLAG = "FLAG";
  String COUNTRY_CODE = "COUNTRY_CODE";
  String INSTALLATION_ID = "INSTALLATION_ID";
  String TOKEN_EXPIRES_AT = "TOKEN_EXPIRES_AT";



  Future<void> clearDataExceptLoginFields() async {
    SharedPreferences sp = await SharedPreferences.getInstance();

    // List of keys to keep
    List<String> keysToKeep = [
      MOBILE_NO,
      PASSWORD,
      FLAG,
      COUNTRY_CODE,
      INSTALLATION_ID,
    ];

    // Get all saved keys
    Set<String> allKeys = sp.getKeys();

    // Remove all keys except those in keysToKeep
    for (String key in allKeys) {
      if (!keysToKeep.contains(key)) {
        await sp.remove(key);
      }
    }
  }
  Future<void> setBoolValue(String key, bool value) async {
    final SharedPreferences sp = await SharedPreferences.getInstance();
    await sp.setBool(key, value);
  }

 Future<bool?> getBoolValue(String key)async{
    SharedPreferences sp = await SharedPreferences.getInstance();
    return sp.getBool(key);
}

 Future<void> setStringValue(String key, String value) async {
    final SharedPreferences sp = await SharedPreferences.getInstance();
    await sp.setString(key, value);
}

 Future<String?> getStringValue(String key)async{
    SharedPreferences sp = await SharedPreferences.getInstance();
    return sp.getString(key);
}

  Future<void> clearData() async {
    final SharedPreferences sp = await SharedPreferences.getInstance();
    await sp.clear();
  }

}


class SecureStorageService {
  String user_id = "user_id";
  String user_name = "user_name";
  String Token = "Token";

  static const _sessionKeys = ['user_id', 'user_name', 'Token'];

  SecureStorageService._internal();

  static final SecureStorageService _instance = SecureStorageService._internal();

  factory SecureStorageService() {
    return _instance;
  }

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<SharedPreferences> _prefs() => SharedPreferences.getInstance();

  /// Web over plain HTTP cannot use [FlutterSecureStorage] (secure context).
  /// SharedPreferences keeps login/signup and session reads working on web.
  Future<void> writeData(String key, String value) async {
    if (kIsWeb) {
      await (await _prefs()).setString(key, value);
      return;
    }
    await _storage.write(key: key, value: value);
  }

  Future<String?> readData(String key) async {
    if (kIsWeb) {
      return (await _prefs()).getString(key);
    }
    return _storage.read(key: key);
  }

  Future<void> deleteData(String key) async {
    if (kIsWeb) {
      await (await _prefs()).remove(key);
      return;
    }
    await _storage.delete(key: key);
  }

  Future<bool> hasSession() async {
    final token = await readData(Token) ?? '';
    final id = await readData(user_id) ?? '';
    return token.isNotEmpty && id.isNotEmpty;
  }

  Future<void> deleteAllData() async {
    if (kIsWeb) {
      final prefs = await _prefs();
      for (final key in _sessionKeys) {
        await prefs.remove(key);
      }
      return;
    }
    await _storage.deleteAll();
  }
}
