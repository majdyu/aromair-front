import 'package:dio/dio.dart';
import 'package:front_erp_aromair/data/models/parfum.dart';

class ParfumService {
  final Dio _dio;

  ParfumService(this._dio);

  Future<List<Parfum>> list() async {
    try {
      final resp = await _dio.get(
        'parfums/list',
        options: Options(headers: {'accept': '*/*'}),
      );

      final data = resp.data;
      if (data is List) {
        return Parfum.listFromJson(data);
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
      throw Exception('Erreur lors du chargement des parfums: $e');
    }
  }
}
