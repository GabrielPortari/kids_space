import 'package:flutter/material.dart';

/// AppButton: botão padronizável e focado em aparência.
/// Visuals configuráveis: `padding`, `borderRadius`, `elevation`,
/// `backgroundColor`, `gradient`, `border`, `shadowColor`, `minWidth`, `height`.
/// 
class AppButton extends StatelessWidget {
	final VoidCallback? onPressed;
	final String text;
	final ButtonStyle? style;
  final bool enabled;
	final EdgeInsetsGeometry? padding;
	final Widget? icon;
	final bool iconOnRight;

	const AppButton({
		Key? key,
		required this.text,
		required this.onPressed,
    this.enabled = true,
		this.style,
		this.padding,
		this.icon,
		this.iconOnRight = false,
	}) : super(key: key);

	@override
	Widget build(BuildContext context) {
		return ElevatedButton(
			onPressed: enabled ? onPressed : null,
			style: style ?? ElevatedButton.styleFrom(
				padding: padding ?? const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
			),
			child: icon == null
				? Text(text)
				: Row(
					mainAxisSize: MainAxisSize.min,
					children: iconOnRight
						? [
							Text(text),
							const SizedBox(width: 8),
							icon!,
						]
						: [
							icon!,
							const SizedBox(width: 8),
							Text(text),
						],
				),
		);
	}
}

