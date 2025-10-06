class CreateReclamationRequest {
  final String probleme;
  final int clientId;

  const CreateReclamationRequest({
    required this.probleme,
    required this.clientId,
  });

  Map<String, dynamic> toJson() => {'probleme': probleme, 'clientId': clientId};

  CreateReclamationRequest copyWith({String? probleme, int? clientId}) =>
      CreateReclamationRequest(
        probleme: probleme ?? this.probleme,
        clientId: clientId ?? this.clientId,
      );
}
