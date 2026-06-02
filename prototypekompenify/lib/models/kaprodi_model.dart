class KaprodiModel {
  final int? id;
  final String userId;
  final String nip;

  KaprodiModel({
    this.id,
    required this.userId,
    required this.nip,
  });

  factory KaprodiModel.fromJson(Map<String, dynamic> json) {
    return KaprodiModel(
      id: json['id'],
      userId: json['user_id'] ?? '',
      nip: json['nip'] ?? '',
    );
  }
}