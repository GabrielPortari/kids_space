import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';

class SkeletonList extends StatelessWidget {
  final int itemCount;
  const SkeletonList({Key? key, this.itemCount = 6}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.only(top: 8.0, left: 8.0, right: 8.0),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return Skeletonizer(
          enabled: true,
          child: Card(
            margin: const EdgeInsets.symmetric(vertical: 6),
            child: SizedBox(
              height: 56,
              child: ListTile(
                leading: CircleAvatar(radius: 20, backgroundColor: Colors.grey.shade300),
                title: const SizedBox.shrink(),
                subtitle: const SizedBox.shrink(),
              ),
            ),
          ),
        );
      },
    );
  }
}
