import 'package:front_erp_aromair/data/models/diffuseur.dart';
import 'package:front_erp_aromair/data/services/diffuseur_service.dart';

class DiffuseurRepository {
  final DiffuseurService svc;
  DiffuseurRepository(this.svc);

  Future<List<Diffuseur>> list() async {
    final raw = await svc.getList();
    return Diffuseur.listFromJson(raw);
  }

  Future<Diffuseur> create({
    required String modele,
    required String typCarte,
    required String designation,
    required double consommation,
  }) async {
    final raw = await svc.create({
      'modele': modele,
      'typCarte': typCarte,
      'designation': designation,
      'consommation': consommation,
    });
    return Diffuseur.fromJson(raw);
  }

  Future<void> delete(int id) async {
    await svc.deleteById(id);
  }
}
