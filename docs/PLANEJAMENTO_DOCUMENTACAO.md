# Planejamento de Documentação - Kids Space Microserviço
## Sistema de Check-in/Check-out para Espaço Kids

**Objetivo Geral**: Aplicar técnicas de levantamento de requisitos, análise orientada a objetos, design orientado a objetos e modelagem UML, produzindo artefatos completos de um microserviço.

---

## 1. ENTREGÁVEL 1: Levantamento e Especificação de Requisitos (30 pontos)

### 1.1 Requisitos Funcionais (RF)

#### RF-01: Autenticação de Colaboradores
- **Descrição**: Sistema deve permitir login de colaboradores (professores/coordenadores) com email e senha
- **Atores**: Colaborador
- **Pré-condições**: Colaborador cadastrado no sistema, credenciais válidas
- **Fluxo Principal**:
  1. Colaborador acessa tela de login
  2. Insere email e senha
  3. Sistema valida credenciais contra base de dados
  4. Se válido, armazena sessão localmente (SharedPreferences)
  5. Redireciona para tela home
- **Fluxo Alternativo**: Se credenciais inválidas, exibe mensagem de erro
- **Pós-condições**: Colaborador autenticado, sessão ativa

#### RF-02: Seleção de Empresa
- **Descrição**: Colaborador deve selecionar a empresa (espaço kids) onde irá trabalhar
- **Atores**: Colaborador autenticado
- **Pré-condições**: Colaborador logado, empresas cadastradas no sistema
- **Fluxo Principal**:
  1. Sistema carrega lista de empresas disponíveis
  2. Colaborador busca e seleciona uma empresa
  3. Sistema armazena empresa selecionada no contexto
  4. Redireciona para tela home com contexto da empresa
- **Pós-condições**: Empresa selecionada no contexto, dados carregados para empresa

#### RF-03: Gerenciar Crianças (CRUD)
- **Descrição**: Colaboradores podem visualizar, criar, atualizar e deletar crianças cadastradas
- **Atores**: Colaborador, Sistema
- **Pré-condições**: Empresa selecionada, colaborador com permissão
- **Fluxo Principal (Criar)**:
  1. Colaborador aciona botão "Adicionar Criança"
  2. Abre formulário com campos: nome, documento, responsáveis
  3. Insere dados e confirma
  4. Sistema valida dados (nome não vazio, documento válido)
  5. Persiste criança no banco de dados
  6. Atualiza lista na UI
- **Fluxo Alternativo (Visualizar)**:
  1. Tela inicial exibe lista de crianças ativas
  2. Colaborador pode filtrar por nome ou responsável
  3. Clica em criança para ver detalhes
- **Pós-condições**: Criança persistida ou deletada, UI sincronizada

#### RF-04: Realizar Check-in/Check-out
- **Descrição**: Colaborador registra entrada ou saída de criança do espaço
- **Atores**: Colaborador
- **Pré-condições**: Criança presente na lista, empresa selecionada
- **Fluxo Principal**:
  1. Colaborador seleciona criança na lista de presentes
  2. Clica botão "Check-in" ou "Check-out"
  3. Sistema registra evento com: id, childId, collaboratorId, timestamp, tipo (in/out)
  4. Atualiza status `isActive` da criança
  5. Persiste evento em base de dados
  6. Exibe confirmação e atualiza UI
- **Validações**:
  - Não permitir check-in duplo (criança já ativa)
  - Não permitir check-out de criança inativa
  - Registrar quem fez o check (collaboratorId)
- **Pós-condições**: Evento de check registrado, status da criança atualizado

#### RF-05: Visualizar Log de Eventos
- **Descrição**: Sistema mantém histórico de check-in/out para auditoria
- **Atores**: Colaborador
- **Pré-condições**: Eventos registrados para criança ou empresa
- **Fluxo Principal**:
  1. Colaborador acessa tela "Log de Presença"
  2. Sistema exibe últimos 30 eventos (ou data selecionada)
  3. Mostra: criança, responsável, horário, tipo (in/out), colaborador responsável
  4. Permite filtrar por data, criança ou tipo de evento
- **Pós-condições**: Log exibido com filtros aplicados

#### RF-06: Gerenciar Responsáveis
- **Descrição**: Administrador/Coordenador cadastra pais/responsáveis e seus dados
- **Atores**: Coordenador, Colaborador
- **Pré-condições**: Empresa selecionada
- **Fluxo Principal**:
  1. Abre tela de usuários (pais/responsáveis)
  2. Visualiza lista com nome, email, telefone, documento
  3. Pode adicionar novo responsável
  4. Relaciona responsável a crianças sob sua guarda
  5. Sistema persiste relacionamento (User → Children)
- **Pós-condições**: Responsável cadastrado e vinculado a crianças

#### RF-07: Sincronização de Dados
- **Descrição**: Aplicação sincroniza dados locais com backend periodicamente
- **Atores**: Sistema
- **Pré-condições**: Conectividade internet disponível
- **Fluxo Principal**:
  1. Ao abrir app, verifica dados não sincronizados
  2. Envia eventos pendentes (check-in/out offline)
  3. Baixa atualizações de crianças, responsáveis e eventos
  4. Atualiza base local (SharedPreferences ou SQLite)
  5. Resync a cada 5 minutos (background job)
- **Pós-condições**: Dados sincronizados com backend

---

### 1.2 Requisitos Não-Funcionais (RNF)

| ID | Requisito | Descrição |
|---|---|---|
| RNF-01 | Performance | Listar crianças deve responder em < 2s, mesmo com 10k+ registros |
| RNF-02 | Usabilidade | Interface intuitiva, botões grandes, sem necessidade de manual |
| RNF-03 | Disponibilidade | App funciona offline; sincroniza ao reconectar |
| RNF-04 | Segurança | Senhas com hash (bcrypt/SHA256), HTTPS, sem armazenar password em memória |
| RNF-05 | Escalabilidade | Suporte para múltiplas empresas, 1000+ crianças por empresa, 100+ colaboradores |
| RNF-06 | Manutenibilidade | Código estruturado em camadas (MVC/Layered), SOLID, testes unitários |
| RNF-07 | Compatibilidade | iOS 12+, Android 8+, dispositivos com 2GB RAM mínimo |
| RNF-08 | Internacionalização | Suporte pt-BR e en-US, timestamps em fuso local |
| RNF-09 | Auditoria | Rastrear quem fez check-in/out, timestamps UTC e local |
| RNF-10 | Integridade | Eventos imutáveis, não permitir edição/deleção de check já realizado |

---

### 1.3 Regras de Negócio (RN)

| ID | Regra | Descrição |
|---|---|---|
| RN-01 | Estado Criança | Uma criança só pode estar em estado "ativo" (presente) se o último evento for check-in |
| RN-02 | Responsável Único | Cada criança deve ter pelo menos um responsável vinculado |
| RN-03 | Duplicação Check-in | Não permitir check-in de criança que já está ativa (sem check-out) |
| RN-04 | Duplicação Check-out | Não permitir check-out de criança inativa |
| RN-05 | Permissões | Colaborador só vê crianças da sua empresa; coordenadores veem todas |
| RN-06 | Timestamp Imutável | Timestamp de evento não pode ser editado após criação |
| RN-07 | Histórico Completo | Todo evento deve ser persistido, nunca deletado (soft-delete se necessário) |
| RN-08 | Horário Operacional | Check-in/out permitido apenas dentro de horários de funcionamento (07:00-18:00) |
| RN-09 | Sincronização | Se offline, eventos devem ser fila-dos e enviados ao reconectar |
| RN-10 | Aviso Saída | Sistema notifica pais/responsáveis quando criança faz check-out |

---

### 1.4 Casos de Uso Principais

#### Caso de Uso 1: UC-01 - Realizar Check-in/Check-out
```
Ator Primário: Colaborador
Ator Secundário: Sistema, Base de Dados, Sistema de Notificação

Pré-condição: 
  - Colaborador autenticado
  - Empresa selecionada
  - Criança existe no sistema e pertence à empresa

Fluxo Principal:
  1. Colaborador acessa tela "Home" ou "Crianças Ativas"
  2. Sistema exibe lista de crianças (ativas em verde, inativas em branco)
  3. Colaborador seleciona criança e clica "Check-in" ou "Check-out"
  4. Sistema valida:
     - Se check-in: criança não está ativa (RN-03)
     - Se check-out: criança está ativa (RN-04)
     - Horário dentro de operacional (RN-08)
  5. Sistema cria evento CheckEvent com:
     - id: UUID
     - childId, collaboratorId, companyId
     - timestamp: now (UTC)
     - checkType: IN/OUT
  6. Sistema persiste evento
  7. Sistema atualiza Child.isActive = true (check-in) ou false (check-out)
  8. UI atualiza com confirmação visual
  9. Se online, envia evento para backend
  10. Se responsável configurado, dispara notificação (RN-10)

Fluxo Alternativo A - Validação falha:
  6a. Sistema exibe erro (e.g., "Criança já ativa")
  6b. Não cria evento, retorna à tela anterior

Fluxo Alternativo B - Offline:
  9b. Evento é fila-do localmente (dirty flag)
  9c. UI exibe badge "sincronizando"
  9d. Ao reconectar, tenta enviar e marca como sincronizado

Pós-condição:
  - Evento criado e persistido
  - Status da criança atualizado
  - Responsáveis notificados (se aplicável)
  - Backend sincronizado (se online)

Exceções:
  - Colaborador sem permissão: exibe "Sem acesso"
  - Rede indisponível (offline): usa modo local
  - BD indisponível: exibe "Erro ao salvar"
```

#### Caso de Uso 2: UC-02 - Gerenciar Crianças (CRUD)
```
Ator Primário: Coordenador / Colaborador Admin

Fluxo - Criar Criança:
  1. Abre tela "Adicionar Criança"
  2. Preenche: nome, documento (CPF), responsáveis
  3. Seleciona responsáveis da lista existente
  4. Clica "Salvar"
  5. Sistema valida (RN-02: pelo menos 1 responsável)
  6. Cria Child com isActive=false, createdAt/updatedAt
  7. Persiste e retorna à lista

Fluxo - Visualizar Crianças:
  1. Tela "Crianças" exibe todas as crianças da empresa
  2. Ordenadas por nome
  3. Indicador visual se ativa (✓) ou inativa
  4. Filtro por nome/documento

Fluxo - Atualizar Criança:
  1. Seleciona criança da lista
  2. Abre formulário de edição
  3. Atualiza campos permitidos (nome, responsáveis)
  4. Clica "Atualizar"
  5. Sistema valida
  6. Persiste e notifica mudança

Fluxo - Deletar Criança:
  1. Seleciona criança
  2. Clica "Deletar"
  3. Sistema pede confirmação
  4. Se confirmar, soft-delete (marca como deletada, não remove)
  5. Remove da lista visual
```

#### Caso de Uso 3: UC-03 - Autenticar Colaborador
```
Ator Primário: Colaborador
Ator Secundário: AuthService, SharedPreferences

Fluxo Principal:
  1. Abre app, redirecionado a SplashScreen
  2. Sistema verifica se existe session salva localmente
  3. Se sim, restaura session e vai para HomeScreen
  4. Se não, mostra LoginScreen
  5. Colaborador insere email e senha
  6. Clica "Entrar"
  7. AuthService valida contra AuthMock (simula backend)
  8. Se válido, carrega Collaborator completo
  9. CollaboratorController armazena em SharedPreferences
  10. UI redireciona para CompanySelectionScreen
  11. Colaborador seleciona empresa
  12. HomeScreen carregada com contexto da empresa

Fluxo Alternativo - Credenciais inválidas:
  8a. Exibe "Usuário ou senha inválidos"
  8b. Limpa campos, permite nova tentativa

Fluxo Alternativo - Logout:
  1. Colaborador clica menu "Sair"
  2. Sistema limpa session de SharedPreferences
  3. Redireciona para LoginScreen
```

---

## 2. ENTREGÁVEL 2: Modelagem UML OO (40 pontos)

### 2.1 Diagrama de Casos de Uso

```
┌─────────────────────────────────────────────────────────────────┐
│                           KIDS SPACE                             │
│              Microserviço Check-in/Check-out                    │
└─────────────────────────────────────────────────────────────────┘

┌──────────────────┐
│  Colaborador     │
│  (Professor)     │
└────────┬─────────┘
         │
    ┌────┴─────────────────────────────────────────────┐
    │                                                  │
    ├─ (login)  ◇ Autenticar Colaborador
    │           ├─ Inserir credenciais
    │           ├─ Validar contra backend
    │           └─ Armazenar sessão
    │
    ├─ (usar)   ◇ Selecionar Empresa
    │           ├─ Listar empresas disponíveis
    │           ├─ Filtrar por nome
    │           └─ Estabelecer contexto
    │
    ├─ (usa)    ◇ Realizar Check-in/Check-out
    │           ├─ Selecionar criança
    │           ├─ Registrar evento
    │           └─ Atualizar status criança
    │
    ├─ (usa)    ◇ Visualizar Log de Eventos
    │           ├─ Filtrar por data/criança
    │           └─ Exibir histórico
    │
    └─ (usa)    ◇ Gerenciar Crianças (CRUD)
    ┌─ (usa)    ├─ Criar criança
    │           ├─ Editar criança
    │           ├─ Deletar criança
    │           └─ Visualizar lista
    │
    └─ (usa)    ◇ Gerenciar Responsáveis
                ├─ Criar responsável
                ├─ Listar responsáveis
                └─ Vincular a crianças

┌──────────────────┐
│  Coordenador     │
│  (Admin)         │
└────────┬─────────┘
         │ (extends)
         │ (inclui todos os UC de Colaborador +)
         │
         ├─ ◇ Gerenciar Colaboradores
         │  ├─ Criar colaborador
         │  ├─ Atualizar permissões
         │  └─ Deletar colaborador
         │
         └─ ◇ Gerar Relatórios
            ├─ Presença por período
            ├─ Ausências/Faltas
            └─ Exportar dados

┌──────────────────┐
│  Sistema         │
│  (Ator Secundário)
└────────┬─────────┘
         │
         ├─ ◆ Sincronizar Dados
         │  ├─ Enviar eventos pendentes
         │  ├─ Baixar atualizações
         │  └─ Resolver conflitos
         │
         ├─ ◆ Notificar Responsáveis
         │  ├─ Check-out registrado
         │  └─ Alertas de presença
         │
         └─ ◆ Auditar Eventos
            ├─ Registrar mudanças
            └─ Rastrear quem fez o quê

```

### 2.2 Diagrama de Classes (Modelo de Dados)

```
┌────────────────────────────────────────────────────────────────────────┐
│                      DIAGRAMA DE CLASSES                              │
└────────────────────────────────────────────────────────────────────────┘

┌─ BaseModel ◄──────────────┐
│ ─────────────────────────  │
│ - createdAt: DateTime      │ (Parent)
│ - updatedAt: DateTime      │
│ ────────────────────────── │
│ + toJson(): Map            │
│ + toJsonTimestamps(): Map  │
│ + tryParseTimestamp(): ?   │
└────────────────────────────┘
   ▲          ▲          ▲
   │          │          │
   │(extends) │(extends) │(extends)
   │          │          │
   │          │          │
┌──┴─────────┴┐       ┌─┴──────────────┐
│   Company   │       │    User        │       ┌────────────────┐
│ ─────────── │       │ ────────────── │       │   CheckType    │
│ - id        │       │ - id           │       │ ────────────── │
│ - name      │       │ - name         │       │ + CHECK_IN     │
│ - logoUrl   │       │ - email        │       │ + CHECK_OUT    │
│             │       │ - phone        │       └────────────────┘
│ relations:  │       │ - document     │            △
│ * collab.   │       │ - companyId    │            │(uses)
│ * users     │       │ - childrenIds  │            │
│ * children  │       │                │            │
│             │       │ relations:     │            │
└─────────────┘       │ * Company      │            │
      ▲               │ * Children     │            │
      │               │ (many-to-many)│            │
      │               └────────────────┘            │
      │ (has)              ▲                       │
      │                    │(has)                  │
      └────────────────┬───┘                       │
                       │                           │
                       │                           │
           ┌───────────┴──────────┬────────────────┴──────┐
           │                      │                       │
    ┌──────▼──────────┐    ┌──────▼──────────┐   ┌────────▼──────────┐
    │     Child       │    │  Collaborator   │   │   CheckEvent      │
    │ ──────────────  │    │ ──────────────  │   │ ─────────────────  │
    │ - id            │    │ - id            │   │ - id               │
    │ - name          │    │ - name          │   │ - companyId        │
    │ - companyId     │    │ - companyId     │   │ - childId          │
    │ - document      │    │ - email         │   │ - collaboratorId   │
    │ - isActive      │    │ - phoneNumber   │   │ - timestamp        │
    │ - responsibles  │    │ - password      │   │ - checkType        │
    │   (refs)        │    │ - role          │   │ - lastCheckInTime  │
    │                 │    │                 │   │ - duration         │
    │ relations:      │    │ relations:      │   │                    │
    │ * User (many)   │    │ * Company       │   │ relations:         │
    │ * CheckEvents   │    │ * CheckEvents   │   │ * Child            │
    │                 │    │                 │   │ * Collaborator     │
    └─────────────────┘    └─────────────────┘   │ * Company          │
                                                  └────────────────────┘

    Key Relationships:
    ─────────────────
    Company 1──* User  : Uma empresa tem múltiplos responsáveis/pais
    Company 1──* Child : Uma empresa tem múltiplas crianças
    Company 1──* Collaborator : Uma empresa tem múltiplos colaboradores
    
    User *──* Child : Um responsável cuida de múltiplas crianças
                      Uma criança pode ter múltiplos responsáveis
    
    Child 1──* CheckEvent : Uma criança tem múltiplos eventos de check
    Collaborator 1──* CheckEvent : Um colaborador registra múltiplos checks
    
    CheckEvent *──1 Company : Cada evento pertence a uma empresa

```

### 2.3 Diagrama de Sequência - Realizar Check-in

```
┌──────────┐  ┌──────────────┐  ┌──────────────┐  ┌─────────────┐  ┌─────────────┐
│Colabor.  │  │HomeScreen/UI │  │ChildController
│          │  │              │  │              │  │ CheckService │  │  Database   │
└────┬─────┘  └──────┬───────┘  └──────┬───────┘  └──────┬──────┘  └──────┬──────┘
     │               │                 │                 │               │
     │ 1. Seleciona criança            │                 │               │
     │─────────────────────────────────>                 │               │
     │               │                 │                 │               │
     │               │ 2. onCheckIn(childId)             │               │
     │               │────────────────────────────────────>              │
     │               │                 │                 │               │
     │               │                 │ 3. valida isActive             │
     │               │                 │ ─ se true: erro               │
     │               │                 │ ─ se false: continua          │
     │               │                 │                 │               │
     │               │                 │ 4. cria CheckEvent            │
     │               │                 │    {id, childId, collab,      │
     │               │                 │     timestamp, IN}            │
     │               │                 │                 │               │
     │               │                 │ 5. saveCheckEvent(event)      │
     │               │                 │─────────────────────────────────>
     │               │                 │                 │ 6. INSERT    │
     │               │                 │                 │──────────────>
     │               │                 │                 │ 7. id, success
     │               │                 │                 │<──────────────
     │               │                 │                 │               │
     │               │                 │ 8. updateChildStatus(childId, true)
     │               │                 │                 │               │
     │               │                 │ 9. updateChild(child.copyWith(isActive=true))
     │               │                 │─────────────────────────────────>
     │               │                 │                 │ 10. UPDATE  │
     │               │                 │                 │──────────────>
     │               │                 │                 │ 11. updated
     │               │                 │                 │<──────────────
     │               │                 │                 │               │
     │               │<─ 12. onSuccess(event) ────────────                │
     │               │                 │                 │               │
     │               │ 13. atualiza UI (criança em verde, ativa)         │
     │               │                 │                 │               │
     │               │ 14. exibe confirmação               │               │
     │               │                 │                 │               │
     │ 15. vê mudança visual ◄─────────                 │               │
     │               │                 │                 │               │

```

### 2.4 Diagrama de Sequência - Autenticação

```
┌──────────┐  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐  ┌─────────────┐
│Colabor.  │  │LoginScreen   │  │AuthController│  │AuthService   │  │SharedPrefs  │
└────┬─────┘  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘  └──────┬──────┘
     │               │                 │                │                │
     │ 1. Insere email/senha            │                │                │
     │─────────────────────────────────>                 │                │
     │               │                 │                │                │
     │               │ 2. onLogin(email, password)       │                │
     │               │────────────────────────────────────>               │
     │               │                 │                │                │
     │               │                 │ 3. login(email, pwd)            │
     │               │                 │───────────────────────────────>  │
     │               │                 │                │                │
     │               │                 │                │ 4. busca em mockData
     │               │                 │                │ 5. valida hash/pwd
     │               │                 │                │ (simula backend)
     │               │                 │                │                │
     │               │                 │                │ 6. if valid, retorna Collaborator
     │               │                 │<──────────────────────────────  │
     │               │                 │                │                │
     │               │                 │ 7. se sucesso, obter CollaboratorData
     │               │                 │───────────────────────────────>  │
     │               │                 │                │                │
     │               │                 │ 8. salvar em SharedPreferences   │
     │               │                 │                │ 9. save(key, collab)
     │               │                 │                │──────────────> │
     │               │                 │                │ 10. OK
     │               │                 │                │<──────────────
     │               │                 │                │                │
     │               │<─ 11. onSuccess(collaborator) ─────                │
     │               │                 │                │                │
     │               │ 12. redireciona para CompanySelectionScreen
     │               │                 │                │                │
     │ 13. vê tela de seleção de empresa               │                │

```

---

## 3. ENTREGÁVEL 3: Análise e Design Orientado a Objetos (30 pontos)

### 3.1 Identificação de Classes, Objetos e Responsabilidades

#### Domínio - Entidades Principais

| Classe | Responsabilidades | Coesão | Exemplo |
|--------|------------------|--------|---------|
| **Company** | Representar espaço kids; agrupar colaboradores, crianças, usuários | Alta | Company(id, name, logoUrl, createdAt, updatedAt) |
| **Child** | Representar criança; gerenciar status (ativa/inativa); relacionamento com responsáveis | Alta | Child(id, name, companyId, isActive, responsibleUserIds) |
| **User** | Representar pai/responsável; gerenciar dados de contato; indicar crianças sob sua guarda | Alta | User(id, name, email, phone, document, childrenIds) |
| **Collaborator** | Representar professor/coordenador; guardar credenciais; gerenciar permissões | Alta | Collaborator(id, name, email, password, companyId, role) |
| **CheckEvent** | Registrar evento de check-in/out; imutável após criação; auditoria | Alta | CheckEvent(id, childId, collaboratorId, timestamp, checkType) |

#### Serviços (Application/Business Logic Layer)

| Classe | Responsabilidades | Métodos Chave |
|--------|------------------|---------------|
| **AuthService** | Validar credenciais; autenticar colaborador contra mock/backend | login(email, pwd) -> bool |
| **UserService** | CRUD de usuários (pais); listar por empresa; buscar por id | getUserById, getUsersByCompanyId, createUser, updateUser, deleteUser |
| **ChildService** | CRUD de crianças; listar ativas/inativas; atualizar status | getChildById, listByCompany, createChild, updateStatus, softDelete |
| **CheckEventService** | Registrar check-in/out; validar regras; recuperar histórico | recordCheckEvent, validateCheck, getLogByChildId, getLastCheck |
| **CollaboratorService** | CRUD de colaboradores; gerenciar permissions | getCollaboratorById, listByCompany, createCollab, updateRole |
| **SyncService** | Sincronizar dados offline->online; resolver conflitos | syncPendingEvents, downloadUpdates, resolveConflicts |

#### Controllers (State Management MobX)

| Classe | Responsabilidades | Observables | Computed |
|--------|------------------|------------|----------|
| **UserController** | Gerenciar estado de usuários; filtrar; notificar UI | users[], userFilter | filteredUsers |
| **ChildController** | Gerenciar estado de crianças; mapping child->responsibles | children[], selectedChildId | activeChildren, getChildrenWithResponsibles() |
| **CheckEventController** | Gerenciar log de eventos; estado de carregamento | events[], logEvents[], isLoadingEvents | lastCheckIn, lastCheckOut, activeCheckins |
| **AuthController** | Gerenciar autenticação; sessão; logout | — | — |
| **CompanyController** | Gerenciar empresa selecionada | companySelected | — |
| **CollaboratorController** | Gerenciar colaborador logado | loggedCollaborator | — |

#### Views (UI Layer)

| Classe | Responsabilidades | Exemplo |
|--------|------------------|---------|
| **HomeScreen** | Tela principal; exibir crianças ativas; acionar check-in/out | Stateful, carrega activeChildren, MobX Observer |
| **ChildrenScreen** | Listar todas as crianças; CRUD; filtro por nome | SearchField, ListView builder, _childCard helper |
| **LoginScreen** | Formulário de autenticação; persistência de sessão | TextFields, login button, validação |
| **CheckEventLogScreen** | Visualizar histórico de check-in/out | ListView com 30 últimos eventos, filtros por data |
| **AddChildDialog** | Diálogo para criar/editar criança | Form, TextFields, Multi-select de responsáveis |

---

### 3.2 Princípios OOP Aplicados

#### 3.2.1 Abstração (Abstraction)

**Implementação**: Classes base abstratas e interfaces definem contrato.

```dart
// BaseModel abstrai conceito de "entidade com timestamps"
abstract class BaseModel {
  final DateTime createdAt;
  final DateTime updatedAt;
  
  // Template para serialização
  Map<String, dynamic> toJsonTimestamps();
  
  // Factory para parsing robusto
  static DateTime? tryParseTimestamp(dynamic value);
}

// Child e User herdam e reutilizam lógica de timestamps
class Child extends BaseModel {
  // especialização: adição de isActive, responsibleUserIds
}
```

**Benefício**: Reduz duplicação; centraliza lógica de timestamp.

---

#### 3.2.2 Herança (Inheritance)

**Implementação**: Hierarquia simples e profunda evitada.

```
BaseModel (abstract)
├── Child
├── User
├── Company
├── CheckEvent
└── Collaborator
```

**Por quê**:
- Todas as entidades precisam de `createdAt/updatedAt` para auditoria
- Centraliza serialização JSON (`toJsonTimestamps()`)
- Facilita extensions futuras (ex.: soft-delete com `deletedAt`)

**Regra**: Máx. 2 níveis de herança; preferir composição para comportamentos.

---

#### 3.2.3 Encapsulamento (Encapsulation)

**Implementação**: Separação de responsabilidades por camadas.

```dart
// View nunca chama Service diretamente
// View -> Controller (MobX) -> Service

// Senhas são privadas no Collaborator; toJson() não as expõe
class Collaborator {
  final String? password;  // privado, nunca serializado
  
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    // password EXCLUSIVAMENTE NOT incluído
  };
}

// CheckEvent é imutável; eventos não podem ser editados
class CheckEvent {
  final String id;  // final
  final DateTime timestamp;  // final, não setter
  
  // Sem método setTimestamp(), sem copyWith(timestamp: ...)
  // Garante integridade de auditoria
}
```

**Benefício**: Segurança, integridade de dados, menos bugs.

---

#### 3.2.4 Polimorfismo (Polymorphism)

**Implementação**: Substituição de tipos via herança e interfaces.

```dart
// CheckType enum com polimorfismo implícito
enum CheckType { checkIn, checkOut }

// Diferentes comportamentos conforme tipo
CheckEvent event = CheckEvent(..., checkType: CheckType.checkIn);

// Processamento diferenciado
if (event.checkType == CheckType.checkIn) {
  child.isActive = true;
} else {
  child.isActive = false;
}

// Possível refatoração futura com classes:
abstract class Check {
  void apply(Child child);
}

class CheckInBehavior extends Check {
  void apply(Child child) => child.isActive = true;
}
```

**Benefício**: Código extensível; fácil adicionar novos tipos de check.

---

#### 3.2.5 SOLID Principles

| Princípio | Aplicação |
|-----------|-----------|
| **S**ingle Responsibility | CheckEventService só gerencia eventos; UserService só usuários; Controllers lidam com estado UI |
| **O**pen/Closed | BaseModel aberto para extensão (novas entidades), fechado para modificação |
| **L**iskov Substitution | Child, User, Company podem substituir BaseModel sem quebrar código |
| **I**nterface Segregation | Controllers têm interfaces mínimas; Views consomem apenas o necessário via DI |
| **D**ependency Inversion | Views dependem de abstrações (GetIt DI), não de implementações concretas |

---

### 3.3 Arquitetura OOD Proposta

#### 3.3.1 Camadas (Layered Architecture)

```
┌─────────────────────────────────────────────────┐
│  UI Layer (Flutter Widgets)                     │
│  ├─ Screens (StatefulWidget)                   │
│  ├─ Dialogs                                    │
│  └─ Helper Widgets (_buildXxx private methods) │
└────────────────────┬────────────────────────────┘
                     │ (observa)
                     ▼
┌─────────────────────────────────────────────────┐
│  State Management Layer (MobX Controllers)      │
│  ├─ UserController (Observable)                │
│  ├─ ChildController (@computed)               │
│  ├─ CheckEventController (@action)            │
│  ├─ AuthController                             │
│  ├─ CompanyController                          │
│  └─ CollaboratorController                     │
└────────────────────┬────────────────────────────┘
                     │ (usa)
                     ▼
┌─────────────────────────────────────────────────┐
│  Business Logic Layer (Services)                │
│  ├─ AuthService (login, logout)               │
│  ├─ UserService (CRUD User)                   │
│  ├─ ChildService (CRUD Child, status)        │
│  ├─ CheckEventService (record, validate, log) │
│  ├─ CollaboratorService (CRUD, permissions)  │
│  └─ SyncService (offline->online, conflicts)  │
└────────────────────┬────────────────────────────┘
                     │ (usa)
                     ▼
┌─────────────────────────────────────────────────┐
│  Data Layer (Models + Persistence)              │
│  ├─ Models (BaseModel, Child, User, ...)       │
│  ├─ Repository (Mock / API / SQLite)           │
│  ├─ LocalStorage (SharedPreferences, SQLite)   │
│  └─ Remote API (HTTP Client)                   │
└────────────────────┬────────────────────────────┘
                     │ (lê/escreve)
                     ▼
┌─────────────────────────────────────────────────┐
│  Database / External Services                   │
│  ├─ Mock Data (dev)                            │
│  ├─ SQLite Local DB                            │
│  └─ Backend API (production)                   │
└─────────────────────────────────────────────────┘
```

#### 3.3.2 Padrões de Design Aplicados

| Padrão | Onde | Por quê |
|--------|------|--------|
| **MVC** | View → Controller → Model | Separação clara; fácil testar lógica |
| **Singleton** | GetIt (DI Container) | Garantir instância única de Controllers |
| **Observer** | MobX @observable | Reatividade automática; UI atualiza quando dados mudam |
| **Factory** | Model.fromJson() | Parsing robusto; centraliza lógica de desserialização |
| **Adapter** | Service layer | Adapta mock/API/SQLite para mesma interface |
| **Strategy** | CheckType enum (futura classe) | Diferentes comportamentos de check-in/out |
| **Builder** | Dialog forms | Construir objetos complexos (Child, User) passo a passo |
| **Decorator** | Skeletonizer, Observer | Enriquecer widgets com comportamentos (loading, reatividade) |

---

### 3.3.3 Padrão de Data Flow (Unidireccional)

```
User Interaction (tap button)
          │
          ▼
    View (Screen)
          │
          ▼
  Controller @action
    (e.g., onCheckIn)
          │
          ▼
  Service.recordCheck()
          │
          ▼
  Repository.save()
          │
          ▼
  Local DB / Mock
          │
          ▼
  Return result
          │
          ▼
  Controller @observable
    (e.g., logEvents [])
          │
          ▼
  @computed derivado
  (e.g., activeCheckins)
          │
          ▼
  View @Observer(rebuilds)
          │
          ▼
  UI atualizada
```

**Benefício**: Fluxo previsível; fácil debugar; reduz side-effects.

---

### 3.4 Justificativa: Escalabilidade, Reutilização e Manutenção

#### 3.4.1 Escalabilidade

**Horizontal (múltiplas empresas, colaboradores, crianças)**:
- Modelos usam `companyId` para isolamento por tenant
- Services filtram por empresa; Controllers atuam em contexto
- Sem acoplamento entre empresas

**Vertical (cresce em funcionalidades)**:
- Novas entidades estendem BaseModel (ex.: Atividade, Medicação)
- Novos Controllers seguem padrão MobX (Observable, Computed, Action)
- Novas Screens reutilizam helpers widget privados (padrão estabelecido)
- Services adicionais não quebram arquitetura existente

**Exemplo**: Adicionar "NotificationService"
```dart
// Serviço novo
class NotificationService {
  Future<void> notifyParentCheckout(CheckEvent event) async { ... }
}

// Controller existente usa novo serviço
abstract class _CheckEventController {
  final _notificationService = NotificationService();
  
  @action
  Future<void> recordCheckOut(String childId) async {
    final event = await _service.recordCheck(...);
    await _notificationService.notifyParent(event); // novo fluxo
  }
}

// UI não muda; Controller orquestra tudo
```

#### 3.4.2 Reutilização

**Modelos**:
- `BaseModel` encapsula timestamps; reutilizado por todas as entidades
- `CheckType` enum pode ser estendido sem quebra

**Services**:
- UserService usado por múltiplos Controllers
- CheckEventService compartilhado entre HomeScreen e LogScreen
- Sem duplicação de lógica

**Controllers**:
- UserController fornece `filteredUsers` @computed reutilizado em:
  - AddChildDialog (selecionar responsáveis)
  - UserProfileScreen (listar usuários)
  - RelatoriosScreen (futura)

**UI Helpers**:
- `_getInitials(String name)` reutilizado em múltiplas screens (Avatars)
- `_buildEmptyState(String message)` reutilizado para "Nenhuma criança encontrada"
- Pattern de "widget helpers privados" copiável em novas screens

#### 3.4.3 Manutenção

**Baixo Acoplamento**:
- Views não conhecem Services; apenas Controllers
- Controllers não conhecem Details de Dialogs; apenas Models
- Fácil trocar implementação (mock ↔ API)

**Coesão Alta**:
- Cada classe tem responsabilidade bem-definida
- CheckEventService = check-events, ponto
- Não mistura auth, sync, notificação

**Testabilidade**:
- Services podem ser mockados facilmente
- Controllers testáveis com MobX + testes unitários
- Models imutáveis; sem side-effects

**Exemplo de mudança sem quebras**:
```dart
// IF: Backend agora retorna timestamp em ms epoch (não ISO string)
// THEN: Apenas atualizar Factory no Model, resto funciona igual

factory CheckEvent.fromJson(Map<String, dynamic> json) => CheckEvent(
  // Antes:
  // timestamp: DateTime.parse(json['timestamp'] as String),
  
  // Depois:
  timestamp: DateTime.fromMillisecondsSinceEpoch(json['timestamp'] as int),
);

// Views, Services, Controllers não mudam
```

---

## 4. Resumo Executivo

### Fases de Implementação Propostas

| Fase | Duração | Entregáveis |
|------|---------|-------------|
| **1. Setup & Modelos** | 1-2 sprints | BaseModel, Child, User, Company, Collaborator, CheckEvent |
| **2. Camada de Serviços** | 2-3 sprints | AuthService, UserService, ChildService, CheckEventService |
| **3. Controllers (MobX)** | 2 sprints | UserController, ChildController, CheckEventController, etc. |
| **4. UI Camada 1** | 2-3 sprints | LoginScreen, HomeScreen, ChildrenScreen, Log |
| **5. Integrações** | 1-2 sprints | Sync offline, Notificações, Relatórios básicos |
| **6. Testes & Polish** | 1-2 sprints | Unit tests, Integration tests, Performance tuning |

### Métricas de Qualidade

- **Cobertura de testes**: Alvo 80%+ (Services e Controllers)
- **Coesão de classe**: Alta (cada classe, 1-3 responsabilidades)
- **Acoplamento entre camadas**: Baixo (via DI e abstrações)
- **Ciclomatic complexity**: < 10 por método
- **Documentação**: README + comentários em métodos complexos

---

## Próximos Passos

1. **Validar requisitos** com stakeholders (pais, coordenadores, professores)
2. **Refinar Casos de Uso** com fluxos alternativos detalhaados
3. **Implementar Protótipo** (Phase 1-2) para validação de arquitetura
4. **Iterações Ágeis** com feedback contínuo
5. **Documentação Living** (atualizar conforme evoluir)

---

**Documento Preparado**: Dezembro 2025
**Versão**: 1.0
**Status**: Pronto para Revisão e Aprovação
