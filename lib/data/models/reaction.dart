class Reaction {
  final int? id;
  final int profileId;
  final String date;
  final String mealType;
  final String description;
  final String symptoms;

  Reaction({
    this.id,
    required this.profileId,
    required this.date,
    required this.mealType,
    this.description = '',
    this.symptoms = '',
  });

  factory Reaction.fromMap(Map<String, dynamic> map) => Reaction(
        id: map['id'] as int?,
        profileId: map['profileId'] as int,
        date: map['date'] as String,
        mealType: map['mealType'] as String,
        description: map['description'] as String? ?? '',
        symptoms: map['symptoms'] as String? ?? '',
      );

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'profileId': profileId,
        'date': date,
        'mealType': mealType,
        'description': description,
        'symptoms': symptoms,
      };

  Reaction copyWith({
    int? id,
    int? profileId,
    String? date,
    String? mealType,
    String? description,
    String? symptoms,
  }) =>
      Reaction(
        id: id ?? this.id,
        profileId: profileId ?? this.profileId,
        date: date ?? this.date,
        mealType: mealType ?? this.mealType,
        description: description ?? this.description,
        symptoms: symptoms ?? this.symptoms,
      );
}
