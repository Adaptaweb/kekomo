import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../data/models/meal_log.dart';
import '../data/models/reaction.dart';
import '../data/models/allergen.dart';
import '../data/allergen_knowledge_base.dart';

import 'meal_log_provider.dart';
import 'reaction_provider.dart';
import 'allergen_provider.dart';
import 'settings_provider.dart';

class AllergenInsightData {
  final String allergenName;
  final int totalAppearances;
  final int appearancesNearReaction;
  final List<String> matchedProducts;

  const AllergenInsightData({
    required this.allergenName,
    required this.totalAppearances,
    required this.appearancesNearReaction,
    required this.matchedProducts,
  });

  String get description {
    if (matchedProducts.isNotEmpty) {
      final unique = matchedProducts.toSet().toList();
      return 'Detectado en: ${unique.take(4).join(", ")}'
          '${unique.length > 4 ? "..." : ""}';
    }
    return 'Registrado $totalAppearances ${totalAppearances == 1 ? 'vez' : 'veces'}';
  }
}

class WeeklySummary {
  final Map<int, Set<String>> mealsByDay;
  final int completionPercent;
  final int reactionCount;
  final int allergenCount;
  final List<AllergenInsightData> allergenInsights;
  final int totalLogged;
  final int pendingSlots;
  final int totalSlotsToDate;
  final int daysElapsed;
  final int mealTypesPerDay;

  const WeeklySummary({
    required this.mealsByDay,
    required this.completionPercent,
    required this.reactionCount,
    required this.allergenCount,
    required this.allergenInsights,
    required this.totalLogged,
    required this.pendingSlots,
    required this.totalSlotsToDate,
    required this.daysElapsed,
    required this.mealTypesPerDay,
  });
}

({String from, String to, int daysElapsed, int daysRemaining}) _weekRange() {
  final now = DateTime.now();
  final weekday = now.weekday;
  final monday = now.subtract(Duration(days: weekday - 1));
  final fmt = DateFormat('yyyy-MM-dd');
  return (
    from: fmt.format(monday),
    to: fmt.format(now),
    daysElapsed: weekday,
    daysRemaining: 7 - weekday,
  );
}

final weeklySummaryProvider =
    FutureProvider.family<WeeklySummary, int>((ref, profileId) async {
  final range = _weekRange();
  final includeDinner = ref.watch(mealIncludeDinnerProvider);

  final mealsAsync = ref.watch(mealLogsByDateRangeProvider(
    DateRangeArgs(profileId: profileId, from: range.from, to: range.to),
  ));

  final reactionsAsync = ref.watch(reactionsByDateRangeProvider(
    ReactionDateRangeArgs(profileId: profileId, from: range.from, to: range.to),
  ));

  final allergensAsync = ref.watch(normalizedAllergensProvider(profileId));

  final meals = mealsAsync.maybeWhen(data: (m) => m, orElse: () => <MealLog>[]);
  final reactions =
      reactionsAsync.maybeWhen(data: (r) => r, orElse: () => <Reaction>[]);
  final allergens =
      allergensAsync.maybeWhen(data: (a) => a, orElse: () => <Allergen>[]);

  final mainMeals = meals.where((m) => m.mealType != 'Colaciones').toList();
  final mainReactions =
      reactions.where((r) => r.mealType != 'Colaciones').toList();

  final mealsByDay = <int, Set<String>>{};
  for (int i = 0; i < 7; i++) {
    mealsByDay[i] = {};
  }

  final monday = DateTime.parse(range.from);
  for (final meal in mainMeals) {
    final d = DateTime.parse(meal.date);
    final diff = d.difference(monday).inDays;
    if (diff >= 0 && diff < 7) {
      mealsByDay[diff] = {...mealsByDay[diff]!, meal.mealType};
    }
  }

  final mealTypesPerDay = includeDinner ? 4 : 3;
  final totalLogged =
      mealsByDay.values.fold<int>(0, (a, b) => a + b.length);
  final totalSlotsToDate = mealTypesPerDay * range.daysElapsed;

  final loggedToday = DateTime.now().weekday - 1;
  final todayLogged = mealsByDay[loggedToday]?.length ?? 0;
  final pendingToday =
      (mealTypesPerDay - todayLogged).clamp(0, mealTypesPerDay);
  final pendingSlots = pendingToday;

  final completionPercent = totalSlotsToDate > 0
      ? ((totalLogged / totalSlotsToDate) * 100).round().clamp(0, 100)
      : 0;

  final reactionDates = mainReactions.map((r) => r.date).toSet();

  final allergenInsights = <AllergenInsightData>[];
  for (final allergen in allergens) {
    final products = productsForProfileAllergen(allergen.name);
    if (products.isEmpty) continue;

    final normalizedProducts = products
        .map((p) => normalizeAllergenText(p))
        .where((p) => p.length >= 3)
        .toList();

    int totalApps = 0;
    int nearReaction = 0;
    final matchedSet = <String>{};

    for (final meal in mainMeals) {
      final mealText = normalizeAllergenText(meal.foodItemsText);
      final mealMatched = <String>{};
      for (final product in normalizedProducts) {
        if (mealText.contains(product)) {
          mealMatched.add(product);
        }
      }
      if (mealMatched.isNotEmpty) {
        totalApps++;
        matchedSet.addAll(mealMatched);
        if (reactionDates.contains(meal.date)) {
          nearReaction++;
        }
      }
    }
    if (totalApps > 0) {
      allergenInsights.add(AllergenInsightData(
        allergenName: allergen.name,
        totalAppearances: totalApps,
        appearancesNearReaction: nearReaction,
        matchedProducts: matchedSet.toList(),
      ));
    }
  }

  allergenInsights.sort((a, b) {
    final byReactions =
        b.appearancesNearReaction.compareTo(a.appearancesNearReaction);
    if (byReactions != 0) return byReactions;
    return b.totalAppearances.compareTo(a.totalAppearances);
  });

  return WeeklySummary(
    mealsByDay: mealsByDay,
    completionPercent: completionPercent,
    reactionCount: mainReactions.length,
    allergenCount: allergens.length,
    allergenInsights: allergenInsights,
    totalLogged: totalLogged,
    pendingSlots: pendingSlots,
    totalSlotsToDate: totalSlotsToDate,
    daysElapsed: range.daysElapsed,
    mealTypesPerDay: mealTypesPerDay,
  );
});
