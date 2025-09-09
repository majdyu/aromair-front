import 'package:dio/dio.dart';
import 'package:front_erp_aromair/utils/api_constants.dart';
import 'package:front_erp_aromair/utils/storage_helper.dart';

Dio buildDio() {
  final dio = Dio(BaseOptions(
    baseUrl: ApiConstants.baseUrl, // "http://localhost:8089/aromair_erp/api/"
    connectTimeout: const Duration(seconds: 8),
    receiveTimeout: const Duration(seconds: 15),
    validateStatus: (s) => s != null && s < 500, // on gère les 4xx nous-mêmes
  ));

  dio.interceptors.add(InterceptorsWrapper(
    onRequest: (opt, handler) async {
      final token = (await StorageHelper.getUser())?['token'];
      if (token != null) opt.headers['Authorization'] = 'Bearer $token';
      handler.next(opt);
    },
  ));

  dio.interceptors.add(LogInterceptor(
    requestBody: true,
    responseBody: true,
  ));
  return dio;
}
