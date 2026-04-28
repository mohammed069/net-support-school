import 'package:flutter/material.dart';

import '../localization/app_localizations.dart';

extension BuildContextX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this)!;

  bool get isArabic => Localizations.localeOf(this).languageCode == 'ar';
}
