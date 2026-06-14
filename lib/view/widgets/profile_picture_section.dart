import 'package:flutter/material.dart';
import 'package:kids_space/util/string_utils.dart';

class ProfilePictureSection extends StatelessWidget {
  final String? name;
  final VoidCallback? onAddPhoto;
  final double radius;

  const ProfilePictureSection({
    super.key,
    this.name,
    this.onAddPhoto,
    this.radius = 48,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final initials = getInitials(name);

    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: radius * 2,
          height: radius * 2,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                scheme.primary,
                scheme.primaryContainer,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: scheme.primary.withValues(alpha: 0.25),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Center(
            child: Text(
              initials,
              style: TextStyle(
                fontSize: radius * 0.55,
                color: Colors.white,
                fontWeight: FontWeight.w700,
                letterSpacing: 1,
              ),
            ),
          ),
        ),
        if (onAddPhoto != null)
          Positioned(
            bottom: 2,
            right: 2,
            child: GestureDetector(
              onTap: onAddPhoto,
              child: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: scheme.primary.withValues(alpha: 0.3),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 6,
                    ),
                  ],
                ),
                child: Icon(
                  Icons.camera_alt_rounded,
                  size: 16,
                  color: scheme.primary,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
