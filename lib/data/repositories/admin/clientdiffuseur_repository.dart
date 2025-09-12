import 'package:front_erp_aromair/data/models/clientdiffuseur_detail.dart';
import 'package:front_erp_aromair/data/services/clientdiffuseur_service.dart';

abstract class IClientDiffuseurRepository {
  Future<ClientDiffuseurDetail> getDetail(int id);

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

}


