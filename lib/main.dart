import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'insights.dart';
import 'texts.dart';
import 'locale_number.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'macros.dart';

void main() { WidgetsFlutterBinding.ensureInitialized(); runApp(const Makro360App()); }

class Makro360App extends StatelessWidget {
  const Makro360App({super.key});
  @override Widget build(BuildContext context) => MaterialApp(
    title: 'Makro 360',
    supportedLocales: MacroTexts.locales,
    localizationsDelegates: MacroTexts.delegates,
    theme: ThemeData(useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xff087e65))),
    home: const MacroHome());
}

class MacroHome extends StatefulWidget {
  const MacroHome({super.key});
  @override State<MacroHome> createState() => _MacroHomeState();
}

class _MacroHomeState extends State<MacroHome> {
  static const storage = FlutterSecureStorage();
  MacroJournal journal = MacroJournal();
  bool loading = true;
  String? error;
  int tab = 0;
  final name = TextEditingController();
  final protein = TextEditingController();
  final carbs = TextEditingController();
  final fat = TextEditingController();
  final grams = TextEditingController(text: '100');
  final importController = TextEditingController();
  final calories = TextEditingController(text: '2000');
  final ratios = [TextEditingController(text: '30'), TextEditingController(text: '45'), TextEditingController(text: '25')];
  MacroFood? selected;
  @override void initState() { super.initState(); _load(); }
  Future<void> _load() async {
    try {
      final raw = await storage.read(key: 'macro_journal_v1');
      final loaded = raw == null ? MacroJournal() : MacroJournal.importJson(raw);
      if (mounted) setState(() { journal = loaded; loading = false; error = null; });
    } catch (_) { if (mounted) setState(() { loading = false; error = 'Unable to read private journal'; }); }
  }
  Future<void> _save() async {
    try { await storage.write(key: 'macro_journal_v1', value: journal.exportJson()); if (mounted) setState(() {}); }
    catch (_) { _notice('Unable to save. Your last change may not be persisted.'); }
  }
  void _notice(String message) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message))); }
  double? _number(TextEditingController c) => parseMacroNumber(c.text);
  void _addFood() {
    final p = _number(protein), c = _number(carbs), f = _number(fat);
    if (p == null || c == null || f == null) { _notice('Enter valid nutrients'); return; }
    try {
      final food = MacroFood(id: DateTime.now().microsecondsSinceEpoch.toString(), name: name.text.trim(), protein: p, carbs: c, fat: f);
      journal.addFood(food); selected = food; name.clear(); protein.clear(); carbs.clear(); fat.clear(); _save();
    } catch (_) { _notice('Check food name and nutrient values'); }
  }
  void _logMeal() {
    final amount = _number(grams);
    if (selected == null || amount == null) { _notice('Choose a food and quantity'); return; }
    try { journal.log(MacroMeal(id: DateTime.now().microsecondsSinceEpoch.toString(), food: selected!, grams: amount, at: DateTime.now())); _save(); }
    catch (_) { _notice('Invalid serving size'); }
  }
  void _updateTargets() {
    try {
      final energy = parseMacroWholeNumber(calories.text, minimum: 500, maximum: 10000);
      final protein = parseMacroWholeNumber(ratios[0].text, maximum: 100);
      final carbs = parseMacroWholeNumber(ratios[1].text, maximum: 100);
      final fat = parseMacroWholeNumber(ratios[2].text, maximum: 100);
      if (energy == null || protein == null || carbs == null || fat == null) throw const FormatException('Invalid target');
      final next = MacroProfile(calories: energy, proteinPercent: protein,
        carbsPercent: carbs, fatPercent: fat);
      next.validate(); journal.profile = next; _save();
    } catch (_) { _notice('Target percentages must total 100 and calories 500–10000'); }
  }
  @override void dispose() { for (final c in [name, protein, carbs, fat, grams, calories, importController, ...ratios]) { c.dispose(); } super.dispose(); }
  String _t(String key) => MacroTexts.t(context, key);
  Widget _field(String label, TextEditingController controller, {bool numeric = true}) => Padding(
    padding: const EdgeInsets.only(bottom: 8), child: TextField(controller: controller,
      keyboardType: numeric ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
      decoration: InputDecoration(labelText: label, border: const OutlineInputBorder())));
  Widget _dashboard() {
    final now = DateTime.now();
    final p = journal.profile;
    final values = [journal.total(now, (m) => m.protein), journal.total(now, (m) => m.carbs), journal.total(now, (m) => m.fat)];
    final targets = [p.proteinGrams, p.carbsGrams, p.fatGrams];
    final labels = ['Protein', 'Carbohydrate', 'Fat'];
    return ListView(children: [
      Text('Today: ${journal.total(now, (m) => m.kcal).toStringAsFixed(0)} / ${p.calories} kcal', style: Theme.of(context).textTheme.titleLarge),
      const SizedBox(height: 16),
      for (var i = 0; i < 3; i++) Card(child: ListTile(title: Text(labels[i]), subtitle: LinearProgressIndicator(
        value: (values[i] / targets[i]).clamp(0.0, 1.0)), trailing: Text('${values[i].toStringAsFixed(1)} / ${targets[i].toStringAsFixed(1)} g'))),
      const SizedBox(height: 12), Text(_t('todayMeals'), style: Theme.of(context).textTheme.titleMedium),
      for (final m in journal.forDay(now)) ListTile(title: Text(m.food.name), subtitle: Text('${m.grams} g'), trailing: Text('${m.kcal.toStringAsFixed(0)} kcal')),
    ]);
  }
  Widget _foods() => ListView(children: [
    _field(_t('foodName'), name, numeric: false), _field(_t('protein'), protein), _field(_t('carbs'), carbs), _field(_t('fat'), fat),
    FilledButton(onPressed: _addFood, child: Text(_t('saveFood'))),
    const Divider(),
    for (final food in journal.foods) ListTile(title: Text(food.name), subtitle: Text('P ${food.protein} · C ${food.carbs} · F ${food.fat}'),
      trailing: Text('${food.kcal.toStringAsFixed(0)} kcal')),
  ]);
  Widget _log() => ListView(children: [
    DropdownButtonFormField<String>(value: selected?.id, decoration: InputDecoration(labelText: _t('selectFood')),
      items: journal.foods.map((f) => DropdownMenuItem(value: f.id, child: Text(f.name))).toList(),
      onChanged: (id) => setState(() { selected = journal.foods.where((f) => f.id == id).firstOrNull; })),
    const SizedBox(height: 12), _field(_t('serving'), grams),
    FilledButton(onPressed: _logMeal, child: Text(_t('saveMeal'))),
    const Divider(),
    OutlinedButton.icon(icon: const Icon(Icons.content_copy),
      label: Text(_t('repeatYesterday')),
      onPressed: () {
        final now = DateTime.now();
        final count = journal.copyDay(now.subtract(const Duration(days: 1)), now);
        if (count == 0) { _notice(_t('noYesterday')); } else { _save(); }
      }),
    for (final m in journal.meals.reversed) ListTile(title: Text(m.food.name), subtitle: Text(m.at.toLocal().toString()),
      trailing: IconButton(tooltip: _t('deleteMeal'), icon: const Icon(Icons.delete_outline), onPressed: () { journal.meals.remove(m); _save(); })),
  ]);
  Widget _targets() => ListView(children: [
    _field(_t('dailyCalories'), calories), _field(_t('proteinPercent'), ratios[0]), _field(_t('carbsPercent'), ratios[1]), _field(_t('fatPercent'), ratios[2]),
    FilledButton(onPressed: _updateTargets, child: Text(_t('saveTargets'))),
    const SizedBox(height: 24), OutlinedButton(onPressed: () async {
      final yes = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(title: Text(_t('deleteAll')),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(_t('cancel'))),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text(_t('delete')))]));
      if (yes == true) { await storage.delete(key: 'macro_journal_v1'); if (mounted) setState(() { journal = MacroJournal(); selected = null; }); }
    }, child: Text(_t('deleteAll'))),
  ]);

  Widget _insights() {
    final reports = MacroInsights.lastSevenDays(journal, DateTime.now());
    final avg = MacroInsights.averageCalories(reports);
    final progress = MacroInsights.proteinGoalCompletion(reports, journal.profile);
    return ListView(children: [
      Text(_t('sevenDays'), style: Theme.of(context).textTheme.titleLarge),
      const SizedBox(height: 8),
      Text('Average on logged days: ${avg.toStringAsFixed(0)} kcal'),
      Text('Protein target reached on ${(progress * 100).toStringAsFixed(0)}% of logged days'),
      const SizedBox(height: 16),
      for (final report in reports) Card(child: ListTile(
        title: Text('${report.day.day}.${report.day.month}.${report.day.year}'),
        subtitle: LinearProgressIndicator(value: report.calorieProgress(journal.profile)),
        trailing: Text('${report.calories.toStringAsFixed(0)} kcal · ${report.mealCount} meals'),
      )),
      const SizedBox(height: 12),
      Text(_t('nutritionNote')),
    ]);
  }

  Widget _privacy() {
    return ListView(children: [
      Text(_t('privateData'), style: Theme.of(context).textTheme.titleLarge),
      const SizedBox(height: 12),
      Text(_t('privacyNote')),
      const SizedBox(height: 12),
      FilledButton.icon(
        icon: const Icon(Icons.copy_all_outlined),
        onPressed: () async {
          await Clipboard.setData(ClipboardData(text: journal.exportJson()));
          _notice('Backup JSON copied to clipboard. Treat as sensitive data.');
        },
        label: Text(_t('copyBackup')),
      ),
      const SizedBox(height: 12),
      OutlinedButton.icon(
        icon: const Icon(Icons.restore_outlined),
        onPressed: () async {
          final confirmed = await showDialog<bool>(context: context, builder: (dialogContext) => AlertDialog(
            title: Text(_t('restoreBackup')),
            content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
              Text(_t('restoreNotice')),
              const SizedBox(height: 12),
              TextField(controller: importController, maxLines: 5, decoration: InputDecoration(
                labelText: _t('backupInput'), border: OutlineInputBorder())),
            ])),
            actions: [TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: Text(_t('cancel'))),
              FilledButton(onPressed: () => Navigator.pop(dialogContext, true), child: Text(_t('restore')))],
          ));
          if (confirmed != true) return;
          try {
            final restored = MacroJournal.importJson(importController.text);
            await storage.write(key: 'macro_journal_v1', value: restored.exportJson());
            if (mounted) setState(() { journal = restored; selected = null; });
            _notice('Backup restored');
          } catch (_) { _notice('Invalid backup; existing entries preserved'); }
        },
        label: Text(_t('restoreBackup')),
      ),
    ]);
  }
  @override Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('Makro 360')),
    body: loading ? const Center(child: CircularProgressIndicator()) : error != null ? Center(child: Column(
      mainAxisSize: MainAxisSize.min, children: [Text(error!), TextButton(onPressed: _load, child: Text(_t('retry')))])) :
      Padding(padding: const EdgeInsets.all(16), child: [_dashboard(), _foods(), _log(), _targets(), _insights(), _privacy()][tab]),
    bottomNavigationBar: NavigationBar(selectedIndex: tab, onDestinationSelected: (v) => setState(() => tab = v), destinations: [
      NavigationDestination(icon: Icon(Icons.dashboard_outlined), label: _t('today')),
      NavigationDestination(icon: Icon(Icons.restaurant_menu), label: _t('foods')),
      NavigationDestination(icon: Icon(Icons.add_circle_outline), label: _t('log')),
      NavigationDestination(icon: Icon(Icons.tune), label: _t('targets')),
      NavigationDestination(icon: Icon(Icons.insights_outlined), label: _t('trends')),
      NavigationDestination(icon: Icon(Icons.privacy_tip_outlined), label: _t('privacy')),
    ]));
}
