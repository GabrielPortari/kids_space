import 'package:kids_space/model/check_event.dart';

class Child {
  final String id;
  final String name;
  final String companyId;
  final List<String> responsibleUserIds; // IDs dos responsáveis
  final List<CheckEvent> checkEvents;
  
  Child({
    required this.id,
    required this.name,
    required this.companyId,
    required this.responsibleUserIds,
    required this.checkEvents,
  });
}