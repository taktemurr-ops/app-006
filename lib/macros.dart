import 'dart:convert';

class MacroProfile {
  const MacroProfile({required this.calories, required this.proteinPercent,
    required this.carbsPercent, required this.fatPercent});
  final int calories, proteinPercent, carbsPercent, fatPercent;
  void validate() {
    if (calories < 500 || calories > 10000 || proteinPercent < 0 || carbsPercent < 0 || fatPercent < 0 ||
        proteinPercent + carbsPercent + fatPercent != 100) {
      throw ArgumentError('Invalid macro targets');
    }
  }
  double get proteinGrams => calories * proteinPercent / 100 / 4;
  double get carbsGrams => calories * carbsPercent / 100 / 4;
  double get fatGrams => calories * fatPercent / 100 / 9;
  Map<String, dynamic> toJson() => {'calories': calories, 'protein': proteinPercent, 'carbs': carbsPercent, 'fat': fatPercent};
  factory MacroProfile.fromJson(Map<String, dynamic> json) => MacroProfile(
    calories: (json['calories'] as num).toInt(), proteinPercent: (json['protein'] as num).toInt(),
    carbsPercent: (json['carbs'] as num).toInt(), fatPercent: (json['fat'] as num).toInt())..validate();
}

class MacroFood {
  const MacroFood({required this.id, required this.name, required this.protein,
    required this.carbs, required this.fat});
  final String id, name;
  final double protein, carbs, fat; // per 100 grams
  double get kcal => protein * 4 + carbs * 4 + fat * 9;
  void validate() {
    if (id.isEmpty || name.trim().isEmpty || name.length > 120 ||
        ![protein, carbs, fat].every((v) => v.isFinite && v >= 0 && v <= 100) ||
        protein + carbs + fat > 100.00001) throw ArgumentError('Invalid food');
  }
  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'protein': protein, 'carbs': carbs, 'fat': fat};
  factory MacroFood.fromJson(Map<String, dynamic> json) => MacroFood(
    id: json['id'] as String, name: json['name'] as String,
    protein: (json['protein'] as num).toDouble(), carbs: (json['carbs'] as num).toDouble(),
    fat: (json['fat'] as num).toDouble())..validate();
}

class MacroMeal {
  const MacroMeal({required this.id, required this.food, required this.grams, required this.at});
  final String id;
  final MacroFood food;
  final double grams;
  final DateTime at;
  double get protein => food.protein * grams / 100;
  double get carbs => food.carbs * grams / 100;
  double get fat => food.fat * grams / 100;
  double get kcal => protein * 4 + carbs * 4 + fat * 9;
  void validate() {
    food.validate();
    if (id.isEmpty || !grams.isFinite || grams <= 0 || grams > 10000) throw ArgumentError('Invalid meal');
  }
  Map<String, dynamic> toJson() => {'id': id, 'food': food.toJson(), 'grams': grams, 'at': at.toUtc().toIso8601String()};
  factory MacroMeal.fromJson(Map<String, dynamic> json) => MacroMeal(
    id: json['id'] as String, food: MacroFood.fromJson(Map<String, dynamic>.from(json['food'] as Map)),
    grams: (json['grams'] as num).toDouble(), at: DateTime.parse(json['at'] as String))..validate();
}

class MacroJournal {
  MacroJournal({MacroProfile? profile}) : profile = profile ?? const MacroProfile(
    calories: 2000, proteinPercent: 30, carbsPercent: 45, fatPercent: 25);
  MacroProfile profile;
  final foods = <MacroFood>[];
  final meals = <MacroMeal>[];
  List<MacroMeal> forDay(DateTime day) => meals.where((m) {
    final local = m.at.toLocal();
    return local.year == day.year && local.month == day.month && local.day == day.day;
  }).toList();
  double total(DateTime day, double Function(MacroMeal) value) => forDay(day).fold(0, (sum, m) => sum + value(m));
  void addFood(MacroFood food) { food.validate(); if (foods.any((f) => f.id == food.id)) throw StateError('Duplicate food'); foods.add(food); }
  void log(MacroMeal meal) { meal.validate(); if (meals.any((m) => m.id == meal.id)) throw StateError('Duplicate meal'); meals.add(meal); }
  /// Copies meals from one calendar day into another without modifying history.
  /// Returns the number of copied servings.
  int copyDay(DateTime source, DateTime target) {
    final prior = forDay(source);
    for (var i = 0; i < prior.length; i++) {
      final original = prior[i];
      final originalLocal = original.at.toLocal();
      log(MacroMeal(
        id: 'copied-${DateTime.now().microsecondsSinceEpoch}-$i',
        food: original.food, grams: original.grams,
        at: DateTime(target.year, target.month, target.day,
          originalLocal.hour, originalLocal.minute),
      ));
    }
    return prior.length;
  }

  String exportJson() => jsonEncode({'schemaVersion': 1, 'profile': profile.toJson(),
    'foods': foods.map((e) => e.toJson()).toList(), 'meals': meals.map((e) => e.toJson()).toList()});
  static MacroJournal importJson(String source) {
    if (source.length > 2000000) throw const FormatException('Backup exceeds allowed size');
    final data = Map<String, dynamic>.from(jsonDecode(source) as Map);
    if (data['schemaVersion'] != 1) throw const FormatException('Unsupported schema');
    if (data['foods'] is! List || (data['foods'] as List).length > 10000 ||
        data['meals'] is! List || (data['meals'] as List).length > 50000) {
      throw const FormatException('Malformed or oversized backup');
    }
    final result = MacroJournal(profile: MacroProfile.fromJson(Map<String, dynamic>.from(data['profile'] as Map)));
    for (final raw in data['foods'] as List) { result.addFood(MacroFood.fromJson(Map<String, dynamic>.from(raw as Map))); }
    for (final raw in data['meals'] as List) { result.log(MacroMeal.fromJson(Map<String, dynamic>.from(raw as Map))); }
    return result;
  }
}
