import 'package:kids_space/model/check_event.dart';
import 'package:kids_space/model/user.dart';

class Child {
  final String id;
  final String name;
  final String companyId;
  final List<User> responsibleUsers; // IDs dos responsáveis
  final List<CheckEvent>? checkEvents;
  
  Child({
    required this.id,
    required this.name,
    required this.companyId,
    required this.responsibleUsers,
    required this.checkEvents,
  });
}