import 'package:flutter_test/flutter_test.dart';
import 'package:makro_360/macros.dart';

void main() {
  test('macro calorie conversion and percentages', () {
    const p = MacroProfile(calories: 2000, proteinPercent: 30, carbsPercent: 45, fatPercent: 25);
    p.validate();
    expect(p.proteinGrams, 150);
    expect(p.carbsGrams, 225);
    expect(p.fatGrams, closeTo(55.5556, 0.001));
  });
  test('invalid target sum rejected', () {
    expect(() => const MacroProfile(calories: 2000, proteinPercent: 50, carbsPercent: 50, fatPercent: 50).validate(), throwsArgumentError);
  });
  test('food and serving calories', () {
    const food = MacroFood(id: 'f1', name: 'Test food', protein: 20, carbs: 10, fat: 5);
    food.validate();
    final meal = MacroMeal(id: 'm1', food: food, grams: 150, at: DateTime(2026, 11, 17));
    expect(meal.kcal, closeTo(247.5, 0.001));
  });
  test('journal export/import retains all entries', () {
    final journal = MacroJournal();
    const food = MacroFood(id: 'f1', name: 'Food', protein: 20, carbs: 10, fat: 5);
    journal.addFood(food);
    journal.log(MacroMeal(id: 'm1', food: food, grams: 150, at: DateTime(2026, 11, 17)));
    final restored = MacroJournal.importJson(journal.exportJson());
    expect(restored.foods.single.name, 'Food');
    expect(restored.meals.single.grams, 150);
  });
  test('reject invalid JSON schema', () {
    expect(() => MacroJournal.importJson('{"schemaVersion":99}'), throwsFormatException);
  });
}
