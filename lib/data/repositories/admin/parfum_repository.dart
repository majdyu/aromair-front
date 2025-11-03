import 'package:front_erp_aromair/data/models/parfum.dart';
import 'package:front_erp_aromair/data/services/parfum_service.dart';

class ParfumRepository {
  final ParfumService _service;

  ParfumRepository(this._service);

  Future<List<Parfum>> fetch() {
    return _service.list();
  }
}
