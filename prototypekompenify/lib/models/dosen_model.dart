class DosenModel {
  final String id;
  final String userId;
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
      id: json['id']?.toString() ?? '',
      userId: json['user_id']?.toString() ?? '',
      nip: json['nip']?.toString() ?? '',
      prodi: json['prodi']?.toString(),
      signature_base64: json['signature_base64']?.toString(),
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