import '../company.dart';
import '../user.dart';
import '../collaborator.dart';
import '../child.dart';

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
