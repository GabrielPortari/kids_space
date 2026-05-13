import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:kids_space/controller/parent_controller.dart';
import 'package:kids_space/model/child.dart';
import 'package:kids_space/model/parent.dart';
import 'package:kids_space/view/screens/profile_screen.dart';
import 'package:kids_space/util/localization_service.dart';

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
    // Prefer parentsSnapshot if available
    final snaps = widget.child?.parentsSnapshot;
    if (snaps != null && snaps.isNotEmpty) {
      for (final s in snaps) {
        final id = s['id'] as String?;
        final name = s['name'] as String?;
        if (id != null) {
          final cached = _userController.getUserById(id);
          if (cached != null)
            _responsibles.add(cached);
          else
            _responsibles.add(Parent(id: id, name: name));
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
    final header = Row(
      children: [
        Expanded(
          child: Text(
            translate('profile.responsibles_title'),
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        IconButton(
          icon: Icon(_collapsed ? Icons.expand_more : Icons.expand_less),
          onPressed: () => setState(() => _collapsed = !_collapsed),
        ),
      ],
    );

    final firstWidget = _responsibles.isEmpty
        ? Center(
            child: Text(
              translate('profile.no_responsibles'),
              style: TextStyle(color: Theme.of(context).colorScheme.primary),
            ),
          )
        : ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(_responsibles.first.name ?? ''),
            subtitle: Text('${_responsibles.first.document ?? '-'}'),
            onTap: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (_) =>
                      ProfileScreen(selectedUser: _responsibles.first),
                ),
              );
            },
          );

    final fullListWidget = _responsibles.isEmpty
        ? Center(
            child: Text(
              translate('profile.no_responsibles'),
              style: TextStyle(color: Theme.of(context).colorScheme.primary),
            ),
          )
        : Column(
            children: _responsibles.map((u) {
              return Column(
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(u.name ?? ''),
                    subtitle: Text(u.document ?? '-'),
                    onTap: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (_) => ProfileScreen(selectedUser: u),
                        ),
                      );
                    },
                  ),
                  const Divider(height: 1),
                ],
              );
            }).toList(),
          );

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            header,
            const SizedBox(height: 12),
            AnimatedCrossFade(
              firstChild: firstWidget,
              secondChild: fullListWidget,
              crossFadeState: _collapsed
                  ? CrossFadeState.showFirst
                  : CrossFadeState.showSecond,
              duration: const Duration(milliseconds: 220),
              firstCurve: Curves.easeInOut,
              secondCurve: Curves.easeInOut,
              sizeCurve: Curves.easeInOut,
            ),
          ],
        ),
      ),
    );
  }
}
