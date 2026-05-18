import 'package:flutter/material.dart';

enum CompanyTileType {
  company,
  dashboard,
  attendances,
  responsible,
  child,
  collaborator,
  reports,
}

class CompanyTileModel {
  final CompanyTileType type;
  final IconData icon;

  const CompanyTileModel({required this.type, required this.icon});
}
