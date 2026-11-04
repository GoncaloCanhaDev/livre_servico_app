part of '../historico_screen.dart';

Future<bool> _confirmHardDelete(BuildContext context, String title) async {
  final ok = await showDialog<bool>(
    context: context,
    builder: (dialogCtx) => AlertDialog(
      title: Text(title),
      content: const Text(
        'Vai apagar permanentemente todos os registos. Esta ação não pode ser desfeita.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogCtx, false),
          child: const Text('Cancelar'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(dialogCtx, true),
          child: const Text('Apagar tudo', style: TextStyle(color: Colors.red)),
        ),
      ],
    ),
  );
  return ok == true;
}

Future<bool> _confirmDelete(BuildContext context, String what) async {
  final ok = await showDialog<bool>(
    context: context,
    builder: (dialogCtx) => AlertDialog(
      title: Text('Apagar $what?'),
      content: const Text('Esta ação não pode ser desfeita.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogCtx, false),
          child: const Text('Cancelar'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(dialogCtx, true),
          child: const Text('Apagar', style: TextStyle(color: Colors.red)),
        ),
      ],
    ),
  );
  return ok == true;
}

Widget _emptyMsg(String msg) => Center(
  child: Padding(
    padding: const EdgeInsets.all(24),
    child: Builder(
      builder: (context) => Text(
        msg,
        textAlign: TextAlign.center,
        style: TextStyle(color: context.muted),
      ),
    ),
  ),
);

/// The Histórico search text, read by every tab below it.
class _HistoricoQuery extends InheritedNotifier<ValueNotifier<String>> {
  const _HistoricoQuery({
    required ValueNotifier<String> query,
    required super.child,
  }) : super(notifier: query);

  static String of(BuildContext context) =>
      context
          .dependOnInheritedWidgetOfExactType<_HistoricoQuery>()
          ?.notifier
          ?.value ??
      '';
}

/// [items] whose [text] matches [query] (see [matchesQuery]).
List<T> _searched<T>(String query, List<T> items, String Function(T) text) =>
    query.trim().isEmpty
    ? items
    : [
        for (final e in items)
          if (matchesQuery(text(e), query)) e,
      ];

/// [msg] when nothing is saved, "Sem resultados." while searching.
Widget _emptyOr(String query, String msg) =>
    _emptyMsg(query.trim().isEmpty ? msg : 'Sem resultados.');

/// For a Histórico tab: a change in its data reloads it only while it is the
/// open tab; otherwise the change is remembered and the tab reloads when it
/// is opened. Services call [_changed]; the tab implements [_reload].
mixin _ReloadWhenOpen<T extends StatefulWidget> on State<T> {
  /// This tab's position in the Histórico tabs.
  int get tabIndex;

  void _reload();

  TabController? _tabs;
  bool _stale = false;

  bool get _isOpen => _tabs == null || _tabs!.index == tabIndex;

  void _changed() {
    if (_isOpen) {
      _reload();
    } else {
      _stale = true;
    }
  }

  void _tabChanged() {
    if (_stale && _isOpen) {
      _stale = false;
      _reload();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final tabs = DefaultTabController.maybeOf(context);
    if (tabs != _tabs) {
      _tabs?.removeListener(_tabChanged);
      _tabs = tabs?..addListener(_tabChanged);
    }
  }

  @override
  void dispose() {
    _tabs?.removeListener(_tabChanged);
    super.dispose();
  }
}

/// What a day's Diárias take from Listas 2.0, for every day at once: the
/// Visíveis (Lista Visível is done with one) and how many Automáticas were
/// sent (only counted).
class _Listas2ByDay {
  _Listas2ByDay._(this._visiveis, this._autoCounts);

  static Future<_Listas2ByDay> load() async {
    final visiveis = <DateTime, List<Visivel2Entry>>{};
    for (final v in await Visivel2Service.instance.history()) {
      (visiveis[v.serviceDay] ??= []).add(v);
    }
    final autos = <DateTime, int>{};
    for (final a in await Auto2Service.instance.history()) {
      final day = currentServiceDay(a.createdAt);
      autos[day] = (autos[day] ?? 0) + 1;
    }
    return _Listas2ByDay._(visiveis, autos);
  }

  final Map<DateTime, List<Visivel2Entry>> _visiveis;
  final Map<DateTime, int> _autoCounts;

  List<Visivel2Entry> visiveis(DateTime day) => _visiveis[day] ?? const [];
  int autoCount(DateTime day) => _autoCounts[day] ?? 0;
}

enum _ItemType {
  truck,
  opening,
  auto,
  auto2,
  report,
  visual,
  visivel2,
  tasks,
  inventory,
}

class _HistoryInitials extends StatelessWidget {
  const _HistoryInitials({required this.names});
  final List<String> names;

  @override
  Widget build(BuildContext context) {
    if (names.isEmpty) return const SizedBox.shrink();
    return Tooltip(
      message: joinNames(names),
      child: PersonInitialsRow(names: names, size: 28),
    );
  }
}

class _BackdatedRow extends StatelessWidget {
  const _BackdatedRow();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.history_toggle_off, size: 12, color: context.faint),
          SizedBox(width: 4),
          Text(
            'Preenchido a posteriori',
            style: TextStyle(fontSize: 11, color: context.faint),
          ),
        ],
      ),
    );
  }
}

Widget _dimmedIfDeleted({required bool deleted, required Widget child}) {
  if (!deleted) return child;
  return IgnorePointer(child: Opacity(opacity: 0.4, child: child));
}

Widget _trailingWithInitials(String? initials, Widget child) => child;

class _DayItem {
  _DayItem({
    required this.type,
    required this.time,
    required this.title,
    required this.subtitle,
    this.icon = Icons.circle,
    this.iconColor,
    this.names = const [],
    this.deleted = false,
  });
  final _ItemType type;
  final DateTime time;
  final String title;
  final String subtitle;
  final IconData icon;

  /// The theme's primary colour when null.
  final Color? iconColor;
  final List<String> names;
  final bool deleted;
}

class _HistoryDismissible extends StatelessWidget {
  const _HistoryDismissible({
    required this.itemKey,
    required this.child,
    required this.onDelete,
    required this.onSendWhatsApp,
    required this.deletePromptName,
  });

  final Key itemKey;
  final Widget child;
  final Future<void> Function() onDelete;
  final Future<void> Function(BuildContext) onSendWhatsApp;
  final String deletePromptName;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () {
        showModalBottomSheet(
          context: context,
          builder: (ctx) => SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: Icon(Icons.send, color: context.colors.primary),
                  title: const Text('Enviar por WhatsApp'),
                  onTap: () async {
                    Navigator.pop(ctx);
                    await onSendWhatsApp(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title: Text('Apagar $deletePromptName'),
                  onTap: () async {
                    Navigator.pop(ctx);
                    if (await _confirmDelete(context, deletePromptName)) {
                      await onDelete();
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
      child: child,
    );
  }
}
