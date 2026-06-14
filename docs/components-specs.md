# Kids Space — Component Library Specs
> Framework: Flutter / Material 3 · Regras aplicadas: SKILL.md prioridades 1–9
> Paleta de referência: `design-tokens.json` → `color.semantic`

---

## Sumário de Pontos de Fricção (5 bullets)

1. **Check-in em 4+ toques sem atalhos de recentes** — viola `touch-target-size`, `progressive-disclosure`, `loading-buttons`. Fluxo: buscar → rolar → selecionar responsável → confirmar. Em pico (08h–09h) o colaborador repete isso 30x seguidas.
2. **Checkout sem modal CPF estruturado** — viola `error-placement`, `inline-validation`, `error-clarity`. O backend exige CPF do responsável mas a UI não tem passo dedicado; o erro chega apenas no submit.
3. **Cadastro pai/criança em 3 fluxos desconectados** — viola `multi-step-progress`, `escape-routes`. Criar pai (registro), criar filho (perfil do pai), vincular (assign parent) — nenhum wizard unificado.
4. **Dados de saúde da criança sem badge de urgência** — viola `color-not-only`, `visual-hierarchy`, `primary-action`. Alergias e medicamentos ficam no final do profile sem destaque, invisíveis num check-in rápido.
5. **Feedback de rede/erro genérico sem retry** — viola `error-recovery`, `timeout-feedback`, `offline-support`. Snackbar desaparece em 4s, sem botão de retry, sem distinguir erro de validação de erro de conexão.

## 3 Telas Críticas para Priorizar

| # | Tela | Motivo |
|---|------|--------|
| 1 | **Check-in / Check-out** | Maior frequência; cada segundo de latência UX = fila real |
| 2 | **Profile da Criança** | Hub de saúde + gestão; dados críticos precisam de destaque |
| 3 | **Wizard Família (Pai + Filho)** | Onboarding alto impacto; hoje exige 3 telas separadas |

---

## Wireframes Low-Fi — Mobile (375dp)

### Tela 1: Check-in / Check-out

```
┌──────────────────────────────────────────┐  H=56dp sticky
│ ← Kids Space              [Empresa ABC]  │  AppBar
├──────────────────────────────────────────┤
│                                          │
│ ┌──────────────────────────────────────┐ │  H=56dp, border-radius=12
│ │ 🔍  Buscar criança...           [×] │ │  autofocus, debounce 300ms
│ └──────────────────────────────────────┘ │
│                                          │
│  ── RECENTES ──────────────────────────  │  Seção nova: últimas 5
│  ┌──────────────────────────────────────┐│
│  │ 👤 Ana Silva  [● Presente]    08:02 ││  H=64dp, touch target OK
│  │    Resp: Maria Silva                 ││
│  └──────────────────────────────────────┘│
│  ┌──────────────────────────────────────┐│
│  │ 👤 João P.   [○ Ausente]      —     ││
│  │    Resp: Carlos P.                   ││
│  └──────────────────────────────────────┘│
│  ── TODAS AS CRIANÇAS ──────────────────  │
│  [lista paginada — skeleton até carregar] │
│                                          │
└──────────────────────────────────────────┘

  Estado de busca:
┌──────────────────────────────────────────┐
│ ← "mar"                             [×] │
├──────────────────────────────────────────┤
│  ┌──────────────────────────────────────┐│
│  │ 👤 Marcos L.  [● Presente]   07:55 ││
│  └──────────────────────────────────────┘│
│  ┌──────────────────────────────────────┐│
│  │ 👤 Maria F.   [○ Ausente]      —    ││
│  └──────────────────────────────────────┘│
│                                          │
│  Nenhum outro resultado para "mar"       │  empty state com dica
└──────────────────────────────────────────┘
```

### Tela 2: Modal Check-in (Bottom Sheet)

```
┌──────────────────────────────────────────┐
│ ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ │  Scrim 50% — SKILL.md §: scrim
├──────────────────────────────────────────┤  Slide-up, radius=16 top
│  ─────  (drag handle)                    │
│                                          │
│  Check-in                         [✕]   │  H título = 24sp bold
│  ─────────────────────────────────────   │
│                                          │
│  👤 Ana Silva, 6 anos                    │  Avatar + nome
│  ┌── ⚠️ ALERTA DE SAÚDE ─────────────┐  │  health-alert-bg, border FFB300
│  │ Alergia: Amendoim                  │  │  H=auto, padding=12
│  │ Medicamento: Ritalina 10mg (08h)   │  │
│  └────────────────────────────────────┘  │
│                                          │
│  Selecione o responsável                 │  label 13sp medium
│  ┌──────────────────────────────────────┐│  H=56dp
│  │ ○ Maria Silva (mãe)  📱 (11)9xxxx  ││
│  └──────────────────────────────────────┘│
│  ┌──────────────────────────────────────┐│
│  │ ○ Carlos Silva (pai) 📱 (11)8xxxx  ││
│  └──────────────────────────────────────┘│
│                                          │
│  Observações (opcional)                  │
│  ┌──────────────────────────────────────┐│  H=80dp, multiline
│  │                                      ││
│  └──────────────────────────────────────┘│
│                                          │
│  ┌──────────────────────────────────────┐│  H=56dp, primary CTA
│  │          ✓  Confirmar Check-in       ││  desabilitado até selecionar resp.
│  └──────────────────────────────────────┘│
└──────────────────────────────────────────┘
```

### Tela 3: Modal Confirmação CPF (Check-out)

```
┌──────────────────────────────────────────┐
│ ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ │
├──────────────────────────────────────────┤  Dialog (não bottom sheet — mais formal)
│                                          │
│  ╔════════════════════════════════════╗  │  width=min(343,100%), radius=16
│  ║  🔐 Confirmação de CPF            ║  │
│  ║  ────────────────────────────     ║  │
│  ║                                   ║  │
│  ║  Confirme o CPF do responsável    ║  │  15sp, line-height 1.5
│  ║  para concluir o checkout de      ║  │
│  ║  Ana Silva.                       ║  │
│  ║                                   ║  │
│  ║  Responsável: Maria Silva         ║  │  13sp, cor secundária
│  ║                                   ║  │
│  ║  CPF *                            ║  │  label obrigatório
│  ║  ┌─────────────────────────────┐  ║  │  H=56dp, inputType=number
│  ║  │ 000.000.000-00              │  ║  │  mask aplicada
│  ║  └─────────────────────────────┘  ║  │
│  ║  [erro aqui se inválido]          ║  │  13sp error-color, role=alert
│  ║                                   ║  │
│  ║  ┌─────────────────────────────┐  ║  │  H=48dp
│  ║  │    Confirmar Check-out      │  ║  │  primary button
│  ║  └─────────────────────────────┘  ║  │
│  ║  ┌─────────────────────────────┐  ║  │  H=48dp, text button
│  ║  │          Cancelar           │  ║  │  cor: on-surface-secondary
│  ║  └─────────────────────────────┘  ║  │
│  ╚════════════════════════════════════╝  │
└──────────────────────────────────────────┘
```

### Tela 4: Wizard Família (3 steps)

```
STEP 1/3 — Dados do Responsável
┌──────────────────────────────────────────┐
│ ← Cadastrar Família            Step 1/3  │  progress no title ou indicador
│  ══════════════○─────○─────────          │  step indicator
├──────────────────────────────────────────┤
│                                          │
│  Dados do Responsável                    │  H=24sp bold
│                                          │
│  Nome completo *                         │
│  ┌──────────────────────────────────────┐│  H=56dp
│  │ ex: Maria Silva                      ││
│  └──────────────────────────────────────┘│
│  CPF *                                   │
│  ┌──────────────────────────────────────┐│
│  │ 000.000.000-00                       ││  mask, inputType=number
│  └──────────────────────────────────────┘│
│  Telefone *                              │
│  ┌──────────────────────────────────────┐│
│  │ (11) 9 0000-0000                     ││
│  └──────────────────────────────────────┘│
│  E-mail                                  │
│  ┌──────────────────────────────────────┐│
│  └──────────────────────────────────────┘│
│                                          │
│  ┌──────────────────────────────────────┐│  H=56dp
│  │          Próximo →                   ││
│  └──────────────────────────────────────┘│
└──────────────────────────────────────────┘

STEP 2/3 — Dados da Criança
[similar — nome, nascimento, CPF, observações de saúde iniciais]

STEP 3/3 — Revisão + Confirmação
[resumo dos dados — botão "Cadastrar Família"]
```

---

## Hi-Fi Spec — Component 1: `ChildListTile`

### Descrição
Card de criança na lista principal. Suporta 3 estados de presença: `checkedIn`, `checkedOut`, `pending`.

### Props / State
```dart
// Props
final Child child;
final AttendanceStatus status;       // checkedIn | checkedOut | pending
final String? primaryResponsible;
final VoidCallback onTap;
final VoidCallback? onCheckinTap;    // null = oculta ação rápida
final bool showQuickAction;          // default: true (company/collaborator)
```

### Variantes Visuais
| Variante | Background | Borda esquerda | Badge | Ação rápida |
|----------|-----------|----------------|-------|-------------|
| `checkedIn` | `checkin-bg (#E8F5E9)` | 4dp `secondary (#388E3C)` | "● Presente" verde | "Fazer checkout" |
| `checkedOut` | `surface (#FFF)` | 4dp `neutral-200` | "○ Ausente" cinza | "Fazer check-in" |
| `pending` | `checkout-bg (#FFF8E1)` | 4dp `warning (#E65100)` | "⚑ Pendente" laranja | — |

### Dimensões
- Height: `min 80dp` (touch target mínimo garantido)
- Horizontal padding: `16dp`
- Avatar: `40×40dp`, radius=full
- Fonte nome: `17sp / weight 600`
- Fonte responsável: `13sp / weight 400 / on-surface-secondary`
- Borda esquerda: `4dp solid`
- Radius card: `12dp`
- Margin vertical: `4dp`

### Estados de interação (SKILL.md §2: press-feedback)
- **Resting**: shadow-sm, surface/checkin-bg
- **Pressed**: opacity 0.92, scale 0.98 (120ms ease-in)
- **Focused (teclado)**: outline 2dp primary, offset 2dp

### Badge de Alerta de Saúde
Quando `child.healthInfo` contém dados críticos (alergias, medicamentos):
- Ícone `⚕` 16dp laranja em canto superior direito
- Tooltip/Semantics: "Possui informações de saúde — toque para ver"
- NUNCA depender só da cor (SKILL.md §1: color-not-only)

### Snippet Flutter
```dart
class ChildListTile extends StatelessWidget {
  const ChildListTile({
    super.key,
    required this.child,
    required this.status,
    this.primaryResponsible,
    required this.onTap,
    this.onQuickActionTap,
    this.showQuickAction = true,
  });

  final Child child;
  final AttendanceStatus status;
  final String? primaryResponsible;
  final VoidCallback onTap;
  final VoidCallback? onQuickActionTap;
  final bool showQuickAction;

  Color get _borderColor => switch (status) {
    AttendanceStatus.checkedIn  => const Color(0xFF388E3C),
    AttendanceStatus.checkedOut => const Color(0xFFDDE2ED),
    AttendanceStatus.pending    => const Color(0xFFE65100),
  };

  Color get _bgColor => switch (status) {
    AttendanceStatus.checkedIn  => const Color(0xFFE8F5E9),
    AttendanceStatus.checkedOut => Colors.white,
    AttendanceStatus.pending    => const Color(0xFFFFF8E1),
  };

  @override
  Widget build(BuildContext context) {
    final hasHealthAlert = child.healthInfo != null &&
        !(child.healthInfo!.isEmpty);

    return Semantics(
      label: '${child.name}, ${_statusLabel}. '
             '${hasHealthAlert ? "Possui informações de saúde." : ""}',
      button: true,
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 4),
        color: _bgColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            constraints: const BoxConstraints(minHeight: 80),
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(color: _borderColor, width: 4),
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(children: [
                _Avatar(name: child.name),
                const SizedBox(width: 12),
                Expanded(child: _Info(
                  name: child.name,
                  responsible: primaryResponsible,
                  status: status,
                )),
                if (hasHealthAlert)
                  _HealthBadge(),
                if (showQuickAction && onQuickActionTap != null)
                  _QuickActionButton(
                    status: status,
                    onTap: onQuickActionTap!,
                  ),
              ]),
            ),
          ),
        ),
      ),
    );
  }

  String get _statusLabel => switch (status) {
    AttendanceStatus.checkedIn  => 'Presente',
    AttendanceStatus.checkedOut => 'Ausente',
    AttendanceStatus.pending    => 'Pendente',
  };
}
```

---

## Hi-Fi Spec — Component 2: `CheckinBottomSheet`

### Descrição
Bottom sheet acionada ao tocar em uma criança. Exibe alerta de saúde (se houver), seleção de responsável e campo de observações. Executa POST `/v2/attendance/checkin`.

### Props / State
```dart
// Props
final Child child;
final List<Parent> availableParents;
final String collaboratorId;
final String companyId;
final Future<void> Function(CheckinPayload) onConfirm;

// State interno
String? selectedParentId;      // null = botão desabilitado
String notes = '';
bool isLoading = false;
String? errorMessage;
```

### Payload para o backend
```json
POST /v2/attendance/checkin
Authorization: Bearer <Firebase ID Token>
Content-Type: application/json

{
  "childId": "string",
  "collaboratorId": "string",
  "companyId": "string",
  "parentId": "string",
  "notes": "string (opcional)",
  "type": "checkin"
}
```

### Estados do componente
| Estado | UI |
|--------|----|
| `idle` | Formulário editável, botão habilitado se parentId selecionado |
| `loading` | Botão desabilitado + CircularProgressIndicator dentro do botão |
| `error-network` | Banner vermelho: "Sem conexão. [Tentar novamente]" |
| `error-validation` | Texto vermelho abaixo do campo problemático |
| `success` | Sheet fecha + SnackBar "✓ Check-in registrado para Ana Silva" |

### Microcopy
- Título: **"Check-in"**
- Selecionar responsável label: "Quem está trazendo a criança?"
- Botão confirmar (desabilitado): "Selecione o responsável"
- Botão confirmar (habilitado): "Confirmar Check-in"
- Loading: "Registrando..."
- Erro de rede: "Falha na conexão. Verifique o Wi-Fi e tente novamente."
- Sucesso: "Check-in de Ana Silva registrado às 08:02"
- Alerta de saúde: "⚠️ Atenção: esta criança possui informações de saúde importantes."

### Dimensões / Layout
- Border-radius top: `16dp`
- Drag handle: `32×4dp`, `neutral-300`, centered, margin-top `8dp`
- Padding interno: `16dp` horizontal, `24dp` bottom (+ safe area)
- Alerta de saúde: background `#FFF8E1`, border `#FFB300 1dp`, radius `8dp`, padding `12dp`
- RadioListTile responsável: height `56dp`, touch target OK
- TextField observações: height `80dp`, maxLines `3`
- Botão confirmar: height `56dp`, radius `12dp`, full-width

### Snippet Flutter
```dart
Future<void> showCheckinSheet(
  BuildContext context, {
  required Child child,
  required List<Parent> parents,
  required CheckinService service,
}) async {
  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => DraggableScrollableSheet(
      initialChildSize: 0.75,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      builder: (_, scrollCtrl) => _CheckinSheetContent(
        child: child,
        parents: parents,
        service: service,
        scrollController: scrollCtrl,
      ),
    ),
  );
}

class _CheckinSheetContent extends StatefulWidget { /* ... */ }

class _CheckinSheetContentState extends State<_CheckinSheetContent> {
  String? _parentId;
  final _notesCtrl = TextEditingController();
  bool _loading = false;
  String? _error;

  Future<void> _submit() async {
    if (_parentId == null) return;
    setState(() { _loading = true; _error = null; });
    try {
      await widget.service.checkin(CheckinPayload(
        childId: widget.child.id!,
        parentId: _parentId!,
        notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
      ));
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Check-in de ${widget.child.name} registrado.'),
          backgroundColor: const Color(0xFF388E3C),
          behavior: SnackBarBehavior.floating,
        ));
      }
    } on NetworkException {
      setState(() => _error = 'Falha na conexão. Verifique o Wi-Fi e tente novamente.');
    } catch (e) {
      setState(() => _error = 'Erro inesperado. Tente novamente.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) => Container(
    decoration: const BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    child: Column(children: [
      _DragHandle(),
      _SheetHeader(title: 'Check-in', onClose: () => Navigator.pop(context)),
      Expanded(child: ListView(
        controller: widget.scrollController,
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        children: [
          if (widget.child.healthInfo != null && !widget.child.healthInfo!.isEmpty)
            _HealthAlertBanner(healthInfo: widget.child.healthInfo!),
          _ParentSelector(
            parents: widget.parents,
            selectedId: _parentId,
            onChanged: (id) => setState(() => _parentId = id),
          ),
          const SizedBox(height: 16),
          _NotesField(controller: _notesCtrl),
          if (_error != null) ...[
            const SizedBox(height: 8),
            _ErrorBanner(message: _error!, onRetry: _submit),
          ],
          const SizedBox(height: 24),
          _ConfirmButton(
            label: _parentId == null ? 'Selecione o responsável' : 'Confirmar Check-in',
            enabled: _parentId != null && !_loading,
            loading: _loading,
            onPressed: _submit,
          ),
        ],
      )),
    ]),
  );
}
```

---

## Hi-Fi Spec — Component 3: `CpfConfirmationDialog` (Checkout)

### Descrição
Dialog modal que aparece ANTES de confirmar o checkout. Exige CPF do responsável. Regra de negócio do backend — não alterar.

### Props / State
```dart
// Props
final Child child;
final Parent responsible;
final Future<bool> Function(String cpf) onValidate;
final VoidCallback onConfirmed;

// State interno
final TextEditingController _cpfCtrl;
bool isLoading = false;
String? errorMessage;
bool cpfVisible = false;
```

### Payload para o backend
```json
POST /v2/attendance/checkout
Authorization: Bearer <Firebase ID Token>
Content-Type: application/json

{
  "attendanceId": "string",
  "collaboratorId": "string",
  "parentId": "string",
  "parentDocument": "000.000.000-00",  ← CPF confirmado
  "notes": "string (opcional)"
}
```

### Estados do Dialog
| Estado | UI |
|--------|----|
| `idle` | Campo CPF vazio, botão confirmar desabilitado |
| `typing` | Mask aplicada, botão habilitado após 14 chars (000.000.000-00) |
| `loading` | Spinner no botão, campo readOnly |
| `error-cpf` | "CPF incorreto. Verifique e tente novamente." abaixo do campo |
| `error-network` | Banner "Falha de conexão. [Tentar novamente]" |
| `success` | Dialog fecha + SnackBar laranja "✓ Checkout de Ana Silva confirmado" |

### Microcopy crítica
- Título: **"Confirmação de Saída"**
- Subtítulo: "Confirme o CPF do responsável para concluir o checkout de **Ana Silva**."
- Label do campo: "CPF do responsável"
- Hint: "000.000.000-00"
- Botão confirmar: "Confirmar Saída"
- Botão cancelar: "Cancelar"
- Erro CPF: "CPF não confere com o cadastro. Verifique e tente novamente."
- Erro rede: "Sem conexão. Verifique o Wi-Fi."
- Sucesso: "Saída de Ana Silva confirmada às 17:32."

### Dimensões
- Width: `min(343dp, 100% - 32dp)`
- Radius: `16dp`
- Padding: `24dp`
- Campo CPF: `56dp` height, `56dp` touch target
- Botão confirmar: `48dp` height, radius `12dp`
- Gap entre botões: `8dp` — SKILL.md §2: touch-spacing

### Snippet Flutter
```dart
Future<void> showCpfConfirmationDialog(
  BuildContext context, {
  required Child child,
  required Parent responsible,
  required CheckoutService service,
  required String attendanceId,
}) async {
  await showDialog(
    context: context,
    barrierDismissible: false,  // obrigatório confirmar ou cancelar
    builder: (ctx) => _CpfDialog(
      child: child,
      responsible: responsible,
      onConfirm: (cpf) async {
        await service.checkout(CheckoutPayload(
          attendanceId: attendanceId,
          parentId: responsible.id!,
          parentDocument: cpf,
        ));
      },
    ),
  );
}

class _CpfDialog extends StatefulWidget { /* ... */ }

class _CpfDialogState extends State<_CpfDialog> {
  final _cpfCtrl = TextEditingController();
  bool _loading = false;
  String? _error;

  String get _rawCpf => _cpfCtrl.text.replaceAll(RegExp(r'[^\d]'), '');
  bool get _isComplete => _rawCpf.length == 11;

  Future<void> _confirm() async {
    if (!_isComplete) return;
    setState(() { _loading = true; _error = null; });
    try {
      await widget.onConfirm(_rawCpf);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Saída de ${widget.child.name} confirmada.'),
          backgroundColor: const Color(0xFFE65100),
          behavior: SnackBarBehavior.floating,
        ));
      }
    } on InvalidDocumentException {
      setState(() => _error = 'CPF não confere. Verifique e tente novamente.');
      // SKILL.md §8: focus-management — focar no campo com erro
      FocusScope.of(context).requestFocus(_cpfFocusNode);
    } on NetworkException {
      setState(() => _error = 'Sem conexão. Verifique o Wi-Fi.');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    contentPadding: const EdgeInsets.all(24),
    title: const Text('Confirmação de Saída',
      style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),
    content: Column(mainAxisSize: MainAxisSize.min, children: [
      // Subtítulo com nome em bold
      RichText(text: TextSpan(
        style: const TextStyle(fontSize: 15, color: Color(0xFF495267), height: 1.5),
        children: [
          const TextSpan(text: 'Confirme o CPF do responsável para concluir o checkout de '),
          TextSpan(text: widget.child.name ?? 'a criança',
            style: const TextStyle(fontWeight: FontWeight.w600)),
          const TextSpan(text: '.'),
        ],
      )),
      const SizedBox(height: 8),
      // Responsável
      Text('Responsável: ${widget.responsible.name ?? '-'}',
        style: const TextStyle(fontSize: 13, color: Color(0xFF9AA3B5))),
      const SizedBox(height: 20),
      // Campo CPF
      Semantics(
        label: 'CPF do responsável, campo obrigatório',
        child: TextFormField(
          controller: _cpfCtrl,
          focusNode: _cpfFocusNode,
          keyboardType: TextInputType.number,
          inputFormatters: [CpfInputFormatter()],   // máscara 000.000.000-00
          decoration: InputDecoration(
            labelText: 'CPF do responsável *',
            hintText: '000.000.000-00',
            border: const OutlineInputBorder(),
            errorText: _error,                       // SKILL.md §8: error-placement
          ),
          onChanged: (_) => setState(() => _error = null),
        ),
      ),
    ]),
    actions: [
      // SKILL.md §8: destructive-emphasis — cancelar subordinado ao confirmar
      TextButton(
        onPressed: _loading ? null : () => Navigator.pop(context),
        child: const Text('Cancelar'),
      ),
      FilledButton(
        onPressed: (_isComplete && !_loading) ? _confirm : null,
        child: _loading
          ? const SizedBox(width: 20, height: 20,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
          : const Text('Confirmar Saída'),
      ),
    ],
  );
}
```

---

## Hi-Fi Spec — Component 4: `HealthInfoAlertBanner`

### Descrição
Banner compacto mostrado no topo do modal de check-in e no profile da criança. Garante que dados críticos de saúde não sejam ignorados.

### Regra de exibição
Mostrar se `child.healthInfo != null && !child.healthInfo!.isEmpty`

### Variantes
| Variante | Contexto | Comportamento |
|----------|---------|---------------|
| `compact` | Modal check-in | Altura fixa ~60dp, mostra apenas tipos de dado presentes (ex: "Alergia · Medicamento") |
| `expanded` | Profile da criança | Card completo com todas as categorias e chips |

### Microcopy
- Compact: "⚕ Atenção: Alergia a amendoim · Medicamento: Ritalina"
- Expanded: "Cuidados Médicos — toque para expandir"
- Sem dados: não exibir nada (nunca mostrar "Sem informações")

### Snippet Flutter (variant compact)
```dart
class HealthInfoAlertBanner extends StatelessWidget {
  const HealthInfoAlertBanner({super.key, required this.healthInfo, this.compact = false});
  final ChildHealthInfo healthInfo;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    if (healthInfo.isEmpty) return const SizedBox.shrink();

    final parts = <String>[
      if ((healthInfo.allergies ?? []).isNotEmpty)
        'Alergia: ${healthInfo.allergies!.join(", ")}',
      if ((healthInfo.medications ?? []).isNotEmpty)
        'Medicamento: ${healthInfo.medications!.map((m) => m.name).join(", ")}',
      if ((healthInfo.dietaryRestrictions ?? []).isNotEmpty)
        'Restrição alimentar: ${healthInfo.dietaryRestrictions!.join(", ")}',
    ];

    if (parts.isEmpty && !compact) return const SizedBox.shrink();

    return Semantics(
      label: 'Alerta de saúde: ${parts.join(". ")}',
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFFFF8E1),
          border: Border.all(color: const Color(0xFFFFB300)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Icon(Icons.health_and_safety, color: Color(0xFFE65100), size: 20),
          const SizedBox(width: 8),
          Expanded(child: Text(
            compact ? parts.join(' · ') : parts.join('\n'),
            style: const TextStyle(fontSize: 13, color: Color(0xFF303649), height: 1.4),
          )),
        ]),
      ),
    );
  }
}
```

---

## Hi-Fi Spec — Component 5: `FamilyRegistrationWizard`

### Descrição
Wizard de 3 passos que cria pai + filho em sequência, substituindo os 3 fluxos separados atuais.

### Props
```dart
final String companyId;
final VoidCallback onCompleted;
```

### Steps
| Step | Dados coletados | Endpoint chamado |
|------|----------------|-----------------|
| 1/3 — Responsável | nome, CPF, telefone, email | `POST /v2/parents` → guarda `parentId` |
| 2/3 — Criança | nome, nascimento, CPF, observações saúde iniciais | `POST /v2/children` (com `parentId` e `companyId`) |
| 3/3 — Revisão | Exibe tudo, permite editar cada seção | Nada — só confirmação |

### Estado de erro por step
- Se API falhar no step 1: "Falha ao cadastrar responsável. [Tentar novamente]" — NÃO avança para step 2
- Se API falhar no step 2: "Falha ao cadastrar criança. [Tentar novamente]" — mantém dados do step 1 intactos

### Indicador de progresso
```
Step 1:  ●──────○──────○   Responsável
Step 2:  ●──────●──────○   Criança
Step 3:  ●──────●──────●   Revisão
```
Height: `4dp`, colores: active=primary, inactive=neutral-200

### Payload Step 1 (POST /v2/parents)
```json
{
  "name": "string",
  "document": "string (CPF sem máscara)",
  "contact": "string (telefone)",
  "email": "string (opcional)",
  "companyId": "string"
}
```

### Payload Step 2 (POST /v2/children)
```json
{
  "name": "string",
  "birthDate": "YYYY-MM-DD",
  "document": "string (opcional)",
  "companyId": "string",
  "parents": ["parentId-do-step-1"],
  "healthInfo": {
    "allergies": [],
    "dietaryRestrictions": [],
    "medications": [],
    "medicalConditions": [],
    "fearsOrSensitivities": []
  }
}
```

---

## Protótipo do Fluxo Crítico (Descrição Interativa)

### Fluxo: Check-in → Check-out → Histórico

```
[TELA LISTA DE CRIANÇAS]
   │
   ├─ Toque em "Ana Silva (Ausente)"
   │         ↓ [Animação: bottom sheet sobe - 300ms ease-out]
   │
   [BOTTOM SHEET: CHECK-IN]
   │  ⚕ Alerta de saúde visível imediatamente (se houver)
   │  Seleciona responsável via RadioListTile
   │  Campo observações (opcional)
   │  Botão "Confirmar Check-in" → loading → fecha sheet
   │         ↓ [SnackBar verde 3s, floating]
   │
   [TELA LISTA — "Ana Silva" agora "● Presente"]
   │  Badge verde, borda esquerda verde
   │         
   ├─ Toque em "Ana Silva (Presente)" → mesma bottom sheet
   │  mas agora mostra botão "Fazer Checkout"
   │  Toca "Fazer Checkout"
   │         ↓ [Animação: Dialog aparece com scale+fade - 200ms]
   │
   [DIALOG: CONFIRMAÇÃO CPF]
   │  "Confirme o CPF do responsável"
   │  Campo CPF com máscara
   │  Digitação → botão habilita com 11 dígitos
   │  Confirmar → loading → fecha dialog
   │         ↓ [SnackBar laranja 3s]
   │
   [TELA LISTA — "Ana Silva" volta a "○ Ausente"]
   │
   └─ Tab "Relatórios" → histórico filtrado por data/período
```

### Estados de Rede
```
[OFFLINE / TIMEOUT]
┌──────────────────────────────────────────┐
│ ⚠️  Sem conexão com a internet           │  Cor: error-surface, sticky top
│     Alguns dados podem estar desatualizados  │  height=40dp
│                          [Reconectar]    │  botão retry
└──────────────────────────────────────────┘
```

---

## Handoff Técnico — Integração Firebase

### Fluxo de autenticação (não alterar)
```dart
// Toda requisição ao backend deve incluir:
final user = FirebaseAuth.instance.currentUser;
final token = await user?.getIdToken(forceRefresh: false);

// No ApiClient (já implementado):
headers['Authorization'] = 'Bearer $token';

// Refresh automático: Firebase ID tokens expiram em 1h.
// O SDK Flutter renova automaticamente via getIdToken().
// NÃO armazenar o token em SharedPreferences/local storage.
```

### Checklist de integração
- [ ] `firebase_auth` inicializado em `main()` antes de `runApp()`
- [ ] `ApiClient` usa `getIdToken(forceRefresh: false)` — já implementado
- [ ] Tratar `FirebaseAuthException` com código `token-expired` → redirecionar para login
- [ ] Tratar HTTP 401 do backend → chamar `getIdToken(forceRefresh: true)` e retry 1x
- [ ] Tratar HTTP 403 → exibir "Sem permissão para esta ação"
- [ ] Timeout de requisição: `30s` — exibir mensagem de retry ao usuário
- [ ] Requerer campos obrigatórios antes do submit (validação client-side)
- [ ] NUNCA enviar CPF em query params — sempre no body (POST)
