class AuthenticationResponse {
  final String token;
  final String message;

  AuthenticationResponse({required this.token, required this.message});

  factory AuthenticationResponse.fromJson(Map<String, dynamic> json) {
    return AuthenticationResponse(
      token: json['token'],
      message: json['message'],
    );
  }
}
