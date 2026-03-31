import 'dart:developer' as dev;
import 'package:flutter/material.dart';
import 'package:kids_space/model/user_type.dart';
import 'package:kids_space/model/child.dart';
import 'package:kids_space/model/company.dart';
import 'package:kids_space/model/collaborator.dart';
import 'package:kids_space/model/parent.dart';
import 'package:kids_space/util/date_hour_util.dart';
import 'package:kids_space/view/widgets/profile_picture_section.dart';
import 'package:kids_space/view/widgets/profile_header_section.dart';
import 'package:kids_space/view/widgets/profile_info_card_section.dart';
import 'package:kids_space/view/widgets/profile_children_card_section.dart';
import 'package:kids_space/view/widgets/profile_responsibles_card_section.dart';
import 'package:kids_space/util/localization_service.dart';

class ProfileContent extends StatelessWidget {
  final Parent? selectedUser;
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
    dev.log(
      'ProfileContent build - selectedUser: ${selectedUser?.toJson() ?? selectedUser}',
      name: 'ProfileContent',
    );
    dev.log(
      'ProfileContent build - selectedChild: ${selectedChild?.toJson() ?? selectedChild}',
      name: 'ProfileContent',
    );
    dev.log(
      'ProfileContent build - selectedCollaborator: ${selectedCollaborator?.toJson() ?? selectedCollaborator}',
      name: 'ProfileContent',
    );
    dev.log(
      'ProfileContent build - selectedCompany: ${selectedCompany?.toJson() ?? selectedCompany}',
      name: 'ProfileContent',
    );
    final Map<String, String> infoMap = _getProfileData();
    final profileEntries = infoMap.entries.toList();
    final Map<String, String> addressMap = _getAddressData();
    final addressEntries = addressMap.entries.toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 16),
        ProfilePictureSection(
          name:
              selectedUser?.name ??
              selectedCollaborator?.name ??
              selectedCompany?.name ??
              selectedChild?.name ??
              '?',
          onAddPhoto: () {},
        ),
        const SizedBox(height: 16),
        ProfileHeaderSection(
          name:
              selectedChild?.name ??
              selectedUser?.name ??
              selectedCollaborator?.name ??
              selectedCompany?.name ??
              translate('profile.name_placeholder', defaultText: 'Unknown'),
          userTypeLabel: selectedUser != null
              ? translate('profile.user_type.user', defaultText: 'Usuário')
              : selectedCompany != null
              ? translate('profile.user_type.company', defaultText: 'Empresa')
              : selectedCollaborator != null
              ? (selectedCollaborator?.userType == UserType.company
                    ? translate(
                        'profile.user_type.admin',
                        defaultText: 'Administrador',
                      )
                    : translate(
                        'profile.user_type.collaborator',
                        defaultText: 'Colaborador',
                      ))
              : selectedChild != null
              ? translate('profile.user_type.child', defaultText: 'Criança')
              : translate(
                  'profile.user_type.unknown',
                  defaultText: 'Desconhecido',
                ),
          id:
              selectedUser?.id ??
              selectedCollaborator?.id ??
              selectedChild?.id ??
              selectedCompany?.id,
        ),
        const SizedBox(height: 16),
        ProfileInfoCardSection(
          title: translate(
            'profile.personal_title',
            defaultText: 'Dados pessoais',
          ),
          entries: profileEntries,
        ),
        const SizedBox(height: 16),
        ProfileInfoCardSection(
          title: translate('profile.address_title', defaultText: 'Endereço'),
          entries: addressEntries,
        ),
        const SizedBox(height: 16),
        if (selectedUser != null)
          ProfileChildrenCardSection(user: selectedUser),
        if (selectedChild != null)
          ProfileResponsiblesCardSection(child: selectedChild),
      ],
    );
  }

  Map<String, String> _getProfileData() {
    if (selectedUser != null) {
      final u = selectedUser!;
      final dt = DateTime.tryParse(u.birthDate ?? '');
      return {
        translate('profile.name', defaultText: 'Nome'): u.name ?? '-',
        translate('profile.email', defaultText: 'Email'): u.email ?? '-',
        translate('profile.birth_date', defaultText: 'Data de nascimento'):
            dt == null ? '-' : formatDate_ddMMyyyy(dt),
        translate('profile.phone', defaultText: 'Telefone'): u.contact ?? '-',
        translate('profile.document', defaultText: 'Documento'):
            u.document ?? '-',
      };
    } else if (selectedCollaborator != null) {
      final c = selectedCollaborator!;
      final dt = DateTime.tryParse(c.birthDate ?? '');
      return {
        translate('profile.name', defaultText: 'Nome'): c.name ?? '-',
        translate('profile.email', defaultText: 'Email'): c.email ?? '-',
        translate('profile.birth_date', defaultText: 'Data de nascimento'):
            dt == null ? '-' : formatDate_ddMMyyyy(dt),
        translate('profile.phone', defaultText: 'Telefone'): c.contact ?? '-',
        translate('profile.document', defaultText: 'Documento'):
            c.document ?? '-',
      };
    } else if (selectedCompany != null) {
      final co = selectedCompany!;
      return {
        translate('profile.fantasy_name', defaultText: 'Nome fantasia'):
            co.name ?? '-',
        translate('profile.corporate_name', defaultText: 'Razão social'):
            co.legalName ?? '-',
        translate('profile.cnpj', defaultText: 'CNPJ'): co.cnpj ?? '-',
        translate('profile.website', defaultText: 'Site'): co.website ?? '-',
        translate('profile.logo_url', defaultText: 'URL do logo'):
            co.logoUrl ?? '-',
      };
    } else if (selectedChild != null) {
      final ch = selectedChild!;
      final dt = DateTime.tryParse(ch.birthDate ?? '');
      return {
        translate('profile.name', defaultText: 'Nome'): ch.name ?? '-',
        translate('profile.email', defaultText: 'Email'): ch.email ?? '-',
        translate('profile.birth_date', defaultText: 'Data de nascimento'):
            dt == null ? '-' : formatDate_ddMMyyyy(dt),
        translate('profile.phone', defaultText: 'Telefone'): ch.contact ?? '-',
        translate('profile.document', defaultText: 'Documento'):
            ch.document ?? '-',
        translate(
          'profile.status',
          defaultText: 'Status',
        ): (ch.checkedIn ?? false)
            ? translate('profile.active', defaultText: 'Ativo')
            : translate('profile.inactive', defaultText: 'Inativo'),
      };
    }
    return {};
  }

  Map<String, String> _getAddressData() {
    if (selectedUser != null) {
      final u = selectedUser!;
      final u_address = u.address;
      return {
        translate('profile.address', defaultText: 'Endereço'):
            u_address?.address ?? '-',
        translate('profile.address_number', defaultText: 'Número'):
            u_address?.number ?? '-',
        translate('profile.address_complement', defaultText: 'Complemento'):
            u_address?.complement ?? '-',
        translate('profile.neighborhood', defaultText: 'Bairro'):
            u_address?.neighborhood ?? '-',
        translate('profile.city', defaultText: 'Cidade'):
            u_address?.city ?? '-',
        translate('profile.state', defaultText: 'Estado'):
            u_address?.state ?? '-',
        translate('profile.zip_code', defaultText: 'CEP'):
            u_address?.zipcode ?? '-',
      };
    } else if (selectedCollaborator != null) {
      final c = selectedCollaborator!;
      final c_address = c.address;
      return {
        translate('profile.address', defaultText: 'Endereço'):
            c_address?.address ?? '-',
        translate('profile.address_number', defaultText: 'Número'):
            c_address?.number ?? '-',
        translate('profile.address_complement', defaultText: 'Complemento'):
            c_address?.complement ?? '-',
        translate('profile.neighborhood', defaultText: 'Bairro'):
            c_address?.neighborhood ?? '-',
        translate('profile.city', defaultText: 'Cidade'):
            c_address?.city ?? '-',
        translate('profile.state', defaultText: 'Estado'):
            c_address?.state ?? '-',
        translate('profile.zip_code', defaultText: 'CEP'):
            c_address?.zipcode ?? '-',
      };
    } else if (selectedCompany != null) {
      final co = selectedCompany!;
      final co_address = co.address;
      return {
        translate('profile.address', defaultText: 'Endereço'):
            co_address?.address ?? '-',
        translate('profile.address_number', defaultText: 'Número'):
            co_address?.number ?? '-',
        translate('profile.address_complement', defaultText: 'Complemento'):
            co_address?.complement ?? '-',
        translate('profile.neighborhood', defaultText: 'Bairro'):
            co_address?.neighborhood ?? '-',
        translate('profile.city', defaultText: 'Cidade'):
            co_address?.city ?? '-',
        translate('profile.state', defaultText: 'Estado'):
            co_address?.state ?? '-',
        translate('profile.zip_code', defaultText: 'CEP'):
            co_address?.zipcode ?? '-',
      };
    } else if (selectedChild != null) {
      final ch = selectedChild!;
      final ch_address = ch.address;
      return {
        translate('profile.address', defaultText: 'Endereço'):
            ch_address?.address ?? '-',
        translate('profile.address_number', defaultText: 'Número'):
            ch_address?.number ?? '-',
        translate('profile.address_complement', defaultText: 'Complemento'):
            ch_address?.complement ?? '-',
        translate('profile.neighborhood', defaultText: 'Bairro'):
            ch_address?.neighborhood ?? '-',
        translate('profile.city', defaultText: 'Cidade'):
            ch_address?.city ?? '-',
        translate('profile.state', defaultText: 'Estado'):
            ch_address?.state ?? '-',
        translate('profile.zip_code', defaultText: 'CEP'):
            ch_address?.zipcode ?? '-',
      };
    }
    return {};
  }
}
