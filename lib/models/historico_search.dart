import 'package:intl/intl.dart';

import 'auto_list.dart';
import 'daily_tasks.dart';
import 'fold_text.dart';
import 'inventory.dart';
import 'opening_list.dart';
import 'pedido.dart';
import 'report_list.dart';
import 'truck_reception.dart';
import 'visual_list.dart';

/// Whether every word of [query] appears in [text], ignoring case and
/// accents. An empty query matches everything.
bool matchesQuery(String text, String query) {
  final folded = foldText(text);
  return foldText(
    query,
  ).split(RegExp(r'\s+')).where((w) => w.isNotEmpty).every(folded.contains);
}

/// [d] as the Histórico search finds it: "8/10/2026" and "quinta-feira, 8
/// de outubro de 2026".
String dateWords(DateTime d) =>
    '${d.day}/${d.month}/${d.year} '
    '${DateFormat("EEEE, d 'de' MMMM 'de' y", 'pt_PT').format(d)}';

String _join(Iterable<Object?> parts) =>
    parts.where((p) => p != null && '$p'.isNotEmpty).join(' ');

/// The text a Receção de Camião is searched by: date, tipo, matrícula,
/// fornecedor, notes, problemas, departamentos, expositores, who and totals.
String truckSearchText(TruckReception t) => _join([
  dateWords(t.arrivalTime),
  truckTitle(t),
  t.licensePlate,
  t.supplier,
  t.notes,
  t.issues,
  for (final p in t.pallets) p.label,
  for (final e in t.expositores) e.content,
  ...t.createdByNames,
  t.createdByInitials,
  '${t.totalPallets} paletes',
]);

/// A Lista de Abertura: date, who sent each section, values.
String openingSearchText(OpeningList l) => _join([
  dateWords(l.serviceDay),
  for (final s in ListSection.values) ...l.namesOf(s),
  ...l.createdByNames,
  l.createdByInitials,
  l.congelados,
  l.opls,
  l.naoPereciveis,
  l.total,
]);

/// A Lista Automática: date, who, values.
String autoSearchText(AutoList a) => _join([
  dateWords(a.createdAt),
  ...a.createdByNames,
  a.createdByInitials,
  a.congelados,
  a.opls,
  a.naoPereciveis,
  a.total,
]);

/// A Relatório: date, who, values.
String reportSearchText(ReportList r) => _join([
  dateWords(r.serviceDay),
  ...r.createdByNames,
  r.createdByInitials,
  r.diasSemVendas,
  r.regularizacoes,
  r.massiva,
  r.repetidos,
  r.total,
]);

/// A Lista Visual entry: date, who, itens picados.
String visualSearchText(VisualList v) => _join([
  dateWords(v.serviceDay),
  ...v.createdByNames,
  v.createdByInitials,
  v.itensPicados,
]);

/// The Diárias of a day: date and everyone who did a task.
String dailyTasksSearchText(DailyTasks t) => _join([
  dateWords(t.serviceDay),
  ...t.kiwiAberturaByNames,
  t.kiwiAberturaBy,
  ...t.alteracoesPrecoByNames,
  t.alteracoesPrecoBy,
  ...t.verificacaoTemperaturasByNames,
  t.verificacaoTemperaturasBy,
  ...t.preenchimentoQuadroByNames,
  t.preenchimentoQuadroBy,
  ...t.verificacaoValidadesByNames,
  t.verificacaoValidadesBy,
  ...t.validadesNoiteByNames,
  ...t.kiwiFechoByNames,
  t.kiwiFechoBy,
]);

/// An Inventário: date, name, code, who, value.
String inventorySearchText(Inventory i) => _join([
  dateWords(i.createdAt),
  i.name,
  i.code,
  ...i.createdByNames,
  i.createdByInitials,
  formatCents(i.valueCents),
]);

/// A Pedido: dates, número, fornecedor, who.
String pedidoSearchText(Pedido p) => _join([
  dateWords(p.createdAt),
  if (p.expectedDate case final d?) dateWords(d),
  p.numero,
  p.supplier,
  p.createdByInitials,
]);
