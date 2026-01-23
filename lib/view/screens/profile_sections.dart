import 'dart:developer' as dev;
import 'package:flutter/material.dart';
import 'package:kids_space/model/base_user.dart';
import 'package:kids_space/model/child.dart';
import 'package:kids_space/model/company.dart';
import 'package:kids_space/model/collaborator.dart';
import 'package:kids_space/model/user.dart';
import 'package:kids_space/util/date_hour_util.dart';
import 'package:kids_space/view/widgets/profile_picture_section.dart';
import 'package:kids_space/view/widgets/profile_header_section.dart';
import 'package:kids_space/view/widgets/profile_info_card_section.dart';
import 'package:kids_space/view/widgets/profile_children_card_section.dart';
import 'package:kids_space/view/widgets/profile_responsibles_card_section.dart';
import 'package:kids_space/util/localization_service.dart';

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
    dev.log('ProfileContent build - selectedUser: ${selectedUser?.toJson() ?? selectedUser}', name: 'ProfileContent');
    dev.log('ProfileContent build - selectedChild: ${selectedChild?.toJson() ?? selectedChild}', name: 'ProfileContent');
    dev.log('ProfileContent build - selectedCollaborator: ${selectedCollaborator?.toJson() ?? selectedCollaborator}', name: 'ProfileContent');
    dev.log('ProfileContent build - selectedCompany: ${selectedCompany?.toJson() ?? selectedCompany}', name: 'ProfileContent');
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
          name: selectedChild?.name ?? selectedUser?.name ?? selectedCollaborator?.name ?? selectedCompany?.fantasyName ?? translate('profile.name_placeholder'),
          userTypeLabel: selectedUser != null ? translate('profile.user_type.user') : selectedCompany != null ? translate('profile.user_type.company') : selectedCollaborator != null ? (selectedCollaborator?.userType == UserType.companyAdmin ? translate('profile.user_type.admin') : translate('profile.user_type.collaborator')) : selectedChild != null ? translate('profile.user_type.child') : translate('profile.user_type.unknown'),
          id: selectedUser?.id ?? selectedCollaborator?.id ?? selectedChild?.id ?? selectedCompany?.id,
        ),
        const SizedBox(height: 16),
        ProfileInfoCardSection(title: translate('profile.personal_title'), entries: profileEntries),
        const SizedBox(height: 16),
        ProfileInfoCardSection(title: translate('profile.address_title'), entries: addressEntries),
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
        translate('profile.name'): u.name ?? '-',
        translate('profile.email'): u.email ?? '-',
        translate('profile.birth_date'): dt == null ? '-' : formatDate_ddMMyyyy(dt),
        translate('profile.phone'): u.phone ?? '-',
        translate('profile.document'): u.document ?? '-',
      };
    } else if (selectedCollaborator != null) {
      final c = selectedCollaborator!;
      final dt = DateTime.tryParse(c.birthDate ?? '');
      return {
        translate('profile.name'): c.name ?? '-',
        translate('profile.email'): c.email ?? '-',
        translate('profile.birth_date'): dt == null ? '-' : formatDate_ddMMyyyy(dt),
        translate('profile.phone'): c.phone ?? '-',
        translate('profile.document'): c.document ?? '-',
      };
    } else if (selectedCompany != null) {
      final co = selectedCompany!;
      return {
        translate('profile.fantasy_name'): co.fantasyName ?? '-',
        translate('profile.corporate_name'): co.corporateName ?? '-',
        translate('profile.cnpj'): co.cnpj ?? '-',
        translate('profile.website'): co.website ?? '-',
        translate('profile.responsible'): co.responsible?.name ?? '-',
        translate('profile.logo_url'): co.logoUrl ?? '-',
        translate('profile.collaborators'): (co.collaborators ?? 0).toString(),
        translate('profile.users'): (co.users ?? 0).toString(),
        translate('profile.children'): (co.children ?? 0).toString(),
      };
    } else if (selectedChild != null) {
      final ch = selectedChild!;
      final dt = DateTime.tryParse(ch.birthDate ?? '');
      return {
        translate('profile.name'): ch.name ?? '-',
        translate('profile.email'): ch.email ?? '-',
        translate('profile.birth_date'): dt == null ? '-' : formatDate_ddMMyyyy(dt),
        translate('profile.phone'): ch.phone ?? '-',
        translate('profile.document'): ch.document ?? '-',
        translate('profile.status'): (ch.checkedIn ?? false) ? translate('profile.active') : translate('profile.inactive'),
      };
    }
    return {};
  }

  Map<String, String> _getAddressData() {
    if (selectedUser != null) {
      final u = selectedUser!;
      return {
        translate('profile.address'): u.address ?? '-',
        translate('profile.address_number'): u.addressNumber ?? '-',
        translate('profile.address_complement'): u.addressComplement ?? '-',
        translate('profile.neighborhood'): u.neighborhood ?? '-',
        translate('profile.city'): u.city ?? '-',
        translate('profile.state'): u.state ?? '-',
        translate('profile.zip_code'): u.zipCode ?? '-',
      };
    } else if (selectedCollaborator != null) {
      final c = selectedCollaborator!;
      return {
        translate('profile.address'): c.address ?? '-',
        translate('profile.address_number'): c.addressNumber ?? '-',
        translate('profile.address_complement'): c.addressComplement ?? '-',
        translate('profile.neighborhood'): c.neighborhood ?? '-',
        translate('profile.city'): c.city ?? '-',
        translate('profile.state'): c.state ?? '-',
        translate('profile.zip_code'): c.zipCode ?? '-',
      };
    } else if (selectedCompany != null) {
      final co = selectedCompany!;
      return {
        translate('profile.address'): co.address ?? '-',
        translate('profile.address_number'): co.addressNumber ?? '-',
        translate('profile.address_complement'): co.addressComplement ?? '-',
        translate('profile.neighborhood'): co.neighborhood ?? '-',
        translate('profile.city'): co.city ?? '-',
        translate('profile.state'): co.state ?? '-',
        translate('profile.zip_code'): co.zipCode ?? '-',
      };
    } else if (selectedChild != null) {
      final ch = selectedChild!;
      return {
        translate('profile.address'): ch.address ?? '-',
        translate('profile.address_number'): ch.addressNumber ?? '-',
        translate('profile.address_complement'): ch.addressComplement ?? '-',
        translate('profile.neighborhood'): ch.neighborhood ?? '-',
        translate('profile.city'): ch.city ?? '-',
        translate('profile.state'): ch.state ?? '-',
        translate('profile.zip_code'): ch.zipCode ?? '-',
      };
    }
    return {};
  }
}
