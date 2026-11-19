part of '../horarios_screen.dart';

/// The sheet for [person]'s [day]: what it is, what the file says and who
/// changed it; for editors, the codes to change it to, a swap with someone
/// else that day, and putting the file's back.
Future<void> _openDaySheet(
  BuildContext context,
  _HorarioView view,
  Person person,
  DateTime day,
) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => _DaySheet(view: view, person: person, day: day),
  );
}

class _DaySheet extends StatefulWidget {
  const _DaySheet({
    required this.view,
    required this.person,
    required this.day,
  });

  final _HorarioView view;
  final Person person;
  final DateTime day;

  @override
  State<_DaySheet> createState() => _DaySheetState();
}

class _DaySheetState extends State<_DaySheet> {
  bool _busy = false;

  HorarioService get _service => HorarioService.instance;

  Future<void> _run(Future<void> Function(String by) action) async {
    setState(() => _busy = true);
    final navigator = Navigator.of(context);
    await action(await horarioAuthorName());
    navigator.pop();
  }

  Future<void> _set(String code, {int? entrada, int? saida}) => _run(
    (by) => _service.change(
      widget.person,
      widget.day,
      code,
      entrada: entrada,
      saida: saida,
      by: by,
    ),
  );

  Future<void> _otherCode() async {
    final known = _service.index.monthCovering(widget.day)?.codigos ?? {};
    final result = await showDialog<({String code, int? entrada, int? saida})>(
      context: context,
      builder: (_) => _OtherCodeDialog(known: known),
    );
    if (result == null) return;
    await _set(result.code, entrada: result.entrada, saida: result.saida);
  }

  /// A shift with no code: only its entrada and saída.
  Future<void> _hoursOnly() async {
    final result = await showDialog<({String code, int? entrada, int? saida})>(
      context: context,
      builder: (_) => const _OtherCodeDialog(known: {}, hoursOnly: true),
    );
    if (result == null) return;
    await _set(result.code, entrada: result.entrada, saida: result.saida);
  }

  Future<void> _swap() async {
    final view = widget.view;
    final others = [
      for (final l in view.index.linesOn(widget.day, people: view.people))
        if (view.people[l.linha.personId] case final p?)
          if (p.syncUuid != widget.person.syncUuid) (person: p, dia: l.dia),
    ]..sort((a, b) => a.person.fullName.compareTo(b.person.fullName));
    final other = await showDialog<Person>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Trocar com…'),
        children: [
          for (final o in others)
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, o.person),
              child: Text('${o.person.fullName} · ${o.dia?.text ?? '—'}'),
            ),
        ],
      ),
    );
    if (other == null) return;
    await _run((by) => _service.swap(widget.person, other, widget.day, by: by));
  }

  @override
  Widget build(BuildContext context) {
    final view = widget.view;
    final index = _service.index;
    final now = index.dayOf(widget.person, widget.day);
    final file = index.fileDayOf(widget.person, widget.day);
    final base = index.baseDayOf(widget.person, widget.day);
    final changed = now?.changed;
    final usage = index.codeUsage(widget.day).entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final codigos = index.monthCovering(widget.day)?.codigos ?? {};
    final title =
        '${widget.person.fullName} · '
        '${DateFormat('EEE, d MMM', 'pt_PT').format(widget.day)}';

    Widget chip(String code, String label) => ChoiceChip(
      key: ValueKey('code-$code'),
      label: Text(label),
      selected: now?.code == code,
      onSelected: _busy ? null : (_) => _set(code),
    );

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            Text('Agora: ${_describe(now)}'),
            Text(
              'No ficheiro: ${_describe(file)}',
              style: TextStyle(color: context.muted),
            ),
            if (base != null && base.fromProfile)
              Text(
                'Perfil: ${_describe(base)}',
                style: TextStyle(color: context.muted),
              ),
            if (changed != null)
              Text(
                'Alterado por ${changed.changedBy.isEmpty ? '—' : changed.changedBy}'
                ' a ${DateFormat('d/M, HH:mm', 'pt_PT').format(changed.changedAt)}',
                style: TextStyle(color: context.warningText),
              ),
            if (view.canEdit) ...[
              const SizedBox(height: 16),
              const Text(
                'Turnos',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final e in usage)
                    chip(
                      e.key,
                      '${e.key} · ${HorarioDia(date: widget.day, code: e.key, entrada: codigos[e.key]!.entrada, saida: codigos[e.key]!.saida).text}',
                    ),
                ],
              ),
              const SizedBox(height: 12),
              const Text('Fora', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  for (final code in const ['FO', 'F', 'A', 'LP'])
                    chip(code, '$code · ${horarioOffCodes[code]}'),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  OutlinedButton.icon(
                    icon: const Icon(Icons.edit_outlined),
                    label: const Text('Outro código'),
                    onPressed: _busy ? null : _otherCode,
                  ),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.schedule),
                    label: const Text('Só horas'),
                    onPressed: _busy ? null : _hoursOnly,
                  ),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.swap_horiz),
                    label: const Text('Trocar com…'),
                    onPressed: _busy ? null : _swap,
                  ),
                  if (changed != null)
                    TextButton.icon(
                      icon: const Icon(Icons.undo),
                      label: const Text('Repor o do ficheiro'),
                      onPressed: _busy
                          ? null
                          : () => _run(
                              (_) => _service.revert(widget.person, widget.day),
                            ),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// "G82 · 06:00–15:00", "09:00–18:00" (hours only) or "nada".
String _describe(HorarioDia? d) => d == null
    ? 'nada'
    : d.code.isEmpty
    ? d.text
    : '${d.code} · ${d.text}';

/// Asks for a code; for a shift code the month doesn't know, its entrada
/// and saída too. With [hoursOnly], only the entrada and saída.
class _OtherCodeDialog extends StatefulWidget {
  const _OtherCodeDialog({required this.known, this.hoursOnly = false});

  final Map<String, ({int entrada, int saida})> known;
  final bool hoursOnly;

  @override
  State<_OtherCodeDialog> createState() => _OtherCodeDialogState();
}

class _OtherCodeDialogState extends State<_OtherCodeDialog> {
  final _code = TextEditingController();
  final _entrada = TextEditingController();
  final _saida = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _code.dispose();
    _entrada.dispose();
    _saida.dispose();
    super.dispose();
  }

  String get _normalized => normalizeHorarioCode(_code.text);

  /// A code the app knows (its hours or an off code) needs no hours.
  bool get _needsHours {
    if (widget.hoursOnly) return true;
    final c = _normalized;
    return c.isNotEmpty &&
        !widget.known.containsKey(c) &&
        !horarioOffCodes.containsKey(c) &&
        !ignoredOffCodes.contains(c);
  }

  int? _time(String text) {
    final m = RegExp(r'^(\d{1,2})[:h.]?([0-5]\d)?$').firstMatch(text.trim());
    if (m == null) return null;
    final h = int.parse(m.group(1)!);
    final min = int.parse(m.group(2) ?? '0');
    return h > 24 ? null : h * 60 + min;
  }

  void _ok() {
    final code = widget.hoursOnly ? '' : _normalized;
    if (code.isEmpty && !widget.hoursOnly) {
      setState(() => _error = 'Escreva o código.');
      return;
    }
    if (!_needsHours) {
      Navigator.pop(context, (code: code, entrada: null, saida: null));
      return;
    }
    final e = _time(_entrada.text);
    final s = _time(_saida.text);
    if (e == null || s == null) {
      setState(() => _error = 'Indique a entrada e a saída, como 07:00.');
      return;
    }
    Navigator.pop(context, (code: code, entrada: e, saida: s));
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(widget.hoursOnly ? 'Só horas' : 'Outro código'),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (!widget.hoursOnly)
          TextField(
            controller: _code,
            autofocus: true,
            textCapitalization: TextCapitalization.characters,
            decoration: const InputDecoration(labelText: 'Código (ex.: H73)'),
            onChanged: (_) => setState(() => _error = null),
          ),
        if (_needsHours) ...[
          const SizedBox(height: 8),
          Text(
            widget.hoursOnly
                ? 'Um turno sem código: indique a entrada e a saída.'
                : 'Código novo neste mês: indique as horas.',
            style: TextStyle(color: context.muted),
          ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _entrada,
                  autofocus: widget.hoursOnly,
                  keyboardType: TextInputType.datetime,
                  decoration: const InputDecoration(labelText: 'Entrada'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _saida,
                  keyboardType: TextInputType.datetime,
                  decoration: const InputDecoration(labelText: 'Saída'),
                ),
              ),
            ],
          ),
        ],
        if (_error != null) ...[
          const SizedBox(height: 8),
          Text(_error!, style: TextStyle(color: context.warningText)),
        ],
      ],
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Cancelar'),
      ),
      FilledButton(onPressed: _ok, child: const Text('Guardar')),
    ],
  );
}
