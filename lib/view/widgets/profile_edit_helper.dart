import 'package:flutter/material.dart';
import 'package:kids_space/controller/collaborator_controller.dart';
import 'package:kids_space/controller/parent_controller.dart';
import 'package:kids_space/model/base_model.dart';
import 'package:kids_space/model/collaborator.dart';
import 'package:kids_space/model/parent.dart';
import 'package:kids_space/model/child.dart';
import 'package:kids_space/model/address.dart';
import 'package:kids_space/controller/child_controller.dart';
import 'package:kids_space/view/design_system/app_theme.dart';
import 'package:kids_space/view/widgets/edit_entity_bottom_sheet.dart';
import 'package:kids_space/view/widgets/health_info_edit_bottom_sheet.dart';
import 'package:kids_space/util/localization_service.dart';

/// Helper that shows a choice modal to edit personal data or address and
/// opens the generic `EditEntityBottomSheet` to apply changes.
Future<void> showProfileEditDialogs(
  BuildContext context, {
  Parent? parent,
  Collaborator? collaborator,
  Child? child,
  ChildController? childController,
  required ParentController userController,
  required CollaboratorController collaboratorController,
}) async {
  final choice = await showModalBottomSheet<String?>(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (_) => SafeArea(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).canvasColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 16),
            Text(
              translate('profile.edit_user'),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Divider(),

            ListTile(
              leading: const Icon(Icons.person),
              title: Text(translate('profile.edit_personal')),
              onTap: () => Navigator.of(context).pop('personal'),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: Text(translate('profile.edit_address')),
              onTap: () => Navigator.of(context).pop('address'),
            ),
            if (child != null && childController != null)
              ListTile(
                leading: const Icon(Icons.health_and_safety),
                title: Text(translate('health_info.edit_title')),
                onTap: () => Navigator.of(context).pop('health'),
              ),
            ListTile(
              leading: const Icon(Icons.close, color: danger),
              title: Text(translate('buttons.cancel')),
              onTap: () => Navigator.of(context).pop(null),
            ),
          ],
        ),
      ),
    ),
  );

  if (choice == 'personal') {
    if (parent != null || collaborator != null) {
      await _editPersonal(
        context,
        parent: parent,
        collaborator: collaborator,
        userController: userController,
        collaboratorController: collaboratorController,
      );
    } else if (child != null && childController != null) {
      await _editChildPersonal(
        context,
        child: child,
        childController: childController,
      );
    }
  } else if (choice == 'address') {
    if (parent != null || collaborator != null) {
      await _editAddress(
        context,
        parent: parent,
        collaborator: collaborator,
        userController: userController,
        collaboratorController: collaboratorController,
      );
    } else if (child != null && childController != null) {
      await _editChildAddress(
        context,
        child: child,
        childController: childController,
      );
    }
  } else if (choice == 'health') {
    if (child != null && childController != null) {
      await _editChildHealthInfo(
        context,
        child: child,
        childController: childController,
      );
    }
  }
}

Future<bool?> _confirmDialog(
  BuildContext context,
  String title,
  String content,
) {
  return showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(false),
          child: Text(translate('buttons.cancel')),
        ),
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(true),
          child: Text(translate('buttons.confirm')),
        ),
      ],
    ),
  );
}

Future<void> _showResultDialog(
  BuildContext context,
  bool success,
  String successMsg,
  String errorMsg,
) {
  return showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(
        success ? translate('common.success') : translate('common.error'),
      ),
      content: Text(success ? successMsg : errorMsg),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(),
          child: Text(translate('buttons.ok')),
        ),
      ],
    ),
  );
}

Future<void> _editPersonal(
  BuildContext context, {
  Parent? parent,
  Collaborator? collaborator,
  required ParentController userController,
  required CollaboratorController collaboratorController,
}) async {
  if (parent != null) {
    final u = parent;
    DateTime? parsedBirth = BaseModel.tryParseTimestamp(u.birthDate);
    final fields = [
      FieldDefinition(
        key: 'name',
        label: translate('profile.name'),
        initialValue: u.name ?? '',
        required: true,
      ),
      FieldDefinition(
        key: 'email',
        label: translate('profile.email'),
        type: FieldType.email,
        initialValue: u.email ?? '',
        required: true,
      ),
      FieldDefinition(
        key: 'birthDate',
        label: translate('profile.birth_date'),
        type: FieldType.date,
        initialValue: parsedBirth,
      ),
      FieldDefinition(
        key: 'phone',
        label: translate('profile.phone'),
        type: FieldType.phone,
        initialValue: u.contact ?? '',
      ),
      FieldDefinition(
        key: 'document',
        label: translate('profile.document'),
        initialValue: u.document ?? '',
      ),
    ];

    final res = await showEditEntityBottomSheet(
      context: context,
      title: translate('profile.edit_personal'),
      fields: fields,
    );
    if (res != null) {
      final confirmed = await _confirmDialog(
        context,
        translate('profile.confirm_change_title'),
        translate('profile.confirm_change_personal'),
      );
      if (confirmed != true) return;

      final updated = Parent(
        children: u.children,
        userType: u.userType,
        name: res['name']?.toString() ?? u.name,
        email: res['email']?.toString() ?? u.email,
        birthDate: (() {
          final v = res['birthDate'];
          if (v is DateTime) return v.toIso8601String();
          if (v is String && v.isNotEmpty) return v.toString();
          return u.birthDate;
        })(),
        document: res['document']?.toString() ?? u.document,
        contact: res['phone']?.toString() ?? u.contact,
        address: u.address,
        companyId: u.companyId,
        id: u.id,
        createdAt: u.createdAt,
        updatedAt: DateTime.now(),
      );
      final success = await userController.updateUser(updated);
      await _showResultDialog(
        context,
        success,
        translate('profile.personal_update_success'),
        translate('profile.personal_update_error'),
      );
    }
  } else if (collaborator != null) {
    final c = collaborator;
    DateTime? parsedBirth = BaseModel.tryParseTimestamp(c.birthDate);
    final fields = [
      FieldDefinition(
        key: 'name',
        label: translate('profile.name'),
        initialValue: c.name ?? '',
        required: true,
      ),
      FieldDefinition(
        key: 'birthDate',
        label: translate('profile.birth_date'),
        type: FieldType.date,
        initialValue: parsedBirth,
      ),
      FieldDefinition(
        key: 'phone',
        label: translate('profile.phone'),
        type: FieldType.phone,
        initialValue: c.contact ?? '',
      ),
      FieldDefinition(
        key: 'document',
        label: translate('profile.document'),
        initialValue: c.document ?? '',
      ),
    ];

    final res = await showEditEntityBottomSheet(
      context: context,
      title: translate('profile.edit_personal'),
      fields: fields,
    );
    if (res != null) {
      final confirmed = await _confirmDialog(
        context,
        translate('profile.confirm_change_title'),
        translate('profile.confirm_change_personal'),
      );
      if (confirmed != true) return;

      final updated = Collaborator(
        userType: c.userType,
        name: res['name']?.toString() ?? c.name,
        birthDate: (() {
          final v = res['birthDate'];
          if (v is DateTime) return v.toIso8601String();
          if (v is String && v.isNotEmpty) return v.toString();
          return c.birthDate;
        })(),
        document: res['document']?.toString() ?? c.document,
        contact: res['phone']?.toString() ?? c.contact,
        address: c.address,
        companyId: c.companyId,
        id: c.id,
        createdAt: c.createdAt,
        updatedAt: DateTime.now(),
      );
      final success = await collaboratorController.updateCollaborator(updated);
      await _showResultDialog(
        context,
        success,
        translate('profile.personal_update_success'),
        translate('profile.personal_update_error'),
      );
    }
  }
}

Future<void> _editAddress(
  BuildContext context, {
  Parent? parent,
  Collaborator? collaborator,
  required ParentController userController,
  required CollaboratorController collaboratorController,
}) async {
  if (parent != null) {
    final u = parent;
    final fields = [
      FieldDefinition(
        key: 'address',
        label: translate('profile.address'),
        initialValue: u.address?.address ?? '',
      ),
      FieldDefinition(
        key: 'addressNumber',
        label: translate('profile.address_number'),
        initialValue: u.address?.number ?? '',
      ),
      FieldDefinition(
        key: 'addressComplement',
        label: translate('profile.address_complement'),
        initialValue: u.address?.complement ?? '',
      ),
      FieldDefinition(
        key: 'neighborhood',
        label: translate('profile.neighborhood'),
        initialValue: u.address?.neighborhood ?? '',
      ),
      FieldDefinition(
        key: 'city',
        label: translate('profile.city'),
        initialValue: u.address?.city ?? '',
      ),
      FieldDefinition(
        key: 'state',
        label: translate('profile.state'),
        initialValue: u.address?.state ?? '',
      ),
      FieldDefinition(
        key: 'zipCode',
        label: translate('profile.zip_code'),
        initialValue: u.address?.zipcode ?? '',
      ),
    ];

    final res = await showEditEntityBottomSheet(
      context: context,
      title: translate('profile.edit_address'),
      fields: fields,
    );
    if (res != null) {
      final confirmed = await _confirmDialog(
        context,
        translate('profile.confirm_change_title'),
        translate('profile.confirm_change_address'),
      );
      if (confirmed != true) return;

      final updated = Parent(
        children: u.children,
        userType: u.userType,
        name: u.name,
        email: u.email,
        birthDate: u.birthDate,
        document: u.document,
        contact: u.contact,
        address: (() {
          final any =
              res['address'] != null ||
              res['addressNumber'] != null ||
              res['addressComplement'] != null ||
              res['neighborhood'] != null ||
              res['city'] != null ||
              res['state'] != null ||
              res['zipCode'] != null;
          if (!any) return u.address;
          return Address(
            address: res['address']?.toString() ?? u.address?.address,
            number: res['addressNumber']?.toString() ?? u.address?.number,
            complement:
                res['addressComplement']?.toString() ?? u.address?.complement,
            neighborhood:
                res['neighborhood']?.toString() ?? u.address?.neighborhood,
            city: res['city']?.toString() ?? u.address?.city,
            state: res['state']?.toString() ?? u.address?.state,
            zipcode: res['zipCode']?.toString() ?? u.address?.zipcode,
          );
        })(),
        companyId: u.companyId,
        id: u.id,
        createdAt: u.createdAt,
        updatedAt: DateTime.now(),
      );
      final success = await userController.updateUser(updated);
      await _showResultDialog(
        context,
        success,
        translate('profile.address_update_success'),
        translate('profile.address_update_error'),
      );
    }
  } else if (collaborator != null) {
    final c = collaborator;
    final fields = [
      FieldDefinition(
        key: 'address',
        label: translate('profile.address'),
        initialValue: c.address?.address ?? '',
      ),
      FieldDefinition(
        key: 'addressNumber',
        label: translate('profile.address_number'),
        initialValue: c.address?.number ?? '',
      ),
      FieldDefinition(
        key: 'addressComplement',
        label: translate('profile.address_complement'),
        initialValue: c.address?.complement ?? '',
      ),
      FieldDefinition(
        key: 'neighborhood',
        label: translate('profile.neighborhood'),
        initialValue: c.address?.neighborhood ?? '',
      ),
      FieldDefinition(
        key: 'city',
        label: translate('profile.city'),
        initialValue: c.address?.city ?? '',
      ),
      FieldDefinition(
        key: 'state',
        label: translate('profile.state'),
        initialValue: c.address?.state ?? '',
      ),
      FieldDefinition(
        key: 'zipCode',
        label: translate('profile.zip_code'),
        initialValue: c.address?.zipcode ?? '',
      ),
    ];

    final res = await showEditEntityBottomSheet(
      context: context,
      title: 'Editar endereço',
      fields: fields,
    );
    if (res != null) {
      final confirmed = await _confirmDialog(
        context,
        'Confirmar alteração',
        'Deseja aplicar as alterações no endereço?',
      );
      if (confirmed != true) return;

      final updated = Collaborator(
        userType: c.userType,
        name: c.name,
        email: c.email,
        birthDate: c.birthDate,
        document: c.document,
        contact: c.contact,
        address: (() {
          final any =
              res['address'] != null ||
              res['addressNumber'] != null ||
              res['addressComplement'] != null ||
              res['neighborhood'] != null ||
              res['city'] != null ||
              res['state'] != null ||
              res['zipCode'] != null;
          if (!any) return c.address;
          return Address(
            address: res['address']?.toString() ?? c.address?.address,
            number: res['addressNumber']?.toString() ?? c.address?.number,
            complement:
                res['addressComplement']?.toString() ?? c.address?.complement,
            neighborhood:
                res['neighborhood']?.toString() ?? c.address?.neighborhood,
            city: res['city']?.toString() ?? c.address?.city,
            state: res['state']?.toString() ?? c.address?.state,
            zipcode: res['zipCode']?.toString() ?? c.address?.zipcode,
          );
        })(),
        companyId: c.companyId,
        id: c.id,
        createdAt: c.createdAt,
        updatedAt: DateTime.now(),
      );
      final success = await collaboratorController.updateCollaborator(updated);
      await _showResultDialog(
        context,
        success,
        'Endereço atualizado com sucesso.',
        'Falha ao atualizar endereço.',
      );
    }
  }
}

/// Show edit dialogs for a [Child] following the same pattern used for User/Collaborator.
/// Returns `true` if an update occurred successfully, `false` on failure, or `null` if cancelled.
Future<bool?> showChildEditDialogs(
  BuildContext context, {
  Child? child,
  required ChildController childController,
}) async {
  final choice = await showModalBottomSheet<String?>(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (_) => SafeArea(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).canvasColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 16),
            Text(
              translate('profile.edit_child'),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Divider(),
            ListTile(
              leading: const Icon(Icons.person),
              title: Text(translate('profile.edit_personal')),
              onTap: () => Navigator.of(context).pop('personal'),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: Text(translate('profile.edit_address')),
              onTap: () => Navigator.of(context).pop('address'),
            ),
            ListTile(
              leading: const Icon(Icons.health_and_safety),
              title: Text(translate('health_info.edit_title')),
              onTap: () => Navigator.of(context).pop('health'),
            ),
            ListTile(
              leading: const Icon(Icons.close, color: danger),
              title: Text(translate('buttons.cancel')),
              onTap: () => Navigator.of(context).pop(null),
            ),
          ],
        ),
      ),
    ),
  );

  if (choice == 'personal') {
    return await _editChildPersonal(
      context,
      child: child,
      childController: childController,
    );
  } else if (choice == 'address') {
    return await _editChildAddress(
      context,
      child: child,
      childController: childController,
    );
  } else if (choice == 'health') {
    return await _editChildHealthInfo(
      context,
      child: child,
      childController: childController,
    );
  }
  return null;
}

Future<bool?> _editChildPersonal(
  BuildContext context, {
  Child? child,
  required ChildController childController,
}) async {
  if (child == null) return null;
  final c = child;
  DateTime? parsedBirth = BaseModel.tryParseTimestamp(c.birthDate);
  final fields = [
    FieldDefinition(
      key: 'name',
      label: translate('profile.name'),
      initialValue: c.name ?? '',
      required: true,
    ),
    FieldDefinition(
      key: 'email',
      label: 'Email',
      type: FieldType.email,
      initialValue: c.email ?? '',
    ),
    FieldDefinition(
      key: 'birthDate',
      label: 'Data de Nascimento',
      type: FieldType.date,
      initialValue: parsedBirth,
    ),
    FieldDefinition(
      key: 'phone',
      label: 'Telefone',
      type: FieldType.phone,
      initialValue: c.contact ?? '',
    ),
    FieldDefinition(
      key: 'document',
      label: 'Documento',
      initialValue: c.document ?? '',
    ),
  ];

  final res = await showEditEntityBottomSheet(
    context: context,
    title: 'Editar dados pessoais',
    fields: fields,
  );
  if (res == null) return null;

  final confirmed = await _confirmDialog(
    context,
    'Confirmar alteração',
    'Deseja aplicar as alterações nos dados pessoais?',
  );
  if (confirmed != true) return null;

  final updated = Child(
    parents: c.parents,
    checkedIn: c.checkedIn,
    // userType remains
    userType: c.userType,
    name: res['name']?.toString() ?? c.name,
    email: res['email']?.toString() ?? c.email,
    birthDate: (() {
      final v = res['birthDate'];
      if (v is DateTime) return v.toIso8601String();
      if (v is String && v.isNotEmpty) return v.toString();
      return c.birthDate;
    })(),
    document: res['document']?.toString() ?? c.document,
    contact: res['contact']?.toString() ?? c.contact,
    address: c.address,
    companyId: c.companyId,
    id: c.id,
    createdAt: c.createdAt,
    updatedAt: DateTime.now(),
  );

  final success = await childController.updateChild(updated);
  await _showResultDialog(
    context,
    success,
    'Dados pessoais atualizados com sucesso.',
    'Falha ao atualizar dados pessoais.',
  );
  return success;
}

Future<bool?> _editChildAddress(
  BuildContext context, {
  Child? child,
  required ChildController childController,
}) async {
  if (child == null) return null;
  final c = child;
  final fields = [
    FieldDefinition(
      key: 'address',
      label: 'Endereço',
      initialValue: c.address?.address ?? '',
    ),
    FieldDefinition(
      key: 'addressNumber',
      label: 'Número',
      initialValue: c.address?.number ?? '',
    ),
    FieldDefinition(
      key: 'addressComplement',
      label: 'Complemento',
      initialValue: c.address?.complement ?? '',
    ),
    FieldDefinition(
      key: 'neighborhood',
      label: 'Bairro',
      initialValue: c.address?.neighborhood ?? '',
    ),
    FieldDefinition(
      key: 'city',
      label: 'Cidade',
      initialValue: c.address?.city ?? '',
    ),
    FieldDefinition(
      key: 'state',
      label: 'Estado',
      initialValue: c.address?.state ?? '',
    ),
    FieldDefinition(
      key: 'zipCode',
      label: 'CEP',
      initialValue: c.address?.zipcode ?? '',
    ),
  ];

  final res = await showEditEntityBottomSheet(
    context: context,
    title: 'Editar endereço',
    fields: fields,
  );
  if (res == null) return null;

  final confirmed = await _confirmDialog(
    context,
    'Confirmar alteração',
    'Deseja aplicar as alterações no endereço?',
  );
  if (confirmed != true) return null;

  final updated = Child(
    parents: c.parents,
    checkedIn: c.checkedIn,
    userType: c.userType,
    name: c.name,
    email: c.email,
    birthDate: c.birthDate,
    document: c.document,
    contact: c.contact,
    address: (() {
      final any =
          res['address'] != null ||
          res['addressNumber'] != null ||
          res['addressComplement'] != null ||
          res['neighborhood'] != null ||
          res['city'] != null ||
          res['state'] != null ||
          res['zipCode'] != null;
      if (!any) return c.address;
      return Address(
        address: res['address']?.toString() ?? c.address?.address,
        number: res['addressNumber']?.toString() ?? c.address?.number,
        complement:
            res['addressComplement']?.toString() ?? c.address?.complement,
        neighborhood:
            res['neighborhood']?.toString() ?? c.address?.neighborhood,
        city: res['city']?.toString() ?? c.address?.city,
        state: res['state']?.toString() ?? c.address?.state,
        zipcode: res['zipCode']?.toString() ?? c.address?.zipcode,
      );
    })(),
    companyId: c.companyId,
    id: c.id,
    createdAt: c.createdAt,
    updatedAt: DateTime.now(),
  );

  final success = await childController.updateChild(updated);
  await _showResultDialog(
    context,
    success,
    'Endereço atualizado com sucesso.',
    'Falha ao atualizar endereço.',
  );
  return success;
}

Future<bool?> _editChildHealthInfo(
  BuildContext context, {
  Child? child,
  required ChildController childController,
}) async {
  if (child == null) return null;

  final result = await showHealthInfoEditBottomSheet(
    context: context,
    current: child.healthInfo,
  );
  if (result == null) return null;

  final confirmed = await _confirmDialog(
    context,
    translate('profile.confirm_change_title'),
    translate('health_info.confirm_change'),
  );
  if (confirmed != true) return null;

  final updated = Child(
    id: child.id,
    createdAt: child.createdAt,
    updatedAt: DateTime.now(),
    name: child.name,
    email: child.email,
    birthDate: child.birthDate,
    document: child.document,
    contact: child.contact,
    address: child.address,
    companyId: child.companyId,
    parents: child.parents,
    checkedIn: child.checkedIn,
    userType: child.userType,
    healthInfo: result,
  );

  final success = await childController.updateChild(updated);
  await _showResultDialog(
    context,
    success,
    translate('health_info.update_success'),
    translate('health_info.update_error'),
  );
  return success;
}
