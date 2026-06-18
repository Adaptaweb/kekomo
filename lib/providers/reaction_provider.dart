import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/reaction.dart';
import 'profile_provider.dart';

final reactionsByDateProvider =
    FutureProvider.family<List<Reaction>, ReactionDateArgs>((ref, args) async {
  final repo = ref.read(repositoryProvider);
  return repo.getReactionsByDate(args.profileId, args.date);
});

final allReactionsProvider =
    FutureProvider.family<List<Reaction>, int>((ref, profileId) async {
  final repo = ref.read(repositoryProvider);
  return repo.getAllReactions(profileId);
});

final reactionsByDateRangeProvider =
    FutureProvider.family<List<Reaction>, ReactionDateRangeArgs>(
        (ref, args) async {
  final repo = ref.read(repositoryProvider);
  return repo.getReactionsByDateRange(args.profileId, args.from, args.to);
});

class ReactionDateRangeArgs {
  final int profileId;
  final String from;
  final String to;

  const ReactionDateRangeArgs({
    required this.profileId,
    required this.from,
    required this.to,
  });

  @override
  bool operator ==(Object other) =>
      other is ReactionDateRangeArgs &&
      other.profileId == profileId &&
      other.from == from &&
      other.to == to;

  @override
  int get hashCode => Object.hash(profileId, from, to);
}

class ReactionDateArgs {
  final int profileId;
  final String date;

  ReactionDateArgs(this.profileId, this.date);

  @override
  bool operator ==(Object other) =>
      other is ReactionDateArgs &&
      other.profileId == profileId &&
      other.date == date;

  @override
  int get hashCode => Object.hash(profileId, date);
}

final reactionDialogMealTypeProvider = StateProvider<String?>((ref) => null);
final reactionDialogSymptomsProvider = StateProvider<String>((ref) => '');
final reactionDialogDescriptionProvider = StateProvider<String>((ref) => '');

class ReactionNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> triggerReactionPrompt(
      int profileId, String date, String mealType) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(repositoryProvider);
      final existing = await repo.getReaction(profileId, date, mealType);
      ref.read(reactionDialogMealTypeProvider.notifier).state = mealType;
      if (existing != null) {
        ref.read(reactionDialogSymptomsProvider.notifier).state =
            existing.symptoms;
        ref.read(reactionDialogDescriptionProvider.notifier).state =
            existing.description;
      } else {
        ref.read(reactionDialogSymptomsProvider.notifier).state = '';
        ref.read(reactionDialogDescriptionProvider.notifier).state = '';
      }
    });
  }

  Future<void> confirmReaction(int profileId, String date) async {
    final mealType = ref.read(reactionDialogMealTypeProvider);
    if (mealType == null) {
      state = AsyncError(
        StateError('No hay tipo de comida activo para la reacción'),
        StackTrace.current,
      );
      return;
    }
    final symptoms = ref.read(reactionDialogSymptomsProvider);
    final description = ref.read(reactionDialogDescriptionProvider);

    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(repositoryProvider);
      final existing = await repo.getReaction(profileId, date, mealType);
      // Si ya existe, conservamos su id para que updateReaction (que filtra
      // por id) no afecte a otras filas en el futuro.
      final reaction = Reaction(
        id: existing?.id,
        profileId: profileId,
        date: date,
        mealType: mealType,
        symptoms: symptoms,
        description: description,
      );
      if (existing != null) {
        await repo.updateReaction(reaction);
      } else {
        await repo.insertReaction(reaction);
      }
      ref.read(reactionDialogMealTypeProvider.notifier).state = null;
      ref.read(reactionDialogSymptomsProvider.notifier).state = '';
      ref.read(reactionDialogDescriptionProvider.notifier).state = '';
      _invalidate(profileId, date);
    });
  }

  Future<void> deleteReactionById(int id, int profileId, String date) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(repositoryProvider);
      await repo.deleteReactionById(id);
      _invalidate(profileId, date);
    });
  }

  /// Compatibilidad: borra la reacción identificada por la sección
  /// (perfil + fecha + tipo de comida). Hace un lookup previo del id
  /// y luego borra por id para no afectar filas con misma sección.
  Future<void> deleteReaction(
      int profileId, String date, String mealType) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final repo = ref.read(repositoryProvider);
      final existing = await repo.getReaction(profileId, date, mealType);
      if (existing?.id != null) {
        await repo.deleteReactionById(existing!.id!);
      }
      _invalidate(profileId, date);
    });
  }

  void _invalidate(int profileId, String date) {
    ref.invalidate(reactionsByDateProvider(ReactionDateArgs(profileId, date)));
    ref.invalidate(allReactionsProvider(profileId));
    ref.invalidate(reactionsByDateRangeProvider);
  }
}

final reactionNotifierProvider =
    AsyncNotifierProvider<ReactionNotifier, void>(ReactionNotifier.new);
