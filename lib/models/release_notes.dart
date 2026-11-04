/// What a version brought, in words for the people using the app (not the
/// CHANGELOG's): shown once in the "Novidades" popup after an update.
typedef ReleaseNote = ({String version, List<String> items});

/// Newest first. Only versions worth telling everyone about get an entry
/// (a small fix needs none, and then no popup shows for it); add one in the
/// commit that bumps [appVersion] when it does.
const releaseNotes = <ReleaseNote>[
  (
    version: '0.83.0',
    items: [
      'Diárias: a Lista Visível marca-se sozinha quando se faz um Visível em '
          'Listas 2.0, e a Lista Automática mostra quantas automáticas já se '
          'enviaram hoje.',
    ],
  ),
  (
    version: '0.82.0',
    items: [
      'As Diárias já não incluem a Lista de Abertura, o Relatório, a Lista '
          'Visual nem a Lista Automática: as listas continuam em Listas 1.0 '
          'e no Histórico.',
    ],
  ),
  (
    version: '0.81.0',
    items: [
      'Listas 2.0 → Visível: depois de uma volta de Automáticas, percorra a '
          'loja, conte os itens picados e finalize: fica no Histórico, em '
          'Visível 2.0, e pode enviar por WhatsApp.',
    ],
  ),
  (
    version: '0.80.0',
    items: [
      'Listas 2.0 → Automáticas: Mercearia, Pet Food, Bebidas e os outros '
          'itens, cada um enviado sozinho quando estiver feito, como em '
          'Listas 1.0: o número, quem o fez e a mensagem por WhatsApp. Fica '
          'no Histórico, em Automáticas 2.0.',
    ],
  ),
  (
    version: '0.77.0',
    items: [
      'Reportar erro ou sugestão (em Definições): encontrou um erro ou tem '
          'uma ideia? Escreva ao administrador da aplicação. Só ele lê.',
    ],
  ),
  (
    version: '0.76.0',
    items: [
      'Novidades: depois de cada atualização aparece esta janela, uma vez, '
          'com o que mudou. Fica marcada como vista na sua conta, em todos '
          'os dispositivos.',
      'Documentos (no Início): PDFs para todas as lojas, abertos na app, '
          'também sem rede depois de abertos uma vez.',
      'As listas antigas (Abertura, Automáticas, Relatório, Visual) estão '
          'em Listas 1.0; as novas listas vão para Listas 2.0.',
      'Cada tarefa tem agora ✓ Feita e ✗ Não feita (com o motivo).',
    ],
  ),
];

/// The version before the popup existed: an install that already used the
/// app but never saw a popup counts as having seen up to this one.
const releaseNotesBaseline = '0.75.1';

/// Compares two `MAJOR.MINOR.PATCH` versions (a `+BUILD` is ignored; a
/// missing or unreadable part counts as 0).
int compareVersions(String a, String b) {
  List<int> parts(String v) => [
    for (final p in v.split('+').first.split('.')) int.tryParse(p) ?? 0,
  ];
  final pa = parts(a), pb = parts(b);
  for (var i = 0; i < 3; i++) {
    final x = i < pa.length ? pa[i] : 0, y = i < pb.length ? pb[i] : 0;
    if (x != y) return x.compareTo(y);
  }
  return 0;
}

/// The newer of [a] and [b]; null when both are.
String? newerVersion(String? a, String? b) {
  if (a == null) return b;
  if (b == null) return a;
  return compareVersions(a, b) >= 0 ? a : b;
}

/// The notes to show someone who last saw [seen] and now runs [current]:
/// those after [seen] up to [current], newest first. None when [seen] is
/// null (a first install: the tutorial is for that).
List<ReleaseNote> unseenReleaseNotes(
  String? seen,
  String current, {
  List<ReleaseNote> notes = releaseNotes,
}) {
  if (seen == null) return const [];
  return [
    for (final n in notes)
      if (compareVersions(n.version, seen) > 0 &&
          compareVersions(n.version, current) <= 0)
        n,
  ];
}
