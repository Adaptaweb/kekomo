import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/allergen.dart';
import '../data/allergen_knowledge_base.dart';
import 'profile_provider.dart';

/// Provider que retorna los alérgenos del perfil normalizados a las 14
/// categorías canónicas (Apio, Cacao, Trigo, Huevo, Leche, Mani, Mariscos,
/// Mostaza, Nuez, Palta, Pescado, Sesamo, Soya, Sulfitos).
/// Alérgenos con nombres antiguos (e.g. "Leche y Lácteos") se renombran
/// a su equivalente corto (e.g. "Leche") para mantener consistencia.
final normalizedAllergensProvider =
    FutureProvider.family<List<Allergen>, int>((ref, profileId) async {
  final raw = await ref.watch(allergensProvider(profileId).future);
  final repo = ref.read(repositoryProvider);

  final seen = <String>{};
  final result = <Allergen>[];
  final renames = <int, String>{};

  for (final a in raw) {
    final normalized = normalizeAllergenName(a.name);
    if (normalized != a.name && a.id != null) {
      renames[a.id!] = normalized;
    }
    if (seen.add(normalized)) {
      result.add(Allergen(
        id: a.id,
        profileId: a.profileId,
        name: normalized,
      ));
    }
  }

  if (renames.isNotEmpty) {
    for (final entry in renames.entries) {
      await repo.updateAllergen(Allergen(
        id: entry.key,
        profileId: profileId,
        name: entry.value,
      ));
    }
    ref.invalidate(allergensProvider(profileId));
  }

  return result;
});

final allergensProvider =
    FutureProvider.family<List<Allergen>, int>((ref, profileId) async {
  final repo = ref.read(repositoryProvider);
  return repo.getAllergensByProfileId(profileId);
});

final showAllergenDialogProvider = StateProvider<bool>((ref) => false);
final allergenInputProvider = StateProvider<String>((ref) => '');

class AllergenNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> addAllergen(int profileId, String name) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(repositoryProvider);
      final normalized = normalizeAllergenName(name);
      await repo.insertAllergen(
          Allergen(profileId: profileId, name: normalized));
      ref.invalidate(allergensProvider(profileId));
    });
  }

  Future<void> removeAllergen(int id) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(repositoryProvider);
      await repo.deleteAllergen(id);
      ref.invalidate(allergensProvider);
    });
  }

  Future<void> addInitialAllergens(int profileId, List<String> names) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(repositoryProvider);
      for (final name in names) {
        final normalized = normalizeAllergenName(name);
        await repo.insertAllergen(
            Allergen(profileId: profileId, name: normalized));
      }
      ref.invalidate(allergensProvider(profileId));
    });
  }

  Future<void> clearAll(int profileId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(repositoryProvider);
      await repo.clearAllAllergens(profileId);
      ref.invalidate(allergensProvider(profileId));
    });
  }
}

final allergenNotifierProvider =
    AsyncNotifierProvider<AllergenNotifier, void>(AllergenNotifier.new);
