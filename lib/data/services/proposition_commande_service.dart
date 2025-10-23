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
      // Map common Dio errors to human-friendly messages
      final statusCode = e.response?.statusCode;
      final msg = switch (e.type) {
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
      throw Exception('Erreur lors du chargement des commandes: $e');
    }
  }
}
