import 'package:flutter/material.dart';
import 'package:kids_space/util/string_utils.dart';

class ProfilePictureSection extends StatelessWidget {
  final String? name;
  final VoidCallback? onAddPhoto;
  final double radius;

  const ProfilePictureSection({super.key, this.name, this.onAddPhoto, this.radius = 50});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        CircleAvatar(
          radius: radius,
          backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
          child: Text(
            getInitials(name),
            style: TextStyle(fontSize: radius * 0.8, color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w600),
          ),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: onAddPhoto,
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(6),
                child: Icon(
                  Icons.add_a_photo,
                  color: Theme.of(context).colorScheme.onPrimary,
                  size: 20,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
