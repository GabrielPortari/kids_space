import 'package:flutter/material.dart';
import 'package:kids_space/model/base_user.dart';
import 'package:kids_space/model/child.dart';
import 'package:kids_space/model/company.dart';
import 'package:kids_space/model/collaborator.dart';
import 'package:kids_space/model/user.dart';
import 'package:kids_space/view/widgets/profile_picture_section.dart';
import 'package:kids_space/view/widgets/profile_header_section.dart';
import 'package:kids_space/view/widgets/profile_info_card_section.dart';
import 'package:kids_space/view/widgets/profile_children_card_section.dart';
import 'package:kids_space/view/widgets/profile_responsibles_card_section.dart';

class ProfileContent extends StatelessWidget {
  final User? selectedUser;
  final Collaborator? selectedCollaborator;
  final Company? selectedCompany;
  final Child? selectedChild;

  const ProfileContent({
    Key? key,
    this.selectedUser,
    this.selectedCollaborator,
    this.selectedCompany,
    this.selectedChild,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Map<String, String> infoMap = _getProfileData();
    final profileEntries = infoMap.entries.toList();
    final Map<String, String> addressMap = _getAddressData();
    final addressEntries = addressMap.entries.toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 16),
        ProfilePictureSection(
          name: selectedUser?.name ?? selectedCollaborator?.name ?? selectedCompany?.fantasyName ?? selectedChild?.name ?? '?',
          onAddPhoto: () {},
        ),
        const SizedBox(height: 16),
        ProfileHeaderSection(
          name: selectedChild?.name ?? selectedUser?.name ?? selectedCollaborator?.name ?? selectedCompany?.fantasyName ?? 'name_placeholder',
          userTypeLabel: selectedUser != null ? 'Usuário' : selectedCompany != null ? 'Empresa' : selectedCollaborator != null ? (selectedCollaborator?.userType == UserType.companyAdmin ? 'Administrador' : 'Colaborador') : selectedChild != null ? 'Criança' : 'user_type_placeholder',
          id: selectedUser?.id ?? selectedCollaborator?.id ?? selectedChild?.id ?? selectedCompany?.id ?? 'user_id_placeholder',
        ),
        const SizedBox(height: 16),
        ProfileInfoCardSection(title: 'Dados pessoais', entries: profileEntries),
        const SizedBox(height: 16),
        ProfileInfoCardSection(title: 'Endereço', entries: addressEntries),
        const SizedBox(height: 16),
        if (selectedUser != null) ProfileChildrenCardSection(user: selectedUser),
        if (selectedChild != null) ProfileResponsiblesCardSection(child: selectedChild),
      ],
    );
  }

  Map<String, String> _getProfileData() {
    if (selectedUser != null) {
      final u = selectedUser!;
      final dt = DateTime.tryParse(u.birthDate ?? '');
      return {
        'Nome': u.name ?? '-',
        'Email': u.email ?? '-',
        'Data de Nascimento': dt == null ? '-' : dt.toLocal().toString(),
        'Telefone': u.phone ?? '-',
        'Documento': u.document ?? '-',
      };
    } else if (selectedCollaborator != null) {
      final c = selectedCollaborator!;
      final dt = DateTime.tryParse(c.birthDate ?? '');
      return {
        'Nome': c.name ?? '-',
        'Email': c.email ?? '-',
        'Data de Nascimento': dt == null ? '-' : dt.toLocal().toString(),
        'Telefone': c.phone ?? '-',
        'Documento': c.document ?? '-',
      };
    } else if (selectedCompany != null) {
      final co = selectedCompany!;
      return {
        'Nome fantasia': co.fantasyName ?? '-',
        'Razão social': co.corporateName ?? '-',
        'CNPJ': co.cnpj ?? '-',
        'Site': co.website ?? '-',
        'Responsável': co.responsible?.name ?? '-',
        'Logo (URL)': co.logoUrl ?? '-',
        'Colaboradores': (co.collaborators ?? 0).toString(),
        'Usuários': (co.users ?? 0).toString(),
        'Crianças': (co.children ?? 0).toString(),
      };
    } else if (selectedChild != null) {
      final ch = selectedChild!;
      final dt = DateTime.tryParse(ch.birthDate ?? '');
      return {
        'Nome': ch.name ?? '-',
        'Email': ch.email ?? '-',
        'Data de Nascimento': dt == null ? '-' : dt.toLocal().toString(),
        'Telefone': ch.phone ?? '-',
        'Documento': ch.document ?? '-',
        'Status': (ch.checkedIn ?? false) ? 'Ativa' : 'Inativa',
      };
    }
    return {};
  }

  Map<String, String> _getAddressData() {
    if (selectedUser != null) {
      final u = selectedUser!;
      return {
        'Endereço': u.address ?? '-',
        'Número': u.addressNumber ?? '-',
        'Complemento': u.addressComplement ?? '-',
        'Bairro': u.neighborhood ?? '-',
        'Cidade': u.city ?? '-',
        'Estado': u.state ?? '-',
        'CEP': u.zipCode ?? '-',
      };
    } else if (selectedCollaborator != null) {
      final c = selectedCollaborator!;
      return {
        'Endereço': c.address ?? '-',
        'Número': c.addressNumber ?? '-',
        'Complemento': c.addressComplement ?? '-',
        'Bairro': c.neighborhood ?? '-',
        'Cidade': c.city ?? '-',
        'Estado': c.state ?? '-',
        'CEP': c.zipCode ?? '-',
      };
    } else if (selectedCompany != null) {
      final co = selectedCompany!;
      return {
        'Endereço': co.address ?? '-',
        'Número': co.addressNumber ?? '-',
        'Complemento': co.addressComplement ?? '-',
        'Bairro': co.neighborhood ?? '-',
        'Cidade': co.city ?? '-',
        'Estado': co.state ?? '-',
        'CEP': co.zipCode ?? '-',
      };
    } else if (selectedChild != null) {
      final ch = selectedChild!;
      return {
        'Endereço': ch.address ?? '-',
        'Número': ch.addressNumber ?? '-',
        'Complemento': ch.addressComplement ?? '-',
        'Bairro': ch.neighborhood ?? '-',
        'Cidade': ch.city ?? '-',
        'Estado': ch.state ?? '-',
        'CEP': ch.zipCode ?? '-',
      };
    }
    return {};
  }
}
