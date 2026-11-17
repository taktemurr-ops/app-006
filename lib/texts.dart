import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class MacroTexts {
  const MacroTexts._();
  static const locales = [Locale('tr'), Locale('en'), Locale('ar')];
  static const delegates = [
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ];

  static String t(BuildContext context, String key) {
    final language = Localizations.localeOf(context).languageCode;
    return (_translations[language] ?? _translations['en']!)[key] ??
        _translations['en']![key] ?? key;
  }

  static const _translations = <String, Map<String, String>>{
    'tr': {
      'today': 'Bugün', 'foods': 'Besinler', 'log': 'Öğün Ekle', 'targets': 'Hedefler',
      'trends': 'Analiz', 'privacy': 'Gizlilik', 'foodName': 'Besin adı',
      'protein': 'Protein / 100 g', 'carbs': 'Karbonhidrat / 100 g',
      'fat': 'Yağ / 100 g', 'saveFood': 'Besini kaydet', 'selectFood': 'Besin',
      'serving': 'Porsiyon (g)', 'saveMeal': 'Öğün kaydet', 'deleteMeal': 'Öğünü sil',
      'dailyCalories': 'Günlük kalori', 'proteinPercent': 'Protein %',
      'carbsPercent': 'Karbonhidrat %', 'fatPercent': 'Yağ %',
      'saveTargets': 'Hedefleri kaydet', 'deleteAll': 'Tüm yerel verileri sil',
      'cancel': 'İptal', 'delete': 'Sil', 'retry': 'Tekrar dene',
      'todayMeals': 'Bugünkü öğünler', 'sevenDays': 'Yedi günlük özet',
      'nutritionNote': 'Besin değerleri tahminidir; tıbbi tavsiye değildir.',
      'privateData': 'Özel veri yönetimi', 'copyBackup': 'JSON yedeği kopyala',
      'restoreBackup': 'JSON yedeğini geri yükle', 'backupInput': 'JSON yedeğini yapıştır',
      'restore': 'Geri yükle', 'todayKcal': 'Bugün', 'recordedAverage': 'Kayıtlı günlerin ortalaması',
      'proteinCompletion': 'Protein hedefi tutturulan kayıtlı gün oranı',
      'privacyNote': 'Kayıtlar cihazın korumalı alanında tutulur. Panoya kopyalanan JSON şifreli değildir.',
      'restoreNotice': 'Geri yükleme mevcut tüm besin ve öğün kayıtlarını değiştirir.',
      'repeatYesterday': 'Dünkü öğünleri kopyala', 'noYesterday': 'Dün kayıtlı öğün yok',
    },
    'en': {
      'today': 'Today', 'foods': 'Foods', 'log': 'Log', 'targets': 'Targets',
      'trends': 'Trends', 'privacy': 'Privacy', 'foodName': 'Food name',
      'protein': 'Protein / 100 g', 'carbs': 'Carbs / 100 g',
      'fat': 'Fat / 100 g', 'saveFood': 'Save food', 'selectFood': 'Food',
      'serving': 'Serving (g)', 'saveMeal': 'Log meal', 'deleteMeal': 'Delete meal',
      'dailyCalories': 'Daily calories', 'proteinPercent': 'Protein %',
      'carbsPercent': 'Carbs %', 'fatPercent': 'Fat %',
      'saveTargets': 'Save targets', 'deleteAll': 'Delete all local data',
      'cancel': 'Cancel', 'delete': 'Delete', 'retry': 'Retry',
      'todayMeals': 'Today’s meals', 'sevenDays': 'Seven-day summary',
      'nutritionNote': 'Nutrition totals are estimates, not medical advice.',
      'privateData': 'Private data controls', 'copyBackup': 'Copy JSON backup',
      'restoreBackup': 'Restore from JSON', 'backupInput': 'Paste JSON backup',
      'restore': 'Restore', 'todayKcal': 'Today', 'recordedAverage': 'Average on logged days',
      'proteinCompletion': 'Protein target reached on logged days',
      'privacyNote': 'Records stay in this device’s secure storage. Clipboard JSON is NOT encrypted.',
      'restoreNotice': 'Restoring replaces all current food and meal entries.',
      'repeatYesterday': 'Copy yesterday’s meals', 'noYesterday': 'No meals logged yesterday',
    },
    'ar': {
      'today': 'اليوم', 'foods': 'الأطعمة', 'log': 'تسجيل وجبة', 'targets': 'الأهداف',
      'trends': 'التحليلات', 'privacy': 'الخصوصية', 'foodName': 'اسم الطعام',
      'protein': 'البروتين / 100 غ', 'carbs': 'الكربوهيدرات / 100 غ',
      'fat': 'الدهون / 100 غ', 'saveFood': 'حفظ الطعام', 'selectFood': 'الطعام',
      'serving': 'الحصة (غ)', 'saveMeal': 'تسجيل الوجبة', 'deleteMeal': 'حذف الوجبة',
      'dailyCalories': 'السعرات اليومية', 'proteinPercent': 'البروتين %',
      'carbsPercent': 'الكربوهيدرات %', 'fatPercent': 'الدهون %',
      'saveTargets': 'حفظ الأهداف', 'deleteAll': 'حذف البيانات المحلية',
      'cancel': 'إلغاء', 'delete': 'حذف', 'retry': 'إعادة المحاولة',
      'todayMeals': 'وجبات اليوم', 'sevenDays': 'ملخص سبعة أيام',
      'nutritionNote': 'القيم الغذائية تقديرية وليست نصيحة طبية.',
      'privateData': 'التحكم بالبيانات الخاصة', 'copyBackup': 'نسخ نسخة JSON',
      'restoreBackup': 'استعادة نسخة JSON', 'backupInput': 'الصق نسخة JSON',
      'restore': 'استعادة', 'todayKcal': 'اليوم', 'recordedAverage': 'متوسط الأيام المسجلة',
      'proteinCompletion': 'نسبة أيام تحقيق هدف البروتين',
      'privacyNote': 'تبقى البيانات محمية على جهازك. نسخة JSON في الحافظة غير مشفرة.',
      'restoreNotice': 'الاستعادة تستبدل جميع الأطعمة والوجبات الحالية.',
      'repeatYesterday': 'نسخ وجبات الأمس', 'noYesterday': 'لا توجد وجبات للأمس',
    },
  };
}
