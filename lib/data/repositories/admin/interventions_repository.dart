import 'package:front_erp_aromair/data/models/create_intervention_request.dart';
import 'package:front_erp_aromair/data/models/etat_client_diffuseur.dart';
import 'package:front_erp_aromair/data/models/intervention_detail.dart';
import 'package:front_erp_aromair/data/models/intervention_item.dart';
import 'package:front_erp_aromair/data/models/option_item.dart';
import 'package:front_erp_aromair/data/services/interventions_service.dart';

class InterventionsRepository {
  final InterventionsService _service;
  InterventionsRepository(this._service);

  Future<List<InterventionItem>> list({
    required DateTime from,
    required DateTime to,
    String? statut,
    String? q,
  }) => _service.list(from: from, to: to, statut: statut, q: q);

  Future<void> delete(int id) => _service.delete(id);

  Future<void> create(CreateInterventionRequest body) => _service.create(body);

  Future<InterventionDetail> detail(int id) async {
    final data = await _service.detailRaw(id);
    return InterventionDetail.fromJson(data);
  }

  Future<List<OptionItem>> clientsMin() => _service.getClientsMin();
  Future<List<OptionItem>> techniciensMin() => _service.getTechniciensMin();
  Future<List<OptionItem>> diffuseursByClientMin(int clientId) =>
      _service.getClientDiffuseursByClientMin(clientId);


  Future<void> updateTafs(int interventionId, List<TafCreate> tafs) {
    return _service.updateTafs(interventionId, tafs);
  }

  Future<void> updateMeta(
    int id, {
    DateTime? date,
    bool? estPayementObligatoire,
    String? remarque,
    double? payement,
    int? userId,
  }) {
    return _service.updateMeta(
      id,
      date: date,
      estPayementObligatoire: estPayementObligatoire,
      remarque: remarque,
      payement: payement,
      userId: userId,
    );
  }

  //---------------------------------------------------------------
   Future<EtatClientDiffuseur> etatClientDiffuseur(
    int interventionId,
    int clientDiffuseurId,
  ) {
    return _service.etatClientDiffuseur(interventionId, clientDiffuseurId);
  }

  Future<void> patchIcd(
    int interventionId,
    int clientDiffuseurId, {
    bool? qualiteBonne,
    bool? fuite,
    bool? enMarche,
  }) {
    return _service.patchIcd(
      interventionId,
      clientDiffuseurId,
      qualiteBonne: qualiteBonne,
      fuite: fuite,
      enMarche: enMarche,
    );
  }
  
}