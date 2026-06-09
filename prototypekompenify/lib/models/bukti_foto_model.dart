class BuktiFotoModel {
  final String id;
  final String fotoUrl;

  BuktiFotoModel({required this.id, required this.fotoUrl});

  factory BuktiFotoModel.fromJson(Map<String, dynamic> json) {
    return BuktiFotoModel(
      id: json['id'].toString(),
      fotoUrl: json['foto_url'] ?? '',
    );
  }
}