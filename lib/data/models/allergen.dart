class Allergen {
  final int? id;
  final int profileId;
  final String name;

  Allergen({
    this.id,
    required this.profileId,
    required this.name,
  });

  factory Allergen.fromMap(Map<String, dynamic> map) => Allergen(
        id: map['id'] as int?,
        profileId: map['profileId'] as int,
        name: map['name'] as String,
      );

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'profileId': profileId,
        'name': name,
      };

  Allergen copyWith({
    int? id,
    int? profileId,
    String? name,
  }) =>
      Allergen(
        id: id ?? this.id,
        profileId: profileId ?? this.profileId,
        name: name ?? this.name,
      );
}
