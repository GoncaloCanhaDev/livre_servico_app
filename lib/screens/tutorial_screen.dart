import 'package:flutter/material.dart';

import '../services/settings_service.dart';
import '../theme.dart';

/// One page of the tutorial.
class TutorialStep {
  const TutorialStep(this.icon, this.title, this.text);

  final IconData icon;
  final String title;
  final String text;
}

/// What the tutorial walks through, in order: Home first, then its buttons.
const tutorialSteps = [
  TutorialStep(
    Icons.waving_hand_outlined,
    'Bem-vindo',
    'O Livre Serviço Companion junta o dia da loja num só sítio: o que há '
        'para fazer, quem está a trabalhar e o que já foi feito.\n\n'
        'O dia de serviço vai das 5h às 5h do dia seguinte.',
  ),
  TutorialStep(
    Icons.today_outlined,
    'Hoje',
    'No topo do ecrã inicial, o cartão "Hoje" mostra quem está a trabalhar '
        'agora, as tarefas diárias que faltam, os aniversários, os pedidos '
        'atrasados e os camiões do dia. Toque numa linha para abrir o que '
        'ela resume.\n\n'
        'Por cima aparecem os avisos que lhe enviaram: toque em "Visto" '
        'depois de os ler.',
  ),
  TutorialStep(
    Icons.task_alt,
    'Tarefas',
    'Em Tarefas estão as Diárias, as Semanais e as Personalizadas. Marque '
        'cada uma quando estiver feita e escolha quem a fez: fica registado '
        'para toda a equipa.',
  ),
  TutorialStep(
    Icons.checklist,
    'Listas',
    'A Abertura e as Automáticas enviam-se por secção (Congelados, OPLS, '
        'Não Perecíveis). Quando as três secções da Abertura estão enviadas, '
        'a Lista de Abertura fica feita nas Diárias.\n\n'
        'Aqui estão também o Relatório do Dia Anterior e a Lista Visual.',
  ),
  TutorialStep(
    Icons.local_shipping,
    'Camiões, Inventários e Pedidos',
    'Em Camiões regista a receção: o tipo de camião, as paletes de cada '
        'departamento, os expositores e o vasilhame enviado.\n\n'
        'Em Inventários, o nome, o código e o valor final. Em Pedidos, o '
        'número, o fornecedor e a data prevista.',
  ),
  TutorialStep(
    Icons.people,
    'Pessoas e Informações',
    'Pessoas mostra a equipa por secção, com as folgas, as ausências e o '
        'horário de cada um. Toque numa pessoa para ver os detalhes.\n\n'
        'Informações guarda os dados da loja, os protocolos, as avarias, as '
        'reclamações e os contactos úteis.',
  ),
  TutorialStep(
    Icons.history,
    'Histórico',
    'Tudo o que é registado fica no Histórico, separado por tipo. Use a '
        'pesquisa para encontrar um camião, uma lista ou uma tarefa de outro '
        'dia.',
  ),
  TutorialStep(
    Icons.cloud_sync,
    'Conta e sincronização',
    'Com uma conta e uma loja (Definições → Conta e Sincronização), os '
        'dados passam entre os telemóveis da equipa sozinhos. Sem rede, a '
        'aplicação continua a funcionar e envia tudo quando a ligação '
        'voltar.\n\n'
        'Pode rever este tutorial em Definições → Tutorial.',
  ),
];

/// A few pages showing what the app does, swiped or stepped through with the
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
            Expanded(
              child: PageView(
                controller: _pages,
                onPageChanged: (p) => setState(() => _page = p),
                children: [for (final s in tutorialSteps) _StepPage(s)],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 0; i < tutorialSteps.length; i++)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: i == _page ? 18 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: i == _page
                          ? context.colors.primary
                          : context.greyedFill,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  if (_page > 0)
                    TextButton(
                      onPressed: () => _goTo(_page - 1),
                      child: const Text('Anterior'),
                    ),
                  const Spacer(),
                  FilledButton(
                    onPressed: last ? _finish : () => _goTo(_page + 1),
                    child: Text(last ? 'Concluir' : 'Seguinte'),
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
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
      child: Column(
        children: [
          Icon(step.icon, size: 64, color: context.colors.primary),
          const SizedBox(height: 16),
          Text(
            step.title,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 16),
          Text(
            step.text,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, height: 1.4),
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
            subtitle: const Text('Veja como funciona em poucos passos.'),
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
