import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/profile.dart';
import '../data/kecomo_repository.dart';
import 'navigation_provider.dart';

final repositoryProvider = Provider<KeComoRepository>((ref) => KeComoRepository());

final allProfilesProvider = FutureProvider<List<Profile>>((ref) async {
  final repo = ref.read(repositoryProvider);
  return repo.getAllProfiles();
});

final activeProfileIdProvider = StateProvider<int?>((ref) => null);

final activeProfileProvider = FutureProvider<Profile?>((ref) async {
  final id = ref.watch(activeProfileIdProvider);
  if (id == null) return null;
  final repo = ref.read(repositoryProvider);
  return repo.getProfileById(id);
});

class ProfileNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  void switchProfile(int profileId) {
    ref.read(activeProfileIdProvider.notifier).state = profileId;
    ref.read(currentScreenProvider.notifier).state = KeComoScreen.today;
    ref.read(selectedDateProvider.notifier).state = _todayDate();
  }

  Future<int> createProfile(
      String firstName, String lastName, String category,
      {int age = 0, String? photoUri}) async {
    state = const AsyncLoading();
    try {
      final repo = ref.read(repositoryProvider);
      final profile = Profile(
        firstName: firstName,
        lastName: lastName,
        age: age,
        category: category,
        photoUri: photoUri,
      );
      final newId = await repo.insertProfile(profile);
      ref.read(activeProfileIdProvider.notifier).state = newId;
      ref.invalidate(allProfilesProvider);
      state = const AsyncData(null);
      return newId;
    } catch (e, st) {
      state = AsyncError(e, st);
      rethrow;
    }
  }

  Future<void> updateActiveProfile(String aliasName, String? photoUri) async {
    final id = ref.read(activeProfileIdProvider);
    if (id == null) return;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(repositoryProvider);
      await repo.updateProfile(id, aliasName, photoUri);
      ref.invalidate(allProfilesProvider);
      ref.invalidate(activeProfileProvider);
    });
  }

  Future<void> updateActiveProfileFull(Profile profile) async {
    final id = ref.read(activeProfileIdProvider);
    if (id == null) return;
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(repositoryProvider);
      await repo.updateProfileFull(profile.copyWith(id: id));
      ref.invalidate(allProfilesProvider);
      ref.invalidate(activeProfileProvider);
    });
  }

  String _todayDate() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }
}

final profileNotifierProvider =
    AsyncNotifierProvider<ProfileNotifier, void>(ProfileNotifier.new);
