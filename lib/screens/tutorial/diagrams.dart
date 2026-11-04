part of '../tutorial_screen.dart';

// Sketches of the app's screens for the tutorial, made of small boxes and
// lines rather than screenshots, so they follow the theme. The orange
// numbers match the steps under each sketch.

/// A numbered orange circle: on a sketch, it points at what step [n] says.
class _Marker extends StatelessWidget {
  const _Marker(this.n, {this.size = 18});

  final int n;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.orange.shade800,
        shape: BoxShape.circle,
      ),
      child: Text(
        '$n',
        style: TextStyle(
          color: Colors.white,
          fontSize: size * 0.6,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

/// A phone screen: the black bar with [title] (and [actions]) over [children].
class _Screen extends StatelessWidget {
  const _Screen({
    required this.title,
    required this.children,
    this.actions = const [],
  });

  final String title;
  final List<Widget> actions;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 340),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: context.colors.surface,
        border: Border.all(color: context.greyedFill, width: 1.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            color: AppColors.black,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                ...actions,
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: children,
            ),
          ),
        ],
      ),
    );
  }
}

/// A white icon on the black bar, with its marker.
class _BarIcon extends StatelessWidget {
  const _BarIcon(this.icon, this.marker);

  final IconData icon;
  final int marker;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 6),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.white),
          const SizedBox(width: 3),
          _Marker(marker, size: 15),
        ],
      ),
    );
  }
}

/// A rounded box on a sketch; [marker] sits at its top right.
class _Box extends StatelessWidget {
  const _Box({required this.child, this.marker, this.color, this.dark = false});

  final Widget child;
  final int? marker;
  final Color? color;

  /// Black with white text, like the Total cards.
  final bool dark;

  @override
  Widget build(BuildContext context) {
    final box = Container(
      width: double.infinity,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: dark ? AppColors.black : color ?? context.colors.surface,
        border: Border.all(color: dark ? AppColors.black : context.hairline),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DefaultTextStyle.merge(
        style: TextStyle(
          fontSize: 11,
          color: dark ? Colors.white : null,
          height: 1.3,
        ),
        child: child,
      ),
    );
    final m = marker;
    if (m == null) return box;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        box,
        Positioned(top: -6, right: -6, child: _Marker(m)),
      ],
    );
  }
}

/// One line of a sketch: an optional icon, the text, something at the end.
class _Line extends StatelessWidget {
  const _Line(this.text, {this.icon, this.trailing, this.bold = false});

  final String text;
  final IconData? icon;
  final Widget? trailing;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: context.muted),
            const SizedBox(width: 6),
          ],
          Expanded(
            child: Text(
              text,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 11,
                fontWeight: bold ? FontWeight.w700 : null,
              ),
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}

/// A small filled badge, like the role and folga tags.
class _Tag extends StatelessWidget {
  const _Tag(this.text, this.color);

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 4),
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 9,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

/// An outlined button, like Home's.
class _Button extends StatelessWidget {
  const _Button(this.label, {this.icon, this.filled = false});

  final String label;
  final IconData? icon;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final fg = filled ? context.colors.onPrimary : context.colors.onSurface;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: filled ? context.colors.primary : null,
        border: Border.all(color: context.colors.onSurface),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 13, color: fg),
            const SizedBox(width: 4),
          ],
          Flexible(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: fg,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A text field holding [value] (greyed when empty).
class _Field extends StatelessWidget {
  const _Field(this.value, {this.width = 44});

  final String value;

  /// Null stretches it, and its text starts on the left like a hint.
  final double? width;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        border: Border.all(color: context.greyedFill),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        value.isEmpty ? '—' : value,
        textAlign: width == null ? TextAlign.start : TextAlign.end,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 11,
          color: value.isEmpty ? context.faint : null,
        ),
      ),
    );
  }
}

/// A row of tab names, the first one open.
class _Tabs extends StatelessWidget {
  const _Tabs(this.names);

  final List<String> names;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Wrap(
        spacing: 10,
        runSpacing: 4,
        children: [
          for (final (i, n) in names.indexed)
            Container(
              padding: const EdgeInsets.only(bottom: 2),
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: i == 0 ? context.colors.primary : Colors.transparent,
                    width: 2,
                  ),
                ),
              ),
              child: Text(
                n,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: i == 0 ? FontWeight.w800 : null,
                  color: i == 0 ? null : context.muted,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// A down arrow between the stages of a flow.
class _Arrow extends StatelessWidget {
  const _Arrow();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Icon(Icons.arrow_downward, size: 16, color: context.faint),
    );
  }
}

const _gap = SizedBox(height: 8);

/// The WhatsApp chip a send ends with.
class _WhatsApp extends StatelessWidget {
  const _WhatsApp(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return _Box(
      color: context.tint(Colors.green),
      child: Row(
        children: [
          Icon(Icons.chat, size: 14, color: Colors.green.shade700),
          const SizedBox(width: 6),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}

// --- The sketches, one per page ---

/// The service day from 5h to 5h, with the two Validades windows.
class _DayDiagram extends StatelessWidget {
  const _DayDiagram();

  @override
  Widget build(BuildContext context) {
    // Hours from 5h: Manhã 5–14 (9 h), the gap 14–19 (5 h), Noite 19–5 (10 h).
    Widget band(int flex, String label, Color? color) => Expanded(
      flex: flex,
      child: Container(
        height: 28,
        alignment: Alignment.center,
        color: color ?? context.faintest,
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
    Widget hour(int flex, String label) => Expanded(
      flex: flex,
      child: Text(label, style: TextStyle(fontSize: 10, color: context.muted)),
    );
    return Container(
      constraints: const BoxConstraints(maxWidth: 340),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: context.hairline),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Um dia de serviço',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
          ),
          _gap,
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Row(
              children: [
                band(9, 'Manhã', Colors.orange.shade700),
                band(5, '', null),
                band(10, 'Noite', Colors.indigo.shade400),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              hour(9, '5h'),
              hour(5, '14h'),
              hour(9, '19h'),
              Text('5h', style: TextStyle(fontSize: 10, color: context.muted)),
            ],
          ),
          _gap,
          Text(
            'Às 5h abre um dia novo. As janelas Manhã e Noite são as da '
            'Verificação de Validades.',
            style: TextStyle(fontSize: 11, color: context.muted),
          ),
        ],
      ),
    );
  }
}

class _HomeDiagram extends StatelessWidget {
  const _HomeDiagram();

  @override
  Widget build(BuildContext context) {
    const buttons = [
      (Icons.local_shipping, 'Camiões'),
      (Icons.checklist, 'Listas 2.0'),
      (Icons.archive_outlined, 'Listas 1.0'),
      (Icons.assignment, 'Inventários'),
      (Icons.task_alt, 'Tarefas'),
      (Icons.receipt_long, 'Pedidos'),
      (Icons.info_outline, 'Informações'),
      (Icons.description_outlined, 'Documentos'),
      (Icons.history, 'Histórico'),
      (Icons.people, 'Pessoas'),
    ];
    return _Screen(
      title: 'Livre Serviço Companion',
      actions: const [
        _BarIcon(Icons.campaign_outlined, 1),
        _BarIcon(Icons.settings, 2),
      ],
      children: [
        _Box(
          marker: 3,
          color: context.tint(Colors.blue),
          child: const _Line('Aviso: reunião às 15h', icon: Icons.campaign),
        ),
        _gap,
        const _Box(
          marker: 4,
          child: Column(
            children: [
              _Line('Hoje · domingo, 1 de novembro', bold: true),
              _Line('A trabalhar agora (5)', icon: Icons.badge_outlined),
              _Line('Por fazer (3)', icon: Icons.task_alt),
            ],
          ),
        ),
        _gap,
        Stack(
          clipBehavior: Clip.none,
          children: [
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 5,
              crossAxisSpacing: 5,
              childAspectRatio: 4.2,
              children: [for (final (i, l) in buttons) _Button(l, icon: i)],
            ),
            const Positioned(top: -6, right: -6, child: _Marker(5)),
          ],
        ),
      ],
    );
  }
}

class _TodayDiagram extends StatelessWidget {
  const _TodayDiagram();

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 340),
      child: Column(
        children: [
          _Box(
            child: Column(
              children: [
                const _Line('Hoje · domingo, 1 de novembro', bold: true),
                const SizedBox(height: 4),
                _Line(
                  'A trabalhar agora (5) · Ana, Rui, Marta…',
                  icon: Icons.badge_outlined,
                  trailing: const _Marker(1, size: 15),
                ),
                const _Line('     Hoje: 9 de dia · 6 de noite'),
                _Line(
                  'Por fazer (3) · Kiwi Fecho, Lista Visual…',
                  icon: Icons.task_alt,
                  trailing: const _Marker(2, size: 15),
                ),
                _Line(
                  'Aniversários · Sofia · amanhã',
                  icon: Icons.cake_outlined,
                  trailing: const _Marker(3, size: 15),
                ),
                _Line(
                  '1 pedido atrasado · 2 camiões hoje',
                  icon: Icons.receipt_long,
                  trailing: const _Marker(4, size: 15),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TaskDiagram extends StatelessWidget {
  const _TaskDiagram();

  @override
  Widget build(BuildContext context) {
    return _Screen(
      title: 'Tarefas',
      children: [
        Row(
          children: [
            const Expanded(
              child: _Tabs(['Diárias', 'Semanais', 'Personalizadas']),
            ),
            const _Marker(1),
          ],
        ),
        _Box(
          marker: 2,
          child: Row(
            children: [
              _TaskMark(Icons.check, context.colors.primary),
              const SizedBox(width: 4),
              _TaskMark(Icons.close, context.colors.error),
              const SizedBox(width: 6),
              const Expanded(child: _Line('Kiwi Abertura')),
              Text(
                'Por fazer',
                style: TextStyle(fontSize: 11, color: context.muted),
              ),
            ],
          ),
        ),
        const _Arrow(),
        _Box(
          marker: 3,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _Line('Quem concluiu?', bold: true),
              _Line(
                'Ana Costa',
                icon: Icons.check_box,
                trailing: Text('hoje', style: TextStyle(color: context.muted)),
              ),
              const _Line('Rui Silva', icon: Icons.check_box_outline_blank),
            ],
          ),
        ),
        const _Arrow(),
        _Box(
          marker: 4,
          color: context.tint(Colors.green),
          child: Row(
            children: [
              _TaskMark(Icons.check, context.colors.primary, filled: true),
              const SizedBox(width: 6),
              const Expanded(child: _Line('Kiwi Abertura · Por Ana Costa')),
            ],
          ),
        ),
        _gap,
        const Stack(
          clipBehavior: Clip.none,
          children: [
            _WhatsApp('✅ Kiwi Abertura · Ana Costa'),
            Positioned(top: -6, right: -6, child: _Marker(5)),
          ],
        ),
        _gap,
        _Box(
          marker: 6,
          color: context.tint(Colors.red),
          child: Row(
            children: [
              _TaskMark(Icons.close, context.colors.error, filled: true),
              const SizedBox(width: 6),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _Line('Kiwi Fecho · Rui Silva'),
                    Text(
                      'Não feita: sem sistema',
                      style: TextStyle(
                        fontSize: 10,
                        color: context.colors.error,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// A task's ✓ Feita or ✗ Não feita marker, small.
class _TaskMark extends StatelessWidget {
  const _TaskMark(this.icon, this.color, {this.filled = false});

  final IconData icon;
  final Color color;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 18,
      height: 18,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: filled ? color : null,
        border: Border.all(color: color, width: 1.5),
      ),
      child: Icon(icon, size: 12, color: filled ? Colors.white : color),
    );
  }
}

class _AberturaDiagram extends StatelessWidget {
  const _AberturaDiagram();

  @override
  Widget build(BuildContext context) {
    Widget section(String name, String value, {String? by, int? marker}) =>
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 3),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (by != null)
                      Text(
                        by,
                        style: TextStyle(fontSize: 10, color: context.muted),
                      ),
                  ],
                ),
              ),
              _Field(value),
              const SizedBox(width: 6),
              Icon(
                by == null ? Icons.send : Icons.check_circle,
                size: 16,
                color: context.colors.primary,
              ),
              SizedBox(
                width: 22,
                child: marker == null
                    ? null
                    : Align(
                        alignment: Alignment.centerRight,
                        child: _Marker(marker, size: 15),
                      ),
              ),
            ],
          ),
        );
    return _Screen(
      title: 'Listas 1.0',
      children: [
        const Row(
          children: [
            Expanded(
              child: _Tabs([
                'Abertura',
                'Automáticas',
                'Relatório Dia Anterior',
                'Visual',
              ]),
            ),
            _Marker(1),
          ],
        ),
        section('Congelados', '12', by: 'Por Ana Costa', marker: 4),
        section('OPLS', '8', marker: 3),
        section('Não Perecíveis', '', marker: 2),
        _gap,
        const _Box(
          dark: true,
          marker: 5,
          child: _Line(
            'Total',
            bold: true,
            trailing: Text(
              '20',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
            ),
          ),
        ),
      ],
    );
  }
}

class _Listas2Diagram extends StatelessWidget {
  const _Listas2Diagram();

  @override
  Widget build(BuildContext context) {
    Widget item(String name, String value, {int? marker}) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          Expanded(
            child: Text(
              name,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
            ),
          ),
          _Field(value),
          const SizedBox(width: 6),
          Icon(
            Icons.check_circle,
            size: 16,
            color: value.isEmpty ? context.faint : context.colors.primary,
          ),
          SizedBox(
            width: 22,
            child: marker == null
                ? null
                : Align(
                    alignment: Alignment.centerRight,
                    child: _Marker(marker, size: 15),
                  ),
          ),
        ],
      ),
    );
    return _Screen(
      title: 'Listas 2.0',
      children: [
        const Row(
          children: [
            Expanded(child: _Tabs(['Automáticas', 'Visível'])),
            _Marker(1),
          ],
        ),
        item('Mercearia', '14', marker: 2),
        item('Pet Food', ''),
        item('Bebidas', '', marker: 3),
        item('Vinhos e Destilados', ''),
      ],
    );
  }
}

class _Visivel2Diagram extends StatelessWidget {
  const _Visivel2Diagram();

  @override
  Widget build(BuildContext context) {
    return const _Screen(
      title: 'Listas 2.0',
      children: [
        _Tabs(['Automáticas', 'Visível']),
        _Box(marker: 1, child: _Line('Itens Picados', trailing: _Field('37'))),
        _gap,
        Row(
          children: [
            _Button('Finalizar', icon: Icons.check_circle, filled: true),
            SizedBox(width: 6),
            _Marker(2),
          ],
        ),
        _gap,
        _Box(
          dark: true,
          marker: 3,
          child: _Line(
            'Hoje · Itens Picados',
            bold: true,
            trailing: Text(
              '37',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
            ),
          ),
        ),
      ],
    );
  }
}

class _ReportDiagram extends StatelessWidget {
  const _ReportDiagram();

  @override
  Widget build(BuildContext context) {
    Widget value(String label, String v) =>
        _Line(label, trailing: _Field(v, width: 52));
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 340),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: _Box(
              marker: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const _Line('Relatório', bold: true),
                  value('Dias s/ vendas', '4'),
                  value('Regularizações', '2'),
                  value('Massiva', '1'),
                  value('Repetidos', '0'),
                  const SizedBox(height: 6),
                  const Row(
                    children: [
                      Expanded(child: _Button('Finalizar', filled: true)),
                      SizedBox(width: 4),
                      _Marker(2, size: 15),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _Box(
              marker: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const _Line('Visual', bold: true),
                  value('Itens Picados', '120'),
                  value('Quebra (€)', '35,40'),
                  value('Benefício (€)', '12,10'),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(3),
                          child: LinearProgressIndicator(
                            value: 0.6,
                            minHeight: 6,
                            backgroundColor: context.hairline,
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      const _Marker(4, size: 15),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '120 de 200',
                    style: TextStyle(fontSize: 10, color: context.muted),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TruckDiagram extends StatelessWidget {
  const _TruckDiagram();

  @override
  Widget build(BuildContext context) {
    Widget header(String title, String action, int marker) => Padding(
      padding: const EdgeInsets.only(top: 6, bottom: 2),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
            ),
          ),
          Text(
            action,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: context.colors.primary,
            ),
          ),
          const SizedBox(width: 4),
          _Marker(marker, size: 15),
        ],
      ),
    );
    return _Screen(
      title: 'Receção de Camião',
      actions: const [_Marker(1, size: 15)],
      children: [
        const _Line(
          'Tipo de camião · Perecíveis',
          icon: Icons.local_shipping_outlined,
          trailing: _Marker(2, size: 15),
        ),
        const _Line('Hora de chegada · 07:30', icon: Icons.schedule),
        header('Paletes', '+ Adicionar', 3),
        const _Line('Mercearia', trailing: _Field('6')),
        const _Line('Bebidas', trailing: _Field('4')),
        header('Expositores', '+ Adicionar', 4),
        const _Line('Gelados · 2'),
        header('Vasilhame a Enviar', 'Selecionar', 5),
        const _Line('Palete EUR · 3'),
        const SizedBox(height: 6),
        const Row(
          children: [
            Expanded(child: _Field('Matrícula', width: null)),
            SizedBox(width: 6),
            Expanded(child: _Field('Fornecedor', width: null)),
            SizedBox(width: 4),
            _Marker(6, size: 15),
          ],
        ),
        _gap,
        const Row(
          children: [
            Expanded(
              child: _Button('Guardar', icon: Icons.check, filled: true),
            ),
            SizedBox(width: 4),
            _Marker(7, size: 15),
          ],
        ),
      ],
    );
  }
}

class _InventoryDiagram extends StatelessWidget {
  const _InventoryDiagram();

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 340),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Box(
            marker: 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const _Line('Novo inventário', bold: true),
                const Row(
                  children: [
                    Expanded(child: _Field('Iogurtes', width: null)),
                    SizedBox(width: 6),
                    _Field('4471', width: 60),
                  ],
                ),
                const SizedBox(height: 6),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    'Continuar',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: context.colors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const _Arrow(),
          const _Box(
            marker: 2,
            child: _Line(
              'Valor do inventário',
              bold: true,
              trailing: _Field('-12,50', width: 60),
            ),
          ),
          const SizedBox(height: 14),
          _Box(
            marker: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const _Line('Novo pedido', bold: true),
                const _Line('Número do pedido', trailing: _Field('4512')),
                const _Line(
                  'Fornecedor (opcional)',
                  trailing: _Field('Lactogal', width: 70),
                ),
                const _Line(
                  'Data prevista de chegada',
                  trailing: _Field('3/11', width: 50),
                ),
              ],
            ),
          ),
          const _Arrow(),
          _Box(
            marker: 4,
            child: _Line(
              'Pedido 4512 · Lactogal · 3/11',
              icon: Icons.receipt_long,
              trailing: _Tag('Atrasado', Colors.orange.shade800),
            ),
          ),
        ],
      ),
    );
  }
}

class _PeopleDiagram extends StatelessWidget {
  const _PeopleDiagram();

  @override
  Widget build(BuildContext context) {
    Widget person(String name, List<Widget> tags) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        children: [
          CircleAvatar(
            radius: 10,
            backgroundColor: context.hairline,
            child: Text(
              name[0],
              style: TextStyle(fontSize: 10, color: context.colors.onSurface),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              runSpacing: 2,
              children: [
                Text(name, style: const TextStyle(fontSize: 11)),
                ...tags,
              ],
            ),
          ),
        ],
      ),
    );
    Widget section(String title) => Padding(
      padding: const EdgeInsets.only(top: 6, bottom: 2),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: context.muted,
        ),
      ),
    );
    return _Screen(
      title: 'Pessoas',
      actions: const [_BarIcon(Icons.add, 4)],
      children: [
        const Row(
          children: [
            Expanded(
              child: _Field('Procurar por nome, equipa ou nº', width: null),
            ),
            SizedBox(width: 4),
            _Marker(1, size: 15),
          ],
        ),
        section('Livre Serviço · Dia'),
        Row(
          children: [
            Expanded(
              child: person('Ana Costa', [
                _Tag('Chefe de Secção', AppColors.black),
              ]),
            ),
            const _Marker(3, size: 15),
          ],
        ),
        Row(
          children: [
            Expanded(
              child: person('Rui Silva', [
                _Tag('Novo', Colors.blue.shade700),
                _Tag('🎂 Faz anos', Colors.pink.shade400),
              ]),
            ),
            const _Marker(2, size: 15),
          ],
        ),
        person('Marta Lopes', [_Tag('Folga', Colors.grey.shade600)]),
        person('João Reis', [_Tag('Férias', Colors.orange.shade800)]),
      ],
    );
  }
}

class _InfoDiagram extends StatelessWidget {
  const _InfoDiagram();

  @override
  Widget build(BuildContext context) {
    Widget group(IconData icon, String name, int marker) => Expanded(
      child: _Box(
        marker: marker,
        child: Column(
          children: [
            Icon(icon, size: 20, color: context.colors.primary),
            const SizedBox(height: 4),
            Text(
              name,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
    return _Screen(
      title: 'Informações',
      children: [
        Row(
          children: [
            group(Icons.store, 'Informações da Loja', 1),
            const SizedBox(width: 8),
            group(Icons.rule, 'Protocolos', 2),
          ],
        ),
        _gap,
        Row(
          children: [
            group(Icons.support_agent, 'Ações de Suporte', 2),
            const SizedBox(width: 8),
            group(Icons.contact_phone, 'Contactos Úteis', 3),
          ],
        ),
        _gap,
        _Box(
          marker: 4,
          child: _Line(
            'Manutenção · Sr. Carlos',
            icon: Icons.push_pin,
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final i in [Icons.phone, Icons.chat, Icons.email])
                  Padding(
                    padding: const EdgeInsets.only(left: 6),
                    child: Icon(i, size: 14, color: context.colors.primary),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _DocumentsDiagram extends StatelessWidget {
  const _DocumentsDiagram();

  @override
  Widget build(BuildContext context) {
    Widget doc(String title, String info, {int? marker}) => _Box(
      marker: marker,
      child: _Line(
        title,
        icon: Icons.picture_as_pdf,
        trailing: Text(
          info,
          style: TextStyle(fontSize: 10, color: context.muted),
        ),
      ),
    );
    return _Screen(
      title: 'Documentos',
      children: [
        doc('Receção de mercadoria', '320 KB', marker: 1),
        _gap,
        doc('Regras de segurança', '1,2 MB', marker: 2),
      ],
    );
  }
}

class _HistoricoDiagram extends StatelessWidget {
  const _HistoricoDiagram();

  @override
  Widget build(BuildContext context) {
    return _Screen(
      title: 'Histórico',
      children: [
        const Row(
          children: [
            Expanded(
              child: _Tabs([
                'Tudo',
                'Camiões',
                'Abertura',
                'Automáticas',
                'Relatório',
                '…',
              ]),
            ),
            _Marker(1),
          ],
        ),
        const Row(
          children: [
            Icon(Icons.search, size: 14),
            SizedBox(width: 4),
            Expanded(child: _Field('Mercearia', width: null)),
            SizedBox(width: 4),
            _Marker(2, size: 15),
          ],
        ),
        _gap,
        const _Box(
          marker: 3,
          child: Column(
            children: [
              _Line(
                'Camião · Perecíveis · 07:30',
                icon: Icons.local_shipping_outlined,
              ),
              _Line('     Mercearia 6 · Bebidas 4 · por Rui Silva'),
            ],
          ),
        ),
        _gap,
        const _Box(
          child: _Line('Lista de Abertura · Total 20', icon: Icons.checklist),
        ),
      ],
    );
  }
}

class _AvisosDiagram extends StatelessWidget {
  const _AvisosDiagram();

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 340),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _Box(
            marker: 1,
            color: context.tint(Colors.blue),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const _Line(
                  'Reunião de equipa às 15h na sala.',
                  icon: Icons.campaign,
                  bold: true,
                ),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'De Ana Costa · há 2 h',
                        style: TextStyle(fontSize: 10, color: context.muted),
                      ),
                    ),
                    const _Button('Visto'),
                    const SizedBox(width: 4),
                    const _Marker(2, size: 15),
                  ],
                ),
              ],
            ),
          ),
          _gap,
          _Screen(
            title: 'Novo aviso',
            actions: const [_Marker(4, size: 15)],
            children: [
              const _Field('Reunião de equipa às 15h na sala.', width: null),
              _gap,
              const Text(
                'Para',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              Wrap(
                spacing: 4,
                runSpacing: 4,
                children: [
                  _Tag('Livre Serviço', context.colors.primary),
                  _Tag('Fruta', context.greyedFill),
                  _Tag('Escolher pessoas', context.greyedFill),
                ],
              ),
              _gap,
              const _Button('Enviar', icon: Icons.send, filled: true),
            ],
          ),
        ],
      ),
    );
  }
}

class _AccountDiagram extends StatelessWidget {
  const _AccountDiagram();

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 340),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _Box(
            marker: 1,
            child: _Line(
              'Criar conta · email e palavra-passe',
              icon: Icons.person_add_alt,
            ),
          ),
          const _Arrow(),
          const _Box(
            marker: 2,
            child: _Line(
              'Entrar com código',
              icon: Icons.key,
              trailing: _Field('K7P2QX', width: 64),
            ),
          ),
          const _Arrow(),
          const _Box(
            marker: 3,
            child: _Line(
              'Quem é você? · Rui Silva',
              icon: Icons.badge_outlined,
            ),
          ),
          const _Arrow(),
          _Box(
            marker: 4,
            color: context.tint(Colors.orange),
            child: const _Line(
              'Pedido enviado · à espera de aprovação',
              icon: Icons.hourglass_top,
            ),
          ),
          const _Arrow(),
          _Box(
            marker: 5,
            color: context.tint(Colors.green),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.phone_android, size: 22),
                const SizedBox(width: 6),
                Icon(Icons.sync_alt, size: 16, color: context.muted),
                const SizedBox(width: 6),
                Icon(Icons.cloud_done, size: 26, color: Colors.green.shade700),
                const SizedBox(width: 6),
                Icon(Icons.sync_alt, size: 16, color: context.muted),
                const SizedBox(width: 6),
                const Icon(Icons.phone_android, size: 22),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
