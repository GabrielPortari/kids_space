import 'package:easy_localization/easy_localization.dart';

class LocalizationService {
  static String t(
    String key, {
    List<String>? args,
    Map<String, String>? namedArgs,
    String? defaultText,
  }) {
    try {
      final res = key.tr(args: args, namedArgs: namedArgs);
      if (res == null || res.isEmpty) return defaultText ?? key;
      return res;
    } catch (_) {
      return defaultText ?? key;
    }
  }
}

String translate(
  String key, {
  List<String>? args,
  Map<String, String>? namedArgs,
  String? defaultText,
}) => LocalizationService.t(
  key,
  args: args,
  namedArgs: namedArgs,
  defaultText: defaultText,
);
