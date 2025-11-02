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
  User(id: 'u1', name: 'Maria', companyId: '1', email: 'maria@techkids.com', phone: '123456789', document: '12345678901'),
  User(id: 'u2', name: 'Carlos', companyId: '1', email: 'carlos@techkids.com', phone: '987654321', document: '10987654321'),
  User(id: 'u3', name: 'Fernanda', companyId: '1', email: 'fernanda@techkids.com', phone: '456789123', document: '45678912345'),
  User(id: 'u4', name: 'Rafael', companyId: '1', email: 'rafael@techkids.com', phone: '321654987', document: '32165498765'),
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
    companyId: '1',
    responsibleUsers: [mockUsers[1]],
    checkEvents: [],
  ),
  Child(
    id: 'ch3',
    name: 'Gabriel',
    companyId: '1',
    responsibleUsers: [mockUsers[2]],
    checkEvents: [],
  ),
  Child(
    id: 'ch4',
    name: 'Beatriz',
    companyId: '1',
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
    companyId: '1',
    child: mockChildren[0],
    collaborator: mockCollaborators[0],
    timestamp: DateTime.now().subtract(Duration(hours: 5)),
    checkType: CheckType.checkIn,
  ),
  CheckEvent(
    id: 'e2',
    companyId: '1',
    child: mockChildren[0],
    collaborator: mockCollaborators[0],
    timestamp: DateTime.now().subtract(Duration(hours: 1)),
    checkType: CheckType.checkOut,
  ),
  CheckEvent(
    id: 'e3',
    companyId: '1',
    child: mockChildren[1],
    collaborator: mockCollaborators[0],
    timestamp: DateTime.now().subtract(Duration(hours: 4)),
    checkType: CheckType.checkIn,
  ),
  CheckEvent(
    id: 'e4',
    companyId: '1',
    child: mockChildren[2],
    collaborator: mockCollaborators[0],
    timestamp: DateTime.now().subtract(Duration(hours: 3)),
    checkType: CheckType.checkIn,
  ),
  CheckEvent(
    id: 'e5',
    companyId: '1',
    child: mockChildren[3],
    collaborator: mockCollaborators[0],
    timestamp: DateTime.now().subtract(Duration(hours: 2)),
    checkType: CheckType.checkIn,
  ),
  CheckEvent(
    id: 'e6',
    companyId: '1',
    child: mockChildren[1],
    collaborator: mockCollaborators[0],
    timestamp: DateTime.now().subtract(Duration(minutes: 30)),
    checkType: CheckType.checkOut,
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
