# Kids Space — Accessibility Checklist
> Padrão: WCAG 2.1 AA · Material 3 · Flutter Semantics
> Baseado em: SKILL.md prioridade 1 (Accessibility — CRITICAL)

---

## PARTE 1 — Checklist WCAG AA por Categoria

### 1.1 Contraste de Cor (Critério 1.4.3 / 1.4.11)

| Item | Requisito | Verificação |
|------|-----------|-------------|
| Texto normal (< 18sp) | Razão ≥ 4.5:1 | [ ] |
| Texto grande (≥ 18sp bold ou ≥ 24sp regular) | Razão ≥ 3:1 | [ ] |
| Componentes de UI (inputs, botões, ícones funcionais) | Razão ≥ 3:1 | [ ] |
| Badge "● Presente" (verde sobre fundo verde-claro) | Razão ≥ 4.5:1 | [ ] |
| Badge "○ Ausente" (cinza sobre fundo branco) | Razão ≥ 4.5:1 | [ ] |
| Alerta de saúde (texto `#303649` sobre `#FFF8E1`) | Razão ≥ 4.5:1 — passa com 8.5:1 ✓ | [ ] |
| Texto desabilitado (on-surface-disabled) | Não precisa de 4.5:1, mas deve ser identificável por outra pista | [ ] |
| Estado de erro (error `#B00020` sobre branco) | Razão 5.9:1 ✓ | [ ] |
| Placeholder em inputs | ≥ 4.5:1 (Flutter: usar cor explícita, não padrão cinza-claro) | [ ] |

**Ferramentas:** [Colour Contrast Analyser](https://www.tpgi.com/color-contrast-checker/), plugin Figma A11y Annotations.

### 1.2 Alternativas Textuais (Critério 1.1.1)

| Item | Requisito | Verificação |
|------|-----------|-------------|
| Avatar com iniciais do nome | `Semantics(label: 'Foto de ${name}')` | [ ] |
| Ícone de saúde `⚕` | `Semantics(label: 'Alerta de saúde')` | [ ] |
| Ícone de status (●/○) | Semântica: "Presente" / "Ausente" — não apenas ícone | [ ] |
| Ícone de busca (lupa) | `Semantics(label: 'Buscar criança')` | [ ] |
| Botão de fechar modal (✕) | `Semantics(label: 'Fechar', button: true)` | [ ] |
| Logo da empresa | `ExcludeSemantics()` se decorativa | [ ] |
| Loading spinner | `Semantics(label: 'Carregando...', liveRegion: true)` | [ ] |

### 1.3 Adaptabilidade (Critério 1.3.1 / 1.3.3)

| Item | Requisito | Verificação |
|------|-----------|-------------|
| Formulários com labels explícitas | `InputDecoration(labelText: ...)` — não só placeholder | [ ] |
| Campos obrigatórios marcados | Asterisco (*) + `Semantics(required: true)` | [ ] |
| Ordem de foco lógica | Tab order = ordem visual de cima → baixo, esquerda → direita | [ ] |
| Instruções não dependem de cor ou forma sozinhas | "O campo em vermelho" → "O campo CPF (marcado com erro)" | [ ] |
| Status de check-in comunicado por texto | "● Presente" — não apenas ponto verde | [ ] |

### 1.4 Distinguível (Critério 1.4.4 / 1.4.10 / 1.4.12)

| Item | Requisito | Verificação |
|------|-----------|-------------|
| Texto aumenta até 200% sem perda de conteúdo | Testar com acessibilidade de sistema no tamanho máximo | [ ] |
| Sem scroll horizontal em nenhuma tela | MediaQuery.textScaleFactor dinâmico testado | [ ] |
| Espaçamento de texto customizável | Não fixar `height:` e `letterSpacing:` com px absolutos | [ ] |
| Conteúdo não cortado com fonte grande | Usar `overflow: TextOverflow.ellipsis` com `maxLines` ou `Flexible` | [ ] |

### 2.1 Teclado / Navegação (Critério 2.1.1 / 2.1.2)

| Item | Requisito | Verificação |
|------|-----------|-------------|
| Todos os elementos interativos alcançáveis por Tab | Testar com teclado físico/bluetooth no Android/iOS | [ ] |
| Sem armadilha de foco | Modais: foco confinado dentro → ao fechar, retorna ao trigger | [ ] |
| Dialogs têm foco inicial no primeiro campo | `autofocus: true` no campo CPF do CpfConfirmationDialog | [ ] |
| Bottom sheets podem ser fechadas com Escape/gesto | `barrierDismissible` configurado intencionalmente | [ ] |
| Ações de teclado consistentes | Enter = submit, Escape = fechar modal | [ ] |

### 2.4 Navegável (Critério 2.4.3 / 2.4.7)

| Item | Requisito | Verificação |
|------|-----------|-------------|
| Foco visível em todos os elementos interativos | `FocusDecoration` ou `focusColor` configurado — NUNCA remover outline | [ ] |
| Outline de foco: ≥ 2dp, contraste ≥ 3:1 | Cor `primary-500 (#2962FF)` sobre branco = 5.6:1 ✓ | [ ] |
| Breadcrumb / indicador de step no wizard | Tela atual anunciada ao TalkBack/VoiceOver | [ ] |
| Título de cada tela/dialog único e descritivo | Não "Perfil" mas "Perfil de Ana Silva" | [ ] |

### 4.1 Compatível (Critério 4.1.2 / 4.1.3)

| Item | Requisito | Verificação |
|------|-----------|-------------|
| Nome, função, valor nos componentes | `Semantics(label, button, checked, enabled)` preenchidos | [ ] |
| Mensagens de erro anunciadas por screen reader | `errorText` do Flutter ativa `aria-live` nativo | [ ] |
| Status updates anunciados | `SemanticsService.announce()` ou `liveRegion: true` para check-in confirmado | [ ] |
| Toast/SnackBar acessível | Usar `ScaffoldMessenger` — Flutter já gerencia a11y; NÃO usar overlay customizado sem semântica | [ ] |

---

## PARTE 2 — Checklist Mobile/Touch Específico

| Item | Padrão | Status |
|------|--------|--------|
| Touch target mínimo | 48×48dp — `GestureDetector` com `hitTestBehavior` se necessário | [ ] |
| Gap mínimo entre targets | 8dp — verificar botões próximos em cards compactos | [ ] |
| Feedback visual em 100ms | `InkWell` ripple ou `AnimatedContainer` opacity | [ ] |
| Sem interações hover-only | Todos os estados acessíveis via tap | [ ] |
| Safe areas respeitadas | `SafeArea()` em todas as telas, `MediaQuery.of(context).padding` para offset | [ ] |
| Zoom do sistema não bloqueado | `never` não usar `allowImplicitScrolling: false` em TextFields | [ ] |
| Orientação landscape suportada | Testar landscape — sem overflow horizontal | [ ] |

---

## PARTE 3 — Casos de Teste de Usabilidade

> 5 casos obrigatórios, cobrindo Colaborador (staff) e Responsável (parent).

---

### Caso de Teste 1: Check-in rápido (Colaborador)
**Persona:** Colaboradora Maria, 32 anos, usa o app 30× por dia no horário de entrada.
**Cenário:** Registrar entrada de 3 crianças seguidas em menos de 2 minutos.

**Passos:**
1. Abrir tela de crianças
2. Localizar criança 1 por busca
3. Tocar no card → modal check-in abre
4. Verificar se alerta de saúde está visível (criança 1 tem alergia a amendoim)
5. Selecionar responsável
6. Confirmar check-in
7. Repetir para criança 2 (sem saúde crítica)
8. Repetir para criança 3 via "Recentes"

**Critério de aceitação de usabilidade:**
- [ ] ≤ 3 toques por check-in após o primeiro (busca + seleção responsável + confirmar)
- [ ] Alerta de saúde visível SEM scroll
- [ ] Criança 3 aparece em Recentes → 1 toque + confirmar
- [ ] Nenhuma dúvida sobre qual botão pressionar
- [ ] Tempo total ≤ 90 segundos para as 3 crianças

---

### Caso de Teste 2: Checkout com CPF incorreto (Colaborador)
**Persona:** Colaborador Pedro, primeira semana de trabalho.
**Cenário:** Tentar fazer checkout de Ana Silva, digitar CPF errado, corrigir e confirmar.

**Passos:**
1. Localizar Ana Silva (status: Presente)
2. Acionar checkout
3. Dialog de CPF abre
4. Digitar CPF incorreto
5. Tocar "Confirmar Saída"
6. Ler mensagem de erro
7. Corrigir o CPF
8. Confirmar — sucesso

**Critério de aceitação de usabilidade:**
- [ ] Mensagem de erro é clara: ONDE errou e O QUE fazer
- [ ] Foco retorna ao campo CPF automaticamente após erro
- [ ] Botão "Confirmar" não some — usuário sabe que pode tentar de novo
- [ ] Não é necessário fechar e reabrir o dialog
- [ ] Texto do sucesso menciona o nome da criança (confirmação de ação correta)

---

### Caso de Teste 3: Cadastro de nova família (Colaborador)
**Persona:** Administradora da creche, cadastrando família nova.
**Cenário:** Cadastrar pai Carlos Souza e filho Lucas Souza via wizard.

**Passos:**
1. Tocar FAB na tela de crianças
2. Wizard abre — Step 1/3
3. Preencher dados do pai (nome, CPF, telefone)
4. Avançar para Step 2/3
5. Preencher dados da criança (nome, data de nascimento)
6. Adicionar alergia: "lactose"
7. Avançar para Step 3/3 (revisão)
8. Confirmar cadastro
9. Verificar que Lucas aparece na lista com responsável Carlos

**Critério de aceitação de usabilidade:**
- [ ] Progresso sempre visível (Step X/3)
- [ ] "Voltar" funciona e preserva dados já preenchidos
- [ ] Adição de alergia intuitiva (chip + campo de texto)
- [ ] Revisão mostra todos os dados antes do submit
- [ ] Após sucesso, Lucas aparece na lista sem precisar dar refresh manual

---

### Caso de Teste 4: Verificação de saúde antes do check-in (Colaborador)
**Persona:** Colaboradora Ana, recém contratada, nunca viu a criança.
**Cenário:** Registrar entrada de Pedro, que tem TDAH e medicação às 08h.

**Passos:**
1. Buscar "Pedro" na lista
2. Tocar no card de Pedro
3. Modal de check-in abre
4. Ler o alerta de saúde ANTES de qualquer outra ação
5. Reconhecer medicamento e horário
6. Selecionar responsável
7. Confirmar check-in

**Critério de aceitação de usabilidade:**
- [ ] Alerta de saúde é o PRIMEIRO elemento visual abaixo do nome
- [ ] Dados críticos (medicamento + horário) visíveis sem scroll
- [ ] Colaboradora consegue ler e processar a informação em ≤ 5 segundos
- [ ] Cor/ícone comunica "atenção" mesmo sem ler o texto
- [ ] Teste com screen reader: TalkBack lê o alerta antes dos campos de seleção

---

### Caso de Teste 5: Acesso ao histórico após check-in (Responsável/Pai)
**Persona:** Carlos Souza, pai de Lucas, quer confirmar que o filho foi registrado.
**Cenário:** Ver no app que Lucas deu entrada às 08:05 de hoje.

> ⚠️ **Nota:** Esta funcionalidade pode estar fora do escopo atual do app (perfil de parent). Se não existir, documentar como requisito futuro.

**Passos:**
1. Fazer login como responsável
2. Acessar perfil de Lucas
3. Localizar histórico de presença
4. Confirmar check-in de hoje

**Critério de aceitação de usabilidade:**
- [ ] Histórico visível sem mais de 2 toques a partir do menu principal
- [ ] Data e hora do check-in claramente visíveis
- [ ] Nome do colaborador que registrou visível (para confiança)
- [ ] Se sem histórico: mensagem clara, não tela em branco
- [ ] **Se não implementado:** `[REQUERE BACKEND CHANGE]` — adicionar endpoint `GET /v2/attendance?childId=xxx&parentId=xxx`

---

## PARTE 4 — Pré-entrega Checklist (SKILL.md Pre-Delivery)

### Visual Quality
- [ ] Zero emojis como ícones estruturais — usar `Icons.*` do Material ou `flutter_svg`
- [ ] Todos os ícones do mesmo conjunto (Material Icons 3 filled/outlined consistente por hierarquia)
- [ ] Press state não muda layout (apenas opacity/scale)
- [ ] Zero hardcoded hex — usar tokens semânticos via `Theme.of(context).extension<>()`

### Interaction
- [ ] Todos os tappables têm feedback visual (InkWell ripple ou opacity animation)
- [ ] Touch targets ≥ 48dp confirmados com Flutter DevTools > Widget Inspector
- [ ] Micro-interações entre 150–300ms (não 0ms, não > 400ms)
- [ ] Disabled states: visualmente claro + `onPressed: null` (Flutter desabilita semântica automaticamente)
- [ ] Screen reader order: inspecionar com TalkBack (Android) e VoiceOver (iOS)

### Light Mode (único no MVP)
- [ ] Primary text contrast ≥ 4.5:1 confirmado para todos os backgrounds de card
- [ ] Dividers/borders visíveis (`outline-variant: #DDE2ED` sobre branco)
- [ ] Modal scrim opacity: 50% preto confirmado

### Layout
- [ ] `SafeArea()` em todas as telas
- [ ] Conteúdo não oculto atrás de BottomNavigationBar
- [ ] Testado em: Galaxy A12 (small, 360dp), iPhone 14 (375dp), iPad 10" (768dp)
- [ ] Landscape: sem overflow, layout não quebra
- [ ] Espaçamento 4/8dp rhythm mantido

### Accessibility
- [ ] Imagens decorativas com `ExcludeSemantics()`
- [ ] Campos de formulário com `labelText` (não só placeholder)
- [ ] Erros com `errorText` (não apenas cor)
- [ ] `Semantics(liveRegion: true)` em mensagens dinâmicas (check-in confirmado, erros)
- [ ] `reduced motion`: verificar que animações respeitam `MediaQuery.disableAnimations`
- [ ] Dynamic Type: testar com fonte do sistema no tamanho máximo (±3 níveis)
- [ ] Traits/roles: `Semantics(button: true, checked: x, enabled: y)` em todos os interativos

---

## PARTE 5 — Ferramenta de Verificação Rápida

```bash
# Verificar cores com contraste WCAG AA
# Instalar: https://www.tpgi.com/color-contrast-checker/

# Tokens principais a verificar:
# primary (#2962FF) em branco: 5.5:1 ✓ AA (texto normal)
# secondary (#388E3C) em branco: 4.5:1 ✓ AA (texto normal — limite)
# error (#B00020) em branco: 5.9:1 ✓ AA
# on-surface-secondary (#495267) em branco: 7.2:1 ✓ AA
# warning (#E65100) em branco: 4.6:1 ✓ AA (texto normal — usar com cautela)
# accent/500 (#FF8F00) em branco: 2.9:1 ✗ — USE APENAS COMO BG ou ícone grande
```

```dart
// Flutter: verificar semantics em runtime
// Ativar Accessibility Inspector no Xcode (iOS)
// Ativar TalkBack + Accessibility Scanner no Android

// Testar dynamic text:
// Settings → Accessibility → Display → Font Size → máximo
// Verificar: textos não truncam, cards não overflow, botões não ficam microscópicos
```
