import '../models/authentication_request.dart';
import '../models/authentication_response.dart';
import '../services/auth_service.dart';

class AuthRepository {
  final AuthService _service;

  AuthRepository(this._service);

  Future<AuthenticationResponse> authenticate(AuthenticationRequest request) {
    return _service.login(request);
  }
}
