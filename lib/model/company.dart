import 'package:kids_space/model/base_model.dart';
import 'package:kids_space/model/base_user.dart';
import 'package:kids_space/model/child.dart';
import 'package:kids_space/model/collaborator.dart';
import 'package:kids_space/model/user.dart';

class Company extends BaseModel{

  final String? fantasyName;
  final String? corporateName;
  final String? cnpj;
  final String? website;
  final String? email;
  final String? phone;
  final String? address;
  final String? addressNumber;
  final String? addressComplement;
  final String? neighborhood;
  final String? city;
  final String? state;
  final String? zipCode;
  final BaseUser? responsible;
  final String? logoUrl;
  final List<Collaborator>? collaborators;
  final List<User>? users;
  final List<Child>? children;

  Company({
    required super.createdAt, 
    required super.updatedAt,
    required super.id,
    this.fantasyName, 
    this.corporateName, 
    this.cnpj, 
    this.website, 
    this.address, 
    this.addressNumber, 
    this.addressComplement, 
    this.neighborhood,
     this.city, 
    this.state, 
    this.zipCode, 
    this.responsible, 
    this.logoUrl, 
    this.collaborators, 
    this.users, 
    this.children, this.email, this.phone
  });

  @override
  Map<String, dynamic> toJson() {
    final base = super.toJson();
    base['fantasyName'] = fantasyName;
    base['corporateName'] = corporateName;
    base['cnpj'] = cnpj;
    base['website'] = website;
    base['email'] = email;
    base['phone'] = phone;
    base['address'] = address;
    base['addressNumber'] = addressNumber;
    base['addressComplement'] = addressComplement;
    base['neighborhood'] = neighborhood;
    base['city'] = city;
    base['state'] = state;
    base['zipCode'] = zipCode;
    base['logoUrl'] = logoUrl;
    base['responsible'] = responsible?.toJson();
    base['collaborators'] = collaborators?.map((e) => e.toJson()).toList();
    base['users'] = users?.map((e) => e.toJson()).toList();
    base['children'] = children?.map((e) => e.toJson()).toList();
    return base;
  }

  factory Company.fromJson(Map<String, dynamic> json) {
    return Company(
      id: json['id'] as String?,
      createdAt: BaseModel.tryParseTimestamp(json['createdAt']),
      updatedAt: BaseModel.tryParseTimestamp(json['updatedAt']),
      fantasyName: json['fantasyName'] as String?,
      corporateName: json['corporateName'] as String?,
      cnpj: json['cnpj'] as String?,
      website: json['website'] as String?,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      address: json['address'] as String?,
      addressNumber: json['addressNumber'] as String?,
      addressComplement: json['addressComplement'] as String?,
      neighborhood: json['neighborhood'] as String?,
      city: json['city'] as String?,
      state: json['state'] as String?,
      zipCode: json['zipCode'] as String?,
      logoUrl: json['logoUrl'] as String?,
      responsible: json['responsible'] != null ? BaseUser.fromJson(Map<String, dynamic>.from(json['responsible'])) : null,
      collaborators: json['collaborators'] != null
          ? (json['collaborators'] as List).map((e) => Collaborator.fromJson(Map<String, dynamic>.from(e))).toList()
          : null,
      users: json['users'] != null
          ? (json['users'] as List).map((e) => User.fromJson(Map<String, dynamic>.from(e))).toList()
          : null,
      children: json['children'] != null
          ? (json['children'] as List).map((e) => Child.fromJson(Map<String, dynamic>.from(e))).toList()
          : null,
    );
  }
}