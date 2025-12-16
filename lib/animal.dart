class Animal {
  final String name;
  final String species;
  final int age;
  final double weight;
  final String origin;
  final String diet;
  final String habitat;
  final bool isEndangered;
  final String zooSection;
  final Map<String, dynamic> details;

  Animal({
    required this.name,
    required this.species,
    required this.age,
    required this.weight,
    required this.origin,
    required this.diet,
    required this.habitat,
    required this.isEndangered,
    required this.zooSection,
    required this.details,
  });

  factory Animal.fromJson(Map<String, dynamic> json) {
    return Animal(
      name: json['name'],
      species: json['species'],
      age: json['age'],
      weight: (json['weight'] as num).toDouble(),
      origin: json['origin'],
      diet: json['diet'],
      habitat: json['habitat'],
      isEndangered: json['isEndangered'],
      zooSection: json['zooSection'],
      details: Map<String, dynamic>.from(json['details']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'species': species,
      'age': age,
      'weight': weight,
      'origin': origin,
      'diet': diet,
      'habitat': habitat,
      'isEndangered': isEndangered,
      'zooSection': zooSection,
      'details': details,
    };
  }
}
