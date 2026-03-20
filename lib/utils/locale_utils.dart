import 'package:flutter/widgets.dart';

/// Returns whether the given [locale] should use Chinese copy.
bool isZhLocale(Locale locale) =>
    locale.languageCode.toLowerCase().startsWith('zh');

/// Returns whether the active locale resolved from [context] should use Chinese copy.
bool isZhContext(BuildContext context) =>
    isZhLocale(Localizations.localeOf(context));
