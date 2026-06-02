class DosenModel {
  final int id;
  final int userId;
  final String nip;
  final String? prodi;
  final String? signature_base64;

  DosenModel({
    required this.id,
    required this.userId,
    required this.nip,
    this.prodi,
    this.signature_base64,
  });

  factory DosenModel.fromJson(Map<String, dynamic> json) {
    return DosenModel(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? '',
      nip: json['nip'] ?? '',
      prodi: json['prodi'],
      signature_base64: json['signature_base64'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'nip': nip,
      'prodi': prodi,
      'signature_base64': signature_base64,
    };
  }
}