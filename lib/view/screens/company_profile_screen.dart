import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter/services.dart';
import 'package:kids_space/controller/company_controller.dart';
import 'package:kids_space/model/company.dart';
import 'package:kids_space/view/design_system/app_text.dart';
import 'package:kids_space/view/widgets/edit_entity_bottom_sheet.dart';

final CompanyController _companyController = GetIt.I<CompanyController>();

class CompanyProfileScreen extends StatefulWidget {
  const CompanyProfileScreen({super.key});

  @override
  State<CompanyProfileScreen> createState() => _CompanyProfileScreenState();
}

class _CompanyProfileScreenState extends State<CompanyProfileScreen> {
  bool _fabOpen = false;

  @override
  void initState() {
    super.initState();
    debugPrint('DebuggerLog: CompanyProfileScreen.initState');
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('DebuggerLog: CompanyProfileScreen.build');
    return Scaffold(
      appBar: AppBar(title: const Text('Empresa')),
      body: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 720),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Observer(
                  builder: (_) {
                    final company = _companyController.companySelected;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 24),
                        _companyProfileInfo(company),
                        const SizedBox(height: 24),
                        TextHeaderMedium(company?.name ?? 'Nome da Empresa'),
                        const SizedBox(height: 8),
                        const TextHeaderSmall('Empresa'),
                        const SizedBox(height: 24),
                        _companyProfileCard(company),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (_fabOpen) ...[
            Align(
              alignment: Alignment.centerRight,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(6),
                      boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
                    ),
                    child: const Text('Editar empresa', style: TextStyle(fontSize: 14, color: Colors.black)),
                  ),
                  FloatingActionButton(
                    heroTag: 'company_edit_fab',
                    onPressed: () {
                      debugPrint('DebuggerLog: CompanyProfileScreen.editFab.tap');
                      _onEditCompany();
                      setState(() => _fabOpen = false);
                    },
                    child: const Icon(Icons.edit),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(6),
                      boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
                    ),
                    child: const Text('Copiar ID', style: TextStyle(fontSize: 14, color: Colors.black)),
                  ),
                  FloatingActionButton(
                    heroTag: 'company_copy_fab',
                    onPressed: () async {
                      final id = _companyController.companySelected?.id ?? '';
                      debugPrint('DebuggerLog: CompanyProfileScreen.copyId.tap -> $id');
                      if (id.isNotEmpty) {
                        await Clipboard.setData(ClipboardData(text: id));
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('ID copiado para a área de transferência!')));
                      }
                      setState(() => _fabOpen = false);
                    },
                    child: const Icon(Icons.copy),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
          ],
          FloatingActionButton(
            heroTag: 'company_main_fab',
            onPressed: () {
              setState(() => _fabOpen = !_fabOpen);
              debugPrint('DebuggerLog: CompanyProfileScreen.fab toggled -> $_fabOpen');
            },
            child: Icon(_fabOpen ? Icons.close : Icons.menu),
          ),
        ],
      ),
    );
  }

  Widget _companyProfileInfo(company) {
    return Stack(
      alignment: Alignment.center,
      children: [
        CircleAvatar(
          radius: 50,
          backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
          child: const Icon(Icons.business, size: 60,),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () {
                debugPrint('DebuggerLog: CompanyProfileScreen.changeLogo tapped');
                // TODO: Implement logo upload/change
              },
              child: Container(
                decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary, shape: BoxShape.circle),
                padding: const EdgeInsets.all(6),
                child: Icon(Icons.add_a_photo, color: Theme.of(context).colorScheme.onPrimary, size: 20),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _companyProfileCard(company) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Text('Nome:', style: TextStyle(fontSize: 16)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(company?.name ?? 'Nome da Empresa', style: const TextStyle(fontSize: 16)),
                ),
              ],
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Text('Email:', style: TextStyle(fontSize: 16)),
                const SizedBox(width: 8),
                Expanded(child: Text(company?.toJson()['contactEmail'] ?? 'email@placeholder.com', style: const TextStyle(fontSize: 16))),
              ],
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Text('Telefone:', style: TextStyle(fontSize: 16)),
                const SizedBox(width: 8),
                Expanded(child: Text(company?.toJson()['phone'] ?? '(11) 1234 5678', style: const TextStyle(fontSize: 16))),
              ],
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text('ID:', style: TextStyle(fontSize: 16, color: Colors.grey)),
                    const SizedBox(width: 8),
                    Text(company?.id ?? 'ID da Empresa', style: const TextStyle(fontSize: 16, color: Colors.grey), overflow: TextOverflow.ellipsis),
                  ],
                ),
                const SizedBox(width: 8),
                InkWell(
                  onTap: () async {
                    final id = company?.id ?? '';
                    debugPrint('DebuggerLog: CompanyProfileScreen.copyId tapped -> $id');
                    if (id.isNotEmpty) {
                      await Clipboard.setData(ClipboardData(text: id));
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('ID copiado para a área de transferência!')));
                    }
                  },
                  child: const Padding(padding: EdgeInsets.all(4.0), child: Icon(Icons.copy, size: 18, color: Colors.grey)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  _onEditCompany() async {
    debugPrint('DebuggerLog: CompanyProfileScreen.openEditModal -> companyId=${_companyController.companySelected?.id ?? 'none'}');

    final fields = [
      FieldDefinition(key: 'name', label: 'Nome', initialValue: _companyController.companySelected!.name, required: true),
      FieldDefinition(key: 'contactEmail', label: 'Email', initialValue: _companyController.companySelected!.toJson()['contactEmail']),
      FieldDefinition(key: 'phone', label: 'Telefone', initialValue: _companyController.companySelected!.toJson()['phone']),
    ];
    
    final result = await showEditEntityBottomSheet(context: context, title: 'Editar empresa', fields: fields);
    if (result != null) {
      debugPrint('DebuggerLog: CompanyProfileScreen.editModal.result -> $result');
      // Delegue para _companyController.updateCompanyFromMap(result)
    }
  }
}