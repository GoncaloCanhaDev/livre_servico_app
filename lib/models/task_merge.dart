import 'dart:convert';

import 'auto_mark.dart';
import 'local_row.dart';

/// When a task was marked (feita or não feita, by hand or by the app) and
/// last corrected (confirmed, who did it changed, marked não feita in a
/// review, its number filled in), by the server's clock (`ServerClock`).
/// Kept per task key in `DailyTasks.taskStamps` / `WeeklyTasks.taskStamps`
/// (a custom task's entry has `doneAt` and `editedAt`): when two phones
/// marked the same day differently, [mergeTaskRows] keeps, task by task,
/// the right one instead of one phone's whole day.
class TaskStamp {
  TaskStamp({this.markedAt, this.editedAt});

  factory TaskStamp.fromJson(Map<String, dynamic> j) => TaskStamp(
    markedAt: dateFromJson(j['markedAt']),
    editedAt: dateFromJson(j['editedAt']),
  );

  /// Null on a task marked before 0.96.0: it counts as the earliest.
  DateTime? markedAt;
  DateTime? editedAt;

  Map<String, dynamic> toJson() => {
    'markedAt': dateToJson(markedAt),
    'editedAt': dateToJson(editedAt),
  };
}

/// [stamps] with a mark time [now] for each of [settled] that has none (a
/// task just marked) and none for a task no longer marked.
Map<String, TaskStamp> stampMarks(
  Map<String, TaskStamp> stamps,
  Iterable<String> settled,
  DateTime now,
) {
  final keep = settled.toSet();
  return {
    for (final e in stamps.entries)
      if (keep.contains(e.key)) e.key: e.value,
    for (final k in keep)
      if (!stamps.containsKey(k)) k: TaskStamp(markedAt: now),
  };
}

/// [stamps] with [key] corrected at [now] (see [TaskStamp.editedAt]).
Map<String, TaskStamp> stampEdit(
  Map<String, TaskStamp> stamps,
  String key,
  DateTime now,
) => {
  ...stamps,
  key: TaskStamp(markedAt: stamps[key]?.markedAt ?? now, editedAt: now),
};

Map<String, TaskStamp> taskStampMapFromJson(Object? v) => {
  if (v is Map)
    for (final e in v.entries)
      if (e.key is String && e.value is Map)
        e.key as String: TaskStamp.fromJson(
          Map<String, dynamic>.from(e.value as Map),
        ),
};

Map<String, dynamic> taskStampMapToJson(Map<String, TaskStamp> m) => {
  for (final e in m.entries) e.key: e.value.toJson(),
};

/// The JSON fields of each Diária, by task key: its done flag first, then
/// its names and its numbers. They travel together in a merge.
const dailyTaskFields = {
  'kiwi_abertura': ['kiwiAbertura', 'kiwiAberturaBy', 'kiwiAberturaByNames'],
  'alteracoes_preco': [
    'alteracoesPreco',
    'alteracoesPrecoBy',
    'alteracoesPrecoByNames',
    'alteracoesPrecoCount',
  ],
  'verificacao_temperaturas': [
    'verificacaoTemperaturas',
    'verificacaoTemperaturasBy',
    'verificacaoTemperaturasByNames',
  ],
  'preenchimento_quadro': [
    'preenchimentoQuadro',
    'preenchimentoQuadroBy',
    'preenchimentoQuadroByNames',
  ],
  'verificacao_validades': [
    'verificacaoValidades',
    'verificacaoValidadesBy',
    'verificacaoValidadesByNames',
    'verificacaoValidadesCount',
    'validadesManhaLeft',
    'validadesManhaCarried',
  ],
  'validades_noite': [
    'validadesNoite',
    'validadesNoiteByNames',
    'validadesNoiteCount',
    'validadesNoiteLeft',
    'validadesNoiteCarried',
  ],
  'kiwi_fecho': ['kiwiFecho', 'kiwiFechoBy', 'kiwiFechoByNames'],
};

const weeklyTaskFields = {
  'verificar_1a': [
    'verificar1a',
    'verificar1aBy',
    'verificar1aByNames',
    'verificar1aCount',
  ],
  'verificar_4a': [
    'verificar4a',
    'verificar4aBy',
    'verificar4aByNames',
    'verificar4aCount',
  ],
  'limpeza_maquina_voltas': [
    'limpezaMaquinaVoltas',
    'limpezaMaquinaVoltasBy',
    'limpezaMaquinaVoltasByNames',
  ],
};

/// One task of a row, as JSON, for [_winner].
class _Side {
  _Side(this.row, this.key, List<String> fields)
    : done = row[fields.first] == true,
      notDone = _map(row['notDone'])[key],
      auto = _map(row['autoMarks']).containsKey(key),
      stamp = switch (_map(row['taskStamps'])[key]) {
        final Map s => TaskStamp.fromJson(Map<String, dynamic>.from(s)),
        _ => TaskStamp(),
      };

  final Map<String, dynamic> row;
  final String key;
  final bool done;
  final Object? notDone;
  final bool auto;
  final TaskStamp stamp;

  bool get marked => done || notDone != null;

  /// When marked: the stamp, or a Não feita's own time.
  DateTime? get markedAt =>
      stamp.markedAt ??
      (notDone is Map ? dateFromJson((notDone as Map)['at']) : null);
}

Map<String, dynamic> _map(Object? v) =>
    v is Map ? Map<String, dynamic>.from(v) : <String, dynamic>{};

/// Which of two copies of a task wins:
/// 1. one marked beats one not marked;
/// 2. a correction beats none, and the latest correction wins;
/// 3. a mark by hand beats one by the app;
/// 4. the earliest mark wins (whoever really did it first).
/// Ties go to the copy whose JSON sorts first, so every phone picks the
/// same one. Null when neither is marked.
_Side? _winner(_Side a, _Side b) {
  if (!a.marked && !b.marked) return null;
  if (a.marked != b.marked) return a.marked ? a : b;
  final ea = a.stamp.editedAt;
  final eb = b.stamp.editedAt;
  if (ea != null || eb != null) {
    if (ea == null) return b;
    if (eb == null) return a;
    if (!ea.isAtSameMomentAs(eb)) return ea.isAfter(eb) ? a : b;
  }
  if (a.auto != b.auto) return a.auto ? b : a;
  final ma = a.markedAt;
  final mb = b.markedAt;
  if (ma == null && mb != null) return a;
  if (mb == null && ma != null) return b;
  if (ma != null && mb != null && !ma.isAtSameMomentAs(mb)) {
    return ma.isBefore(mb) ? a : b;
  }
  return _slice(a).compareTo(_slice(b)) <= 0 ? a : b;
}

/// For a task neither copy marked: the copy whose fields hold something (a
/// number typed in, artigos carried from the Validades before) when the
/// other's are all empty, so a copy saved later that never touched the task
/// doesn't wipe it. Null when both or neither hold something (the copy
/// saved last then keeps its own).
_Side? _touched(_Side a, _Side b) {
  bool empty(_Side s) => _fieldsOf(s).every((f) => _isEmpty(s.row[f]));
  final ea = empty(a);
  final eb = empty(b);
  if (ea == eb) return null;
  return ea ? b : a;
}

bool _isEmpty(Object? v) => switch (v) {
  null || false || 0 || '' => true,
  final List l => l.isEmpty,
  _ => false,
};

String _slice(_Side s) => jsonEncode([
  for (final f in _fieldsOf(s)) s.row[f],
  s.notDone,
  _map(s.row['autoMarks'])[s.key],
]);

List<String> _fieldsOf(_Side s) =>
    dailyTaskFields[s.key] ??
    weeklyTaskFields[s.key] ??
    const ['done', 'all']; // a custom task's entry (see [mergeEntries])

/// Two copies of one Diárias or Semanais row ([fields] says which), as
/// `syncData` JSON with `syncUpdatedAt` set: the copy saved last, with each
/// task taken from the copy that wins it ([_winner]). The same whichever
/// copy is [a], so phones that merge the same two end up with the same row.
Map<String, dynamic> mergeTaskRows(
  Map<String, dynamic> a,
  Map<String, dynamic> b,
  Map<String, List<String>> fields,
) {
  final ta = dateFromJson(a['syncUpdatedAt']);
  final tb = dateFromJson(b['syncUpdatedAt']);
  final aIsBase = switch ((ta, tb)) {
    (final x?, final y?) when !x.isAtSameMomentAs(y) => x.isAfter(y),
    _ => jsonEncode(a).compareTo(jsonEncode(b)) <= 0,
  };
  final merged = Map<String, dynamic>.from(aIsBase ? a : b);
  final notDone = _map(merged['notDone']);
  final autoMarks = _map(merged['autoMarks']);
  final stamps = _map(merged['taskStamps']);
  final pending = {...stringsFromJson(merged['pendingCounts'])};
  final backdated = {...stringsFromJson(merged['backdatedTaskKeys'])};
  for (final MapEntry(:key, value: keyFields) in fields.entries) {
    final sa = _Side(a, key, keyFields);
    final sb = _Side(b, key, keyFields);
    final w = _winner(sa, sb) ?? _touched(sa, sb);
    if (w == null) continue;
    for (final f in keyFields) {
      merged[f] = w.row[f];
    }
    void take(Map<String, dynamic> into, String name) {
      final v = _map(w.row[name])[key];
      if (v == null) {
        into.remove(key);
      } else {
        into[key] = v;
      }
    }

    take(notDone, 'notDone');
    take(autoMarks, 'autoMarks');
    take(stamps, 'taskStamps');
    final wPending = stringsFromJson(w.row['pendingCounts']);
    for (final k in [key, leftKey(key)]) {
      wPending.contains(k) ? pending.add(k) : pending.remove(k);
    }
    stringsFromJson(w.row['backdatedTaskKeys']).contains(key)
        ? backdated.add(key)
        : backdated.remove(key);
  }
  merged['notDone'] = notDone;
  merged['autoMarks'] = autoMarks;
  merged['taskStamps'] = stamps;
  merged['pendingCounts'] = pending.toList()..sort();
  merged['backdatedTaskKeys'] = backdated.toList()..sort();
  return merged;
}

/// Two copies of a custom task's entry: the whole entry from the copy that
/// wins, by the same rules as [mergeTaskRows] (`doneAt` or the Não feita's
/// time as when it was marked, `editedAt` as its correction); the copy
/// saved last when neither is marked.
Map<String, dynamic> mergeEntries(
  Map<String, dynamic> a,
  Map<String, dynamic> b,
) {
  _Side side(Map<String, dynamic> e) => _Side(
    {
      'done': e['done'],
      'all': jsonEncode(e),
      'notDone': {if (e['notDone'] != null) 'x': e['notDone']},
      'autoMarks': {if (e['autoMark'] != null) 'x': e['autoMark']},
      'taskStamps': {
        'x': {
          'markedAt': e['doneAt'] ?? _map(e['notDone'])['at'],
          'editedAt': e['editedAt'],
        },
      },
    },
    'x',
    // The whole entry too, so a tie is broken the same way on every phone.
    const ['done', 'all'],
  );
  final sa = side(a);
  final w = _winner(sa, side(b));
  if (w != null) return identical(w, sa) ? a : b;
  final ta = dateFromJson(a['syncUpdatedAt']);
  final tb = dateFromJson(b['syncUpdatedAt']);
  if (ta != null && tb != null && !ta.isAtSameMomentAs(tb)) {
    return ta.isAfter(tb) ? a : b;
  }
  return jsonEncode(a).compareTo(jsonEncode(b)) <= 0 ? a : b;
}
