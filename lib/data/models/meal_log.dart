class MealLog {
  final int? id;
  final int profileId;
  final String date;
  final String mealType;
  final String foodItemsText;
  final bool hasReaction;
  final String reactionSymptoms;
  final String reactionSeverity;
  final DateTime? loggedAt;

  MealLog({
    this.id,
    required this.profileId,
    required this.date,
    required this.mealType,
    required this.foodItemsText,
    this.hasReaction = false,
    this.reactionSymptoms = '',
    this.reactionSeverity = '',
    this.loggedAt,
  });

  factory MealLog.fromMap(Map<String, dynamic> map) => MealLog(
        id: map['id'] as int?,
        profileId: map['profileId'] as int,
        date: map['date'] as String,
        mealType: map['mealType'] as String,
        foodItemsText: map['foodItemsText'] as String,
        hasReaction: (map['hasReaction'] as int? ?? 0) == 1,
        reactionSymptoms: map['reactionSymptoms'] as String? ?? '',
        reactionSeverity: map['reactionSeverity'] as String? ?? '',
        loggedAt: _parseLoggedAt(map['loggedAt']),
      );

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'profileId': profileId,
        'date': date,
        'mealType': mealType,
        'foodItemsText': foodItemsText,
        'hasReaction': hasReaction ? 1 : 0,
        'reactionSymptoms': reactionSymptoms,
        'reactionSeverity': reactionSeverity,
        'loggedAt': loggedAt?.toIso8601String(),
        'photoPaths': '',
      };

  MealLog copyWith({
    int? id,
    int? profileId,
    String? date,
    String? mealType,
    String? foodItemsText,
    bool? hasReaction,
    String? reactionSymptoms,
    String? reactionSeverity,
    Object? loggedAt = _sentinel,
  }) =>
      MealLog(
        id: id ?? this.id,
        profileId: profileId ?? this.profileId,
        date: date ?? this.date,
        mealType: mealType ?? this.mealType,
        foodItemsText: foodItemsText ?? this.foodItemsText,
        hasReaction: hasReaction ?? this.hasReaction,
        reactionSymptoms: reactionSymptoms ?? this.reactionSymptoms,
        reactionSeverity: reactionSeverity ?? this.reactionSeverity,
        loggedAt: identical(loggedAt, _sentinel)
            ? this.loggedAt
            : loggedAt as DateTime?,
      );

  static const Object _sentinel = Object();

  static DateTime? _parseLoggedAt(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String && value.isNotEmpty) {
      return DateTime.tryParse(value);
    }
    return null;
  }
}
