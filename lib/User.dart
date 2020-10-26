import 'package:shared_preferences/shared_preferences.dart';

import 'DBHandler.dart';

class User{

  //Get the user's credentials stored in SharedPreferences
  static Future<List> getUserCredentials() async {
    List<String> userCreds = new List();
    final prefs = await SharedPreferences.getInstance();
    userCreds.add(prefs.getString("EMAIL"));
    userCreds.add(prefs.getString("PASSWORD"));
    return userCreds;
  }

  //User logout handler
  static Future<bool> userLogout() async {
    final prefs = await SharedPreferences.getInstance();
    bool res = await prefs.clear();
    await DBProvider.db.deleteAll();
    return res;
  }

}