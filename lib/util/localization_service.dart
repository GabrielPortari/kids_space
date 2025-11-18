import 'package:easy_localization/easy_localization.dart';

class LocalizationService {
  static String t(String key, {List<String>? args, Map<String, String>? namedArgs}) {
    try {
      return key.tr(args: args, namedArgs: namedArgs);
    } catch (_) {
      return key;
    }
  }
}

String translate(String key, {List<String>? args, Map<String, String>? namedArgs}) =>
    LocalizationService.t(key, args: args, namedArgs: namedArgs);
