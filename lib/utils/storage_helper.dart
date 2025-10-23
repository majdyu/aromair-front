import 'package:shared_preferences/shared_preferences.dart';

class StorageHelper {
  static const _kId = "id";
  static const _kRole = "role";
  static const _kToken = "token";
  static const _kName = "name";

  static Future<void> saveUser(
    int id,
    String role,
    String token, {
    String? name,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kId, id);
    await prefs.setString(_kRole, role);
    await prefs.setString(_kToken, token);
    if (name != null) {
      await prefs.setString(_kName, name);
    }
    // debug print ok
  }

  static Future<void> saveUserName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kName, name);
  }

  static Future<String?> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kName);
  }

  static Future<Map<String, dynamic>?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getInt(_kId);
    final role = prefs.getString(_kRole);
    final token = prefs.getString(_kToken);
    final name = prefs.getString(_kName);
    if (id != null && role != null && token != null) {
      return {"id": id, "role": role, "token": token, "name": name};
    }
    return null;
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
