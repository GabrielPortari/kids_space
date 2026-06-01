import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:kids_space/controller/parent_controller.dart';
import 'package:kids_space/model/child.dart';
import 'package:kids_space/model/parent.dart';
import 'package:kids_space/view/screens/profile_screen.dart';
import 'package:kids_space/util/localization_service.dart';
import 'package:kids_space/util/string_utils.dart';

class ProfileResponsiblesCardSection extends StatefulWidget {
  final Child? child;

  const ProfileResponsiblesCardSection({super.key, this.child});

  @override
  State<ProfileResponsiblesCardSection> createState() =>
      _ProfileResponsiblesCardSectionState();
}

class _ProfileResponsiblesCardSectionState
    extends State<ProfileResponsiblesCardSection> {
  final ParentController _userController = GetIt.I.get<ParentController>();
  final List<Parent> _responsibles = [];
  bool _collapsed = false;

  @override
  void initState() {
    super.initState();
    _loadResponsibles();
  }

  @override
  void didUpdateWidget(covariant ProfileResponsiblesCardSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.child?.id != widget.child?.id) _loadResponsibles();
  }

  void _loadResponsibles() {
    _responsibles.clear();
    final snaps = widget.child?.parentsSnapshot;
    if (snaps != null && snaps.isNotEmpty) {
      for (final s in snaps) {
        final id = s['id'] as String?;
        final name = s['name'] as String?;
        if (id != null) {
          final cached = _userController.getUserById(id);
          _responsibles.add(cached ?? Parent(id: id, name: name));
        }
      }
      setState(() {});
      return;
    }
    for (final rId in widget.child?.parents ?? []) {
      final u = _userController.getUserById(rId);
      if (u != null) _responsibles.add(u);
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
                  const Icon(Icons.people_rounded,
                      size: 18, color: Color(0xFF9AA3B5)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      translate('profile.responsibles_title'),
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF0F1218),
                      ),
                    ),
                  ),
                  if (_responsibles.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F0FE),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${_responsibles.length}',
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
            secondChild: _responsibles.isEmpty
                ? Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Text(
                      translate('profile.no_responsibles'),
                      style: const TextStyle(
                          fontSize: 13, color: Color(0xFF9AA3B5)),
                    ),
                  )
                : Column(
                    children: [
                      const Divider(height: 1, color: Color(0xFFEEF1F7)),
                      ..._responsibles.map(
                        (r) => _ResponsibleRow(
                          responsible: r,
                          onTap: () => Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (_) => ProfileScreen(selectedParent: r),
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

class _ResponsibleRow extends StatelessWidget {
  final Parent responsible;
  final VoidCallback onTap;

  const _ResponsibleRow({required this.responsible, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: scheme.primaryContainer,
              child: Text(
                getInitials(responsible.name),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: scheme.primary,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    responsible.name ?? '—',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF0F1218),
                    ),
                  ),
                  if (responsible.contact != null &&
                      responsible.contact!.isNotEmpty)
                    Text(
                      responsible.contact!,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF9AA3B5),
                      ),
                    ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded,
                size: 16, color: Color(0xFFC4CADA)),
          ],
        ),
      ),
    );
  }
}
