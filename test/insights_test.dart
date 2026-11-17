import 'package:flutter_test/flutter_test.dart';
import 'package:makro_360/insights.dart';
import 'package:makro_360/locale_number.dart';
import 'package:makro_360/macros.dart';

void main() {
  const rice = MacroFood(id: 'rice', name: 'Rice', protein: 3, carbs: 28, fat: 1);
  test('daily totals are local calendar day scoped', () {
    final book = MacroJournal();
    book.log(MacroMeal(id: 'm1', food: rice, grams: 100, at: DateTime(2026, 11, 17, 12)));
    book.log(MacroMeal(id: 'm2', food: rice, grams: 200, at: DateTime(2026, 11, 16, 12)));
    final report = DailyMacroReport.fromJournal(book, DateTime(2026, 11, 17));
    expect(report.mealCount, 1);
    expect(report.carbs, 28);
  });
  test('weekly report includes seven calendar days and no divide by zero', () {
    final reports = MacroInsights.lastSevenDays(MacroJournal(), DateTime(2026, 11, 17));
    expect(reports.length, 7);
    expect(reports.first.day.day, 11);
    expect(reports.last.day.day, 17);
    expect(MacroInsights.averageCalories(reports), 0);
    expect(MacroInsights.proteinGoalCompletion(reports, MacroJournal().profile), 0);
  });
  test('copying previous day creates new meals while preserving original', () {
    final book = MacroJournal();
    book.log(MacroMeal(id: 'old', food: rice, grams: 150, at: DateTime(2026, 11, 16, 19)));
    expect(book.copyDay(DateTime(2026, 11, 16), DateTime(2026, 11, 17)), 1);
    expect(book.forDay(DateTime(2026, 11, 16)).length, 1);
    expect(book.forDay(DateTime(2026, 11, 17)).single.grams, 150);
  });
  test('oversized backup is rejected before parsing', () {
    expect(() => MacroJournal.importJson(List.filled(2000001, 'x').join()), throwsFormatException);
  });
  test('Arabic and Persian digits work, grouping and malicious input reject', () {
    expect(parseMacroNumber('١٢٫٥'), 12.5);
    expect(parseMacroNumber('۱۲,۵'), 12.5);
    expect(parseMacroNumber('12.5'), 12.5);
    expect(parseMacroNumber('1,200,50'), isNull);
    expect(parseMacroNumber('Infinity'), isNull);
    expect(parseMacroNumber('-1'), isNull);
    expect(parseMacroWholeNumber('٢٥'), 25);
    expect(parseMacroWholeNumber('2.5'), isNull);
  });
}
