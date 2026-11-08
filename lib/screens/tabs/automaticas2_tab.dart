import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../../models/auto2_entry.dart';
import '../../models/opening_list.dart';
import '../../services/auto2_service.dart';
import '../../services/settings_service.dart';
import '../../services/whatsapp_service.dart';
import '../../theme.dart';
import '../widgets/person_picker.dart';

/// What is typed for each item: the artigos on its list, and of those how
/// many were left for later and how many were out of stock.
enum _Count {
  total(''),
  porTratar(':porTratar'),
  semStock(':semStock');

  const _Count(this.draftSuffix);
  final String draftSuffix;
}

/// Listas 2.0 → Automáticas, like 1.0's: each item is sent on its own once
/// done (who did it, then WhatsApp), saved to Histórico, and its fields
/// clear for the next one. The item is picked from chips, so its counts are
/// typed without scrolling; every count not yet sent is kept as a draft
/// ([SettingsService.draft]) until it is.
class Automaticas2Tab extends StatefulWidget {
  const Automaticas2Tab({super.key});

  @override
  State<Automaticas2Tab> createState() => _Automaticas2TabState();
}

class _Automaticas2TabState extends State<Automaticas2Tab> {
  final _ctrls = {
    for (final i in Auto2Item.values)
      for (final c in _Count.values)
        (i, c): TextEditingController(
          text: SettingsService.instance.draft(_key(i, c)),
        ),
  };
  late Auto2Item _selected = Auto2Item.values.firstWhere(
    (i) => _ctrls[(i, _Count.total)]!.text.isNotEmpty,
    orElse: () => Auto2Item.values.first,
  );

  static String _key(Auto2Item i, _Count c) =>
      'auto2:${i.name}${c.draftSuffix}';

  void _changed(Auto2Item i, _Count c) {
    SettingsService.instance.setDraft(_key(i, c), _ctrls[(i, c)]!.text);
    setState(() {});
  }

  @override
  void dispose() {
    for (final c in _ctrls.values) {
      c.dispose();
    }
    super.dispose();
  }

  int _get(Auto2Item i, [_Count c = _Count.total]) =>
      int.tryParse(_ctrls[(i, c)]!.text) ?? 0;

  int get _total => Auto2Item.values.fold(0, (sum, i) => sum + _get(i));

  /// Why [i] can't be sent yet, or null when it can.
  String? _problem(Auto2Item i) {
    final total = _get(i);
    if (total == 0) return null;
    if (_get(i, _Count.porTratar) > total) {
      return 'Por tratar não pode ser mais do que os artigos na lista.';
    }
    if (_get(i, _Count.semStock) > total) {
      return 'Sem stock não pode ser mais do que os artigos na lista.';
    }
    return null;
  }

  bool _canSend(Auto2Item i) => _get(i) > 0 && _problem(i) == null;

  Future<void> _send(Auto2Item item) async {
    if (!_canSend(item)) return;
    final value = _get(item);
    final porTratar = _get(item, _Count.porTratar);
    final semStock = _get(item, _Count.semStock);
    final today = currentServiceDay();
    final result = await pickPeopleAndDay(
      context,
      title: 'Quem fez ${item.label}?',
      subtitle:
          'Automáticas · ${item.label}: '
          '${auto2Summary(value, porTratar, semStock)}',
      initialDay: today,
    );
    if (result == null || !mounted) return;
    final names = result.people.map((p) => p.fullName).toList();
    final day = DateTime(result.day.year, result.day.month, result.day.day, 5);
    final isToday = day.isAtSameMomentAs(today);
    await Auto2Service.instance.send(
      item: item,
      value: value,
      porTratar: porTratar,
      semStock: semStock,
      names: names,
      serviceDay: isToday ? null : day,
    );
    if (!mounted) return;

    final dayNote = isToday
        ? ''
        : ' (${DateFormat("d 'de' MMMM", 'pt_PT').format(day)})';
    await WhatsAppService.sendWithConfirm(
      context,
      auto2Message(
        label: item.label,
        value: value,
        porTratar: porTratar,
        semStock: semStock,
        byNames: joinNames(names),
        dayNote: dayNote,
      ),
    );
    if (!mounted) return;
    setState(() {
      for (final c in _Count.values) {
        _ctrls[(item, c)]!.clear();
      }
    });
    for (final c in _Count.values) {
      await SettingsService.instance.setDraft(_key(item, c), '');
    }
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('${item.label} guardado.')));
  }

  Widget _field(String label, _Count c, {String? hint}) {
    final item = _selected;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontSize: 15)),
                if (hint != null)
                  Text(
                    hint,
                    style: TextStyle(fontSize: 12, color: context.muted),
                  ),
              ],
            ),
          ),
          SizedBox(
            width: 100,
            child: TextField(
              key: ValueKey('auto2:${c.name}'),
              controller: _ctrls[(item, c)],
              textAlign: TextAlign.center,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              style: TextStyle(
                fontSize: c == _Count.total ? 20 : 17,
                fontWeight: FontWeight.bold,
              ),
              decoration: const InputDecoration(
                hintText: '0',
                border: OutlineInputBorder(),
                isDense: true,
              ),
              onChanged: (_) => _changed(item, c),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Automáticas',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              'Escolhe a secção, escreve os artigos da lista (e quantos '
              'ficaram por tratar ou sem stock) e envia quando estiver feita. '
              'Os números ficam guardados até serem enviados.',
              style: TextStyle(fontSize: 12, color: context.muted),
            ),
          ),
          const SizedBox(height: 8),
          Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    _selected.label,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  _field('Artigos na lista', _Count.total),
                  _field(
                    'Por tratar',
                    _Count.porTratar,
                    hint: 'Ficaram para depois',
                  ),
                  _field('Sem stock', _Count.semStock),
                  if (_problem(_selected) case final problem?)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        problem,
                        style: TextStyle(color: context.colors.error),
                      ),
                    )
                  else if (_get(_selected) > 0)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        'Tratados: '
                        '${_get(_selected) - _get(_selected, _Count.porTratar)}'
                        ' de ${_get(_selected)}',
                        style: TextStyle(color: context.muted),
                      ),
                    ),
                  const SizedBox(height: 8),
                  FilledButton.icon(
                    icon: const Icon(Icons.send),
                    label: Text('Enviar ${_selected.label}'),
                    onPressed: _canSend(_selected)
                        ? () => _send(_selected)
                        : null,
                  ),
                ],
              ),
            ),
          ),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final i in Auto2Item.values)
                ChoiceChip(
                  label: Text(
                    _get(i) == 0 ? i.label : '${i.label} · ${_get(i)}',
                  ),
                  selected: i == _selected,
                  visualDensity: VisualDensity.compact,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  onSelected: (_) => setState(() => _selected = i),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Card(
            color: AppColors.black,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      letterSpacing: 1,
                    ),
                  ),
                  Text(
                    '$_total',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
