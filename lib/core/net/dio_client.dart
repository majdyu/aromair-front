import 'package:dio/dio.dart';
import 'package:front_erp_aromair/utils/api_constants.dart';
import 'package:front_erp_aromair/utils/storage_helper.dart';

Dio buildDio() {
  final dio = Dio(
    BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: 8),
      receiveTimeout: const Duration(seconds: 15),
      validateStatus: (s) => s != null && s < 500,
    ),
  );

  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (opt, handler) async {
        final token = (await StorageHelper.getUser())?['token'];
        if (token != null) opt.headers['Authorization'] = 'Bearer $token';
        if (!opt.headers.containsKey('accept')) {
          opt.headers['accept'] = '*/*';
        }
        if (!opt.headers.containsKey('Content-Type')) {
          opt.headers['Content-Type'] = 'application/json';
        }

        handler.next(opt);
      },
    ),
  );

  dio.interceptors.add(LogInterceptor(requestBody: true, responseBody: true));
  return dio;
}
