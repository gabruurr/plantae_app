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

}