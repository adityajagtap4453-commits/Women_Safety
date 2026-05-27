import 'package:shared_preferences/shared_preferences.dart';

class MySharedPrefference {
  static SharedPreferences? _preferences;
  static const String key = 'usertype';

  static init() async {
    _preferences = await SharedPreferences.getInstance();
    return _preferences;
  }

  static Future saveUserType(String type) async {
    return await _preferences!.setString(key, type);
  }

  static String getUserType() {
    return _preferences?.getString(key) ?? "";
  }
}
