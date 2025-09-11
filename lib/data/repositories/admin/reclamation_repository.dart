import 'package:front_erp_aromair/data/models/reclamation_detail.dart';
import 'package:front_erp_aromair/data/services/reclamation_service.dart';

abstract class IReclamationRepository {
  Future<ReclamationDetail> getDetail(int id);
  Future<void> patch(int id, Map<String, dynamic> body);

  // Helpers dédiés utilisés par le controller :
  Future<void> patchEtapes(int id, bool etapes);
  Future<void> patchStatut(int id, StatutReclamation statut);
}

class ReclamationRepository implements IReclamationRepository {
  final ReclamationService _service;
  ReclamationRepository(this._service);

  @override
  Future<ReclamationDetail> getDetail(int id) async {
    final json = await _service.getDetail(id);
    return ReclamationDetail.fromJson(json);
  }

  @override
  Future<void> patch(int id, Map<String, dynamic> body) {
    return _service.patch(id, body: body);
  }

  @override
  Future<void> patchEtapes(int id, bool etapes) {
    return _service.patch(id, body: {'etapes': etapes});
  }

  @override
  Future<void> patchStatut(int id, StatutReclamation statut) {
    return _service.patch(id, body: {'statutReclammation': statut.apiValue});
  }
}
