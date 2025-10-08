import 'dart:convert';

import 'package:front_erp_aromair/data/enums/role.dart';

UserRole userRoleFromString(String? v) {
  switch ((v ?? '').toUpperCase()) {
    case 'TECHNICIEN':
      return UserRole.technicien;
    case 'SUPER_ADMIN':
      return UserRole.superAdmin;
    case 'ADMIN':
      return UserRole.admin;
    case 'PRODUCTION':
      return UserRole.production;
    default:
      return UserRole.unknown;
  }
}

String userRoleToString(UserRole r) {
  switch (r) {
    case UserRole.technicien:
      return 'TECHNICIEN';
    case UserRole.superAdmin:
      return 'SUPER_ADMIN';
    case UserRole.admin:
      return 'ADMIN';
    case UserRole.production:
      return 'PRODUCTION';
    case UserRole.unknown:
      return 'UNKNOWN';
  }
}

/// Minimal user model matching the given JSON
class UserItem {
  final int id;
  final String nom;
  final UserRole role;

  const UserItem({required this.nom, required this.role, required this.id});

  UserItem copyWith({String? nom, UserRole? role, int? id}) {
    return UserItem(
      nom: nom ?? this.nom,
      role: role ?? this.role,
      id: id ?? this.id,
    );
  }

  factory UserItem.fromMap(Map<String, dynamic> map) {
    return UserItem(
      nom: (map['nom'] ?? '').toString(),
      role: userRoleFromString(map['role']?.toString()),
      id: (map['id'] ?? 0) as int,
    );
  }

  Map<String, dynamic> toMap() {
    return {'nom': nom, 'role': userRoleToString(role), 'id': id};
  }

  /// Parse one object from a JSON string
  factory UserItem.fromJson(String source) =>
      UserItem.fromMap(json.decode(source) as Map<String, dynamic>);

  /// Encode one object to JSON string
  String toJson() => json.encode(toMap());

  @override
  String toString() => 'UserItem(nom: $nom, role: ${userRoleToString(role)})';

  @override
  bool operator ==(Object other) {
    return other is UserItem &&
        other.nom == nom &&
        other.role == role &&
        other.id == id;
  }

  @override
  int get hashCode => Object.hash(nom, role, id);
}

/// -------- Collection helpers --------

/// Parse a list of users from a decoded JSON array
List<UserItem> usersFromList(List<dynamic> list) {
  return list.map((e) => UserItem.fromMap(e as Map<String, dynamic>)).toList();
}

/// Parse a list of users directly from a JSON string (the array you showed)
List<UserItem> usersFromJson(String jsonArrayString) {
  final decoded = json.decode(jsonArrayString);
  if (decoded is List) {
    return usersFromList(decoded);
  }
  throw const FormatException('Expected a JSON array for users');
}

String usersToJson(List<UserItem> users) {
  return json.encode(users.map((u) => u.toMap()).toList());
}
