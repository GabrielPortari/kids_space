import 'package:flutter/material.dart';

enum AdminTileType { company, responsible, child, collaborator, reports }

class AdminTileModel {
  final AdminTileType type;
  final IconData icon;

  const AdminTileModel({required this.type, required this.icon});
}
