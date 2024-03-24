//*************   © Copyrighted by aagama_it. 

import 'dart:convert';
import 'package:aagama_it/Localization/language_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppLocalizationForCurrentUser {
  AppLocalizationForCurrentUser(this.locale);

  final Locale locale;
  static AppLocalizationForCurrentUser? of(BuildContext context) {
    return Localizations.of<AppLocalizationForCurrentUser>(
        context, AppLocalizationForCurrentUser);
  }

  late Map<String, String> _localizedValues;

  Future<void> load() async {
    String jsonStringValues = await rootBundle.loadString(
        'lib/Localization/json_languages/${locale.languageCode}.json');
    Map<String, dynamic> mappedJson = json.decode(jsonStringValues);
    _localizedValues =
        mappedJson.map((key, value) => MapEntry(key, value.toString()));
  }

  String? translate(String key) {
    return _localizedValues[key];
  }

  // static member to have simple access to the delegate from Material App
  static const LocalizationsDelegate<AppLocalizationForCurrentUser> delegate =
      _AppLocalizationForCurrentUserDelegate();
}

class _AppLocalizationForCurrentUserDelegate
    extends LocalizationsDelegate<AppLocalizationForCurrentUser> {
  const _AppLocalizationForCurrentUserDelegate();

  @override
  bool isSupported(Locale locale) {
    return languagelist.contains(locale.languageCode);
  }

  @override
  Future<AppLocalizationForCurrentUser> load(Locale locale) async {
    AppLocalizationForCurrentUser localization =
        new AppLocalizationForCurrentUser(locale);
    await localization.load();
    return localization;
  }

  @override
  bool shouldReload(LocalizationsDelegate<AppLocalizationForCurrentUser> old) =>
      false;
}
