import 'package:front_erp_aromair/data/models/equipe.dart';
import 'package:front_erp_aromair/data/services/equipe_service.dart';

class EquipesRepository {
  final EquipesService _service;

  EquipesRepository({EquipesService? service})
    : _service = service ?? EquipesService();

  Future<List<Equipe>> fetchEquipes() => _service.getEquipes();
}
