import 'package:dio/dio.dart';
import 'package:front_erp_aromair/data/enums/statut_reclamation.dart';
import 'package:front_erp_aromair/data/models/create_reclamation_request.dart';
import 'package:front_erp_aromair/data/models/reclamation_detail.dart';
import 'package:front_erp_aromair/data/models/reclamtion.dart';
import 'package:front_erp_aromair/data/services/reclamation_service.dart';

abstract class IReclamationRepository {
  Future<ReclamationDetail> getDetail(int id);
  Future<void> patch(int id, Map<String, dynamic> body);

  // Helpers dédiés utilisés par le controller :
  Future<void> patchEtapes(int id, bool etapes);
  Future<void> patchStatut(int id, StatutReclamation statut);
  Future<List<ReclamationRow>> fetchByDate({
    DateTime? du,
    DateTime? jusqua,
    CancelToken? cancelToken,
  });
  Future<void> create(CreateReclamationRequest body);
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

  Future<List<ReclamationRow>> fetchByDate({
    DateTime? du,
    DateTime? jusqua,
    CancelToken? cancelToken,
  }) async {
    final raw = await _service.getListByDate(
      du: du,
      jusqua: jusqua,
      cancelToken: cancelToken,
    );
    return raw.map((m) => ReclamationRow.fromJson(m)).toList();
  }

  @override
  Future<void> create(CreateReclamationRequest body) {
    return _service.create(body);
  }
}
