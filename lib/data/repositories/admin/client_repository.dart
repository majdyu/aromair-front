import 'package:front_erp_aromair/data/models/client_detail.dart';
import 'package:front_erp_aromair/data/services/client_service.dart';

abstract class IClientRepository {
  Future<ClientDetail> getClientDetail(int clientId);
  Future<void> updateClient(int id, Map<String, dynamic> body);
}

class ClientRepository implements IClientRepository {
  final ClientService _service;
  ClientRepository(this._service);

  @override
  Future<ClientDetail> getClientDetail(int clientId) async {
    final json = await _service.getClientDetail(clientId);
    return ClientDetail.fromJson(json);
  }

  @override
  Future<void> updateClient(int id, Map<String, dynamic> body) =>
      _service.updateClient(id, body);
}
