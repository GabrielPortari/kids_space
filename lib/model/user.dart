import 'package:kids_space/model/base_user.dart';

class User extends BaseUser{

  final List<String>? childrenIds; 

  User({
    this.childrenIds,
    super.userType,
    super.name,
    super.email,
    super.photoUrl,
    super.birthDate,
    super.document,
    super.phone,
    super.address,
    super.addressNumber,
    super.addressComplement,
    super.neighborhood,
    super.city,
    super.state,
    super.zipCode,
    super.companyId,
    super.id,
    super.createdAt,
    super.updatedAt,
  });

  @override
  Map<String, dynamic> toJson() {
    final base = super.toJson();
    base['childrenIds'] = childrenIds;
    return base;
  }

  factory User.fromJson(Map<String, dynamic> json) {
    final map = Map<String, dynamic>.from(json);
    final base = BaseUser.fromJson(map);
    final children = map['childrenIds'];
    List<String>? childrenIds;
    if (children is List) {
      childrenIds = children.map((e) => e?.toString() ?? '').where((s) => s.isNotEmpty).toList();
    }
    return User(
      childrenIds: childrenIds,
      userType: base.userType,
      name: base.name,
      email: base.email,
      birthDate: base.birthDate,
      document: base.document,
      phone: base.phone,
      address: base.address,
      addressNumber: base.addressNumber,
      addressComplement: base.addressComplement,
      neighborhood: base.neighborhood,
      city: base.city,
      state: base.state,
      zipCode: base.zipCode,
      companyId: base.companyId,
      id: base.id,
      createdAt: base.createdAt,
      updatedAt: base.updatedAt,
    );
  }

}