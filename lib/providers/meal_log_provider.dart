import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/database_helper.dart';
import '../data/models/meal_log.dart';
import '../data/models/meal_photo.dart';
import 'profile_provider.dart';
import 'summary_provider.dart';

final mealLogsProvider =
    FutureProvider.family<List<MealLog>, int>((ref, profileId) async {
  final repo = ref.read(repositoryProvider);
  return repo.getMealLogsByProfileId(profileId);
});

final mealLogsByDateProvider =
    FutureProvider.family<List<MealLog>, DateProfileArgs>((ref, args) async {
  final repo = ref.read(repositoryProvider);
  return repo.getMealLogsByDate(args.profileId, args.date);
});

final mealLogsByDateRangeProvider =
    FutureProvider.family<List<MealLog>, DateRangeArgs>((ref, args) async {
  final repo = ref.read(repositoryProvider);
  return repo.getMealLogsByDateRange(args.profileId, args.from, args.to);
});

class DateRangeArgs {
  final int profileId;
  final String from;
  final String to;

  const DateRangeArgs({
    required this.profileId,
    required this.from,
    required this.to,
  });

  @override
  bool operator ==(Object other) =>
      other is DateRangeArgs &&
      other.profileId == profileId &&
      other.from == from &&
      other.to == to;

  @override
  int get hashCode => Object.hash(profileId, from, to);
}

class DateProfileArgs {
  final int profileId;
  final String date;

  DateProfileArgs(this.profileId, this.date);

  @override
  bool operator ==(Object other) =>
      other is DateProfileArgs &&
      other.profileId == profileId &&
      other.date == date;

  @override
  int get hashCode => Object.hash(profileId, date);
}

class MealSectionArgs {
  final int profileId;
  final String date;
  final String mealType;

  const MealSectionArgs({
    required this.profileId,
    required this.date,
    required this.mealType,
  });

  @override
  bool operator ==(Object other) =>
      other is MealSectionArgs &&
      other.profileId == profileId &&
      other.date == date &&
      other.mealType == mealType;

  @override
  int get hashCode => Object.hash(profileId, date, mealType);
}

final mealPhotosBySectionProvider = FutureProvider.family<List<MealPhoto>,
    MealSectionArgs>((ref, args) async {
  final repo = ref.read(repositoryProvider);
  return repo.getMealPhotosBySection(args.profileId, args.date, args.mealType);
});

class InputTextNotifier extends StateNotifier<Map<String, String>> {
  InputTextNotifier() : super({});

  void update(String mealType, String text) {
    state = {...state, mealType: text};
  }

  void clear(String mealType) {
    final next = {...state}..remove(mealType);
    state = next;
  }

  void clearAll() {
    state = {};
  }
}

final activeInputTextProvider =
    StateNotifierProvider<InputTextNotifier, Map<String, String>>(
        (ref) => InputTextNotifier());

class MealLogNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> saveMealLog(
    int profileId,
    String date,
    String mealType, {
    DateTime? loggedAt,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final inputText = ref.read(activeInputTextProvider);
      final text = inputText[mealType] ?? '';
      if (text.trim().isEmpty) return;

      final lines = text
          .split('\n')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();

      if (lines.isEmpty) return;

      // Single transaction: si una línea falla, ninguna se persiste.
      final db = await DatabaseHelper.instance.database;
      await db.transaction((txn) async {
        final batch = txn.batch();
        for (final line in lines) {
          batch.insert('meal_logs', MealLog(
            profileId: profileId,
            date: date,
            mealType: mealType,
            foodItemsText: line,
            loggedAt: loggedAt,
          ).toMap());
        }
        await batch.commit(noResult: true);
      });

      ref.read(activeInputTextProvider.notifier).clear(mealType);
      _invalidateLogs(profileId, date);
    });
  }

  Future<void> deleteMealLog(int id, int profileId, String date) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(repositoryProvider);
      await repo.deleteMealLog(id);
      _invalidateLogs(profileId, date);
    });
  }

  Future<void> updateMealLogText(int id, String newText, int profileId,
      String date) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(repositoryProvider);
      await repo.updateMealLogText(id, newText);
      _invalidateLogs(profileId, date);
    });
  }

  Future<void> updateMealLog(MealLog log) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(repositoryProvider);
      await repo.updateMealLog(log);
      _invalidateLogs(log.profileId, log.date);
    });
  }

  Future<void> addPhoto(
      int profileId, String date, String mealType, String path) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(repositoryProvider);
      await repo.insertMealPhoto(MealPhoto(
        profileId: profileId,
        date: date,
        mealType: mealType,
        path: path,
      ));
      ref.invalidate(mealPhotosBySectionProvider(
          MealSectionArgs(profileId: profileId, date: date, mealType: mealType)));
    });
  }

  Future<void> deletePhoto(int photoId, int profileId, String date,
      String mealType) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(repositoryProvider);
      await repo.deleteMealPhoto(photoId);
      ref.invalidate(mealPhotosBySectionProvider(
          MealSectionArgs(profileId: profileId, date: date, mealType: mealType)));
    });
  }

  Future<void> deleteByDateAndMealType(
      int profileId, String date, String mealType) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(repositoryProvider);
      await repo.deleteMealLogsByDateAndMealType(profileId, date, mealType);
      await repo.deleteMealPhotosBySection(profileId, date, mealType);
      _invalidateLogs(profileId, date);
      ref.invalidate(mealPhotosBySectionProvider(
          MealSectionArgs(profileId: profileId, date: date, mealType: mealType)));
    });
  }

  void _invalidateLogs(int profileId, String date) {
    ref.invalidate(mealLogsProvider(profileId));
    ref.invalidate(mealLogsByDateProvider(DateProfileArgs(profileId, date)));
    ref.invalidate(mealLogsByDateRangeProvider);
    ref.invalidate(weeklySummaryProvider(profileId));
  }
}

final mealLogNotifierProvider =
    AsyncNotifierProvider<MealLogNotifier, void>(MealLogNotifier.new);
