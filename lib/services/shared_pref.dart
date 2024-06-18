import 'package:shared_preferences/shared_preferences.dart';

class SharedpreferenceHelper{ 
  static String userIdKey = "USERIDKEY";
  static String userEmailKey = "USEREMAILKEY";
  static String userTokenKey = "USERTOKENKEY";

  Future<bool> saveUserId (String getUserId) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(userIdKey, getUserId);
  }

  Future<bool> saveUserEmail (String getUserEmail) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(userEmailKey, getUserEmail);
  }

  Future<bool> saveUserToken (String getUserToken) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(userTokenKey, getUserToken);
  }

  Future<String> getUserId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(userIdKey).toString();
  }

  Future<String> getUserEmail() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(userEmailKey).toString();
  }

  Future<String> getUserToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(userTokenKey).toString();
  }
}