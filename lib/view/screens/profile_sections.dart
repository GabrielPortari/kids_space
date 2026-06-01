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
import 'package:kids_space/view/widgets/profile_health_info_section.dart';
import 'package:kids_space/util/localization_service.dart';

class ProfileContent extends StatelessWidget {
  final Parent? selectedParent;
  final Collaborator? selectedCollaborator;
  final Company? selectedCompany;
  final Child? selectedChild;

  const ProfileContent({
    Key? key,
    this.selectedParent,
    this.selectedCollaborator,
    this.selectedCompany,
    this.selectedChild,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    dev.log(
      'ProfileContent build - selectedParent: ${selectedParent?.toJson() ?? selectedParent}',
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
              selectedParent?.name ??
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
              selectedParent?.name ??
              selectedCollaborator?.name ??
              selectedCompany?.name ??
              translate('profile.name_placeholder'),
          userTypeLabel: selectedParent != null
              ? translate('profile.user_type.parent')
              : selectedCompany != null
              ? translate('profile.user_type.company')
              : selectedCollaborator != null
              ? (selectedCollaborator?.userType == UserType.company
                    ? translate('profile.user_type.admin')
                    : translate('profile.user_type.collaborator'))
              : selectedChild != null
              ? translate('profile.user_type.child')
              : translate('profile.user_type.unknown'),
          id:
              selectedParent?.id ??
              selectedCollaborator?.id ??
              selectedChild?.id ??
              selectedCompany?.id,
        ),
        const SizedBox(height: 16),
        // Alerta de saúde no topo para crianças — dado crítico antes do scroll
        if (selectedChild != null)
          ProfileHealthInfoSection(healthInfo: selectedChild!.healthInfo),
        if (selectedChild != null) const SizedBox(height: 16),
        ProfileInfoCardSection(
          title: translate('profile.personal_title'),
          icon: Icons.person_outline_rounded,
          entries: profileEntries,
        ),
        const SizedBox(height: 16),
        ProfileInfoCardSection(
          title: translate('profile.address_title'),
          icon: Icons.home_outlined,
          entries: addressEntries,
        ),
        const SizedBox(height: 16),
        if (selectedParent != null)
          ProfileChildrenCardSection(parent: selectedParent),
        if (selectedChild != null)
          ProfileResponsiblesCardSection(child: selectedChild),
      ],
    );
  }

  Map<String, String> _getProfileData() {
    if (selectedParent != null) {
      final u = selectedParent!;
      final dt = DateTime.tryParse(u.birthDate ?? '');
      return {
        translate('profile.name'): u.name ?? '-',
        translate('profile.email'): u.email ?? '-',
        translate('profile.birth_date'): dt == null
            ? '-'
            : formatDate_ddMMyyyy(dt),
        translate('profile.phone'): u.contact ?? '-',
        translate('profile.document'): u.document ?? '-',
      };
    } else if (selectedCollaborator != null) {
      final c = selectedCollaborator!;
      final dt = DateTime.tryParse(c.birthDate ?? '');
      return {
        translate('profile.name'): c.name ?? '-',
        translate('profile.email'): c.email ?? '-',
        translate('profile.birth_date'): dt == null
            ? '-'
            : formatDate_ddMMyyyy(dt),
        translate('profile.phone'): c.contact ?? '-',
        translate('profile.document'): c.document ?? '-',
      };
    } else if (selectedCompany != null) {
      final co = selectedCompany!;
      return {
        translate('profile.fantasy_name'): co.name ?? '-',
        translate('profile.corporate_name'): co.legalName ?? '-',
        translate('profile.email'): co.email ?? '-',
        translate('profile.phone'): co.contact ?? '-',
        translate('profile.cnpj'): co.cnpj ?? '-',
        translate('profile.website'): co.website ?? '-',
        translate('profile.logo_url'): co.logoUrl ?? '-',
      };
    } else if (selectedChild != null) {
      final ch = selectedChild!;
      final dt = DateTime.tryParse(ch.birthDate ?? '');
      return {
        translate('profile.name'): ch.name ?? '-',
        translate('profile.email'): ch.email ?? '-',
        translate('profile.birth_date'): dt == null
            ? '-'
            : formatDate_ddMMyyyy(dt),
        translate('profile.phone'): ch.contact ?? '-',
        translate('profile.document'): ch.document ?? '-',
        translate('profile.status'): (ch.checkedIn ?? false)
            ? translate('profile.active')
            : translate('profile.inactive'),
      };
    }
    return {};
  }

  Map<String, String> _getAddressData() {
    if (selectedParent != null) {
      final addr = selectedParent!.address;
      return {
        translate('profile.address'): addr?.address ?? '-',
        translate('profile.address_number'): addr?.number ?? '-',
        translate('profile.address_complement'): addr?.complement ?? '-',
        translate('profile.neighborhood'): addr?.neighborhood ?? '-',
        translate('profile.city'): addr?.city ?? '-',
        translate('profile.state'): addr?.state ?? '-',
        translate('profile.zip_code'): addr?.zipcode ?? '-',
      };
    } else if (selectedCollaborator != null) {
      final addr = selectedCollaborator!.address;
      return {
        translate('profile.address'): addr?.address ?? '-',
        translate('profile.address_number'): addr?.number ?? '-',
        translate('profile.address_complement'): addr?.complement ?? '-',
        translate('profile.neighborhood'): addr?.neighborhood ?? '-',
        translate('profile.city'): addr?.city ?? '-',
        translate('profile.state'): addr?.state ?? '-',
        translate('profile.zip_code'): addr?.zipcode ?? '-',
      };
    } else if (selectedCompany != null) {
      final addr = selectedCompany!.address;
      return {
        translate('profile.address'): addr?.address ?? '-',
        translate('profile.address_number'): addr?.number ?? '-',
        translate('profile.address_complement'): addr?.complement ?? '-',
        translate('profile.neighborhood'): addr?.neighborhood ?? '-',
        translate('profile.city'): addr?.city ?? '-',
        translate('profile.state'): addr?.state ?? '-',
        translate('profile.zip_code'): addr?.zipcode ?? '-',
      };
    } else if (selectedChild != null) {
      final addr = selectedChild!.address;
      return {
        translate('profile.address'): addr?.address ?? '-',
        translate('profile.address_number'): addr?.number ?? '-',
        translate('profile.address_complement'): addr?.complement ?? '-',
        translate('profile.neighborhood'): addr?.neighborhood ?? '-',
        translate('profile.city'): addr?.city ?? '-',
        translate('profile.state'): addr?.state ?? '-',
        translate('profile.zip_code'): addr?.zipcode ?? '-',
      };
    }
    return {};
  }
}
