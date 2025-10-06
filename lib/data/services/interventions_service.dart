import 'package:dio/dio.dart';
import 'package:front_erp_aromair/core/net/dio_client.dart';
import 'package:front_erp_aromair/data/models/create_intervention_request.dart';
import 'package:front_erp_aromair/data/models/etat_client_diffuseur.dart';
import 'package:front_erp_aromair/data/models/option_item.dart';
import 'package:front_erp_aromair/utils/storage_helper.dart';
import 'package:front_erp_aromair/data/models/intervention_item.dart';
import 'package:intl/intl.dart';

class InterventionsService {
  final Dio _dio = buildDio();

  Future<List<InterventionItem>> list({
    required DateTime from,
    required DateTime to,
    String? statut, // EN_COURS | TRAITE | EN_RETARD | ANNULEE | null = TOUT
    String? q,
  }) async {
    final user = await StorageHelper.getUser();
    final token = user?['token'];

    final resp = await _dio.get(
      "interventions/list",
      queryParameters: {
        "from": from.toIso8601String(), // OK pour @DateTimeFormat ISO
        "to": to.toIso8601String(),
        if (statut != null && statut != "ALL") "statut": statut,
        if (q != null && q.trim().isNotEmpty) "q": q.trim(),
      },
      options: Options(
        headers: {
          if (token != null && token.toString().isNotEmpty)
            'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ),
    );

    final list = (resp.data as List)
        .map((e) => InterventionItem.fromJson(e as Map<String, dynamic>))
        .toList();
    return list;
  }

  Future<void> delete(int id) async {
    final token = (await StorageHelper.getUser())?['token'];
    await _dio.delete(
      "interventions/delete/$id",
      options: Options(
        headers: {if (token != null) 'Authorization': 'Bearer $token'},
      ),
    );
  }

  Future<Map<String, dynamic>> detailRaw(int id) async {
    final token = (await StorageHelper.getUser())?['token'];
    final resp = await _dio.get(
      "interventions/getDetails/$id",
      options: Options(
        headers: {if (token != null) 'Authorization': 'Bearer $token'},
      ),
    );
    return resp.data as Map<String, dynamic>;
  }

  Future<void> create(CreateInterventionRequest body) async {
    final user = await StorageHelper.getUser();
    final token = user?['token'];
    await _dio.post(
      "interventions/create",
      data: body.toJson(),
      options: Options(
        headers: {
          if (token != null) 'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ),
    );
  }

  // --- Lookups (routes back plus bas) ---
  Future<List<OptionItem>> getClientsMin() async {
    final token = (await StorageHelper.getUser())?['token'];
    final r = await _dio.get(
      "lookup/clients/min",
      options: Options(
        headers: {if (token != null) 'Authorization': 'Bearer $token'},
      ),
    );
    return (r.data as List).map((e) => OptionItem.fromJson(e)).toList();
  }

  Future<List<OptionItem>> getTechniciensMin() async {
    final token = (await StorageHelper.getUser())?['token'];
    final r = await _dio.get(
      "lookup/users/techniciens/min",
      options: Options(
        headers: {if (token != null) 'Authorization': 'Bearer $token'},
      ),
    );
    return (r.data as List).map((e) => OptionItem.fromJson(e)).toList();
  }

  Future<List<OptionItem>> getClientDiffuseursByClientMin(int clientId) async {
    final token = (await StorageHelper.getUser())?['token'];
    final r = await _dio.get(
      "lookup/client-diffuseurs/by-client/$clientId/min",
      options: Options(
        headers: {if (token != null) 'Authorization': 'Bearer $token'},
      ),
    );
    return (r.data as List).map((e) => OptionItem.fromJson(e)).toList();
  }

  Future<void> updateTafs(int id, List<TafCreate> tafs) async {
    final token = (await StorageHelper.getUser())?['token'];

    final payload = {
      "tafs": tafs.map((t) {
        final cdId = t.clientDiffuseur?.id; // si ton modèle est nullable
        if (cdId == null) {
          throw ArgumentError(
            "clientDiffuseur.id est obligatoire pour chaque TAF",
          );
        }
        return {
          "typeInterventions": t.typeInterventions,
          "clientDiffuseurId": cdId, // ⟵ ATTENDU PAR LE BACK
        };
      }).toList(),
    };

    await _dio.put(
      "interventions/tafs/$id",
      data: payload,
      options: Options(
        headers: {if (token != null) 'Authorization': 'Bearer $token'},
      ),
    );
  }

  Future<void> updateMeta(
    int id, {
    DateTime? date,
    bool? estPayementObligatoire,
    String? remarque,
    double? payement,
    int? equipeId,
  }) async {
    final token = (await StorageHelper.getUser())?['token'];
    final body = <String, dynamic>{};
    print("--- updateMeta body avant envoi: $body");
    print("token: $token");
    if (date != null) {
      body['date'] = DateFormat("dd-MM-yyyy'T'HH:mm").format(date);
    }
    if (estPayementObligatoire != null) {
      body['estPayementObligatoire'] = estPayementObligatoire;
    }
    if (remarque != null) body['remarque'] = remarque;
    if (payement != null) body['payement'] = payement;
    if (equipeId != null) body['equipeId'] = equipeId;

    await _dio.patch(
      'interventions/updateMeta/$id',
      data: body.isEmpty ? {} : body,
      options: Options(
        headers: {
          if (token != null) 'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );
  }

  //------------------------------------------------------------

  Future<EtatClientDiffuseur> etatClientDiffuseur(
    int interventionId,
    int clientDiffuseurId,
  ) async {
    final token = (await StorageHelper.getUser())?['token'];
    final resp = await _dio.get(
      "interventions/$interventionId/client-diffuseurs/$clientDiffuseurId",
      options: Options(
        headers: {if (token != null) 'Authorization': 'Bearer $token'},
      ),
    );
    // resp.data est déjà un Map<String,dynamic>
    return EtatClientDiffuseur.fromJson(Map<String, dynamic>.from(resp.data));
  }

  Future<void> patchIcd(
    int interventionId,
    int clientDiffuseurId, {
    bool? qualiteBonne,
    bool? fuite,
    bool? enMarche,
  }) async {
    final token = (await StorageHelper.getUser())?['token'];
    await _dio.patch(
      'interventions/$interventionId/client-diffuseurs/$clientDiffuseurId',
      data: {
        'qualiteBonne': qualiteBonne,
        'fuite': fuite,
        'enMarche': enMarche,
      },
      options: Options(
        headers: {if (token != null) 'Authorization': 'Bearer $token'},
      ),
    );
  }
}
