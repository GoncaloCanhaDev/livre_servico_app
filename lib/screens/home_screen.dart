import 'package:flutter/material.dart';

import '../app_version.dart';
import '../services/account_service.dart';
import 'avisos_screen.dart';
import 'destinations.dart';
import 'settings_screen.dart';
import 'tabs/abertura_tab.dart';
import 'tabs/daily_tasks_tab.dart';
import 'tutorial_screen.dart';
import 'widgets/app_frame.dart';
import 'widgets/avisos_card.dart';
import 'widgets/beta_badge.dart';
import 'widgets/join_requests_card.dart';
import 'widgets/profile_request_card.dart';
import 'widgets/today_card.dart';
import 'widgets/transfer_requests_card.dart';
import 'widgets/wide_layout.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                'Livre Serviço Companion',
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(width: 6),
            Text(
              'v$appVersion',
              style: TextStyle(fontSize: 12, color: Colors.white70),
            ),
            SizedBox(width: 8),
            BetaBadge(),
          ],
        ),
        actions: [
          ListenableBuilder(
            listenable: AccountService.instance,
            builder: (context, _) =>
                AccountService.instance.store?.personId == null
                ? const SizedBox.shrink()
                : IconButton(
                    tooltip: 'Avisos',
                    icon: const Icon(Icons.campaign_outlined),
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const AvisosScreen()),
                    ),
                  ),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const SettingsScreen()));
            },
          ),
        ],
      ),
      body: SafeArea(
        child: hasSideMenu(context)
            ? const _Dashboard()
            : SingleChildScrollView(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ..._cards,
                    GridView.count(
                      // Four across on a computer's wider column.
                      crossAxisCount: MediaQuery.sizeOf(context).width >= 600
                          ? 4
                          : 2,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                      mainAxisExtent: 76,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        for (final d in homeDestinations)
                          _NavButton(
                            icon: d.icon,
                            label: d.label,
                            onPressed: () =>
                                Navigator.of(context).push(d.route()),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

/// Home's cards, from the most urgent: what asks for attention, then the day.
const _cards = [
  AvisosCard(),
  ProfileRequestCard(),
  JoinRequestsCard(),
  TransferRequestsCard(),
  TutorialCard(),
  TodayCard(),
];

/// Home beside the computer's side menu (which has the buttons): the cards
/// on the left, and the day's work open beside them to do right there: the
/// Diárias and, with room, the Lista de Abertura.
class _Dashboard extends StatelessWidget {
  const _Dashboard();

  @override
  Widget build(BuildContext context) {
    final abertura = MediaQuery.sizeOf(context).width >= 1180;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(
            width: 400,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: _cards,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _Panel(
              title: 'Tarefas diárias',
              open: homeDestinations.firstWhere((d) => d.label == 'Tarefas'),
              child: const DailyTasksTab(),
            ),
          ),
          if (abertura) ...[
            const SizedBox(width: 16),
            Expanded(
              child: _Panel(
                title: 'Lista de Abertura',
                open: homeDestinations.firstWhere(
                  (d) => d.label == 'Listas 1.0',
                ),
                child: const AberturaTab(),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// A part of another page shown on the dashboard, with a link to [open] the
/// whole page.
class _Panel extends StatelessWidget {
  const _Panel({required this.title, required this.open, required this.child});

  final String title;
  final Destination open;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PanelHeading(
            title,
            action: TextButton.icon(
              onPressed: () => Navigator.of(context).push(open.route()),
              icon: const Icon(Icons.open_in_new, size: 18),
              label: Text('Abrir ${open.label}'),
            ),
          ),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      icon: Icon(icon),
      label: FittedBox(fit: BoxFit.scaleDown, child: Text(label)),
      onPressed: onPressed,
    );
  }
}
