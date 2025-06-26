class Plant {
  final int? id;
  final DateTime? createdAt;
  final String name;
  final String species;
  String imageUrl;
  DateTime lastWatered;
  final String careNotes;

  final int wateringFrequencySeconds;

  Plant({
    this.id,
    this.createdAt,
    required this.name,
    required this.species,
    required this.imageUrl,
    required this.lastWatered,
    required this.careNotes,
    required this.wateringFrequencySeconds,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'species': species,
      'image_url': imageUrl,
      'last_watered': lastWatered.toIso8601String(),
      'care_notes': careNotes,
      'watering_frequency_seconds': wateringFrequencySeconds,
    };
  }

  factory Plant.fromMap(Map<String, dynamic> map) {
    return Plant(
      id: map['id']?.toInt(),
      createdAt:
          map['created_at'] != null ? DateTime.parse(map['created_at']) : null,
      name: map['name'] ?? '',
      species: map['species'] ?? '',
      imageUrl: map['image_url'] ?? '',
      lastWatered: DateTime.parse(map['last_watered']),
      careNotes: map['care_notes'] ?? '',
      wateringFrequencySeconds:
          map['watering_frequency_seconds']?.toInt() ?? 60,
    );
  }

}