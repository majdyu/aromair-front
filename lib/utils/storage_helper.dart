import 'package:shared_preferences/shared_preferences.dart';

class StorageHelper {
  static Future<void> saveUser(int id, String role, String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt("id", id);
    await prefs.setString("role", role);
    await prefs.setString("token", token);
    print("[StorageHelper] User saved: id=$id, role=$role");
  }

  static Future<Map<String, dynamic>?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getInt("id");
    final role = prefs.getString("role");
    final token = prefs.getString("token");

    print("[StorageHelper] Retrieved from SharedPreferences: id=$id, role=$role, token=$token");

    if (id != null && role != null && token != null) {
      return {"id": id, "role": role, "token": token};
    }
    return null;
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    print("[StorageHelper] SharedPreferences cleared.");
  }
}
