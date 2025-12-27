import 'package:flutter/material.dart';

/// AppText: Design system de tipografia com variações prontas.
/// Use `AppText.headerLarge(context)` ou `AppText.bodyMedium(context)` para obter estilos.

class _TextWidgetBase extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final double? fontSize;
  final TextOverflow? overflow;
  final int? maxLines;
  final bool heavy;
  final TextStyle? themeStyle;
  final TextAlign? textAlign;
  final TextDirection? textDirection;
  final String? semanticsLabel;
  final bool? softWrap;
  final double? textScaleFactor;

  const _TextWidgetBase({
    Key? key,
    required this.text,
    this.style,
    this.fontSize,
    this.overflow,
    this.maxLines,
    this.heavy = false,
    this.themeStyle,
    this.textAlign,
    this.textDirection,
    this.semanticsLabel,
    this.softWrap,
    this.textScaleFactor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Merge theme style and explicit style so explicit values override theme
    TextStyle base = (themeStyle ?? const TextStyle()).merge(style);
    if (fontSize != null) base = base.copyWith(fontSize: fontSize);
    if (heavy) base = base.copyWith(fontWeight: FontWeight.w700);

    final Color finalColor = style?.color ?? themeStyle?.color ?? theme.colorScheme.onSurface;
    base = base.copyWith(color: finalColor);

    return Text(
      text,
      style: base,
      overflow: overflow,
      maxLines: maxLines,
      textAlign: textAlign,
      textDirection: textDirection,
      semanticsLabel: semanticsLabel,
      softWrap: softWrap,
      textScaleFactor: textScaleFactor,
    );
  }
}

// Now expose specific widgets that map to textTheme roles.
class TextHeaderLarge extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final double? fontSize;
  final TextOverflow? overflow;
  final int? maxLines;
  final bool heavy;
    final TextAlign? textAlign;
    final TextDirection? textDirection;
    final String? semanticsLabel;
    final bool? softWrap;
    final double? textScaleFactor;

  const TextHeaderLarge(
    this.text, {
    Key? key,
    this.style,
    this.fontSize,
    this.overflow,
    this.maxLines,
    this.heavy = false,
    this.textAlign,
    this.textDirection,
    this.semanticsLabel,
    this.softWrap,
    this.textScaleFactor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeStyle = Theme.of(context).textTheme.headlineLarge ?? const TextStyle(fontSize: 28, height: 1.2);
    return _TextWidgetBase(
      text: text,
      style: style,
      fontSize: fontSize,
      overflow: overflow,
      maxLines: maxLines,
      heavy: heavy,
      themeStyle: themeStyle,
      textAlign: textAlign,
      textDirection: textDirection,
      semanticsLabel: semanticsLabel,
      softWrap: softWrap,
      textScaleFactor: textScaleFactor,
    );
  }
}

class TextHeaderMedium extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final double? fontSize;
  final TextOverflow? overflow;
  final int? maxLines;
  final bool heavy;
    final TextAlign? textAlign;
    final TextDirection? textDirection;
    final String? semanticsLabel;
    final bool? softWrap;
    final double? textScaleFactor;

  const TextHeaderMedium(
    this.text, {
    Key? key,
    this.style,
    this.fontSize,
    this.overflow,
    this.maxLines,
    this.heavy = false,
    this.textAlign,
    this.textDirection,
    this.semanticsLabel,
    this.softWrap,
    this.textScaleFactor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeStyle = Theme.of(context).textTheme.headlineMedium ?? const TextStyle(fontSize: 22, height: 1.25);
    return _TextWidgetBase(
      text: text,
      style: style,
      fontSize: fontSize,
      overflow: overflow,
      maxLines: maxLines,
      heavy: heavy,
      themeStyle: themeStyle,
      textAlign: textAlign,
      textDirection: textDirection,
      semanticsLabel: semanticsLabel,
      softWrap: softWrap,
      textScaleFactor: textScaleFactor,
    );
  }
}

class TextHeaderSmall extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final double? fontSize;
  final TextOverflow? overflow;
  final int? maxLines;
  final bool heavy;
    final TextAlign? textAlign;
    final TextDirection? textDirection;
    final String? semanticsLabel;
    final bool? softWrap;
    final double? textScaleFactor;

  const TextHeaderSmall(
    this.text, {
    Key? key,
    this.style,
    this.fontSize,
    this.overflow,
    this.maxLines,
    this.heavy = false,
    this.textAlign,
    this.textDirection,
    this.semanticsLabel,
    this.softWrap,
    this.textScaleFactor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeStyle = Theme.of(context).textTheme.headlineSmall ?? const TextStyle(fontSize: 18, height: 1.3);
    return _TextWidgetBase(
      text: text,
      style: style,
      fontSize: fontSize,
      overflow: overflow,
      maxLines: maxLines,
      heavy: heavy,
      themeStyle: themeStyle,
      textAlign: textAlign,
      textDirection: textDirection,
      semanticsLabel: semanticsLabel,
      softWrap: softWrap,
      textScaleFactor: textScaleFactor,
    );
  }
}

class TextTitle extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final double? fontSize;
  final TextOverflow? overflow;
  final int? maxLines;
  final bool heavy;
    final TextAlign? textAlign;
    final TextDirection? textDirection;
    final String? semanticsLabel;
    final bool? softWrap;
    final double? textScaleFactor;

  const TextTitle(
    this.text, {
    Key? key,
    this.style,
    this.fontSize,
    this.overflow,
    this.maxLines,
    this.heavy = false,
    this.textAlign,
    this.textDirection,
    this.semanticsLabel,
    this.softWrap,
    this.textScaleFactor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeStyle = Theme.of(context).textTheme.titleLarge ?? const TextStyle(fontSize: 16);
    return _TextWidgetBase(
      text: text,
      style: style,
      fontSize: fontSize,
      overflow: overflow,
      maxLines: maxLines,
      heavy: heavy,
      themeStyle: themeStyle,
      textAlign: textAlign,
      textDirection: textDirection,
      semanticsLabel: semanticsLabel,
      softWrap: softWrap,
      textScaleFactor: textScaleFactor,
    );
  }
}

class TextSubtitle extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final double? fontSize;
  final TextOverflow? overflow;
  final int? maxLines;
  final bool heavy;
    final TextAlign? textAlign;
    final TextDirection? textDirection;
    final String? semanticsLabel;
    final bool? softWrap;
    final double? textScaleFactor;

  const TextSubtitle(
    this.text, {
    Key? key,
    this.style,
    this.fontSize,
    this.overflow,
    this.maxLines,
    this.heavy = false,
    this.textAlign,
    this.textDirection,
    this.semanticsLabel,
    this.softWrap,
    this.textScaleFactor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeStyle = Theme.of(context).textTheme.titleMedium ?? const TextStyle(fontSize: 14);
    return _TextWidgetBase(
      text: text,
      style: style,
      fontSize: fontSize,
      overflow: overflow,
      maxLines: maxLines,
      heavy: heavy,
      themeStyle: themeStyle,
      textAlign: textAlign,
      textDirection: textDirection,
      semanticsLabel: semanticsLabel,
      softWrap: softWrap,
      textScaleFactor: textScaleFactor,
    );
  }
}

class TextBodyLarge extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final double? fontSize;
  final TextOverflow? overflow;
  final int? maxLines;
  final bool heavy;
    final TextAlign? textAlign;
    final TextDirection? textDirection;
    final String? semanticsLabel;
    final bool? softWrap;
    final double? textScaleFactor;

  const TextBodyLarge(
    this.text, {
    Key? key,
    this.style,
    this.fontSize,
    this.overflow,
    this.maxLines,
    this.heavy = false,
    this.textAlign,
    this.textDirection,
    this.semanticsLabel,
    this.softWrap,
    this.textScaleFactor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeStyle = Theme.of(context).textTheme.bodyLarge ?? const TextStyle(fontSize: 16, height: 1.4);
    return _TextWidgetBase(
      text: text,
      style: style,
      fontSize: fontSize,
      overflow: overflow,
      maxLines: maxLines,
      heavy: heavy,
      themeStyle: themeStyle,
      textAlign: textAlign,
      textDirection: textDirection,
      semanticsLabel: semanticsLabel,
      softWrap: softWrap,
      textScaleFactor: textScaleFactor,
    );
  }
}

class TextBodyMedium extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final double? fontSize;
  final TextOverflow? overflow;
  final int? maxLines;
  final bool heavy;
    final TextAlign? textAlign;
    final TextDirection? textDirection;
    final String? semanticsLabel;
    final bool? softWrap;
    final double? textScaleFactor;

  const TextBodyMedium(
    this.text, {
    Key? key,
    this.style,
    this.fontSize,
    this.overflow,
    this.maxLines,
    this.heavy = false,
    this.textAlign,
    this.textDirection,
    this.semanticsLabel,
    this.softWrap,
    this.textScaleFactor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeStyle = Theme.of(context).textTheme.bodyMedium ?? const TextStyle(fontSize: 14, height: 1.4);
    return _TextWidgetBase(
      text: text,
      style: style,
      fontSize: fontSize,
      overflow: overflow,
      maxLines: maxLines,
      heavy: heavy,
      themeStyle: themeStyle,
      textAlign: textAlign,
      textDirection: textDirection,
      semanticsLabel: semanticsLabel,
      softWrap: softWrap,
      textScaleFactor: textScaleFactor,
    );
  }
}

class TextBodySmall extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final double? fontSize;
  final TextOverflow? overflow;
  final int? maxLines;
  final bool heavy;
    final TextAlign? textAlign;
    final TextDirection? textDirection;
    final String? semanticsLabel;
    final bool? softWrap;
    final double? textScaleFactor;

  const TextBodySmall(
    this.text, {
    Key? key,
    this.style,
    this.fontSize,
    this.overflow,
    this.maxLines,
    this.heavy = false,
    this.textAlign,
    this.textDirection,
    this.semanticsLabel,
    this.softWrap,
    this.textScaleFactor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeStyle = Theme.of(context).textTheme.bodySmall ?? const TextStyle(fontSize: 12, height: 1.3);
    return _TextWidgetBase(
      text: text,
      style: style,
      fontSize: fontSize,
      overflow: overflow,
      maxLines: maxLines,
      heavy: heavy,
      themeStyle: themeStyle,
      textAlign: textAlign,
      textDirection: textDirection,
      semanticsLabel: semanticsLabel,
      softWrap: softWrap,
      textScaleFactor: textScaleFactor,
    );
  }
}

class TextButtonLabel extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final double? fontSize;
  final TextOverflow? overflow;
  final int? maxLines;
  final bool heavy;
    final TextAlign? textAlign;
    final TextDirection? textDirection;
    final String? semanticsLabel;
    final bool? softWrap;
    final double? textScaleFactor;

  const TextButtonLabel(
    this.text, {
    Key? key,
    this.style,
    this.fontSize,
    this.overflow,
    this.maxLines,
    this.heavy = false,
    this.textAlign,
    this.textDirection,
    this.semanticsLabel,
    this.softWrap,
    this.textScaleFactor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeStyle = Theme.of(context).textTheme.labelLarge ?? const TextStyle(fontSize: 14, fontWeight: FontWeight.w600);
    return _TextWidgetBase(
      text: text,
      style: style,
      fontSize: fontSize,
      overflow: overflow,
      maxLines: maxLines,
      heavy: heavy,
      themeStyle: themeStyle,
      textAlign: textAlign,
      textDirection: textDirection,
      semanticsLabel: semanticsLabel,
      softWrap: softWrap,
      textScaleFactor: textScaleFactor,
    );
  }
}

/// Usage examples:
/// TextHeader('home.title')
/// Text('Corpo', style: AppText.bodyMedium(context))
