class AuthenticationRequest {
  final String firstname;
  final String password;

  AuthenticationRequest({required this.firstname, required this.password});

  Map<String, dynamic> toJson() => {
        "firstname": firstname,
        "password": password,
      };
}
