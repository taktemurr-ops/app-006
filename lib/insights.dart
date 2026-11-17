import 'macros.dart';

/// Local-only nutrition reporting; never transmits dietary information.
class DailyMacroReport {
  const DailyMacroReport({required this.day, required this.calories,
    required this.protein, required this.carbs, required this.fat,
    required this.mealCount});
  final DateTime day;
  final double calories, protein, carbs, fat;
  final int mealCount;

  double calorieProgress(MacroProfile profile) =>
      (calories / profile.calories).clamp(0.0, 1.0);
  double proteinProgress(MacroProfile profile) =>
      profile.proteinGrams == 0 ? 0 : (protein / profile.proteinGrams).clamp(0.0, 1.0);

  static DailyMacroReport fromJournal(MacroJournal journal, DateTime date) {
    final meals = journal.forDay(date);
    double calories = 0, protein = 0, carbs = 0, fat = 0;
    for (final meal in meals) {
      calories += meal.kcal;
      protein += meal.protein;
      carbs += meal.carbs;
      fat += meal.fat;
    }
    return DailyMacroReport(day: DateTime(date.year, date.month, date.day),
      calories: calories, protein: protein, carbs: carbs, fat: fat,
      mealCount: meals.length);
  }
}

class MacroInsights {
  const MacroInsights._();
  static List<DailyMacroReport> lastSevenDays(MacroJournal journal, DateTime date) {
    final today = DateTime(date.year, date.month, date.day);
    return List<DailyMacroReport>.generate(7,
      (index) => DailyMacroReport.fromJournal(journal,
        today.subtract(Duration(days: 6 - index))));
  }

  static double averageCalories(List<DailyMacroReport> reports, {bool includeEmpty = false}) {
    final selected = includeEmpty ? reports : reports.where((r) => r.mealCount > 0).toList();
    return selected.isEmpty ? 0 : selected.fold<double>(0, (sum, item) => sum + item.calories) / selected.length;
  }

  static double proteinGoalCompletion(List<DailyMacroReport> reports, MacroProfile profile) {
    final recorded = reports.where((r) => r.mealCount > 0).toList();
    if (recorded.isEmpty || profile.proteinGrams <= 0) return 0;
    return recorded.where((r) => r.protein >= profile.proteinGrams).length / recorded.length;
  }
}
