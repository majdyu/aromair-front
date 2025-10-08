import 'package:dio/dio.dart';
import 'package:front_erp_aromair/core/net/dio_client.dart';
import '../models/authentication_request.dart';
import '../models/authentication_response.dart';

class AuthService {
  final Dio _dio = buildDio();

  Future<AuthenticationResponse> login(AuthenticationRequest request) async {
    try {
      final response = await _dio.post(
        "v1/auth/authenticate",
        data: request.toJson(),
      );
      print("[AuthService] Raw response: ${response.data}");
      return AuthenticationResponse.fromJson(response.data);
    } on DioException catch (e) {
      print(
        '[AuthService] DioError url=${e.requestOptions.uri} status=${e.response?.statusCode} data=${e.response?.data}',
      );
      rethrow;
    }
  }
}
