import 'package:flutter/material.dart';
import 'package:kids_space/util/localization_service.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: scheme.primaryContainer,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    Icons.bar_chart_rounded,
                    size: 40,
                    color: scheme.primary,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  translate('reports.title'),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F1218),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Em desenvolvimento',
                  style: const TextStyle(
                    fontSize: 15,
                    color: Color(0xFF9AA3B5),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
