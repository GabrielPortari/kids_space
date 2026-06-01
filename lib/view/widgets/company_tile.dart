import 'package:flutter/material.dart';
import '../../util/company_tile_helpers.dart';
import '../../model/company_tile_model.dart';

class CompanyTile extends StatelessWidget {
  final CompanyTileModel model;
  final VoidCallback? onTap;

  const CompanyTile({super.key, required this.model, this.onTap});

  static const _iconColors = <CompanyTileType, Color>{
    CompanyTileType.dashboard:    Color(0xFF2962FF),
    CompanyTileType.attendances:  Color(0xFF388E3C),
    CompanyTileType.company:      Color(0xFF6A1B9A),
    CompanyTileType.collaborator: Color(0xFF00838F),
    CompanyTileType.responsible:  Color(0xFFE65100),
    CompanyTileType.child:        Color(0xFFAD1457),
    CompanyTileType.reports:      Color(0xFF1565C0),
  };

  static const _bgColors = <CompanyTileType, Color>{
    CompanyTileType.dashboard:    Color(0xFFE8F0FE),
    CompanyTileType.attendances:  Color(0xFFE8F5E9),
    CompanyTileType.company:      Color(0xFFF3E5F5),
    CompanyTileType.collaborator: Color(0xFFE0F7FA),
    CompanyTileType.responsible:  Color(0xFFFFF3E0),
    CompanyTileType.child:        Color(0xFFFCE4EC),
    CompanyTileType.reports:      Color(0xFFE3F2FD),
  };

  @override
  Widget build(BuildContext context) {
    final iconColor = _iconColors[model.type] ?? const Color(0xFF2962FF);
    final bgColor = _bgColors[model.type] ?? const Color(0xFFE8F0FE);
    final title = titleForType(model.type);
    final subtitle = messageForType(model.type);

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFEEF1F7)),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(model.icon, size: 22, color: iconColor),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF0F1218),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF9AA3B5),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: Color(0xFFC4CADA),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
