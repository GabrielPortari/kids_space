# Kids Space — Documentação Técnica

Esta documentação fornece visão técnica completa do projeto Kids Space (aplicativo Flutter para check-in/check-out de crianças). O objetivo é permitir que engenheiros entendam arquitetura, módulos, integrações, fluxos principais e como rodar/estender o sistema.

**Conteúdo**

- Visão geral
- Arquitetura
- Módulos e funcionalidades
- Integrações e dependências
- Guia de configuração
- Fluxos principais
- Decisões técnicas e observações

---

**Última atualização:** 2026-05-05

## 1. Visão geral

- Propósito do projeto: controlar presença (check-in / check-out) de crianças em espaços infantis, gerenciar responsáveis, colaboradores e relatórios administrativos.
- Stack tecnológica:
  - Flutter (Dart)
  - GetIt para injeção de dependências
  - ChangeNotifier (controllers) / MobX listada como dependência (ver nota)
  - HTTP via `http` (e `dio` disponível)
  - Firebase (auth e core) e Cloud Firestore
  - Local storage: `shared_preferences` e `flutter_secure_storage`
  - Internacionalização: `easy_localization`

- Requisitos para rodar localmente:
  - Flutter >= 3.8 (conforme `pubspec.yaml`)
  - Variáveis de ambiente em arquivo `.env` (ex.: `API_BASE_URL`, chaves Firebase)
  - Comandos básicos:

```bash
flutter pub get
# gerar codegen (se alterar stores):
flutter pub run build_runner build --delete-conflicting-outputs
flutter run
```

## 2. Arquitetura

- Estrutura de pastas (visão resumida):

```
lib/
  main.dart
  controller/         # controllers (estado, lógica de UI)
  model/              # modelos/dtos do domínio
  service/            # serviços HTTP / integrações
  util/               # utilitários (GetIt setup, etc)
  view/               # telas, widgets e design system
    screens/
    widgets/
  view/design_system/ # temas, estilos
assets/
  images/
  langs/              # traduções pt-BR / en-US
.env (opcional)
pubspec.yaml
```

- Descrição das camadas e responsabilidades:
  - `view/`: widgets e telas. Contém toda a UI (screens, componentes reutilizáveis, temas).
  - `controller/`: lógica de apresentação e gerenciamento de estado. Os controllers expõem métodos assíncronos usados pela UI.
  - `model/`: classes de domínio (ex.: `BaseModel`, `Attendance`, `Company`, `Child`, `Parent`, `Collaborator`).
  - `service/`: cliente HTTP (`ApiClient`) e serviços por entidade (ex.: `AuthService`, `AttendanceService`, `ChildService`, etc.).
  - `util/`: bootstrap da DI (`lib/util/getit_factory.dart`) e utilitários globais.

## 3. Módulos e funcionalidades

Nota: os nomes abaixo indicam arquivos principais; a navegação e telas estão definidas em `lib/main.dart`.

- Autenticação
  - Responsabilidade: login, logout, persistência de tokens, renovação de sessão.
  - Arquivos: `lib/controller/auth_controller.dart`, `lib/service/auth_service.dart`, rotas: `/login` (veja [lib/main.dart](lib/main.dart)).
  - Comportamento: tokens são salvos em `SharedPreferences`; existe lógica para extrair claims de JWT e derivar `role` e dados do colaborador.

- Gestão de Empresas (Company)
  - Responsabilidade: carregar dados da empresa atual, atualização parcial.
  - Arquivos: `lib/controller/company_controller.dart`, `lib/service/company_service.dart`, modelo `lib/model/company.dart`.

- Controle de Presenças (Attendance)
  - Responsabilidade: check-in, check-out, listagem de checkins ativos, histórico da empresa.
  - Arquivos: `lib/controller/attendance_controller.dart`, `lib/service/attendance_service.dart`, modelo `lib/model/attendance.dart`, widgets modais em `lib/view/widgets/attendance_modal.dart`.

- Gestão de Usuários (Parents/Children/Collaborators)
  - Responsabilidade: CRUD de responsáveis, crianças e colaboradores.
  - Arquivos: `lib/controller/parent_controller.dart`, `lib/controller/child_controller.dart`, `lib/controller/collaborator_controller.dart`, serviços correspondentes em `lib/service/`.

- Administração / Painel (Admin)
  - Responsabilidade: telas administrativas, relatórios, gerenciamento de entidades.
  - Arquivos: `lib/controller/admin_controller.dart`, `lib/controller/admin_management_controller.dart`, serviços `admin_service.dart` e `admin_management_service.dart`, telas em `lib/view/screens/` (prefixo `admin_`).

- Design System e Widgets reutilizáveis
  - Arquivos: `lib/view/design_system/app_theme.dart`, `lib/view/widgets/*` (ex.: `app_bottom_nav.dart`, `company_tile.dart`, `skeleton_list.dart`).

## 4. Integrações e dependências

- Dependências principais (extraídas de `pubspec.yaml`):
  - `get_it`: injeção de dependência e singletons via `lib/util/getit_factory.dart`.
  - `shared_preferences`: persistência simples (tokens, role).
  - `flutter_secure_storage`: armazenamento seguro (disponível para uso de dados sensíveis).
  - `http`: cliente HTTP primário usado em `lib/service/api_client.dart`.
  - `dio`: presente como dependency mas não é o cliente primário (pode ser usado em serviços adicionais).
  - `uuid`: geração de ids no cliente quando necessário.
  - `easy_localization`: internacionalização (`assets/langs/`).
  - `flutter_dotenv`: carrega arquivo `.env` para configurações locais.
  - `mobx`, `flutter_mobx`, `mobx_codegen`, `build_runner`: listados como dependências (ver observação sobre uso real).

- Integrações externas identificadas:
  - Backend REST API: base URL configurável via `API_BASE_URL` (carregado por `flutter_dotenv` e passado para `ApiClient` no startup em `main.dart`).

## 5. Guia de configuração

- Variáveis de ambiente necessárias (exemplos; não exponha valores reais):
  - `API_BASE_URL` — endpoint base do backend (ex.: `https://api.example.com` ou `http://10.0.2.2:3000` para emulador).
  - Outras chaves específicas do ambiente podem existir. [a verificar: localizar `.env.example` ou docs internas]

- Observações sobre segurança:
  - Não comitar `.env` com chaves reais.
  - Tokens são armazenados em `SharedPreferences` por `AuthController` (considerar `flutter_secure_storage` para produção).

- Passos para rodar localmente:

```bash
# instalar dependências
flutter pub get

# (opcional) gerar artefatos de codegen (MobX)
flutter pub run build_runner build --delete-conflicting-outputs

# rodar app em emulador/dispositivo
flutter run
```

Configuração do `ApiClient` (inicialização em `main.dart`) usa `API_BASE_URL` e provedor de token:

- Para testes locais com backend em máquina host, use `http://10.0.2.2:3000` no emulador Android (conforme fallback em `main.dart`).

## 6. Fluxos principais

1. Login e sessão
   - Tela: `/login` (veja `lib/view/screens/login_screen.dart`).
   - Controle: `AuthController.login()` chama `AuthService.login` e salva `idToken` + `refreshToken` em `SharedPreferences`.
   - Após login: token é parseado para extrair claims (role, collaborator/company) e `AuthController.checkLoggedUser()` inicializa `CompanyController` ou `CollaboratorController` conforme role.
   - Expiração: `AuthController.ensureSessionValid()` tenta refresh via `AuthService` e, se falhar, limpa tokens e força navegação para `/login`.

2. Check-in / Check-out
   - Tela/Widget de interação: `lib/view/widgets/attendance_modal.dart` e telas de lista de crianças.
   - Controle: `AttendanceController.checkin()` e `checkout()` chamam `AttendanceService` e atualizam listas locais (`activeCheckins`, `companyEvents`).
   - API: endpoints `POST /v2/attendance/checkin` e `POST /v2/attendance/checkout` (conforme contrato de backend).

3. Carregamento do contexto da empresa
   - Ao inicializar (`main.dart`), `AuthController.checkLoggedUser()` e `CompanyController.loadMyCompany()` tentam popular dados da empresa do usuário logado.
   - `CompanyController` fornece `company` para telas que dependem do contexto.

4. Painel administrativo
   - Rotas administrativas (`/admin_screen`, `/admin_management_*`) agrupam operações de CRUD e relatórios através de `AdminController` e `AdminManagementController`.

5. Internacionalização e recursos
   - `EasyLocalization` inicializado em `main.dart` com `assets/langs` e fallback `pt-BR`.

## 7. Decisões técnicas e observações

- Injeção de dependência: `GetIt` usado globalmente para registrar serviços e controllers em `lib/util/getit_factory.dart`.

- Cliente HTTP: projeto centraliza chamadas no `ApiClient` (`lib/service/api_client.dart`), que aplica headers, tratamento de 401 (tenta refresh) e redirecionamento para `/login` quando sessão inválida.

- Armazenamento de sessão: atual implementação usa `SharedPreferences` para `idToken` e `refreshToken`. Em produção recomenda-se `flutter_secure_storage` para tokens sensíveis.

- Padrão de controllers: atualmente os controllers estendem `ChangeNotifier` (ex.: `AuthController`, `CompanyController`, `AttendanceController`). Apesar de `mobx` constar em `pubspec.yaml`, o código das controllers presentes usa `ChangeNotifier` com chamadas `notifyListeners()`.
  - [a verificar] se existe código gerado `*.g.dart` ou stores MobX a serem usados — caso contrário, considerar remover `mobx` do `pubspec` para evitar confusão.

- Tratamento de datas: `BaseModel.tryParseTimestamp()` tem utilitários para interoperabilidade com timestamps de Firestore/Unix/string.

- Boas práticas e recomendações:
  - Mover armazenamento de tokens para `flutter_secure_storage` em ambientes de produção.
  - Normalizar o uso de gerenciamento de estado (escolher entre `ChangeNotifier` ou MobX) e padronizar codegen se MobX for adotado.
  - Centralizar validações e tratamento de erros no `ApiClient` (já parcialmente implementado).

## 8. Localização de arquivos importantes

- Ponto de entrada: [lib/main.dart](lib/main.dart)
- DI: [lib/util/getit_factory.dart](lib/util/getit_factory.dart)
- Cliente HTTP: [lib/service/api_client.dart](lib/service/api_client.dart)
- Auth controller: [lib/controller/auth_controller.dart](lib/controller/auth_controller.dart)
- Controllers principais: [lib/controller](lib/controller/)
- Models: [lib/model](lib/model/)
- Views/telas: [lib/view/screens](lib/view/screens/)

## 9. O que verificar / próximos passos

- [a verificar] Confirmação do uso real do MobX vs ChangeNotifier (procure por `*.g.dart` e `@observable/@action`).
- [a verificar] Documentação das rotas e permissões por role (quais telas requerem `collaborator` vs `company` vs `admin`).
- [a verificar] Arquivo `.env.example` ou instruções secretas para CI/CD.
