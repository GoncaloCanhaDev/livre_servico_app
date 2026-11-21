/// What a version brought, in words for the people using the app (not the
/// CHANGELOG's): shown once in the "Novidades" popup after an update.
typedef ReleaseNote = ({String version, List<String> items});

/// Newest first. Only versions worth telling everyone about get an entry
/// (a small fix needs none, and then no popup shows for it); add one in the
/// commit that bumps [appVersion] when it does.
const releaseNotes = <ReleaseNote>[
  (
    version: '0.97.11',
    items: [
      'Tarefas marcadas sozinhas: a app passa a sugerir só uma pessoa, à '
          'vez entre quem estava a trabalhar (quem fez essa tarefa menos '
          'vezes no último mês). Corrija em "Rever" se foi outra pessoa.',
    ],
  ),
  (
    version: '0.97.0',
    items: [
      'Estatísticas (para as chefias, na página inicial): como correu a '
          'semana ou o mês. Quantas vezes cada tarefa foi feita, pela app, '
          'não feita ou ficou sem registo, cada dia, as Validades, as Listas '
          '2.0, os camiões, os inventários e o que cada pessoa fez.',
      'O resumo envia-se por WhatsApp com o botão de partilhar.',
    ],
  ),
  (
    version: '0.96.0',
    items: [
      'Definições → Diagnóstico: mostra se este telemóvel está a '
          'sincronizar, o que falta enviar e se marca as tarefas sozinho. Se '
          'algo não chegar a outro telemóvel, partilhe-o com quem o ajuda.',
    ],
  ),
  (
    version: '0.95.0',
    items: [
      'Tarefas marcadas sozinhas: quando acaba a hora de uma tarefa e ninguém '
          'a marcou, a app marca-a como feita por quem estava a trabalhar no '
          'Livre Serviço, segundo o horário. Fica "Automática · por '
          'confirmar".',
      'Supervisores e chefes confirmam ou corrigem em "Rever" (quem fez, ou '
          'não foi feita). Na página inicial aparecem as que faltam '
          'confirmar.',
      'As tarefas com número podem ficar marcadas com o número por '
          'preencher, para preencher depois.',
      'Os chefes mudam a hora de cada tarefa em Definições → Horas das '
          'tarefas.',
    ],
  ),
  (
    version: '0.94.0',
    items: [
      'Validades: ao marcar a Manhã ou a Noite (feita ou não feita), diga '
          'quantos artigos ficaram por fazer. Somam-se sozinhos à seguinte: da '
          'Manhã para a Noite, da Noite para a Manhã do dia seguinte.',
    ],
  ),
  (
    version: '0.93.0',
    items: [
      'Documentos: um PDF de lado roda-se com o botão no topo. O telemóvel '
          'lembra-se da posição na próxima vez.',
    ],
  ),
  (
    version: '0.92.0',
    items: [
      'Horários: as folgas e o horário marcados no perfil da pessoa contam '
          'antes do Excel (férias e ausências do Excel continuam). Uma mudança '
          'feita no dia conta antes de tudo.',
      'Ao mudar um dia, "Só horas" marca a entrada e a saída mesmo sem código '
          '(por exemplo, ficou até às 18h).',
    ],
  ),
  (
    version: '0.91.0',
    items: [
      'Horários: o chefe de secção (ou acima) muda o dia de alguém na app, '
          'pelo código (baixa, chamado na folga, trocas). Os dias mudados têm '
          'um ponto laranja e, ao importar de novo o Excel, a app pergunta '
          'quais ficam.',
    ],
  ),
  (
    version: '0.90.0',
    items: [
      'Horários: o chefe de secção importa o Excel do mês e todos na loja veem '
          'quem trabalha em cada dia, na semana e no mês.',
      'No Início, veja os seus próximos dias. "A trabalhar agora" e as folgas '
          'em Pessoas seguem o horário importado.',
    ],
  ),
  (
    version: '0.89.0',
    items: [
      'No Início, a nuvem no topo mostra se está tudo enviado ou quantas '
          'alterações ainda faltam enviar (por exemplo, sem rede). Toque nela '
          'para ver quando sincronizou e para sincronizar agora.',
    ],
  ),
  (
    version: '0.88.1',
    items: [
      'Listas 2.0 → Automáticas: toque na secção na lista para escrever as '
          'contagens e enviar.',
    ],
  ),
  (
    version: '0.88.0',
    items: [
      'Erros e sugestões: no separador Todos, veja o que já foi enviado e o '
          'estado de cada um (Novo, Visto, Em curso, Resolvido ou Não será '
          'feito), sem o nome de quem enviou.',
    ],
  ),
  (
    version: '0.87.0',
    items: [
      'Inventários → Por fazer: o chefe de secção (ou acima) planeia os '
          'inventários, com data se quiser; quem os fizer toca em Feito e '
          'indica quem foi e o valor.',
    ],
  ),
  (
    version: '0.86.0',
    items: [
      'Listas 2.0 → Automáticas: além dos artigos da lista, pode indicar '
          'quantos ficaram por tratar e quantos estavam sem stock. Aparecem '
          'na mensagem de WhatsApp e no Histórico.',
    ],
  ),
  (
    version: '0.85.3',
    items: [
      'Erros e sugestões tem agora um botão no ecrã inicial.',
      'As Listas 1.0 (as listas antigas) passaram para Definições → Funções '
          'antigas.',
    ],
  ),
  (
    version: '0.85.1',
    items: [
      'Listas 2.0 → Automáticas: escolha a secção e escreva a contagem, sem '
          'ter de andar para baixo.',
      'Listas 2.0: os números escritos ficam guardados até serem enviados, '
          'mesmo que saia da aplicação a meio.',
    ],
  ),
  (
    version: '0.83.1',
    items: [
      'Validades: já não fecham a uma hora certa. Se a verificação foi feita '
          'e não se marcou a tempo, ainda se pode marcar até ao fim do dia.',
    ],
  ),
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
