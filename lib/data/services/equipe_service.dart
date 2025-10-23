import 'package:dio/dio.dart';
import 'package:front_erp_aromair/data/models/equipe.dart';
import 'package:front_erp_aromair/data/models/technicien.dart';
import 'package:front_erp_aromair/utils/api_constants.dart';
import 'package:front_erp_aromair/utils/storage_helper.dart';

class EquipesService {
  final Dio _dio;

  EquipesService(this._dio);

  String _errMsg(Object e) {
    if (e is DioException) {
      final status = e.response?.statusCode;
      final data = e.response?.data;
      final msg = (data is Map && data['error'] != null)
          ? data['error'].toString()
          : e.message ?? 'Erreur réseau';
      return 'Erreur ${status ?? ''} : $msg'.trim();
    }
    return e.toString();
  }

  Future<List<Map<String, dynamic>>> getList() async {
    final token = (await StorageHelper.getUser())?['token'];

    final resp = await _dio.get(
      'equipes/list',
      options: Options(
        responseType: ResponseType.json,
        headers: {if (token != null) 'Authorization': 'Bearer $token'},
      ),
    );

    final data = resp.data;
    if (data is! List) {
      throw StateError(
        'Réponse inattendue pour GET alertes/list: attendu une liste JSON [].',
      );
    }

    return data
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList(growable: false);
  }

  Future<Map<String, dynamic>> getById(int id) async {
    try {
      final token = (await StorageHelper.getUser())?['token'];

      final resp = await _dio.get(
        'equipes/getDetails/$id',
        options: Options(
          responseType: ResponseType.json,
          headers: {if (token != null) 'Authorization': 'Bearer $token'},
        ),
      );

      final data = resp.data;
      if (data is! Map) {
        throw StateError(
          'Réponse inattendue pour GET equipes/getDetails/$id: attendu un objet JSON {}.',
        );
      }

      return Map<String, dynamic>.from(data);
    } catch (e) {
      throw Exception(_errMsg(e));
    }
  }

  Future<Equipe> createEquipe(
    Map<String, dynamic> body, {
    CancelToken? cancelToken,
  }) async {
    try {
      final res = await _dio.post(
        '${ApiConstants.baseUrl}equipes',
        data: body,
        cancelToken: cancelToken,
      );
      return Equipe.fromJson(res.data);
    } catch (e) {
      throw Exception(_errMsg(e));
    }
  }

  // EquipesService.dart
  Future<Map<String, dynamic>> patchMeta(
    int id, {
    String? nom,
    String? description,
    int? chefId,
    List<int>? userIds,
  }) async {
    try {
      final body = <String, dynamic>{};
      if (nom != null) body['nom'] = nom;
      if (description != null) body['description'] = description;
      if (chefId != null) body['chefId'] = chefId;
      if (userIds != null) body['userIds'] = userIds; // <— NEW

      if (body.isEmpty) {
        throw ArgumentError(
          'Aucun champ à mettre à jour pour PATCH equipes/patch/$id',
        );
      }

      final token = (await StorageHelper.getUser())?['token'];

      final resp = await _dio.patch(
        'equipes/patch/$id',
        data: body,
        options: Options(
          responseType: ResponseType.json,
          headers: {if (token != null) 'Authorization': 'Bearer $token'},
        ),
      );

      final data = resp.data;
      if (data is! Map) {
        throw StateError('Réponse inattendue: attendu un objet JSON {}.');
      }
      return Map<String, dynamic>.from(data);
    } catch (e) {
      throw Exception(_errMsg(e));
    }
  }

  Future<List<Map<String, dynamic>>> getTechniciensListEl() async {
    try {
      final token = (await StorageHelper.getUser())?['token'];
      final resp = await _dio.get(
        'users/techniciens/list-el',
        options: Options(
          responseType: ResponseType.json,
          headers: {if (token != null) 'Authorization': 'Bearer $token'},
        ),
      );
      final data = resp.data;
      if (data is! List) {
        throw StateError(
          'Réponse inattendue pour GET users/techniciens/list-el: attendu une liste JSON [].',
        );
      }
      return data
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList(growable: false);
    } catch (e) {
      throw Exception(_errMsg(e));
    }
  }

  /// SUPPRESSION
  Future<void> deleteEquipe(int id, {CancelToken? cancelToken}) async {
    try {
      await _dio.delete(
        '${ApiConstants.baseUrl}equipes/$id',
        cancelToken: cancelToken,
      );
    } catch (e) {
      throw Exception(_errMsg(e));
    }
  }

  Future<TechnicienConsultation> consulterTechnicien({
    required int id,
    required DateTime du,
    required DateTime jusqua,
    CancelToken? cancelToken,
  }) async {
    try {
      final token = (await StorageHelper.getUser())?['token'];
      // Format yyyy-MM-dd without extra deps:
      final duStr = du.toIso8601String().split('T').first;
      final jusquaStr = jusqua.toIso8601String().split('T').first;

      final res = await _dio.get(
        'users/$id/consulterTechnicien',
        queryParameters: {'du': duStr, 'jusqua': jusquaStr},
        options: Options(
          responseType: ResponseType.json,
          headers: {if (token != null) 'Authorization': 'Bearer $token'},
        ),
        cancelToken: cancelToken,
      );

      if (res.data is! Map) {
        throw StateError('Réponse inattendue: objet JSON attendu.');
      }
      return TechnicienConsultation.fromJson(
        Map<String, dynamic>.from(res.data as Map),
      );
    } catch (e) {
      throw Exception(_errMsg(e));
    }
  }
}
