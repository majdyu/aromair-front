import 'package:front_erp_aromair/data/models/alerte_detail.dart';
import 'package:front_erp_aromair/data/services/alertes_service.dart';

class AlertesRepository {
  final AlertesService svc;
  AlertesRepository(this.svc);

  Future<AlerteDetail> detail(int id) async {
    final json = await svc.getDetail(id);
    return AlerteDetail.fromJson(json);
  }

  Future<void> toggle(int id, {String? decisionPrise}) =>
      svc.toggle(id, decisionPrise: decisionPrise);
}
