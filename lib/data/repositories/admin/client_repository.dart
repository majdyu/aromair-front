import 'package:front_erp_aromair/data/models/client_detail.dart';
import 'package:front_erp_aromair/data/services/client_service.dart';
// ADD THIS:
import 'package:front_erp_aromair/data/models/client.dart'; // contains ClientRow

abstract class IClientRepository {
  Future<ClientDetail> getClientDetail(int clientId);
  Future<void> updateClient(int id, Map<String, dynamic> body);
  Future<List<ClientRow>> getClients({String? q, String? type});
  Future<void> createClient(Map<String, dynamic> body);
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

  // ADD THIS:
  @override
  Future<List<ClientRow>> getClients({String? q, String? type}) async {
    final raw = await _service.getClients(q: q, type: type);
    return raw
        .map((e) => ClientRow.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<bool> toggleActive(int id) => _service.toggleActive(id);
  Future<void> createClient(Map<String, dynamic> body) =>
      _service.createClient(body);
}
