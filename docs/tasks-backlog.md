# Kids Space — Tasks Backlog (Sprint 2 semanas)
> Prioridade: P0 = blocker, P1 = alta, P2 = média, P3 = melhorias
> Estimate: SP (story points) — referência: 1 SP ≈ 1 dia de engenheiro sênior Flutter

---

## Issue #1 — [P0] Redesign: Design System & Tokens no Flutter

**Título:** Implementar design system (tokens, tema Material 3, componentes base)

**Descrição:**
Aplicar os tokens definidos em `docs/design-tokens.json` ao `ThemeData` do Flutter. Criar extensões de tema para tokens semânticos (cores de check-in, health-alert, etc.). Garantir que nenhum componente use hex hardcoded.

**Critérios de aceitação:**
- [ ] `AppTheme` exporta `ThemeData` light e high-contrast com tokens do JSON
- [ ] Extensão `KidsSpaceColors` disponível via `Theme.of(context).extension<KidsSpaceColors>()`
- [ ] Zero hardcoded hex/color nos widgets (exceto os já existentes — migrar progressivamente)
- [ ] Tokens de tipografia aplicados ao `TextTheme` (Inter/Nunito via Google Fonts)
- [ ] Tokens de spacing como constantes `KsSpacing.sp4`, `KsSpacing.sp8`, etc.
- [ ] Testes de contraste: rodar `flutter_accessibility_suite` ou verificação manual WCAG AA

**Estimate:** 3 SP
**Labels:** design-system, no-backend-change

---

## Issue #2 — [P0] Redesign: CheckinBottomSheet com alerta de saúde

**Título:** Refatorar modal de check-in com HealthAlertBanner e seleção de responsável

**Descrição:**
Substituir o `attendance_modal.dart` atual pelo `CheckinBottomSheet` especificado em `components-specs.md`. Incluir: exibição prioritária de alerta de saúde, seleção de responsável via `RadioListTile`, campo de observações e tratamento de estados (loading/error/success) com retry.

**Critérios de aceitação:**
- [ ] `HealthInfoAlertBanner` (variant compact) exibido antes da seleção de responsável
- [ ] Botão "Confirmar Check-in" desabilitado até responsável selecionado (`Semantics` correto)
- [ ] Estado loading: botão mostra `CircularProgressIndicator`, campo readOnly
- [ ] Estado error-network: banner com botão "Tentar novamente"
- [ ] Estado success: sheet fecha + `SnackBar` verde floating
- [ ] Touch targets: todos os elementos interativos ≥ 48dp
- [ ] Teste: simular erro de rede → verificar retry funciona

**Estimate:** 3 SP
**Labels:** UX-critical, checkin-flow, no-backend-change

---

## Issue #3 — [P0] Implementar CpfConfirmationDialog no checkout

**Título:** Modal de confirmação de CPF antes do checkout com validação inline

**Descrição:**
Criar `CpfConfirmationDialog` conforme spec em `components-specs.md`. O CPF deve ser validado contra o cadastro do responsável no backend (POST `/v2/attendance/checkout` com `parentDocument`). Aplicar máscara `000.000.000-00`, validação de 11 dígitos antes de habilitar o botão, e tratar resposta de CPF incorreto com mensagem inline.

**Critérios de aceitação:**
- [ ] Dialog aparece ao acionar checkout (não bottom sheet — modal mais formal/intencional)
- [ ] Campo CPF com máscara aplicada via `TextInputFormatter`
- [ ] Botão desabilitado até 11 dígitos preenchidos
- [ ] Erro "CPF não confere" exibido abaixo do campo (não toast) com `role="alert"`
- [ ] Após erro, foco retorna automaticamente ao campo CPF (WCAG focus-management)
- [ ] `barrierDismissible: false` — usuário deve confirmar ou cancelar explicitamente
- [ ] Payload correto: `parentDocument` sem formatação (só dígitos) enviado ao backend
- [ ] Teste: CPF correto → checkout registrado. CPF errado → erro inline mostrado.

**Estimate:** 2 SP
**Labels:** UX-critical, checkout-flow, no-backend-change

---

## Issue #4 — [P1] Wizard de Cadastro de Família (3 passos)

**Título:** Criar wizard unificado Pai + Criança com indicador de progresso

**Descrição:**
Substituir os 3 fluxos separados (cadastro pai, cadastro filho no perfil do pai, assign parent) por um único wizard de 3 passos: (1) Dados do responsável → `POST /v2/parents`, (2) Dados da criança → `POST /v2/children`, (3) Revisão + confirmação. Preservar `parentId` gerado no step 1 para usar no step 2.

**Critérios de aceitação:**
- [ ] Indicador de progresso visual (`LinearProgressIndicator` ou `StepIndicator`) entre os steps
- [ ] Botão "Voltar" em todos os steps (exceto step 1) preserva dados já preenchidos
- [ ] Falha no step 1 NÃO avança para step 2 — mostra retry
- [ ] Falha no step 2 preserva `parentId` do step 1 — retry só recria a criança
- [ ] Step 3 mostra resumo editável antes de finalizar
- [ ] Ação disponível via FAB na tela de crianças (já implementado) e via menu da empresa
- [ ] Validação inline em cada campo (blur → valida — SKILL.md §8: inline-validation)
- [ ] Teste: cancelar no step 2 → confirmar descarte dos dados (dialog de confirmação)

**Estimate:** 5 SP
**Labels:** UX, onboarding, no-backend-change

---

## Issue #5 — [P1] ChildListTile redesign com estados visuais de presença

**Título:** Refatorar card de criança com estados visuais distintos (checkedIn/out/pending)

**Descrição:**
Aplicar o design do `ChildListTile` da spec: borda esquerda colorida por estado, background diferenciado, badge de presença, badge de saúde (`⚕`) quando `healthInfo` não está vazio, e botão de ação rápida para check-in/checkout sem navegar para o perfil.

**Critérios de aceitação:**
- [ ] 3 estados visuais distintos usando APENAS cor + ícone + texto (não só cor — SKILL.md §1: color-not-only)
- [ ] Badge `⚕` visível no canto quando `healthInfo.isEmpty == false`
- [ ] `Semantics` correto: "Ana Silva, Presente. Possui informações de saúde. Botão."
- [ ] Ação rápida de check-in/checkout sem abrir profile (min 48dp touch target)
- [ ] Lista virtualizada com `ListView.builder` para performance (SKILL.md §3: virtualize-lists)
- [ ] Skeleton cards durante loading (SKILL.md §3: progressive-loading)
- [ ] Teste: lista com 100+ crianças — scrolling smooth sem jank

**Estimate:** 2 SP
**Labels:** UX, performance, no-backend-change

---

## Issue #6 — [P1] Health Info Alert no Profile da Criança

**Título:** Mover HealthInfoSection para topo do profile e adicionar banner de urgência

**Descrição:**
Atualmente a seção de cuidados médicos (`ProfileHealthInfoSection`) fica no final do profile após endereço e responsáveis. Deve aparecer logo abaixo das informações pessoais com um banner de alerta colorido (não apenas como card neutro) quando houver dados críticos (alergias, medicamentos).

**Critérios de aceitação:**
- [ ] `HealthInfoAlertBanner` (variant expanded) posicionado ANTES da seção de endereço
- [ ] Cores de alerta (`#FFF8E1`, borda `#FFB300`, ícone `#E65100`) aplicadas
- [ ] Se `healthInfo.isEmpty`, exibir mensagem "Nenhuma informação de saúde cadastrada" (nunca ocultar a seção totalmente — manter ação de editar visível)
- [ ] Seção colapsável/expansível com `ExpansionTile` para não dominar o profile inteiro
- [ ] Edição de saúde acessível via botão edit do profile (já implementado)

**Estimate:** 1 SP
**Labels:** UX, health-data, no-backend-change

---

## Issue #7 — [P1] Seção de Recentes no Check-in (Quick Access)

**Título:** Adicionar seção "Recentes" no topo da lista de check-in com as últimas 5 crianças

**Descrição:**
Reduzir o número de toques para check-in de crianças recorrentes. Mostrar as últimas 5 crianças com ação recente (check-in ou checkout) em uma seção de acesso rápido no topo da lista. Usar cache local (hive/shared_preferences) para persistência entre sessões.

**Critérios de aceitação:**
- [ ] Seção "Recentes" com até 5 itens antes da lista principal
- [ ] Ordenada por última ação (mais recente primeiro)
- [ ] Cada item mostra nome, status atual e botão de ação rápida
- [ ] Cache persiste entre restarts do app (usar `SharedPreferences` ou `Hive`)
- [ ] Seção oculta se não houver histórico (primeira sessão)
- [ ] Teste: fazer check-in de Ana → fechar app → reabrir → Ana aparece em Recentes

**Estimate:** 2 SP
**Labels:** UX, performance, no-backend-change

---

## Issue #8 — [P2] Feedback de Rede e Estado Offline

**Título:** Implementar banner de offline e retry padronizado em toda a app

**Descrição:**
Criar `NetworkStatusBanner` que fica sticky no topo quando o dispositivo detecta ausência de conexão. Padronizar mensagens de erro de rede vs. erros de validação em todos os formulários. Adicionar botão "Tentar novamente" em todos os estados de erro que envolvem requisição de rede.

**Critérios de aceitação:**
- [ ] `connectivity_plus` integrado para detectar mudança de rede
- [ ] Banner sticky no topo (z-index acima de tudo) quando offline: "Sem conexão. Alguns dados podem estar desatualizados."
- [ ] Banner desaparece automaticamente quando reconecta
- [ ] Erro de rede em formulários: mensagem distinta de erro de validação + botão retry inline
- [ ] `SnackBar` de erro NÃO fecha automaticamente quando há ação de retry
- [ ] Teste: desligar Wi-Fi → tentar check-in → banner aparece + retry funciona ao reconectar

**Estimate:** 2 SP
**Labels:** UX, resilience, no-backend-change

---

## Issue #9 — [P2] Responsividade Tablet e Desktop (≥768dp)

**Título:** Layout adaptativo para tablet landscape e desktop com sidebar de navegação

**Descrição:**
Screens ≥768dp devem usar layout de duas colunas: sidebar de navegação à esquerda (substituindo o `BottomNavigationBar`) e conteúdo principal à direita. O conteúdo principal deve ter `maxWidth: 720dp` centralizado. Aplicar gutters adaptativos. (SKILL.md §9: adaptive-navigation)

**Critérios de aceitação:**
- [ ] `LayoutBuilder` detecta largura ≥768dp → usa `NavigationRail` ou `NavigationDrawer` permanente
- [ ] `BottomNavigationBar` oculto em ≥768dp
- [ ] Conteúdo principal: `maxWidth: 720dp` centralizado (já parcialmente implementado)
- [ ] Modais/dialogs têm largura máxima `min(480dp, 100% - 32dp)` em telas grandes
- [ ] Grids adaptam-se: lista de crianças passa de 1 coluna para 2 colunas em ≥768dp
- [ ] Teste: abrir em tablet 10" portrait e landscape — sem overflow, sem conteúdo cortado

**Estimate:** 3 SP
**Labels:** responsive, tablet, no-backend-change

---

## Issue #10 — [P2] Microcopy e Localização Completa

**Título:** Revisar e completar strings de localização pt-BR e en-US com microcopy padronizada

**Descrição:**
Auditar `assets/langs/pt-BR.json` e `en-US.json` para garantir que todas as telas usam strings localizadas (nenhuma string hardcoded em Dart). Aplicar microcopy padronizada conforme `components-specs.md` (especialmente mensagens de erro, confirmações e estados de loading).

**Critérios de aceitação:**
- [ ] Zero strings hardcoded em português no código Dart (grep para confirmar)
- [ ] Todas as novas telas (wizard, dialogs de CPF, health info) têm chaves no JSON
- [ ] Mensagens de erro de rede padronizadas (uma versão única por tipo de erro)
- [ ] Mensagens de confirmação sensível seguem microcopy: "Confirme o CPF do responsável para concluir o checkout de [Nome]."
- [ ] en-US.json sincronizado com pt-BR.json (mesmas chaves)
- [ ] Teste: mudar locale para en-US no device → app inteira em inglês sem strings faltando

**Estimate:** 2 SP
**Labels:** i18n, UX, no-backend-change

---

## Resumo do Sprint

| Issue | Prioridade | Estimate | Backend change? |
|-------|-----------|----------|----------------|
| #1 Design System Tokens | P0 | 3 SP | Não |
| #2 CheckinBottomSheet | P0 | 3 SP | Não |
| #3 CpfConfirmationDialog | P0 | 2 SP | Não |
| #4 Wizard Família | P1 | 5 SP | Não |
| #5 ChildListTile redesign | P1 | 2 SP | Não |
| #6 Health Info Alert | P1 | 1 SP | Não |
| #7 Seção Recentes | P1 | 2 SP | Não |
| #8 Feedback Offline | P2 | 2 SP | Não |
| #9 Responsividade Tablet | P2 | 3 SP | Não |
| #10 Microcopy i18n | P2 | 2 SP | Não |
| **Total** | | **25 SP** | |

**Capacidade sugerida para 2 semanas:** 20–25 SP (1 dev sênior Flutter)
**Sugestão de corte se necessário:** Issues #8, #9 e #10 para próximo sprint.

---

## Itens que requerem mudança no backend (fora do escopo deste sprint)

> Marcar como `requere-backend-change` e NÃO incluir no sprint sem alinhamento com o time de backend.

### BC-01: Endpoint de "Recentes" por colaborador
```
GET /v2/attendance/recent?collaboratorId=xxx&limit=5
→ Retorna últimas 5 crianças com ação de presença pelo colaborador
```
**Alternativa frontend-only:** Cache local das últimas 5 crianças com ação (sem garantia de consistência cross-device).

### BC-02: Validação de CPF inline (antes do checkout completo)
```
POST /v2/parents/:id/verify-document
Body: { "document": "11122233344" }
→ 200 { "valid": true } | 400 { "valid": false, "message": "CPF não confere" }
```
**Alternativa:** Enviar diretamente o checkout e tratar erro 400/422 como "CPF incorreto" — funciona mas com latência maior para o usuário ver o erro.

### BC-03: Health summary no endpoint de listagem de crianças
```
GET /v2/children?companyId=xxx
→ Adicionar campo "hasHealthInfo": true/false em cada item da lista
→ Evita carregar healthInfo completo na listagem (performance)
```
**Alternativa:** Calcular no frontend baseado no objeto completo — OK até ~200 crianças.
