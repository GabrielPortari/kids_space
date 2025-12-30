import 'package:flutter/material.dart';
import 'package:kids_space/model/collaborator.dart';
import 'package:kids_space/model/company.dart';
import 'package:kids_space/model/user.dart';
import 'package:kids_space/util/string_utils.dart';
import 'package:kids_space/view/design_system/app_text.dart';

enum SelectedProfileType {
  user,
  collaborator,
  company
}

class ProfileScreen extends StatefulWidget {
  
  final User? selectedUser;
  final Collaborator? selectedCollaborator;
  final Company? selectedCompany;
  const ProfileScreen({super.key, this.selectedUser, this.selectedCollaborator, this.selectedCompany});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  SelectedProfileType? get selectedProfileType {
    if (widget.selectedUser != null) {
      return SelectedProfileType.user;
    } else if (widget.selectedCollaborator != null) {
      return SelectedProfileType.collaborator;
    } else if (widget.selectedCompany != null) {
      return SelectedProfileType.company;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {

    final Map<String, String> infoMap = _getProfileData();
    final profileEntries = infoMap.entries.toList();
    final Map<String, String> addressMap = _getAddressData();
    final addressEntries = addressMap.entries.toList();

    return Scaffold(
      appBar: _buildAppBar(),
      body: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 720),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 24),
                      _buildAvatarSection(context),
                      const SizedBox(height: 24),
                      _buildHeaderSection(context),
                      const SizedBox(height: 24),
                      _buildInfoCard(context, profileEntries),
                      const SizedBox(height: 24),
                      _buildInfoCard(context, addressEntries),
                      const SizedBox(height: 24),
                      //...selectedProfileType == SelectedProfileType.user ? [_buildChildrensCard()] : [],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
    
  }

  _buildAppBar(){
    String? title = 'Perfil';

    if(selectedProfileType != null){
      switch(selectedProfileType!){
        case SelectedProfileType.user:
          title = 'Perfil de ${widget.selectedUser!.name}';
          debugPrint('DebuggerLog: ProfileScreen.building selectedUserId=${widget.selectedUser?.id ?? 'none'}');
        case SelectedProfileType.collaborator:
          title = 'Perfil de ${widget.selectedCollaborator!.name}';
          debugPrint('DebuggerLog: ProfileScreen.building selectedCollaboratorId=${widget.selectedCollaborator?.id ?? 'none'}');
        case SelectedProfileType.company:
          title = 'Perfil de ${widget.selectedCompany!.fantasyName ?? widget.selectedCompany!.corporateName}';
          debugPrint('DebuggerLog: ProfileScreen.building selectedCompanyId=${widget.selectedCompany?.id ?? 'none'}');
      }
    }

    return AppBar(
      title: Text(title)
    );
  }

  Widget _buildAvatarSection(BuildContext context) {
    String? name = widget.selectedUser?.name ?? widget.selectedCollaborator?.name ?? widget.selectedCompany?.fantasyName ?? 'A';
    return Stack(
      alignment: Alignment.center,
      children: [
        CircleAvatar(
          radius: 50,
          backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
          child: Text(
            getInitials(name),
            style: TextStyle(fontSize: 40, color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w600),
          ),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () {
                debugPrint('DebuggerLog: UserProfileScreen.addPhoto tapped');
                // TODO: Implementar ação para adicionar foto
              },
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

  Widget _buildHeaderSection(BuildContext context) {
    String? name = widget.selectedUser?.name ?? widget.selectedCollaborator?.name ?? widget.selectedCompany?.fantasyName ?? 'name_placeholder';
    String? userType = widget.selectedUser != null ? 'Usuário' : 
      widget.selectedCollaborator != null ? 'Colaborador' : 
      widget.selectedCompany != null ? 'Empresa' : 'user_type_placeholder';

    return Column(
      children: [
        TextHeaderMedium(name),
        const SizedBox(height: 8),
        TextHeaderSmall(userType),
      ],
    );
  }

  Widget _buildInfoCard(BuildContext context, List<MapEntry<String, String>> entries) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        child: entries.isEmpty
            ? const SizedBox.shrink()
            : ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: EdgeInsets.zero,
                itemCount: entries.length,
                itemBuilder: (context, index) {
                  final e = entries[index]; 
                  return _infoRow(e.key, e.value, valueStyle: e.key == 'ID' ? TextStyle(color: Theme.of(context).colorScheme.primary) : null);
                },
                separatorBuilder: (context, index) => const Divider(height: 1),
              ),
      ),
    );  
  }

  Widget _infoRow(String label, String value, {TextStyle? valueStyle}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          TextBodyMedium('$label:'),
          const SizedBox(width: 8),
          TextBodyMedium(value, style: valueStyle),
        ],
      ),
    );
  }

  Map<String, String> _getProfileData() {
    if (selectedProfileType == SelectedProfileType.user && widget.selectedUser != null) {
      final u = widget.selectedUser!;
      return {
        'Nome': u.name ?? '-',
        'Email': u.email ?? '-',
        'Data de Nascimento': u.birthDate ?? '-',
        'Telefone': u.phone ?? '-',
        'Documento': u.document ?? '-',
        'ID': u.id ?? '-',
      };
    } else if (selectedProfileType == SelectedProfileType.collaborator && widget.selectedCollaborator != null) {
      final c = widget.selectedCollaborator!;
      return {
        'Nome': c.name ?? '-',
        'Email': c.email ?? '-',
        'Data de Nascimento': c.birthDate ?? '-',
        'Telefone': c.phone ?? '-',
        'Documento': c.document ?? '-',
        'ID': c.id ?? '-',
      };
    } else if (selectedProfileType == SelectedProfileType.company && widget.selectedCompany != null) {
      final co = widget.selectedCompany!;
      return {
        'Nome': co.fantasyName ?? co.corporateName ?? '-',
        'CNPJ': co.cnpj ?? '-',
        'Site': co.website ?? '-',
        'Telefone': co.address ?? '-',
        'Endereço': '${co.address ?? '-'}${co.adressNumber != null ? ', ${co.adressNumber}' : ''}',
        'ID': co.id ?? '-',
      };
    }
    return {};
  }

  Map<String, String> _getAddressData() {
    if (selectedProfileType == SelectedProfileType.user && widget.selectedUser != null) {
      final u = widget.selectedUser!;
      return {
        'Endereço': u.address ?? '-',
        'Número': u.adressNumber ?? '-',
        'Complemento': u.adressComplement ?? '-',
        'Bairro': u.neighborhood ?? '-',
        'Cidade': u.city ?? '-',
        'Estado': u.state ?? '-',
        'CEP': u.zipCode ?? '-',
      };
    } else if (selectedProfileType == SelectedProfileType.collaborator && widget.selectedCollaborator != null) {
      final c = widget.selectedCollaborator!;
      return {
        'Endereço': c.address ?? '-',
        'Número': c.adressNumber ?? '-',
        'Complemento': c.adressComplement ?? '-',
        'Bairro': c.neighborhood ?? '-',
        'Cidade': c.city ?? '-',
        'Estado': c.state ?? '-',
        'CEP': c.zipCode ?? '-',
      };
    } else if (selectedProfileType == SelectedProfileType.company && widget.selectedCompany != null) {
      final co = widget.selectedCompany!;
      return {
        'Endereço': co.address ?? '-',
        'Número': co.adressNumber ?? '-',
        'Complemento': co.adressComplement ?? '-',
        'Bairro': co.neighborhood ?? '-',
        'Cidade': co.city ?? '-',
        'Estado': co.state ?? '-',
        'CEP': co.zipCode ?? '-',
      };
    }
    return {};
  }
}