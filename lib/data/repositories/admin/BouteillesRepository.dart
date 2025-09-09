// lib/data/repositories/admin/bouteilles_repository.dart

import 'package:front_erp_aromair/data/models/bouteille_detail.dart';
import 'package:front_erp_aromair/data/services/BouteillesService.dart';

class BouteillesRepository {
  final BouteillesService svc;
  BouteillesRepository(this.svc);

  Future<BouteilleDetail> detail(int id) async {
    final json = await svc.getDetail(id);
    return BouteilleDetail.fromJson(json);
  }
}
