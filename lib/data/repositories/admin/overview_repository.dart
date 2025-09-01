import 'package:front_erp_aromair/data/services/overview_service.dart';

class OverviewRepository {
  final OverviewService _service;
  OverviewRepository(this._service);

  Future<List<int>> getOverview() => _service.fetchOverview();
}
