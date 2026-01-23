import 'package:flutter/material.dart';
import 'package:kids_space/controller/collaborator_controller.dart';
import 'package:kids_space/controller/user_controller.dart';
import 'package:kids_space/model/base_model.dart';
import 'package:kids_space/model/collaborator.dart';
import 'package:kids_space/model/user.dart';
import 'package:kids_space/model/child.dart';
import 'package:kids_space/controller/child_controller.dart';
import 'package:kids_space/view/design_system/app_theme.dart';
import 'package:kids_space/view/widgets/edit_entity_bottom_sheet.dart';
import 'package:kids_space/util/localization_service.dart';

/// Helper that shows a choice modal to edit personal data or address and
/// opens the generic `EditEntityBottomSheet` to apply changes.
Future<void> showProfileEditDialogs(
  BuildContext context, {
  User? user,
  Collaborator? collaborator,
  Child? child,
  ChildController? childController,
  required UserController userController,
  required CollaboratorController collaboratorController,
}) async {
  final choice = await showModalBottomSheet<String?>(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (_) => SafeArea(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(color: Theme.of(context).canvasColor, borderRadius: BorderRadius.circular(12)),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const SizedBox(height: 16),
          Text(translate('profile.edit_user'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
            leading: const Icon(Icons.close, color: danger),
            title: Text(translate('buttons.cancel')),
            onTap: () => Navigator.of(context).pop(null),
          ),
        ]),
      ),
    ),
  );

  if (choice == 'personal') {
    if (user != null || collaborator != null) {
      await _editPersonal(context, user: user, collaborator: collaborator, userController: userController, collaboratorController: collaboratorController);
    } else if (child != null && childController != null) {
      await _editChildPersonal(context, child: child, childController: childController);
    }
  } else if (choice == 'address') {
    if (user != null || collaborator != null) {
      await _editAddress(context, user: user, collaborator: collaborator, userController: userController, collaboratorController: collaboratorController);
    } else if (child != null && childController != null) {
      await _editChildAddress(context, child: child, childController: childController);
    }
  }
}

Future<bool?> _confirmDialog(BuildContext context, String title, String content) {
  return showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: [
        TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: Text(translate('buttons.cancel'))),
        TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: Text(translate('buttons.confirm'))),
      ],
    ),
  );
}

Future<void> _showResultDialog(BuildContext context, bool success, String successMsg, String errorMsg) {
  return showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(success ? translate('common.success') : translate('common.error')),
      content: Text(success ? successMsg : errorMsg),
      actions: [
        TextButton(onPressed: () => Navigator.of(ctx).pop(), child: Text(translate('buttons.ok'))),
      ],
    ),
  );
}

Future<void> _editPersonal(
  BuildContext context, {
  User? user,
  Collaborator? collaborator,
  required UserController userController,
  required CollaboratorController collaboratorController,
}) async {
  if (user != null) {
    final u = user;
    DateTime? parsedBirth = BaseModel.tryParseTimestamp(u.birthDate);
    final fields = [
      FieldDefinition(key: 'name', label: translate('profile.name'), initialValue: u.name ?? '', required: true),
      FieldDefinition(key: 'email', label: translate('profile.email'), type: FieldType.email, initialValue: u.email ?? '', required: true),
      FieldDefinition(key: 'birthDate', label: translate('profile.birth_date'), type: FieldType.date, initialValue: parsedBirth),
      FieldDefinition(key: 'phone', label: translate('profile.phone'), type: FieldType.phone, initialValue: u.phone ?? ''),
      FieldDefinition(key: 'document', label: translate('profile.document'), initialValue: u.document ?? ''),
    ];

    final res = await showEditEntityBottomSheet(context: context, title: translate('profile.edit_personal'), fields: fields);
    if (res != null) {
      final confirmed = await _confirmDialog(context, translate('profile.confirm_change_title'), translate('profile.confirm_change_personal'));
      if (confirmed != true) return;

      final updated = User(
        childrenIds: u.childrenIds,
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
        phone: res['phone']?.toString() ?? u.phone,
        address: u.address,
        addressNumber: u.addressNumber,
        addressComplement: u.addressComplement,
        neighborhood: u.neighborhood,
        city: u.city,
        state: u.state,
        zipCode: u.zipCode,
        companyId: u.companyId,
        id: u.id,
        createdAt: u.createdAt,
        updatedAt: DateTime.now(),
      );
      final success = await userController.updateUser(updated);
      await _showResultDialog(context, success, translate('profile.personal_update_success'), translate('profile.personal_update_error'));
    }
  } else if (collaborator != null) {
    final c = collaborator;
    DateTime? parsedBirth = BaseModel.tryParseTimestamp(c.birthDate);
    final fields = [
      FieldDefinition(key: 'name', label: translate('profile.name'), initialValue: c.name ?? '', required: true),
      FieldDefinition(key: 'email', label: translate('profile.email'), type: FieldType.email, initialValue: c.email ?? '', required: true),
      FieldDefinition(key: 'birthDate', label: translate('profile.birth_date'), type: FieldType.date, initialValue: parsedBirth),
      FieldDefinition(key: 'phone', label: translate('profile.phone'), type: FieldType.phone, initialValue: c.phone ?? ''),
      FieldDefinition(key: 'document', label: translate('profile.document'), initialValue: c.document ?? ''),
    ];

    final res = await showEditEntityBottomSheet(context: context, title: translate('profile.edit_personal'), fields: fields);
    if (res != null) {
      final confirmed = await _confirmDialog(context, translate('profile.confirm_change_title'), translate('profile.confirm_change_personal'));
      if (confirmed != true) return;

      final updated = Collaborator(
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
        phone: res['phone']?.toString() ?? c.phone,
        address: c.address,
        addressNumber: c.addressNumber,
        addressComplement: c.addressComplement,
        neighborhood: c.neighborhood,
        city: c.city,
        state: c.state,
        zipCode: c.zipCode,
        companyId: c.companyId,
        id: c.id,
        createdAt: c.createdAt,
        updatedAt: DateTime.now(),
      );
      final success = await collaboratorController.updateCollaborator(updated);
      await _showResultDialog(context, success, translate('profile.personal_update_success'), translate('profile.personal_update_error'));
    }
  }
}

Future<void> _editAddress(
  BuildContext context, {
  User? user,
  Collaborator? collaborator,
  required UserController userController,
  required CollaboratorController collaboratorController,
}) async {
  if (user != null) {
    final u = user;
    final fields = [
      FieldDefinition(key: 'address', label: translate('profile.address'), initialValue: u.address ?? ''),
      FieldDefinition(key: 'addressNumber', label: translate('profile.address_number'), initialValue: u.addressNumber ?? ''),
      FieldDefinition(key: 'addressComplement', label: translate('profile.address_complement'), initialValue: u.addressComplement ?? ''),
      FieldDefinition(key: 'neighborhood', label: translate('profile.neighborhood'), initialValue: u.neighborhood ?? ''),
      FieldDefinition(key: 'city', label: translate('profile.city'), initialValue: u.city ?? ''),
      FieldDefinition(key: 'state', label: translate('profile.state'), initialValue: u.state ?? ''),
      FieldDefinition(key: 'zipCode', label: translate('profile.zip_code'), initialValue: u.zipCode ?? ''),
    ];

    final res = await showEditEntityBottomSheet(context: context, title: translate('profile.edit_address'), fields: fields);
    if (res != null) {
      final confirmed = await _confirmDialog(context, translate('profile.confirm_change_title'), translate('profile.confirm_change_address'));
      if (confirmed != true) return;

      final updated = User(
        childrenIds: u.childrenIds,
        userType: u.userType,
        name: u.name,
        email: u.email,
        birthDate: u.birthDate,
        document: u.document,
        phone: u.phone,
        address: res['address']?.toString() ?? u.address,
        addressNumber: res['addressNumber']?.toString() ?? u.addressNumber,
        addressComplement: res['addressComplement']?.toString() ?? u.addressComplement,
        neighborhood: res['neighborhood']?.toString() ?? u.neighborhood,
        city: res['city']?.toString() ?? u.city,
        state: res['state']?.toString() ?? u.state,
        zipCode: res['zipCode']?.toString() ?? u.zipCode,
        companyId: u.companyId,
        id: u.id,
        createdAt: u.createdAt,
        updatedAt: DateTime.now(),
      );
      final success = await userController.updateUser(updated);
      await _showResultDialog(context, success, translate('profile.address_update_success'), translate('profile.address_update_error'));
    }
  } else if (collaborator != null) {
    final c = collaborator;
    final fields = [
      FieldDefinition(key: 'address', label: translate('profile.address'), initialValue: c.address ?? ''),
      FieldDefinition(key: 'addressNumber', label: translate('profile.address_number'), initialValue: c.addressNumber ?? ''),
      FieldDefinition(key: 'addressComplement', label: translate('profile.address_complement'), initialValue: c.addressComplement ?? ''),
      FieldDefinition(key: 'neighborhood', label: translate('profile.neighborhood'), initialValue: c.neighborhood ?? ''),
      FieldDefinition(key: 'city', label: translate('profile.city'), initialValue: c.city ?? ''),
      FieldDefinition(key: 'state', label: translate('profile.state'), initialValue: c.state ?? ''),
      FieldDefinition(key: 'zipCode', label: translate('profile.zip_code'), initialValue: c.zipCode ?? ''),
    ];

    final res = await showEditEntityBottomSheet(context: context, title: 'Editar endereço', fields: fields);
    if (res != null) {
      final confirmed = await _confirmDialog(context, 'Confirmar alteração', 'Deseja aplicar as alterações no endereço?');
      if (confirmed != true) return;

      final updated = Collaborator(
        userType: c.userType,
        name: c.name,
        email: c.email,
        birthDate: c.birthDate,
        document: c.document,
        phone: c.phone,
        address: res['address']?.toString() ?? c.address,
        addressNumber: res['addressNumber']?.toString() ?? c.addressNumber,
        addressComplement: res['addressComplement']?.toString() ?? c.addressComplement,
        neighborhood: res['neighborhood']?.toString() ?? c.neighborhood,
        city: res['city']?.toString() ?? c.city,
        state: res['state']?.toString() ?? c.state,
        zipCode: res['zipCode']?.toString() ?? c.zipCode,
        companyId: c.companyId,
        id: c.id,
        createdAt: c.createdAt,
        updatedAt: DateTime.now(),
      );
      final success = await collaboratorController.updateCollaborator(updated);
      await _showResultDialog(context, success, 'Endereço atualizado com sucesso.', 'Falha ao atualizar endereço.');
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
        decoration: BoxDecoration(color: Theme.of(context).canvasColor, borderRadius: BorderRadius.circular(12)),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const SizedBox(height: 16),
          Text(translate('profile.edit_child'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
            leading: const Icon(Icons.close, color: danger),
            title: Text(translate('buttons.cancel')),
            onTap: () => Navigator.of(context).pop(null),
          ),
        ]),
      ),
    ),
  );

  if (choice == 'personal') {
    return await _editChildPersonal(context, child: child, childController: childController);
  } else if (choice == 'address') {
    return await _editChildAddress(context, child: child, childController: childController);
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
    FieldDefinition(key: 'name', label: translate('profile.name'), initialValue: c.name ?? '', required: true),
    FieldDefinition(key: 'email', label: 'Email', type: FieldType.email, initialValue: c.email ?? ''),
    FieldDefinition(key: 'birthDate', label: 'Data de Nascimento', type: FieldType.date, initialValue: parsedBirth),
    FieldDefinition(key: 'phone', label: 'Telefone', type: FieldType.phone, initialValue: c.phone ?? ''),
    FieldDefinition(key: 'document', label: 'Documento', initialValue: c.document ?? ''),
  ];

  final res = await showEditEntityBottomSheet(context: context, title: 'Editar dados pessoais', fields: fields);
  if (res == null) return null;

  final confirmed = await _confirmDialog(context, 'Confirmar alteração', 'Deseja aplicar as alterações nos dados pessoais?');
  if (confirmed != true) return null;

  final updated = Child(
    responsibleUserIds: c.responsibleUserIds,
    checkedIn: c.checkedIn,
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
    phone: res['phone']?.toString() ?? c.phone,
    address: c.address,
    addressNumber: c.addressNumber,
    addressComplement: c.addressComplement,
    neighborhood: c.neighborhood,
    city: c.city,
    state: c.state,
    zipCode: c.zipCode,
    companyId: c.companyId,
    id: c.id,
    createdAt: c.createdAt,
    updatedAt: DateTime.now(),
  );

  final success = await childController.updateChild(updated);
  await _showResultDialog(context, success, 'Dados pessoais atualizados com sucesso.', 'Falha ao atualizar dados pessoais.');
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
    FieldDefinition(key: 'address', label: 'Endereço', initialValue: c.address ?? ''),
    FieldDefinition(key: 'addressNumber', label: 'Número', initialValue: c.addressNumber ?? ''),
    FieldDefinition(key: 'addressComplement', label: 'Complemento', initialValue: c.addressComplement ?? ''),
    FieldDefinition(key: 'neighborhood', label: 'Bairro', initialValue: c.neighborhood ?? ''),
    FieldDefinition(key: 'city', label: 'Cidade', initialValue: c.city ?? ''),
    FieldDefinition(key: 'state', label: 'Estado', initialValue: c.state ?? ''),
    FieldDefinition(key: 'zipCode', label: 'CEP', initialValue: c.zipCode ?? ''),
  ];

  final res = await showEditEntityBottomSheet(context: context, title: 'Editar endereço', fields: fields);
  if (res == null) return null;

  final confirmed = await _confirmDialog(context, 'Confirmar alteração', 'Deseja aplicar as alterações no endereço?');
  if (confirmed != true) return null;

  final updated = Child(
    responsibleUserIds: c.responsibleUserIds,
    checkedIn: c.checkedIn,
    userType: c.userType,
    name: c.name,
    email: c.email,
    birthDate: c.birthDate,
    document: c.document,
    phone: c.phone,
    address: res['address']?.toString() ?? c.address,
    addressNumber: res['addressNumber']?.toString() ?? c.addressNumber,
    addressComplement: res['addressComplement']?.toString() ?? c.addressComplement,
    neighborhood: res['neighborhood']?.toString() ?? c.neighborhood,
    city: res['city']?.toString() ?? c.city,
    state: res['state']?.toString() ?? c.state,
    zipCode: res['zipCode']?.toString() ?? c.zipCode,
    companyId: c.companyId,
    id: c.id,
    createdAt: c.createdAt,
    updatedAt: DateTime.now(),
  );

  final success = await childController.updateChild(updated);
  await _showResultDialog(context, success, 'Endereço atualizado com sucesso.', 'Falha ao atualizar endereço.');
  return success;
}
