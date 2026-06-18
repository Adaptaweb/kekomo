class MealTimeRange {
  final int startHour;
  final int startMinute;
  final int endHour;
  final int endMinute;

  const MealTimeRange({
    required this.startHour,
    required this.startMinute,
    required this.endHour,
    required this.endMinute,
  });

  factory MealTimeRange.fromJson(Map<String, dynamic> json) {
    return MealTimeRange(
      startHour: json['startHour'] as int,
      startMinute: json['startMinute'] as int,
      endHour: json['endHour'] as int,
      endMinute: json['endMinute'] as int,
    );
  }

  Map<String, dynamic> toJson() => {
        'startHour': startHour,
        'startMinute': startMinute,
        'endHour': endHour,
        'endMinute': endMinute,
      };

  MealTimeRange copyWith({
    int? startHour,
    int? startMinute,
    int? endHour,
    int? endMinute,
  }) {
    return MealTimeRange(
      startHour: startHour ?? this.startHour,
      startMinute: startMinute ?? this.startMinute,
      endHour: endHour ?? this.endHour,
      endMinute: endMinute ?? this.endMinute,
    );
  }

  bool containsHourMinute(int hour, int minute) {
    final start = startHour * 60 + startMinute;
    final end = endHour * 60 + endMinute;
    final now = hour * 60 + minute;
    return now >= start && now < end;
  }

  String formatLabel() {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(startHour)}:${two(startMinute)} - '
        '${two(endHour)}:${two(endMinute)}';
  }
}

class MealSchedule {
  final MealTimeRange desayuno;
  final MealTimeRange almuerzo;
  final MealTimeRange once;
  final MealTimeRange cena;

  const MealSchedule({
    required this.desayuno,
    required this.almuerzo,
    required this.once,
    required this.cena,
  });

  factory MealSchedule.defaultSchedule() {
    return const MealSchedule(
      desayuno: MealTimeRange(
        startHour: 7,
        startMinute: 0,
        endHour: 9,
        endMinute: 0,
      ),
      almuerzo: MealTimeRange(
        startHour: 12,
        startMinute: 0,
        endHour: 14,
        endMinute: 0,
      ),
      once: MealTimeRange(
        startHour: 16,
        startMinute: 0,
        endHour: 17,
        endMinute: 0,
      ),
      cena: MealTimeRange(
        startHour: 20,
        startMinute: 0,
        endHour: 22,
        endMinute: 0,
      ),
    );
  }

  factory MealSchedule.fromJson(Map<String, dynamic> json) {
    return MealSchedule(
      desayuno: MealTimeRange.fromJson(
          Map<String, dynamic>.from(json['desayuno'] as Map)),
      almuerzo: MealTimeRange.fromJson(
          Map<String, dynamic>.from(json['almuerzo'] as Map)),
      once: MealTimeRange.fromJson(
          Map<String, dynamic>.from(json['once'] as Map)),
      cena: MealTimeRange.fromJson(
          Map<String, dynamic>.from(json['cena'] as Map)),
    );
  }

  Map<String, dynamic> toJson() => {
        'desayuno': desayuno.toJson(),
        'almuerzo': almuerzo.toJson(),
        'once': once.toJson(),
        'cena': cena.toJson(),
      };

  MealSchedule copyWith({
    MealTimeRange? desayuno,
    MealTimeRange? almuerzo,
    MealTimeRange? once,
    MealTimeRange? cena,
  }) {
    return MealSchedule(
      desayuno: desayuno ?? this.desayuno,
      almuerzo: almuerzo ?? this.almuerzo,
      once: once ?? this.once,
      cena: cena ?? this.cena,
    );
  }

  MealTimeRange forMeal(String meal) {
    switch (meal) {
      case 'Desayuno':
        return desayuno;
      case 'Almuerzo':
        return almuerzo;
      case 'Once':
        return once;
      case 'Cena':
        return cena;
      default:
        return desayuno;
    }
  }

  MealSchedule withRange(String meal, MealTimeRange range) {
    switch (meal) {
      case 'Desayuno':
        return copyWith(desayuno: range);
      case 'Almuerzo':
        return copyWith(almuerzo: range);
      case 'Once':
        return copyWith(once: range);
      case 'Cena':
        return copyWith(cena: range);
      default:
        return this;
    }
  }
}
