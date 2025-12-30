import 'package:kids_space/model/base_user.dart';
import '../company.dart';
import '../user.dart';
import '../collaborator.dart';
import '../child.dart';
import '../check_event.dart';

final mockCollaborators = [
  Collaborator(id: 'c0', name: 'Admin', companyId: '1', email: 'admin@techkids.com', password: '123456', userType: UserType.admin),
  Collaborator(id: 'c1', name: 'João', companyId: '1', email: 'joao@techkids.com', password: '123456', userType: UserType.collaborator),
  Collaborator(id: 'c2', name: 'Ana', companyId: '2', email: 'ana@educaplay.com', password: '654321', userType: UserType.collaborator),
  Collaborator(id: 'c3', name: 'Pedro', companyId: '3', email: 'pedro@brincaraprender.com', password: 'abc123', userType: UserType.collaborator),
  Collaborator(id: 'c4', name: 'Juliana', companyId: '4', email: 'juliana@mundoinfantil.com', password: 'juliana1', userType: UserType.collaborator),
];

final List<User> mockUsers = [
  User(
    id: 'u1',
    name: 'Maria',
    companyId: '1',
    email: 'maria@techkids.com',
    phone: '123456789',
    document: '12345678901',
    childrenIds: ['ch1', 'ch5', 'ch6'], // Lucas, Marina, Enzo
    createdAt: DateTime.now().subtract(Duration(days: 30)),
    updatedAt: DateTime.now(),
  ),
  User(
    id: 'u2',
    name: 'Carlos',
    companyId: '1',
    email: 'carlos@techkids.com',
    phone: '987654321',
    document: '10987654321',
    childrenIds: ['ch2'], // Sofia
    createdAt: DateTime.now().subtract(Duration(days: 30)),
    updatedAt: DateTime.now(),
  ),
  User(
    id: 'u3',
    name: 'Fernanda',
    companyId: '1',
    email: 'fernanda@techkids.com',
    phone: '456789123',
    document: '45678912345',
    childrenIds: ['ch3'], // Gabriel
    createdAt: DateTime.now().subtract(Duration(days: 30)),
    updatedAt: DateTime.now(),
  ),
  User(
    id: 'u4',
    name: 'Rafael',
    companyId: '1',
    email: 'rafael@techkids.com',
    phone: '321654987',
    document: '32165498765',
    childrenIds: ['ch4'], // Beatriz
    createdAt: DateTime.now().subtract(Duration(days: 30)),
    updatedAt: DateTime.now(),
  ),
];

final List<Child> mockChildren = [
  // Lucas: Último evento é checkOut (e2, 1h atrás) => isActive: false
  Child(
    id: 'ch1',
    name: 'Lucas',
    companyId: '1',
    responsibleUserIds: ['u1'],
    isActive: false,
    document: '11122233344',
    createdAt: DateTime.now().subtract(Duration(days: 60)),
    updatedAt: DateTime.now().subtract(Duration(days: 1)),
  ),
  // Sofia: Último evento é checkOut (e6, 30min atrás) => isActive: false
  Child(
    id: 'ch2',
    name: 'Sofia',
    companyId: '1',
    responsibleUserIds: ['u2'],
    isActive: false,
    document: '22233344455',
    createdAt: DateTime.now().subtract(Duration(days: 60)),
    updatedAt: DateTime.now().subtract(Duration(days: 1)),
  ),
  // Gabriel: Último evento é checkIn (e4, 3h atrás) => isActive: true
  Child(
    id: 'ch3',
    name: 'Gabriel',
    companyId: '1',
    responsibleUserIds: ['u3'],
    isActive: true,
    document: '33344455566',
    createdAt: DateTime.now().subtract(Duration(days: 60)),
    updatedAt: DateTime.now().subtract(Duration(hours: 3)),
  ),
  // Beatriz: Último evento é checkIn (e5, 2h atrás) => isActive: true
  Child(
    id: 'ch4',
    name: 'Beatriz',
    companyId: '1',
    responsibleUserIds: ['u4'],
    isActive: true,
    document: '44455566677',
    createdAt: DateTime.now().subtract(Duration(days: 60)),
    updatedAt: DateTime.now().subtract(Duration(hours: 2)),
  ),
  // Marina: sem eventos => isActive: false
  Child(
    id: 'ch5',
    name: 'Marina',
    companyId: '1',
    responsibleUserIds: ['u1'],
    isActive: false,
    document: '55566677788',
    createdAt: DateTime.now().subtract(Duration(days: 60)),
    updatedAt: DateTime.now().subtract(Duration(days: 1)),
  ),
  // Enzo: sem eventos => isActive: false
  Child(
    id: 'ch6',
    name: 'Enzo',
    companyId: '1',
    responsibleUserIds: ['u1'],
    isActive: false,
    document: '66677788899',
    createdAt: DateTime.now().subtract(Duration(days: 60)),
    updatedAt: DateTime.now().subtract(Duration(days: 1)),
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
    fantasyName: 'Tech Kids',
    collaborators: [mockCollaborators[0]],
    createdAt: DateTime.now().subtract(Duration(days: 365)),
    updatedAt: DateTime.now(),
  ),
  Company(
    id: '2',
    fantasyName: 'EducaPlay',
    collaborators: [mockCollaborators[1]],
    createdAt: DateTime.now().subtract(Duration(days: 365)),
    updatedAt: DateTime.now(),
  ),
  Company(
    id: '3',
    fantasyName: 'Brincar & Aprender',
    collaborators: [mockCollaborators[2]],
    createdAt: DateTime.now().subtract(Duration(days: 365)),
    updatedAt: DateTime.now(),
  ),
  Company(
    id: '4',
    fantasyName: 'Mundo Infantil',
    collaborators: [mockCollaborators[3]],
    createdAt: DateTime.now().subtract(Duration(days: 365)),
    updatedAt: DateTime.now(),
    
  ),
];
