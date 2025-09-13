import 'package:front_erp_aromair/data/models/available_cab.dart';
import 'package:front_erp_aromair/data/models/clientdiffuseur_detail.dart';
import 'package:front_erp_aromair/data/services/clientdiffuseur_service.dart';

abstract class IClientDiffuseurRepository {
  Future<ClientDiffuseurDetail> getDetail(int id);

  Future<List<AvailableCab>> getCabsDisponibles({String? q});

  Future<void> affecterInit({
    required int clientId,
    required String cab,
    required Map<String, dynamic> body, // <- contient emplacement/maxMin/programmes
  });

  Future<void> retirerClient(String cab);
}

class ClientDiffuseurRepository implements IClientDiffuseurRepository {
  final ClientDiffuseurService _service;
  ClientDiffuseurRepository(this._service);

  @override
  Future<ClientDiffuseurDetail> getDetail(int id) async {
    final json = await _service.getDetail(id);
    return ClientDiffuseurDetail.fromJson(json);
  }

  @override
  Future<void> affecterInit({
    required int clientId,
    required String cab,
    required Map<String, dynamic> body,
  }) =>
      _service.affecterInit(clientId: clientId, cab: cab, body: body);


  @override
  Future<void> retirerClient(String cab) => _service.retirerClient(cab: cab);

  @override
  Future<List<AvailableCab>> getCabsDisponibles({String? q}) async {
    final list = await _service.getCabsDisponibles(q: q);
    return list.map((j) => AvailableCab.fromJson(j)).toList();
  }

}


