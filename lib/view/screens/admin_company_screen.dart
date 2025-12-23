import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter/services.dart';
import 'package:kids_space/controller/company_controller.dart';

final CompanyController _companyController = GetIt.I<CompanyController>();

class AdminCompanyScreen extends StatefulWidget {
  const AdminCompanyScreen({super.key});

  @override
  State<AdminCompanyScreen> createState() => _AdminCompanyScreenState();
}

class _AdminCompanyScreenState extends State<AdminCompanyScreen> {
  bool _fabOpen = false;

  @override
  void initState() {
    super.initState();
    debugPrint('DebuggerLog: AdminCompanyScreen.initState');
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('DebuggerLog: AdminCompanyScreen.build');
    return Scaffold(
      appBar: AppBar(title: const Text('Empresa')),
      body: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ConstrainedBox(
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
                      Text(
                        company?.name ?? 'Nome da Empresa',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Empresa',
                        style: TextStyle(fontSize: 18, color: Colors.deepPurple),
                      ),
                      const SizedBox(height: 24),
                      _companyProfileCard(company),
                    ],
                  );
                },
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
                      debugPrint('DebuggerLog: AdminCompanyScreen.editFab.tap');
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
                      debugPrint('DebuggerLog: AdminCompanyScreen.copyId.tap -> $id');
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
              debugPrint('DebuggerLog: AdminCompanyScreen.fab toggled -> $_fabOpen');
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
          backgroundColor: Colors.deepPurple[100],
          child: const Icon(Icons.business, size: 60, color: Colors.deepPurple),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () {
                debugPrint('DebuggerLog: AdminCompanyScreen.changeLogo tapped');
                // TODO: Implement logo upload/change
              },
              child: Container(
                decoration: BoxDecoration(color: Colors.deepPurple, shape: BoxShape.circle),
                padding: const EdgeInsets.all(6),
                child: const Icon(Icons.add_a_photo, color: Colors.white, size: 20),
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
                    debugPrint('DebuggerLog: AdminCompanyScreen.copyId tapped -> $id');
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

  _onEditCompany() {
    debugPrint('DebuggerLog: AdminCompanyScreen.openEditModal -> companyId=${_companyController.companySelected?.id ?? 'none'}');
    final nameController = TextEditingController(text: _companyController.companySelected?.name ?? '');
    final emailController = TextEditingController(text: _companyController.companySelected?.toJson()['contactEmail'] ?? '');
    final phoneController = TextEditingController(text: _companyController.companySelected?.toJson()['phone'] ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return SafeArea(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            decoration: BoxDecoration(
              color: Theme.of(context).canvasColor,
              borderRadius: BorderRadius.circular(16.0),
            ),
            child: Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Editar empresa', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        IconButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          icon: const Icon(Icons.close),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Nome')),
                    const SizedBox(height: 12),
                    TextField(controller: emailController, decoration: const InputDecoration(labelText: 'Email')),
                    const SizedBox(height: 12),
                    TextField(controller: phoneController, decoration: const InputDecoration(labelText: 'Telefone')),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () {
                            debugPrint('DebuggerLog: AdminCompanyScreen.editModal.cancel');
                            Navigator.of(context).pop();
                          },
                          child: const Text('Cancelar'),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () {
                            debugPrint('DebuggerLog: AdminCompanyScreen.saveModal -> name=${nameController.text}, email=${emailController.text}, phone=${phoneController.text}');
                            // TODO: Salvar alterações via _companyController
                            Navigator.of(context).pop();
                          },
                          child: const Text('Salvar'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}