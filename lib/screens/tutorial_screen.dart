import 'package:flutter/material.dart';

import '../services/settings_service.dart';
import '../theme.dart';
import 'widgets/wide_layout.dart';

part 'tutorial/diagrams.dart';

/// One page of the tutorial: a sketch of the screen with numbered markers,
/// and the steps those numbers point to.
class TutorialStep {
  const TutorialStep({
    required this.icon,
    required this.title,
    required this.intro,
    required this.diagram,
    this.steps = const [],
    this.tip,
  });

  final IconData icon;
  final String title;
  final String intro;
  final Widget diagram;
  final List<String> steps;

  /// A closing hint, under the steps.
  final String? tip;
}

/// The tutorial, split by the area of the app each part shows. Each section
/// has a [TutorialSection.version]: raise it whenever that part of the app
/// (and so its pages here) changes, and Home offers it again to everyone
/// who saw an older version, as if they had never seen it. A new section
/// gets a new [TutorialSection.id] at version 1; never reuse or rename an id
/// (the seen versions are kept by id).
const tutorialSections = [
  TutorialSection(
    id: 'inicio',
    title: 'Início',
    version: 3,
    steps: [
      TutorialStep(
        icon: Icons.waving_hand_outlined,
        title: 'Bem-vindo',
        intro:
            'O Livre Serviço Companion junta o dia da loja num só sítio: o que há '
            'para fazer, quem está a trabalhar e o que já foi feito. Tudo o que '
            'regista conta para o dia de serviço, que vai das 5h às 5h do dia '
            'seguinte.',
        diagram: _DayDiagram(),
        steps: [
          'O ecrã inicial resume o dia; cada botão abre uma área da loja.',
          'Ao concluir alguma coisa, escolha quem a fez: fica registado para '
              'toda a equipa.',
          'Muitas ações abrem o WhatsApp com a mensagem já escrita: só tem de '
              'a enviar ao grupo.',
          'Às 5h começa um dia novo: as listas e as tarefas diárias voltam a '
              'abrir.',
        ],
      ),
      TutorialStep(
        icon: Icons.home_outlined,
        title: 'O ecrã inicial',
        intro: 'É o ponto de partida. De cima para baixo:',
        diagram: _HomeDiagram(),
        steps: [
          'Avisos: os que recebeu e os que enviou.',
          'Definições: conta, tutorial, objetivos e aparência.',
          'Cartões que pedem atenção: avisos novos, pedidos de atualização do '
              'perfil, pedidos para entrar na loja.',
          'O cartão Hoje, com o resumo do dia.',
          'Os botões de cada área: Camiões, Listas 2.0, Listas Legacy, '
              'Inventários, Tarefas, Pedidos, Informações, Documentos, Histórico '
              'e Pessoas.',
        ],
      ),
      TutorialStep(
        icon: Icons.today_outlined,
        title: 'O cartão Hoje',
        intro:
            'Num relance, o estado do dia. Toque numa linha para abrir o que ela '
            'resume.',
        diagram: _TodayDiagram(),
        steps: [
          'A trabalhar agora: quem está no turno neste momento, e quantos '
              'trabalham hoje de dia e de noite.',
          'Por fazer: as tarefas diárias que faltam. Toque para abrir as '
              'Tarefas.',
          'Aniversários de hoje e dos próximos dias.',
          'Pedidos atrasados e os camiões já recebidos hoje.',
        ],
      ),
    ],
  ),
  TutorialSection(
    id: 'tarefas',
    title: 'Tarefas',
    version: 1,
    steps: [
      TutorialStep(
        icon: Icons.task_alt,
        title: 'Marcar uma tarefa',
        intro:
            'Em Tarefas estão as Diárias, as Semanais e as Personalizadas. '
            'Todas se marcam da mesma maneira:',
        diagram: _TaskDiagram(),
        steps: [
          'Abra Tarefas e escolha o separador (Diárias, Semanais ou '
              'Personalizadas).',
          'Cada tarefa tem dois marcadores: ✓ se foi feita, ✗ se não foi. '
              'Só se marca um.',
          'Em "Quem concluiu?", escolha uma ou mais pessoas. Se foi feita '
              'noutro dia, mude o dia.',
          'Confirme: a tarefa fica marcada com os nomes e já não se desmarca '
              'nesse dia.',
          'O WhatsApp abre com a mensagem: envie-a ao grupo.',
          'Com ✗, escolha quem marca e escreva o motivo: a tarefa fica como '
              '"Não feita" com o motivo, e a mensagem diz porquê.',
        ],
        tip:
            'A Verificação de Validades tem duas janelas: Manhã (5h–14h) e '
            'Noite (19h–5h). Fora da janela não se marca como feita, só como '
            'não feita. Em '
            'Personalizadas, o + cria uma tarefa nova (diária, semanal ou '
            'pontual).',
      ),
    ],
  ),
  TutorialSection(
    id: 'listas2',
    title: 'Listas 2.0',
    version: 1,
    steps: [
      TutorialStep(
        icon: Icons.checklist,
        title: 'Listas 2.0',
        intro:
            'O sistema de listas da loja está a mudar. As novas listas vão ficar '
            'em Listas 2.0.',
        diagram: _Listas2Diagram(),
        steps: [
          'Listas 2.0: as novas listas, que vão aparecer aqui em breve.',
          'Listas Legacy: as listas antigas (Abertura, Automáticas, Relatório '
              'e Visual), para as lojas que ainda as usam.',
        ],
        tip:
            'Quando uma secção da aplicação muda, o seu tutorial volta a '
            'aparecer no ecrã inicial, em "Novidades".',
      ),
    ],
  ),
  TutorialSection(
    id: 'listas',
    title: 'Listas Legacy',
    version: 2,
    steps: [
      TutorialStep(
        icon: Icons.checklist,
        title: 'Abertura e Automáticas',
        intro:
            'Em Listas Legacy, a Abertura e as Automáticas enviam-se por secção: '
            'Congelados, OPLS e Não Perecíveis.',
        diagram: _AberturaDiagram(),
        steps: [
          'Abra Listas Legacy → Abertura.',
          'Escreva o número de cada secção.',
          'Quando uma secção estiver feita, toque na seta de enviar ao lado '
              'dela.',
          'Escolha quem a fez e envie a mensagem no WhatsApp.',
          'Com as três secções enviadas, a lista fica finalizada e a Lista de '
              'Abertura fica marcada nas Diárias. A próxima abre às 5h.',
        ],
        tip:
            'As Automáticas funcionam da mesma forma: cada envio guarda essa '
            'secção e limpa o campo para a seguinte.',
      ),
      TutorialStep(
        icon: Icons.insights_outlined,
        title: 'Relatório e Lista Visual',
        intro:
            'Os outros dois separadores de Listas Legacy fecham-se com '
            '"Finalizar".',
        diagram: _ReportDiagram(),
        steps: [
          'Relatório Dia Anterior: preencha os valores (dias sem vendas, '
              'regularizações, massiva, repetidos).',
          'Toque em Finalizar e escolha por quem. O relatório fica bloqueado; '
              'abre um novo às 5h.',
          'Visual: escreva os itens picados, a quebra e o benefício e toque em '
              'Finalizar.',
          'A barra mostra quanto falta para o objetivo diário de itens picados.',
        ],
        tip: 'O objetivo da Lista Visual muda-se em Definições → Objetivos.',
      ),
    ],
  ),
  TutorialSection(
    id: 'camioes',
    title: 'Camiões',
    version: 1,
    steps: [
      TutorialStep(
        icon: Icons.local_shipping,
        title: 'Receber um camião',
        intro:
            'Em Camiões regista-se cada receção, enquanto o camião descarrega.',
        diagram: _TruckDiagram(),
        steps: [
          'Abra Camiões.',
          'Escolha o tipo de camião (Perecíveis ou Não Perecíveis) e confirme a '
              'hora de chegada.',
          'Em Paletes, toque em Adicionar, escolha os departamentos e escreva o '
              'total de cada um (e as mistas).',
          'Em Expositores, adicione os que vieram, com o conteúdo e a '
              'quantidade.',
          'Em Vasilhame a Enviar, toque em Selecionar e escolha o que vai de '
              'volta.',
          'Preencha a matrícula, o fornecedor e, se houve, os problemas na '
              'receção.',
          'Toque em Guardar, escolha quem recebeu e envie a mensagem.',
        ],
      ),
    ],
  ),
  TutorialSection(
    id: 'inventarios',
    title: 'Inventários e Pedidos',
    version: 1,
    steps: [
      TutorialStep(
        icon: Icons.assignment,
        title: 'Inventários e Pedidos',
        intro: 'Dois registos rápidos, cada um com o seu botão "Novo".',
        diagram: _InventoryDiagram(),
        steps: [
          'Inventários → Novo: escreva o nome e o código e toque em Continuar.',
          'Escolha quem faz o inventário, escreva o valor final (pode ser '
              'negativo, ex.: -12,50) e toque em Enviar.',
          'Pedidos → Novo: escreva o número do pedido e, se souber, o fornecedor '
              'e a data prevista de chegada; toque em Criar pedido.',
          'Quando a mercadoria chegar, abra o pedido e toque em Finalizar. Se a '
              'data passar, aparece como atrasado no cartão Hoje.',
        ],
      ),
    ],
  ),
  TutorialSection(
    id: 'pessoas',
    title: 'Pessoas',
    version: 1,
    steps: [
      TutorialStep(
        icon: Icons.people,
        title: 'Pessoas',
        intro:
            'A equipa da loja, por secção e por turno. Quem não trabalha hoje '
            'aparece no fim da sua secção.',
        diagram: _PeopleDiagram(),
        steps: [
          'Procure por nome, equipa ou número de colaborador.',
          'As etiquetas dizem a função, se é novo na empresa, se faz anos, e '
              'porque está fora (folga, férias…).',
          'Toque numa pessoa para ver os detalhes, o horário, as folgas e o '
              'que fez no histórico.',
          'As chefias adicionam pessoas com o +; tocar sem largar numa pessoa '
              'mostra Editar e Remover.',
        ],
        tip:
            'Cada um preenche o seu perfil (nome, foto, aniversário). As folgas, '
            'as ausências e a função são das chefias.',
      ),
    ],
  ),
  TutorialSection(
    id: 'informacoes',
    title: 'Informações',
    version: 1,
    steps: [
      TutorialStep(
        icon: Icons.info_outline,
        title: 'Informações',
        intro: 'O que é preciso saber da loja, sempre à mão.',
        diagram: _InfoDiagram(),
        steps: [
          'Informações da Loja: os dados da loja.',
          'Protocolos e Ações de Suporte (Avarias, Reclamações): como fazer, '
              'com fotos se for preciso.',
          'Contactos Úteis, por grupo: toque em ligar, WhatsApp ou email.',
          'Toque sem largar numa entrada para a editar, afixar no topo, '
              'partilhar ou apagar.',
        ],
      ),
    ],
  ),
  TutorialSection(
    id: 'documentos',
    title: 'Documentos',
    version: 1,
    steps: [
      TutorialStep(
        icon: Icons.description_outlined,
        title: 'Documentos',
        intro:
            'Os documentos em PDF da empresa, iguais em todas as lojas, para '
            'ler na aplicação.',
        diagram: _DocumentsDiagram(),
        steps: [
          'Toque num documento para o abrir. Deslize para mudar de página e '
              'afaste dois dedos para aumentar.',
          'Um documento que já abriu fica guardado no telemóvel e abre mesmo '
              'sem internet.',
        ],
        tip:
            'Os documentos são mantidos pelo administrador da aplicação: '
            'aparecem depois de entrar numa loja.',
      ),
    ],
  ),
  TutorialSection(
    id: 'historico',
    title: 'Histórico',
    version: 1,
    steps: [
      TutorialStep(
        icon: Icons.history,
        title: 'Histórico',
        intro: 'Tudo o que foi registado, de todos os dias.',
        diagram: _HistoricoDiagram(),
        steps: [
          'Escolha o separador: Tudo, ou só Camiões, Abertura, Automáticas, '
              'Relatório, Visual, Tarefas, Inventários ou Pedidos.',
          'Escreva na pesquisa um nome, um departamento ou um número para '
              'filtrar.',
          'Toque num registo para ver os detalhes.',
        ],
      ),
    ],
  ),
  TutorialSection(
    id: 'avisos',
    title: 'Avisos',
    version: 1,
    steps: [
      TutorialStep(
        icon: Icons.campaign_outlined,
        title: 'Avisos',
        intro:
            'Mensagens curtas dentro da aplicação, das chefias para a equipa.',
        diagram: _AvisosDiagram(),
        steps: [
          'Os avisos novos aparecem no topo do ecrã inicial.',
          'Depois de ler, toque em Visto: quem o enviou fica a saber.',
          'No ícone do megafone, no ecrã inicial, estão os Recebidos (e, para quem envia avisos, os '
              'Enviados, com quem já viu).',
          'Para enviar (a partir de Segunda Linha): Novo aviso, escreva o texto, '
              'escolha as equipas ou as pessoas e toque em Enviar.',
        ],
      ),
    ],
  ),
  TutorialSection(
    id: 'conta',
    title: 'Conta e sincronização',
    version: 1,
    steps: [
      TutorialStep(
        icon: Icons.cloud_sync,
        title: 'Conta e sincronização',
        intro:
            'Com uma conta, os dados passam sozinhos entre os telemóveis da '
            'equipa. Sem rede, a aplicação continua a funcionar e envia tudo '
            'quando a ligação voltar.',
        diagram: _AccountDiagram(),
        steps: [
          'Em Definições → Conta e Sincronização, toque em Criar conta (email e '
              'palavra-passe) e confirme o email.',
          'Toque em Entrar com código e escreva o código da loja, que a gerência '
              'lhe dá.',
          'Em "Quem é você?", escolha o seu nome (ou "Não estou na lista").',
          'Espere pela aprovação de uma chefia: assim que for aprovado, a loja '
              'abre sozinha.',
          'Complete o seu perfil. A partir daí, tudo sincroniza.',
        ],
        tip: 'Pode rever este tutorial em Definições → Tutorial.',
      ),
    ],
  ),
];

/// Every page of the tutorial, in order.
final tutorialSteps = [for (final s in tutorialSections) ...s.steps];

/// The sections new to this person or changed since they last saw them.
List<TutorialSection> pendingTutorialSections() => [
  for (final s in tutorialSections)
    if (SettingsService.instance.tutorialSeenVersion(s.id) < s.version) s,
];

/// A part of the tutorial: the pages about one area of the app.
class TutorialSection {
  const TutorialSection({
    required this.id,
    required this.title,
    required this.version,
    required this.steps,
  });

  /// Kept with the version seen; never changes.
  final String id;
  final String title;
  final int version;
  final List<TutorialStep> steps;
}

/// A few pages showing how the app works, swiped or stepped through with the
/// buttons: the pages of [sections] (all of them by default). Finishing or
/// skipping it marks those sections seen, so [TutorialCard] stops offering
/// them.
class TutorialScreen extends StatefulWidget {
  const TutorialScreen({super.key, this.sections = tutorialSections});

  final List<TutorialSection> sections;

  @override
  State<TutorialScreen> createState() => _TutorialScreenState();
}

class _TutorialScreenState extends State<TutorialScreen> {
  final _pages = PageController();
  int _page = 0;

  late final _steps = [for (final s in widget.sections) ...s.steps];

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  void _goTo(int page) => _pages.animateToPage(
    page,
    duration: const Duration(milliseconds: 250),
    curve: Curves.easeOut,
  );

  void _finish() {
    markTutorialSeen(widget.sections);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final last = _page == _steps.length - 1;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tutorial'),
        actions: [
          if (!last)
            TextButton(
              onPressed: _finish,
              style: TextButton.styleFrom(foregroundColor: Colors.white),
              child: const Text('Saltar'),
            ),
        ],
      ),
      body: ReadableWidth(
        child: SafeArea(
          child: Column(
            children: [
              LinearProgressIndicator(
                value: (_page + 1) / _steps.length,
                minHeight: 3,
                backgroundColor: context.hairline,
              ),
              Expanded(
                child: PageView(
                  controller: _pages,
                  onPageChanged: (p) => setState(() => _page = p),
                  children: [for (final s in _steps) _StepPage(s)],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: Row(
                  children: [
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: _page > 0
                            ? TextButton(
                                onPressed: () => _goTo(_page - 1),
                                child: const Text('Anterior'),
                              )
                            : null,
                      ),
                    ),
                    Text(
                      '${_page + 1} de ${_steps.length}',
                      style: TextStyle(color: context.muted),
                    ),
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: FilledButton(
                          onPressed: last ? _finish : () => _goTo(_page + 1),
                          child: Text(last ? 'Concluir' : 'Seguinte'),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StepPage extends StatelessWidget {
  const _StepPage(this.step);

  final TutorialStep step;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(step.icon, size: 28, color: context.colors.primary),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  step.title,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(step.intro, style: const TextStyle(fontSize: 15, height: 1.4)),
          const SizedBox(height: 16),
          Center(child: step.diagram),
          const SizedBox(height: 16),
          for (final (i, text) in step.steps.indexed)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Marker(i + 1, size: 22),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      text,
                      style: const TextStyle(fontSize: 15, height: 1.35),
                    ),
                  ),
                ],
              ),
            ),
          if (step.tip case final tip?)
            Container(
              margin: const EdgeInsets.only(top: 6),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: context.tint(Colors.amber),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.lightbulb_outline, color: context.warningText),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(tip, style: const TextStyle(height: 1.35)),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// Marks [sections] seen at their current version.
Future<void> markTutorialSeen(Iterable<TutorialSection> sections) =>
    SettingsService.instance.setTutorialSeen({
      for (final s in sections) s.id: s.version,
    });

/// On Home while a section of the tutorial is new to this person or changed
/// since they saw it: the whole tutorial the first time ("Primeira vez na
/// aplicação?"), afterwards only the changed sections ("Novidades").
/// Closing it marks them seen.
class TutorialCard extends StatelessWidget {
  const TutorialCard({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: SettingsService.instance,
      builder: (context, _) {
        final pending = pendingTutorialSections();
        if (pending.isEmpty) return const SizedBox.shrink();
        final firstTime = tutorialSections.every(
          (s) => SettingsService.instance.tutorialSeenVersion(s.id) == 0,
        );
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          color: context.tint(Colors.blue),
          child: ListTile(
            leading: Icon(
              firstTime ? Icons.school_outlined : Icons.new_releases_outlined,
            ),
            title: Text(
              firstTime ? 'Primeira vez na aplicação?' : 'Novidades',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              firstTime
                  ? 'Veja como funciona, passo a passo.'
                  : 'Mudou: ${pending.map((s) => s.title).join(', ')}. '
                        'Veja o que há de novo.',
            ),
            trailing: IconButton(
              tooltip: 'Fechar',
              icon: const Icon(Icons.close),
              onPressed: () => markTutorialSeen(pending),
            ),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => TutorialScreen(sections: pending),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Definições → Tutorial and the side menu's Tutorial: the whole tutorial,
/// or one section, marked "Novo" while new or changed for this person.
class TutorialIndexScreen extends StatelessWidget {
  const TutorialIndexScreen({super.key});

  void _open(BuildContext context, List<TutorialSection> sections) =>
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => TutorialScreen(sections: sections)),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tutorial')),
      body: SafeArea(
        child: ReadableWidth(
          child: ListenableBuilder(
            listenable: SettingsService.instance,
            builder: (context, _) {
              final pending = pendingTutorialSections().toSet();
              return ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  ListTile(
                    leading: const Icon(Icons.school_outlined),
                    title: const Text(
                      'Ver tudo',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text('${tutorialSteps.length} páginas'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _open(context, tutorialSections),
                  ),
                  const Divider(),
                  for (final s in tutorialSections)
                    ListTile(
                      leading: Icon(s.steps.first.icon),
                      title: Text(s.title),
                      subtitle: Text(
                        s.steps.map((step) => step.title).join(' · '),
                      ),
                      trailing: pending.contains(s)
                          ? const _NewBadge()
                          : const Icon(Icons.chevron_right),
                      onTap: () => _open(context, [s]),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _NewBadge extends StatelessWidget {
  const _NewBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: context.colors.primary,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        'Novo',
        style: TextStyle(
          color: context.colors.onPrimary,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
