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



  Future<void> clearDataExceptLoginFields() async {
    SharedPreferences sp = await SharedPreferences.getInstance();

    // List of keys to keep
    List<String> keysToKeep = [
      MOBILE_NO,
      PASSWORD,
      FLAG,
      COUNTRY_CODE,
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
  void setBoolValue(String key,bool value)async{
    SharedPreferences sp = await SharedPreferences.getInstance();
    sp.setBool(key, value);
  }

 Future<bool?> getBoolValue(String key)async{
    SharedPreferences sp = await SharedPreferences.getInstance();
    return sp.getBool(key);
}

 void setStringValue(String key,String value)async{
    SharedPreferences sp = await SharedPreferences.getInstance();
    sp.setString(key, value);
}

 Future<String?> getStringValue(String key)async{
    SharedPreferences sp = await SharedPreferences.getInstance();
    return sp.getString(key);
}

  void  clearData() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    await sp.clear();
  }

}


class SecureStorageService {
  String user_id  = "user_id";
  String user_name  = "user_name";
  String Token = "Token";
  // Create a private constructor
  SecureStorageService._internal();

  // Create a static instance of the class
  static final SecureStorageService _instance = SecureStorageService._internal();

  // Factory constructor to return the same instance every time
  factory SecureStorageService() {
    return _instance;
  }

  // Create a FlutterSecureStorage instance
  final FlutterSecureStorage _storage = FlutterSecureStorage();

  // Method to write data
  Future<void> writeData(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  // Method to read data
  Future<String?> readData(String key) async {
    return await _storage.read(key: key);
  }

  // Method to delete data
  Future<void> deleteData(String key) async {
    await _storage.delete(key: key);
  }

  // Method to delete all data
  Future<void> deleteAllData() async {
    await _storage.deleteAll();
  }

}
