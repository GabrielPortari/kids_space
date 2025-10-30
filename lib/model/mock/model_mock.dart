import '../company.dart';
import '../user.dart';
import '../collaborator.dart';
import '../child.dart';
import '../check_event.dart';

final mockCollaborators = [
  Collaborator(id: 'c1', name: 'João', companyId: '1', email: 'joao@techkids.com', password: '123456'),
  Collaborator(id: 'c2', name: 'Ana', companyId: '2', email: 'ana@educaplay.com', password: '654321'),
  Collaborator(id: 'c3', name: 'Pedro', companyId: '3', email: 'pedro@brincaraprender.com', password: 'abc123'),
  Collaborator(id: 'c4', name: 'Juliana', companyId: '4', email: 'juliana@mundoinfantil.com', password: 'juliana1'),
];

final mockUsers = [
  User(id: 'u1', name: 'Maria', companyId: '1'),
  User(id: 'u2', name: 'Carlos', companyId: '2'),
  User(id: 'u3', name: 'Fernanda', companyId: '3'),
  User(id: 'u4', name: 'Rafael', companyId: '4'),
];

final mockChildren = [
  Child(
    id: 'ch1',
    name: 'Lucas',
    companyId: '1',
    responsibleUsers: [mockUsers[0]],
    checkEvents: [],
  ),
  Child(
    id: 'ch2',
    name: 'Sofia',
    companyId: '2',
    responsibleUsers: [mockUsers[1]],
    checkEvents: [],
  ),
  Child(
    id: 'ch3',
    name: 'Gabriel',
    companyId: '3',
    responsibleUsers: [mockUsers[2]],
    checkEvents: [],
  ),
  Child(
    id: 'ch4',
    name: 'Beatriz',
    companyId: '4',
    responsibleUsers: [mockUsers[3]],
    checkEvents: [],
  ),
  Child(
    id: 'ch5',
    name: 'Marina',
    companyId: '1',
    responsibleUsers: [mockUsers[0]],
    checkEvents: [],
  ),
  Child(
    id: 'ch6',
    name: 'Enzo',
    companyId: '1',
    responsibleUsers: [mockUsers[0]],
    checkEvents: [],
  ),
];

final mockCheckEvents = [
  CheckEvent(
    id: 'e1',
    companyId: mockChildren[0].companyId,
    child: mockChildren[0],
    collaborator: mockCollaborators[0],
    timestamp: DateTime.now().subtract(const Duration(hours: 2)),
    checkType: CheckType.checkIn,
  ),
  CheckEvent(
    id: 'e2',
    companyId: mockChildren[0].companyId,
    child: mockChildren[0],
    collaborator: mockCollaborators[0],
    timestamp: DateTime.now().subtract(const Duration(hours: 1, minutes: 30)),
    checkType: CheckType.checkOut,
  ),
  CheckEvent(
    id: 'e6',
    companyId: '1',
    child: mockChildren[0],
    collaborator: mockCollaborators[0],
    timestamp: DateTime.now().subtract(const Duration(minutes: 40)),
    checkType: CheckType.checkIn,
  ),
  CheckEvent(
    id: 'e7',
    companyId: '1',
    child: mockChildren[0],
    collaborator: mockCollaborators[0],
    timestamp: DateTime.now().subtract(const Duration(minutes: 10)),
    checkType: CheckType.checkIn,
  ),
  CheckEvent(
    id: 'e8',
    companyId: '1',
    child: mockChildren[0],
    collaborator: mockCollaborators[0],
    timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
    checkType: CheckType.checkIn,
  ),
  CheckEvent(
    id: 'e3',
    companyId: mockChildren[1].companyId,
    child: mockChildren[1],
    collaborator: mockCollaborators[1],
    timestamp: DateTime.now().subtract(const Duration(hours: 1)),
    checkType: CheckType.checkIn,
  ),
  CheckEvent(
    id: 'e4',
    companyId: mockChildren[2].companyId,
    child: mockChildren[2],
    collaborator: mockCollaborators[2],
    timestamp: DateTime.now().subtract(const Duration(minutes: 45)),
    checkType: CheckType.checkIn,
  ),
  CheckEvent(
    id: 'e5',
    companyId: mockChildren[2].companyId,
    child: mockChildren[2],
    collaborator: mockCollaborators[2],
    timestamp: DateTime.now().subtract(const Duration(minutes: 10)),
    checkType: CheckType.checkOut,
  ),
  CheckEvent(
    id: 'e9',
    companyId: '1',
    child: mockChildren[0],
    collaborator: mockCollaborators[0],
    timestamp: DateTime.now().subtract(const Duration(minutes: 3)),
    checkType: CheckType.checkOut,
  ),
  CheckEvent(
    id: 'e10',
    companyId: '1',
    child: mockChildren[0],
    collaborator: mockCollaborators[0],
    timestamp: DateTime.now().subtract(const Duration(minutes: 2)),
    checkType: CheckType.checkIn,
  ),
  CheckEvent(
    id: 'e11',
    companyId: '1',
    child: mockChildren[0],
    collaborator: mockCollaborators[0],
    timestamp: DateTime.now().subtract(const Duration(minutes: 1)),
    checkType: CheckType.checkOut,
  ),
  CheckEvent(
    id: 'e12',
    companyId: '1',
    child: mockChildren[0],
    collaborator: mockCollaborators[0],
    timestamp: DateTime.now(),
    checkType: CheckType.checkIn,
  ),
  CheckEvent(
    id: 'e13',
    companyId: '1',
    child: mockChildren[0],
    collaborator: mockCollaborators[0],
    timestamp: DateTime.now().subtract(const Duration(minutes: 4)),
    checkType: CheckType.checkIn,
  ),
  CheckEvent(
    id: 'e14',
    companyId: '1',
    child: mockChildren[0],
    collaborator: mockCollaborators[0],
    timestamp: DateTime.now().subtract(const Duration(minutes: 6)),
    checkType: CheckType.checkIn,
  ),
  CheckEvent(
    id: 'e15',
    companyId: '1',
    child: Child(
      id: 'ch5',
      name: 'Marina',
      companyId: '1',
      responsibleUsers: [mockUsers[0]],
      checkEvents: [],
    ),
    collaborator: mockCollaborators[0],
    timestamp: DateTime.now().subtract(const Duration(minutes: 7)),
    checkType: CheckType.checkIn,
  ),
  CheckEvent(
    id: 'e16',
    companyId: '1',
    child: Child(
      id: 'ch6',
      name: 'Enzo',
      companyId: '1',
      responsibleUsers: [mockUsers[0]],
      checkEvents: [],
    ),
    collaborator: mockCollaborators[0],
    timestamp: DateTime.now().subtract(const Duration(minutes: 8)),
    checkType: CheckType.checkIn,
  ),
];

final mockCompanies = [
  Company(
    id: '1',
    name: 'Tech Kids',
    collaborators: [mockCollaborators[0]],
  ),
  Company(
    id: '2',
    name: 'EducaPlay',
    collaborators: [mockCollaborators[1]],
  ),
  Company(
    id: '3',
    name: 'Brincar & Aprender',
    collaborators: [mockCollaborators[2]],
  ),
  Company(
    id: '4',
    name: 'Mundo Infantil',
    collaborators: [mockCollaborators[3]],
  ),
];
