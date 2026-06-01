import 'package:flutter/material.dart';
import 'package:kids_space/model/child.dart';
import 'package:get_it/get_it.dart';
import 'package:kids_space/controller/child_controller.dart';
import 'package:kids_space/model/parent.dart';
import 'package:kids_space/view/screens/profile_screen.dart';
import 'package:kids_space/util/localization_service.dart';
import 'package:kids_space/util/string_utils.dart';

class ProfileChildrenCardSection extends StatefulWidget {
  final Parent? parent;

  const ProfileChildrenCardSection({super.key, this.parent});

  @override
  State<ProfileChildrenCardSection> createState() =>
      _ProfileChildrenCardSectionState();
}

class _ProfileChildrenCardSectionState
    extends State<ProfileChildrenCardSection> {
  final List<Child> _children = [];
  bool _collapsed = false;

  @override
  void initState() {
    super.initState();
    _loadChildren();
  }

  @override
  void didUpdateWidget(covariant ProfileChildrenCardSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.parent?.id != widget.parent?.id) _loadChildren();
  }

  void _loadChildren() {
    _children.clear();
    final childCtrl = GetIt.I.get<ChildController>();
    final snapshots = widget.parent?.childrenSnapshot;
    if (snapshots != null && snapshots.isNotEmpty) {
      for (final s in snapshots) {
        final id = s['id'] as String?;
        final name = s['name'] as String?;
        if (id != null) {
          final cached = childCtrl.getChildById(id);
          _children.add(cached ?? Child(id: id, name: name));
        }
      }
      setState(() {});
      return;
    }
    for (final childId in widget.parent?.children ?? []) {
      if (childId == null) continue;
      final c = childCtrl.getChildById(childId);
      if (c != null) _children.add(c);
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEEF1F7)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // Header
          InkWell(
            onTap: () => setState(() => _collapsed = !_collapsed),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  const Icon(Icons.child_care_rounded,
                      size: 18, color: Color(0xFF9AA3B5)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      translate('ui.children_under_responsibility'),
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF0F1218),
                      ),
                    ),
                  ),
                  if (_children.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F0FE),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${_children.length}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2962FF),
                        ),
                      ),
                    ),
                  const SizedBox(width: 4),
                  AnimatedRotation(
                    turns: _collapsed ? 0 : 0.5,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(Icons.keyboard_arrow_down_rounded,
                        color: Color(0xFF9AA3B5), size: 20),
                  ),
                ],
              ),
            ),
          ),

          // Content
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 200),
            firstCurve: Curves.easeInOut,
            secondCurve: Curves.easeInOut,
            sizeCurve: Curves.easeInOut,
            crossFadeState: _collapsed
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            firstChild: const SizedBox.shrink(),
            secondChild: _children.isEmpty
                ? Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Text(
                      translate('ui.no_children'),
                      style: const TextStyle(
                          fontSize: 13, color: Color(0xFF9AA3B5)),
                    ),
                  )
                : Column(
                    children: [
                      const Divider(height: 1, color: Color(0xFFEEF1F7)),
                      ..._children.map(
                        (c) => _ChildRow(
                          child: c,
                          onTap: () => Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (_) => ProfileScreen(selectedChild: c),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _ChildRow extends StatelessWidget {
  final Child child;
  final VoidCallback onTap;

  const _ChildRow({required this.child, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isIn = child.checkedIn ?? false;
    final scheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor:
                  isIn ? const Color(0xFF388E3C) : scheme.primaryContainer,
              child: Text(
                getInitials(child.name),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: isIn ? Colors.white : scheme.primary,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                child.name ?? '—',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF0F1218),
                ),
              ),
            ),
            if (isIn)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Presente',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF388E3C),
                  ),
                ),
              ),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right_rounded,
                size: 16, color: Color(0xFFC4CADA)),
          ],
        ),
      ),
    );
  }
}
