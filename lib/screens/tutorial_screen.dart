import 'package:flutter/material.dart';

import '../services/settings_service.dart';
import '../theme.dart';

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

/// What the tutorial walks through, in order: the day and Home first, then
/// each of Home's buttons, then avisos and the account.
const tutorialSteps = [
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
      'Os botões de cada área: Camiões, Listas, Inventários, Tarefas, '
          'Pedidos, Informações, Histórico e Pessoas.',
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
      'Toque na tarefa feita.',
      'Em "Quem concluiu?", escolha uma ou mais pessoas. Se foi feita '
          'noutro dia, mude o dia.',
      'Confirme: a tarefa fica marcada com os nomes e já não se desmarca '
          'nesse dia.',
      'O WhatsApp abre com a mensagem: envie-a ao grupo.',
    ],
    tip:
        'A Verificação de Validades tem duas janelas: Manhã (5h–14h) e '
        'Noite (19h–5h). Fora da janela não se pode marcar. Em '
        'Personalizadas, o + cria uma tarefa nova (diária, semanal ou '
        'pontual).',
  ),
  TutorialStep(
    icon: Icons.checklist,
    title: 'Abertura e Automáticas',
    intro:
        'Em Listas, a Abertura e as Automáticas enviam-se por secção: '
        'Congelados, OPLS e Não Perecíveis.',
    diagram: _AberturaDiagram(),
    steps: [
      'Abra Listas → Abertura.',
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
    intro: 'Os outros dois separadores de Listas fecham-se com "Finalizar".',
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
  TutorialStep(
    icon: Icons.local_shipping,
    title: 'Receber um camião',
    intro: 'Em Camiões regista-se cada receção, enquanto o camião descarrega.',
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
  TutorialStep(
    icon: Icons.campaign_outlined,
    title: 'Avisos',
    intro: 'Mensagens curtas dentro da aplicação, das chefias para a equipa.',
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
];

/// A few pages showing how the app works, swiped or stepped through with the
/// buttons. Finishing or skipping it hides [TutorialCard] on Home.
class TutorialScreen extends StatefulWidget {
  const TutorialScreen({super.key});

  @override
  State<TutorialScreen> createState() => _TutorialScreenState();
}

class _TutorialScreenState extends State<TutorialScreen> {
  final _pages = PageController();
  int _page = 0;

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
    SettingsService.instance.setTutorialSeen();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final last = _page == tutorialSteps.length - 1;
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
      body: SafeArea(
        child: Column(
          children: [
            LinearProgressIndicator(
              value: (_page + 1) / tutorialSteps.length,
              minHeight: 3,
              backgroundColor: context.hairline,
            ),
            Expanded(
              child: PageView(
                controller: _pages,
                onPageChanged: (p) => setState(() => _page = p),
                children: [for (final s in tutorialSteps) _StepPage(s)],
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
                    '${_page + 1} de ${tutorialSteps.length}',
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

/// On Home until the tutorial is finished or the card closed.
class TutorialCard extends StatelessWidget {
  const TutorialCard({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: SettingsService.instance,
      builder: (context, _) {
        if (SettingsService.instance.tutorialSeen) {
          return const SizedBox.shrink();
        }
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          color: context.tint(Colors.blue),
          child: ListTile(
            leading: const Icon(Icons.school_outlined),
            title: const Text(
              'Primeira vez na aplicação?',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: const Text('Veja como funciona, passo a passo.'),
            trailing: IconButton(
              tooltip: 'Fechar',
              icon: const Icon(Icons.close),
              onPressed: SettingsService.instance.setTutorialSeen,
            ),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const TutorialScreen()),
            ),
          ),
        );
      },
    );
  }
}
