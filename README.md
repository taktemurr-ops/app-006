# APP-006 — Makro 360 (development, not yet a released package)

Offline-first macro dashboard, custom foods, meal history, goal percentages and grams, weekly analysis, international-digit parsing, privacy-conscious local secure storage and validated JSON import/export. Targets are general tracking examples, **not personalized medical prescriptions**.

Run `flutter create --platforms=android,ios --project-name makro_360 .`, then `flutter pub get`, `dart format lib test`, `flutter analyze`, `flutter test`, `flutter build apk --debug`. GitHub Actions runs these steps after a source upload.

**Not release complete:** native device validation, localization, production monetization, store metadata, accessibility review and original 20-module catalogue acceptance are required. The source is not to be represented as final until those are verified.
