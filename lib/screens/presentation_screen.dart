import 'package:flutter/material.dart';

import '../services/account_service.dart';
import '../services/demo_mode.dart';
import '../theme.dart';
import 'account_screen.dart';
import 'privacy_policy_screen.dart';
import 'widgets/app_frame.dart';

/// The headlines' typeface (bundled in `assets/fonts`).
const _display = 'RobotoCondensed';

/// The widest the page's content gets on a computer.
const _contentWidth = 1120.0;

/// The footer's copyright line: from 2026 to [now]'s year.
String copyrightLine(DateTime now) => now.year > 2026
    ? '© 2026–${now.year} Gonçalo Canha'
    : '© 2026 Gonçalo Canha';

/// The website's first page for a visitor who isn't signed in: a landing
/// page with what the app does, the demo, and the way in (Criar conta /
/// Entrar open Conta, closed again once signed in, when the first page
/// changes underneath). Uses the whole width, unlike the app's pages.
class PresentationScreen extends StatefulWidget {
  const PresentationScreen({super.key});

  @override
  State<PresentationScreen> createState() => _PresentationScreenState();
}

class _PresentationScreenState extends State<PresentationScreen> {
  final _auth = AccountService.instance;

  @override
  void initState() {
    super.initState();
    _auth.addListener(_signedIn);
  }

  @override
  void dispose() {
    _auth.removeListener(_signedIn);
    super.dispose();
  }

  void _signedIn() {
    if (_auth.isSignedIn && mounted) {
      Navigator.of(context).popUntil((r) => r.isFirst);
    }
  }

  void _open(Widget page) => Navigator.push(
    context,
    MaterialPageRoute(builder: (_) => AppFrame(child: page)),
  );

  void _account() => _open(const AccountScreen());

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.sizeOf(context).width >= 900;
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _Section(
                child: _TopBar(wide: wide, onAccount: _account),
              ),
              _Section(
                padding: EdgeInsets.fromLTRB(0, wide ? 56 : 24, 0, 64),
                child: _Hero(wide: wide, onAccount: _account),
              ),
              _Section(
                padding: const EdgeInsets.only(bottom: 64),
                child: _Features(wide: wide),
              ),
              _Section(
                padding: const EdgeInsets.only(bottom: 72),
                child: _Steps(wide: wide),
              ),
              _ClosingBand(wide: wide),
              _Section(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: _Footer(
                  onPrivacy: () => _open(const PrivacyPolicyScreen()),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A band of the page: its content centred, at most [_contentWidth] wide,
/// with the side gutter.
class _Section extends StatelessWidget {
  const _Section({required this.child, this.padding = EdgeInsets.zero});

  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final gutter = MediaQuery.sizeOf(context).width >= 600 ? 32.0 : 16.0;
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: _contentWidth),
        child: Padding(
          padding: padding.add(EdgeInsets.symmetric(horizontal: gutter)),
          // The full width up to the limit, so every band lines up on the
          // same left edge.
          child: SizedBox(width: double.infinity, child: child),
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.wide, required this.onAccount});

  final bool wide;
  final VoidCallback onAccount;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          Icon(Icons.storefront, color: context.colors.primary),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'Livre Serviço Companion',
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontFamily: _display, fontSize: 20),
            ),
          ),
          TextButton(onPressed: onAccount, child: const Text('Entrar')),
          if (wide) ...[
            const SizedBox(width: 8),
            FilledButton(
              onPressed: DemoMode.enter,
              child: const Text('Experimentar a demo'),
            ),
          ],
        ],
      ),
    );
  }
}

/// The three ways in: the demo first.
class _Actions extends StatelessWidget {
  const _Actions({required this.onAccount, this.onDark = false});

  final VoidCallback onAccount;

  /// On the black closing band: light outlines.
  final bool onDark;

  @override
  Widget build(BuildContext context) {
    const size = Size(0, 52);
    final outlined = OutlinedButton.styleFrom(
      minimumSize: size,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      foregroundColor: onDark ? Colors.white : null,
      side: onDark ? const BorderSide(color: Colors.white54) : null,
    );
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        FilledButton.icon(
          style: FilledButton.styleFrom(
            minimumSize: size,
            padding: const EdgeInsets.symmetric(horizontal: 24),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          icon: const Icon(Icons.play_arrow),
          label: const Text('Experimentar a demo'),
          onPressed: DemoMode.enter,
        ),
        OutlinedButton(
          style: outlined,
          onPressed: onAccount,
          child: const Text('Criar conta'),
        ),
      ],
    );
  }
}

class _Hero extends StatelessWidget {
  const _Hero({required this.wide, required this.onAccount});

  final bool wide;
  final VoidCallback onAccount;

  @override
  Widget build(BuildContext context) {
    final text = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'O dia da loja,\ndas 5h às 5h.',
          style: TextStyle(
            fontFamily: _display,
            fontSize: wide ? 64 : 42,
            height: 1.0,
            letterSpacing: -0.5,
            color: context.colors.onSurface,
          ),
        ),
        const SizedBox(height: 20),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Text(
            'Listas de abertura, tarefas, camiões, inventários e a equipa, '
            'registados por quem os faz. No telemóvel, mesmo sem rede, e no '
            'computador, sempre a par com o resto da loja.',
            style: TextStyle(
              fontSize: wide ? 19 : 17,
              height: 1.5,
              color: context.muted,
            ),
          ),
        ),
        const SizedBox(height: 32),
        _Actions(onAccount: onAccount),
        const SizedBox(height: 12),
        Text(
          'A demonstração abre uma loja de exemplo e não guarda nada.',
          style: TextStyle(fontSize: 13, color: context.muted),
        ),
      ],
    );
    if (!wide) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [text, const SizedBox(height: 40), const _DayPanel()],
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(flex: 6, child: text),
        const SizedBox(width: 56),
        const Expanded(flex: 5, child: _DayPanel()),
      ],
    );
  }
}

/// The hero's picture: a day at the store as the app keeps it, from the
/// opening list to the night shift.
class _DayPanel extends StatelessWidget {
  const _DayPanel();

  static const _day = [
    (
      '05:40',
      'Lista de Abertura enviada',
      'Congelados, OPLS, Não Perecíveis',
      true,
    ),
    ('06:20', 'Camião de não perecíveis', '22 paletes · 2 expositores', true),
    ('09:40', 'Validades da manhã', '12 artigos retirados', true),
    ('15:30', 'Aviso à equipa', 'Visto por 5 de 7', true),
    ('21:40', 'Camião de perecíveis', 'A chegar', false),
    ('22:00', 'Entra o turno da noite', '3 pessoas', false),
  ];

  @override
  Widget build(BuildContext context) {
    const ink = Color(0xFF111111);
    const green = Color(0xFF66BB6A);
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 22, 24, 12),
      decoration: BoxDecoration(
        color: ink,
        borderRadius: BorderRadius.circular(24),
        border: context.isDark ? Border.all(color: context.hairline) : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Row(
            children: [
              Expanded(
                child: Text(
                  'Hoje na loja',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: _display,
                    fontSize: 22,
                    color: Colors.white,
                  ),
                ),
              ),
              Text(
                '4 de 6 feitas',
                style: TextStyle(fontSize: 13, color: Colors.white60),
              ),
            ],
          ),
          const SizedBox(height: 16),
          for (final (i, (time, title, detail, done)) in _day.indexed)
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    width: 52,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 1),
                      child: Text(
                        time,
                        style: TextStyle(
                          fontFamily: _display,
                          fontSize: 16,
                          color: done ? Colors.white : Colors.white54,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 24,
                    child: Column(
                      children: [
                        const SizedBox(height: 4),
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: done ? green : null,
                            border: done
                                ? null
                                : Border.all(color: Colors.white38, width: 2),
                          ),
                        ),
                        if (i < _day.length - 1)
                          Expanded(
                            child: Container(width: 2, color: Colors.white12),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: done ? Colors.white : Colors.white70,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            detail,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.white54,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _Features extends StatelessWidget {
  const _Features({required this.wide});

  final bool wide;

  static const _items = [
    (
      Icons.task_alt,
      'Tarefas diárias e semanais',
      'Quem fez o quê e a que horas, sem folhas perdidas.',
    ),
    (
      Icons.checklist,
      'Listas de Abertura e Automáticas',
      'Enviadas por secção, com o nome de quem as fez.',
    ),
    (
      Icons.local_shipping,
      'Receção de camiões',
      'Paletes por departamento, expositores e vasilhame a devolver.',
    ),
    (
      Icons.assignment,
      'Inventários e pedidos',
      'O valor de cada inventário e os pedidos que estão para chegar.',
    ),
    (
      Icons.people,
      'Pessoas e equipas',
      'Quem trabalha hoje, folgas, ausências, aniversários e funções.',
    ),
    (
      Icons.campaign_outlined,
      'Avisos',
      'Uma mensagem para a equipa ou para uma pessoa, com "Visto".',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final columns = MediaQuery.sizeOf(context).width >= 900
        ? 3
        : MediaQuery.sizeOf(context).width >= 600
        ? 2
        : 1;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tudo o que passa pela secção',
          style: TextStyle(
            fontFamily: _display,
            fontSize: wide ? 36 : 28,
            color: context.colors.onSurface,
          ),
        ),
        const SizedBox(height: 24),
        LayoutBuilder(
          builder: (context, box) {
            const gap = 32.0;
            final width = (box.maxWidth - gap * (columns - 1)) / columns;
            return Wrap(
              spacing: gap,
              children: [
                for (final (icon, title, text) in _items)
                  Container(
                    width: width,
                    padding: const EdgeInsets.only(top: 20, bottom: 28),
                    decoration: BoxDecoration(
                      border: Border(top: BorderSide(color: context.hairline)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(icon, color: context.colors.primary, size: 28),
                        const SizedBox(height: 12),
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          text,
                          style: TextStyle(
                            fontSize: 15,
                            height: 1.45,
                            color: context.muted,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _Steps extends StatelessWidget {
  const _Steps({required this.wide});

  final bool wide;

  static const _steps = [
    ('Crie a conta', 'Com o seu email e uma palavra-passe.'),
    ('Peça o código da loja', 'À chefia, e diga quem é na lista de pessoas.'),
    ('Espere pela aprovação', 'Assim que for aprovado, a loja abre sozinha.'),
  ];

  @override
  Widget build(BuildContext context) {
    final steps = [
      for (final (i, (title, text)) in _steps.indexed)
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${i + 1}',
              style: TextStyle(
                fontFamily: _display,
                fontSize: 48,
                height: 1.0,
                color: context.colors.primary,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    text,
                    style: TextStyle(
                      fontSize: 15,
                      height: 1.45,
                      color: context.muted,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Como começar',
          style: TextStyle(
            fontFamily: _display,
            fontSize: wide ? 36 : 28,
            color: context.colors.onSurface,
          ),
        ),
        const SizedBox(height: 24),
        if (wide)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final (i, s) in steps.indexed) ...[
                if (i > 0) const SizedBox(width: 32),
                Expanded(child: s),
              ],
            ],
          )
        else
          for (final s in steps)
            Padding(padding: const EdgeInsets.only(bottom: 20), child: s),
      ],
    );
  }
}

/// The black band before the footer: the demo, once more.
class _ClosingBand extends StatelessWidget {
  const _ClosingBand({required this.wide});

  final bool wide;

  @override
  Widget build(BuildContext context) {
    final state = context.findAncestorStateOfType<_PresentationScreenState>();
    return ColoredBox(
      color: const Color(0xFF111111),
      child: _Section(
        padding: EdgeInsets.symmetric(vertical: wide ? 64 : 48),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Experimente com uma loja de exemplo.',
              style: TextStyle(
                fontFamily: _display,
                fontSize: wide ? 44 : 32,
                height: 1.05,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Pessoas, tarefas e camiões já lá estão. Nada fica guardado.',
              style: TextStyle(fontSize: 17, color: Colors.white70),
            ),
            const SizedBox(height: 28),
            _Actions(onAccount: state?._account ?? () {}, onDark: true),
          ],
        ),
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer({required this.onPrivacy});

  final VoidCallback onPrivacy;

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(fontSize: 13, color: context.muted);
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 16,
      runSpacing: 4,
      children: [
        Text(copyrightLine(DateTime.now()), style: style),
        Text(
          'Aplicação independente, não oficial do Pingo Doce nem da '
          'Jerónimo Martins.',
          style: style,
        ),
        TextButton(
          onPressed: onPrivacy,
          child: const Text('Política de Privacidade'),
        ),
      ],
    );
  }
}
