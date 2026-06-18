class MealPhoto {
  final int? id;
  final int profileId;
  final String date;
  final String mealType;
  final String path;

  MealPhoto({
    this.id,
    required this.profileId,
    required this.date,
    required this.mealType,
    required this.path,
  });

  factory MealPhoto.fromMap(Map<String, dynamic> map) => MealPhoto(
        id: map['id'] as int?,
        profileId: map['profileId'] as int,
        date: map['date'] as String,
        mealType: map['mealType'] as String,
        path: map['path'] as String,
      );

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'profileId': profileId,
        'date': date,
        'mealType': mealType,
        'path': path,
      };
}
