import 'package:front_erp_aromair/data/models/equipe.dart';
import 'package:front_erp_aromair/data/models/technicien.dart';
import 'package:front_erp_aromair/data/services/equipe_service.dart';

class EquipesRepository {
  final EquipesService svc;
  EquipesRepository(this.svc);

  Future<List<Equipe>> list() async {
    final raw = await svc.getList();
    return Equipe.listFromJson(raw);
  }

  Future<Equipe> create(Map<String, dynamic> body) async {
    return svc.createEquipe(body);
  }

  Future<Equipe> getById(int id) async {
    final raw = await svc.getById(id);
    return Equipe.fromJson(raw);
  }

  Future<Equipe> updateMeta(
    int id, {
    String? nom,
    String? description,
    int? chefId,
    List<int>? userIds,
  }) async {
    final raw = await svc.patchMeta(
      id,
      nom: nom,
      description: description,
      chefId: chefId,
      userIds: userIds,
    );
    return Equipe.fromJson(raw);
  }

  Future<List<Map<String, dynamic>>> listTechniciensEl() {
    return svc.getTechniciensListEl();
  }

  Future<TechnicienConsultation> consulterTechnicien(
    int id, {
    required DateTime du,
    required DateTime jusqua,
  }) {
    return svc.consulterTechnicien(id: id, du: du, jusqua: jusqua);
  }
}
