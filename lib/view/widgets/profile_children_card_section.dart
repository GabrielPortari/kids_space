import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:kids_space/model/child.dart';
import 'package:kids_space/model/user.dart';
import 'package:kids_space/controller/child_controller.dart';
import 'package:kids_space/view/screens/profile_screen.dart';


class ProfileChildrenCardSection extends StatefulWidget {
  final User? user;

  const ProfileChildrenCardSection({super.key, this.user});

  @override
  State<ProfileChildrenCardSection> createState() => _ProfileChildrenCardSectionState();
}

class _ProfileChildrenCardSectionState extends State<ProfileChildrenCardSection> {
  final ChildController _childController = GetIt.I.get<ChildController>();
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
    if (oldWidget.user?.id != widget.user?.id) {
      _loadChildren();
    }
  }

  void _loadChildren() {
    _children.clear();
    for (final cId in widget.user?.childrenIds ?? []) {
      final child = _childController.getChildById(cId);
      if (child != null) _children.add(child);
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final header = Row(children: [
      Expanded(
        child: const Text(
          'Crianças sob responsabilidade',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
      IconButton(
        icon: Icon(_collapsed ? Icons.expand_more : Icons.expand_less),
        onPressed: () => setState(() => _collapsed = !_collapsed),
      ),
    ]);

    final firstChildWidget = _children.isEmpty
        ? Center(child: Text('Nenhuma criança cadastrada.', style: TextStyle(color: Theme.of(context).colorScheme.primary)))
        : ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(_children.first.name ?? ''),
            subtitle: Text('${(_children.first.isActive ?? false) ? 'Ativa' : 'Inativa'}${_children.first.document != null && _children.first.document!.isNotEmpty ? ' · ${_children.first.document}' : ''}'),
            onTap: () {
              Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => ProfileScreen(selectedChild: _children.first)));
            },
          );

    final fullListWidget = _children.isEmpty
        ? Center(child: Text('Nenhuma criança cadastrada.', style: TextStyle(color: Theme.of(context).colorScheme.primary)))
        : Column(
            children: _children.map((c) {
              return Column(children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(c.name ?? ''),
                  subtitle: Text('${(c.isActive ?? false) ? 'Ativa' : 'Inativa'}${c.document != null && c.document!.isNotEmpty ? ' · ${c.document}' : ''}'),
                  onTap: () {
                    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => ProfileScreen(selectedChild: c)));
                  },
                ),
                const Divider(height: 1),
              ]);
            }).toList(),
          );

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          header,
          const SizedBox(height: 12),
          AnimatedCrossFade(
            firstChild: firstChildWidget,
            secondChild: fullListWidget,
            crossFadeState: _collapsed ? CrossFadeState.showFirst : CrossFadeState.showSecond,
            duration: const Duration(milliseconds: 220),
            firstCurve: Curves.easeInOut,
            secondCurve: Curves.easeInOut,
            sizeCurve: Curves.easeInOut,
          ),
        ]),
      ),
    );
  }

}
