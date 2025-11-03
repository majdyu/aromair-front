import 'package:dio/dio.dart';
import 'package:front_erp_aromair/data/enums/status_commandes.dart';
import 'package:front_erp_aromair/data/models/commande_potentielle.dart';

/// Low-level HTTP service for Commandes Potentielles
class CommandesPotentiellesService {
  final Dio _dio;

  CommandesPotentiellesService(this._dio);

  Future<List<CommandePotentielleRow>> list({StatusCommande? status}) async {
    try {
      final query = <String, dynamic>{};
      if (status != null && status != StatusCommande.INCONNU) {
        query['status'] = status.name;
      }

      final resp = await _dio.get(
        'commandes-potentielles/list',
        queryParameters: query.isEmpty ? null : query,
        options: Options(headers: {'accept': '*/*'}),
      );

      final data = resp.data;
      if (data is List) {
        return CommandePotentielleRow.listFromJson(data);
      }
      throw const FormatException('Réponse inattendue: payload non-list.');
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;
      final msg = switch (e.type) {
        DioExceptionType.connectionError => 'Connexion échouée au serveur.',
        DioExceptionType.connectionTimeout => 'Délai dépassé (connexion).',
        DioExceptionType.receiveTimeout => 'Délai dépassé (réception).',
        DioExceptionType.sendTimeout => 'Délai dépassé (envoi).',
        DioExceptionType.badCertificate => 'Certificat TLS invalide.',
        DioExceptionType.badResponse =>
          e.response?.data is Map<String, dynamic>
              ? e.response!.data['error'] ??
                    'Réponse invalide du serveur (HTTP $statusCode).'
              : 'Réponse invalide du serveur (HTTP $statusCode).',
        DioExceptionType.cancel => 'Requête annulée.',
        DioExceptionType.unknown => 'Erreur réseau inconnue.',
      };
      throw Exception(msg);
    } catch (e) {
      throw Exception('Erreur lors du chargement des commandes: $e');
    }
  }

  Future<CommandePotentielleRow> toggleBouteilleVide(int id) async {
    try {
      final resp = await _dio.patch(
        'commandes-potentielles/$id/bouteille-vide/toggle',
        options: Options(headers: {'accept': '*/*'}),
      );

      final data = resp.data;
      if (data is Map<String, dynamic>) {
        return CommandePotentielleRow.fromJson(data);
      }
      throw const FormatException('Réponse inattendue: payload non-objet.');
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;
      final msg = switch (e.type) {
        DioExceptionType.connectionError => 'Connexion échouée au serveur.',
        DioExceptionType.connectionTimeout => 'Délai dépassé (connexion).',
        DioExceptionType.receiveTimeout => 'Délai dépassé (réception).',
        DioExceptionType.sendTimeout => 'Délai dépassé (envoi).',
        DioExceptionType.badCertificate => 'Certificat TLS invalide.',
        DioExceptionType.badResponse =>
          e.response?.data is Map<String, dynamic>
              ? e.response!.data['error'] ??
                    'Réponse invalide du serveur (HTTP $statusCode).'
              : 'Réponse invalide du serveur (HTTP $statusCode).',
        DioExceptionType.cancel => 'Requête annulée.',
        DioExceptionType.unknown => 'Erreur réseau inconnue.',
      };
      throw Exception(msg);
    } catch (e) {
      throw Exception('Erreur lors du toggle bouteille: $e');
    }
  }

  Future<CommandePotentielleRow> validateCommande(
    int id, {
    int? interventionId,
  }) async {
    try {
      // build url with optional query
      final String url;
      if (interventionId != null) {
        url =
            'commandes-potentielles/$id/valider?interventionId=$interventionId';
      } else {
        url = 'commandes-potentielles/$id/valider';
      }

      final resp = await _dio.patch(
        url,
        options: Options(headers: {'accept': '*/*'}),
      );

      final data = resp.data;
      if (data is Map<String, dynamic>) {
        if (data.containsKey('error')) {
          throw (data['error']);
        }
        return CommandePotentielleRow.fromJson(data);
      }
      throw const FormatException('Réponse inattendue: payload non-objet.');
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;
      final msg = switch (e.type) {
        DioExceptionType.connectionError => 'Connexion échouée au serveur.',
        DioExceptionType.connectionTimeout => 'Délai dépassé (connexion).',
        DioExceptionType.receiveTimeout => 'Délai dépassé (réception).',
        DioExceptionType.sendTimeout => 'Délai dépassé (envoi).',
        DioExceptionType.badCertificate => 'Certificat TLS invalide.',
        DioExceptionType.badResponse =>
          e.response?.data is Map<String, dynamic>
              ? e.response!.data['error'] ??
                    'Réponse invalide du serveur (HTTP $statusCode).'
              : 'Réponse invalide du serveur (HTTP $statusCode).',
        DioExceptionType.cancel => 'Requête annulée.',
        DioExceptionType.unknown => 'Erreur réseau inconnue.',
      };
      throw (msg);
    }
  }

  Future<CommandePotentielleRow> patchUpdate(
    int id, {
    int? parfumId,
    int? quantite,
    int? nbrBouteilles,
    String? typeTete,
    String? datePlanification,
  }) async {
    try {
      // Build payload dynamically – only include non-null fields
      final Map<String, dynamic> payload = {};
      if (parfumId != null) payload['parfumId'] = parfumId;
      if (quantite != null) payload['quantite'] = quantite;
      if (nbrBouteilles != null) payload['nbrBouteilles'] = nbrBouteilles;
      if (typeTete != null) payload['typeTete'] = typeTete;
      if (datePlanification != null) {
        payload['datePlanification'] = datePlanification;
      }

      // If no fields are provided, avoid sending empty body
      if (payload.isEmpty) {
        throw Exception('Aucun champ à mettre à jour.');
      }

      final resp = await _dio.patch(
        'commandes-potentielles/patch/$id',
        data: payload,
        options: Options(
          headers: {'accept': '*/*', 'Content-Type': 'application/json'},
        ),
      );

      final data = resp.data;
      if (data is Map<String, dynamic>) {
        if (data.containsKey('error')) {
          throw data['error'];
        }
        return CommandePotentielleRow.fromJson(data);
      }
      throw const FormatException('Réponse inattendue: payload non-objet.');
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;
      final msg = switch (e.type) {
        DioExceptionType.connectionError => 'Connexion échouée au serveur.',
        DioExceptionType.connectionTimeout => 'Délai dépassé (connexion).',
        DioExceptionType.receiveTimeout => 'Délai dépassé (réception).',
        DioExceptionType.sendTimeout => 'Délai dépassé (envoi).',
        DioExceptionType.badCertificate => 'Certificat TLS invalide.',
        DioExceptionType.badResponse =>
          e.response?.data is Map<String, dynamic>
              ? e.response!.data['error'] ??
                    'Réponse invalide du serveur (HTTP ${(statusCode)}).'
              : 'Réponse invalide du serveur (HTTP ${(statusCode)}).',
        DioExceptionType.cancel => 'Requête annulée.',
        DioExceptionType.unknown => 'Erreur réseau inconnue.',
      };
      throw (msg);
    } catch (e) {
      throw ('Erreur lors de la mise à jour partielle: $e');
    }
  }

  Future<CommandePotentielleRow> createManualy({
    required int clientDiffuseurId,
    required int? quantiteOpt,
    required int? parfumIdOpt,
    required bool force,
    int? nbrBouteilles,
    String? typeTete,
  }) async {
    try {
      final payload = <String, dynamic>{
        'clientDiffuseurId': clientDiffuseurId,
        'quantiteOpt': quantiteOpt,
        'parfumIdOpt': parfumIdOpt,
        'force': force,
        'nbrBouteilles': nbrBouteilles ?? 0,
        'typeTete': typeTete,
      };

      final resp = await _dio.post(
        // baseUrl already has /api so keep path consistent with others:
        'commandes-potentielles/createManualy',
        data: payload,
        options: Options(
          headers: {'accept': '*/*', 'Content-Type': 'application/json'},
        ),
      );

      final data = resp.data;
      if (data is Map<String, dynamic>) {
        return CommandePotentielleRow.fromJson(data);
      }
      throw const FormatException('Réponse inattendue: payload non-objet.');
    } on DioException catch (e) {
      final statusCode = e.response?.statusCode;
      final serverMsg = (e.response?.data is Map<String, dynamic>)
          ? (e.response!.data['error'] ?? e.response!.data['message'])
          : null;
      final msg =
          serverMsg ??
          switch (e.type) {
            DioExceptionType.connectionError => 'Connexion échouée au serveur.',
            DioExceptionType.connectionTimeout => 'Délai dépassé (connexion).',
            DioExceptionType.receiveTimeout => 'Délai dépassé (réception).',
            DioExceptionType.sendTimeout => 'Délai dépassé (envoi).',
            DioExceptionType.badCertificate => 'Certificat TLS invalide.',
            DioExceptionType.badResponse =>
              'Réponse invalide du serveur (HTTP $statusCode).',
            DioExceptionType.cancel => 'Requête annulée.',
            DioExceptionType.unknown => 'Erreur réseau inconnue.',
          };
      throw Exception(msg);
    } catch (e) {
      throw Exception('Erreur lors de la création manuelle: $e');
    }
  }
}
