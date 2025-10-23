import 'package:dio/dio.dart';
import 'package:front_erp_aromair/data/models/client_detail.dart';

class ContactService {
  final Dio _dio;
  ContactService(this._dio);

  Future<ContactLite> saveOrUpdate({
    required int clientId,
    required Map<String, dynamic> body,
  }) async {
    print('ContactService.saveOrUpdate called with body: $body');
    final resp = await _dio.post('contacts/saveOrUpdate', data: body);
    return ContactLite.fromJson(resp.data);
  }

  Future<void> delete({required int contactId}) async {
    await _dio.delete('contacts/delete/$contactId');
  }
}
