class DosenModel {
  final String id;
  final String userId;
  final String nip;
  final String? signature_base64;

  DosenModel({
    required this.id,
    required this.userId,
    required this.nip,
    this.signature_base64,
  });

  factory DosenModel.fromJson(Map<String, dynamic> json) {
    return DosenModel(
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      nip: json['nip']?.toString() ?? '',
      signature_base64: json['signature_base64']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'nip': nip,
      'signature_base64': signature_base64,
    };
  }
}
