import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefHelper {
  static const String isLoggedInKey = "is_logged_in";

  // Save bool value
  static Future<void> setLoginStatus(bool value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(isLoggedInKey, value);
  }

  // Get bool value (default: false)
  static Future<bool> getLoginStatus() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(isLoggedInKey) ?? false;
  }

  // Clear only login status
  static Future<void> clearLoginStatus() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(isLoggedInKey);
    //await prefs.clear();
  }
}
