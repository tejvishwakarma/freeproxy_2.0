class Country {
  final String id;
  final String name;
  final String code;
  final int proxyCount;

  Country({
    this.id = '',
    required this.name,
    required this.code,
    required this.proxyCount,
  });

  // Create Country from Firestore data
  factory Country.fromFirestore(Map<String, dynamic> data, String documentId) {
    return Country(
      id: documentId,
      name: data['name'] ?? '',
      code: data['code'] ?? '',
      proxyCount: data['proxyCount'] ?? 0,
    );
  }

  // Convert Country to Firestore data
  Map<String, dynamic> toFirestore() {
    return {'name': name, 'code': code, 'proxyCount': proxyCount};
  }
}
