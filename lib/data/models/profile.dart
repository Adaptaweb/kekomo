class Profile {
  final int? id;
  final String firstName;
  final String lastName;
  final int age;
  final String category;
  final String? photoUri;

  Profile({
    this.id,
    required this.firstName,
    required this.lastName,
    this.age = 0,
    required this.category,
    this.photoUri,
  });

  factory Profile.fromMap(Map<String, dynamic> map) => Profile(
        id: map['id'] as int?,
        firstName: map['firstName'] as String,
        lastName: map['lastName'] as String,
        age: map['age'] as int? ?? 0,
        category: map['category'] as String,
        photoUri: map['photoUri'] as String?,
      );

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'firstName': firstName,
        'lastName': lastName,
        'age': age,
        'category': category,
        'photoUri': photoUri,
      };

  Profile copyWith({
    int? id,
    String? firstName,
    String? lastName,
    int? age,
    String? category,
    String? photoUri,
  }) =>
      Profile(
        id: id ?? this.id,
        firstName: firstName ?? this.firstName,
        lastName: lastName ?? this.lastName,
        age: age ?? this.age,
        category: category ?? this.category,
        photoUri: photoUri ?? this.photoUri,
      );
}
