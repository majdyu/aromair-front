import 'package:front_erp_aromair/data/models/user.dart';
import 'package:front_erp_aromair/data/services/user_service.dart';
import 'package:front_erp_aromair/data/enums/role.dart';

class UserRepository {
  final UserService svc;
  UserRepository(this.svc);

  Future<List<UserItem>> list() async {
    final raw = await svc.getListUser();
    return usersFromList(raw);
  }

  Future<UserItem> updateUser({
    required int id,
    required String nom,
    required UserRole role,
    String? password,
  }) async {
    final body = <String, dynamic>{
      'nom': nom,
      'role': userRoleToString(role), // -> "SUPER_ADMIN", "TECHNICIEN", ...
      if (password != null && password.isNotEmpty) 'password': password,
    };

    final raw = await svc.updateUser(id: id, body: body);
    return UserItem.fromMap(raw);
  }

  Future<UserItem> createUser({
    required String nom,
    required UserRole role,
    String? password,
  }) async {
    final body = <String, dynamic>{
      'firstname': nom,
      'role': userRoleToString(role),
      if (password != null && password.isNotEmpty) 'password': password,
    };

    final raw = await svc.createUser(body: body);
    return UserItem.fromMap(raw);
  }
}
