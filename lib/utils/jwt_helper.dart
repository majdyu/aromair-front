import 'dart:convert';

class JwtHelper {
  const JwtHelper._();

  /// Strict decode: throws on malformed token / payload
  static Map<String, dynamic> decode(String token) {
    final parts = token.split('.');
    if (parts.length != 3) {
      throw const FormatException('JWT must have 3 parts');
    }
    final normalized = base64Url.normalize(parts[1]);
    try {
      final jsonStr = utf8.decode(base64Url.decode(normalized));
      final obj = json.decode(jsonStr);
      if (obj is Map<String, dynamic>) return obj;
      throw const FormatException('JWT payload is not a JSON object');
    } on FormatException catch (e) {
      throw FormatException('Invalid base64/JSON in payload: $e');
    }
  }

  /// Soft decode: returns null on any failure
  static Map<String, dynamic>? tryDecode(String token) {
    try {
      return decode(token);
    } catch (_) {
      return null;
    }
  }

  /// Generic claim accessor with light coercions
  static T? claim<T>(String token, String key) {
    final m = tryDecode(token);
    final v = m?[key];
    if (v == null) return null;
    if (v is T) return v;
    if (T == String) return v.toString() as T;
    if (T == int) return int.tryParse('$v') as T?;
    if (T == double) return double.tryParse('$v') as T?;
    if (T == bool) {
      final s = '$v'.toLowerCase();
      if (s == 'true' || s == '1') return true as T;
      if (s == 'false' || s == '0') return false as T;
    }
    return null;
  }

  // Convenience getters
  static String? sub(String token) => claim<String>(token, 'sub');
  static String? role(String token) => claim<String>(token, 'role');
  static int? id(String token) {
    final raw = claim<dynamic>(token, 'id');
    if (raw is int) return raw;
    return int.tryParse('$raw');
  }

  /// exp in seconds since epoch (UTC), or null if missing
  static int? expSeconds(String token) {
    final v = claim<dynamic>(token, 'exp');
    if (v is int) return v;
    if (v is double) return v.toInt();
    return int.tryParse('$v');
  }

  static bool isExpired(String token, {int clockToleranceSec = 0}) {
    final exp = expSeconds(token);
    if (exp == null) return false;
    final nowSec = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    return nowSec > (exp + clockToleranceSec);
  }

  static Duration? timeLeft(String token, {int clockToleranceSec = 0}) {
    final exp = expSeconds(token);
    if (exp == null) return null;
    final nowSec = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    return Duration(seconds: (exp + clockToleranceSec) - nowSec);
  }
}
