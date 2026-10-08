import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/daily_tasks.dart';
import '../models/horario.dart';
import '../models/opening_list.dart';
import '../models/person.dart';
import '../models/planning.dart';
import '../models/teams.dart';
import '../models/truck_reception.dart';
import '../models/validades.dart';
import '../models/visual_list.dart';
import '../services/auto_list_service.dart';
import '../services/daily_tasks_service.dart';
import '../services/horario_service.dart';
import '../services/inventory_service.dart';
import '../services/opening_list_service.dart';
import '../services/person_service.dart';
import '../services/report_list_service.dart';
import '../services/truck_service.dart';
import '../services/visual_list_service.dart';
import '../theme.dart';
import 'person_form_screen.dart';
import 'widgets/person_picker.dart';
import 'widgets/role_badge.dart';

class PersonDetailScreen extends StatefulWidget {
  const PersonDetailScreen({super.key, required this.person});

  final Person person;

  @override
  State<PersonDetailScreen> createState() => _PersonDetailScreenState();
}

class _PersonDetailScreenState extends State<PersonDetailScreen> {
  late Person _person;
  late Future<Map<DateTime, List<_ActivityItem>>> _future;

  @override
  void initState() {
    super.initState();
    _person = widget.person;
    _future = _load();
    OpeningListService.instance.addListener(_reload);
    AutoListService.instance.addListener(_reload);
    ReportListService.instance.addListener(_reload);
    VisualListService.instance.addListener(_reload);
    DailyTasksService.instance.addListener(_reload);
    InventoryService.instance.addListener(_reload);
    TruckService.instance.addListener(_reload);
    PersonService.instance.addListener(_reload);
    HorarioService.instance.addListener(_reload);
  }

  @override
  void dispose() {
    OpeningListService.instance.removeListener(_reload);
    AutoListService.instance.removeListener(_reload);
    ReportListService.instance.removeListener(_reload);
    VisualListService.instance.removeListener(_reload);
    DailyTasksService.instance.removeListener(_reload);
    InventoryService.instance.removeListener(_reload);
    TruckService.instance.removeListener(_reload);
    PersonService.instance.removeListener(_reload);
    HorarioService.instance.removeListener(_reload);
    super.dispose();
  }

  void _reload() {
    if (!mounted) return;
    setState(() => _future = _load());
  }

  DateTime _toServiceDay(DateTime dt) {
    if (dt.hour < 5) {
      final y = dt.subtract(const Duration(days: 1));
      return DateTime(y.year, y.month, y.day, 5);
    }
    return DateTime(dt.year, dt.month, dt.day, 5);
  }

  Future<Map<DateTime, List<_ActivityItem>>> _load() async {
    final name = _person.fullName;
    final items = <_ActivityItem>[];

    final openings = await OpeningListService.instance.history();
    for (final o in openings) {
      if (!o.isFinalized) continue;
      if (!resolveNames(o.createdByNames, o.createdByInitials).contains(name)) {
        continue;
      }
      items.add(
        _ActivityItem(
          time: o.finalizedAt ?? o.serviceDay,
          icon: Icons.check_circle,
          iconColor: AppColors.green,
          title: 'Lista de Abertura',
          subtitle:
              'Cong: ${o.congelados} · OPLS: ${o.opls} · NP: ${o.naoPereciveis} · Total: ${o.total}',
        ),
      );
    }

    final autos = await AutoListService.instance.history();
    for (final a in autos) {
      if (!resolveNames(a.createdByNames, a.createdByInitials).contains(name)) {
        continue;
      }
      items.add(
        _ActivityItem(
          time: a.createdAt,
          icon: Icons.bolt,
          iconColor: AppColors.green,
          title: 'Lista Automática',
          subtitle:
              'Cong: ${a.congelados} · OPLS: ${a.opls} · NP: ${a.naoPereciveis} · Total: ${a.total}',
        ),
      );
    }

    final reports = await ReportListService.instance.history();
    for (final r in reports) {
      if (!r.isFinalized) continue;
      if (!resolveNames(r.createdByNames, r.createdByInitials).contains(name)) {
        continue;
      }
      items.add(
        _ActivityItem(
          time: r.finalizedAt ?? r.serviceDay,
          icon: Icons.check_circle,
          iconColor: AppColors.green,
          title: 'Relatório',
          subtitle:
              'DSV: ${r.diasSemVendas} · Reg: ${r.regularizacoes} · Mas: ${r.massiva} · Rep: ${r.repetidos} · Total: ${r.total}',
        ),
      );
    }

    final visuals = await VisualListService.instance.all();
    for (final v in visuals) {
      if (!resolveNames(v.createdByNames, v.createdByInitials).contains(name)) {
        continue;
      }
      final total = v.beneficioCents - v.quebraCents;
      items.add(
        _ActivityItem(
          time: v.createdAt,
          icon: Icons.visibility,
          iconColor: AppColors.green,
          title: 'Lista Visual',
          subtitle: '${v.itensPicados} itens · Total ${formatCents(total)} €',
        ),
      );
    }

    final invs = await InventoryService.instance.history();
    for (final inv in invs) {
      if (!resolveNames(
        inv.createdByNames,
        inv.createdByInitials,
      ).contains(name)) {
        continue;
      }
      items.add(
        _ActivityItem(
          time: inv.createdAt,
          icon: Icons.assignment,
          iconColor: inv.valueCents >= 0 ? AppColors.green : Colors.redAccent,
          title: 'Inventário: ${inv.name}',
          subtitle: '${formatCents(inv.valueCents)} €',
        ),
      );
    }

    final trucks = await TruckService.instance.all();
    for (final t in trucks) {
      if (!resolveNames(t.createdByNames, t.createdByInitials).contains(name)) {
        continue;
      }
      final parts = <String>[
        if (t.licensePlate != null) t.licensePlate!,
        if (t.supplier != null) t.supplier!,
      ];
      items.add(
        _ActivityItem(
          time: t.arrivalTime,
          icon: Icons.local_shipping,
          iconColor: AppColors.green,
          title: truckTitle(t),
          subtitle:
              '${parts.isNotEmpty ? '${parts.join(' · ')} · ' : ''}${t.totalPallets} paletes',
        ),
      );
    }

    final tasks = await DailyTasksService.instance.history();
    for (final t in tasks) {
      final done = _tasksDoneByPerson(t, name);
      for (final entry in done) {
        items.add(
          _ActivityItem(
            time: t.lastUpdatedAt ?? t.serviceDay,
            icon: Icons.task_alt,
            iconColor: AppColors.green,
            title: 'Tarefa: ${entry.label}',
            subtitle: DateFormat(
              "EEE, d 'de' MMM y",
              'pt_PT',
            ).format(t.serviceDay),
          ),
        );
      }
    }

    final grouped = <DateTime, List<_ActivityItem>>{};
    for (final item in items) {
      final day = _toServiceDay(item.time);
      (grouped[day] ??= []).add(item);
    }
    final sortedKeys = grouped.keys.toList()..sort((a, b) => b.compareTo(a));
    final result = <DateTime, List<_ActivityItem>>{};
    for (final key in sortedKeys) {
      grouped[key]!.sort((a, b) => b.time.compareTo(a.time));
      result[key] = grouped[key]!;
    }
    return result;
  }

  List<({String label})> _tasksDoneByPerson(DailyTasks t, String name) {
    final out = <({String label})>[];
    if (t.kiwiAbertura &&
        resolveNames(t.kiwiAberturaByNames, t.kiwiAberturaBy).contains(name)) {
      out.add((label: 'Kiwi Abertura'));
    }
    if (t.alteracoesPreco &&
        resolveNames(
          t.alteracoesPrecoByNames,
          t.alteracoesPrecoBy,
        ).contains(name)) {
      out.add((label: 'Alterações de Preço'));
    }
    if (t.verificacaoTemperaturas &&
        resolveNames(
          t.verificacaoTemperaturasByNames,
          t.verificacaoTemperaturasBy,
        ).contains(name)) {
      out.add((label: 'Verificação de Temperaturas'));
    }
    if (t.preenchimentoQuadro &&
        resolveNames(
          t.preenchimentoQuadroByNames,
          t.preenchimentoQuadroBy,
        ).contains(name)) {
      out.add((label: 'Preenchimento do Quadro'));
    }
    if (t.verificacaoValidades &&
        resolveNames(
          t.verificacaoValidadesByNames,
          t.verificacaoValidadesBy,
        ).contains(name)) {
      out.add((label: ValidadesTurno.manha.label));
    }
    if (t.validadesNoite && t.validadesNoiteByNames.contains(name)) {
      out.add((label: ValidadesTurno.noite.label));
    }
    if (t.kiwiFecho &&
        resolveNames(t.kiwiFechoByNames, t.kiwiFechoBy).contains(name)) {
      out.add((label: 'Kiwi Fecho'));
    }
    return out;
  }

  Future<void> _openEditForm() async {
    final result = await Navigator.of(context).push<Person>(
      MaterialPageRoute(builder: (_) => PersonFormScreen(existing: _person)),
    );
    if (result != null && mounted) {
      setState(() => _person = result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(_person.fullName),
          actions: [
            IconButton(icon: const Icon(Icons.edit), onPressed: _openEditForm),
          ],
          bottom: const TabBar(
            labelColor: AppColors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: AppColors.white,
            tabs: [
              Tab(text: 'Detalhes'),
              Tab(text: 'Histórico'),
            ],
          ),
        ),
        body: SafeArea(
          child: TabBarView(
            children: [
              _DetailsTab(person: _person),
              _historyTab(),
            ],
          ),
        ),
      ),
    );
  }

  /// The person's activity, grouped by day (newest first).
  Widget _historyTab() {
    final dayFmt = DateFormat("EEEE, d 'de' MMMM y", 'pt_PT');
    final timeFmt = DateFormat('HH:mm');
    return FutureBuilder<Map<DateTime, List<_ActivityItem>>>(
      future: _future,
      builder: (_, snap) {
        if (!snap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final grouped = snap.data!;
        if (grouped.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Text(
                'Sem atividade registada.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.black54),
              ),
            ),
          );
        }
        final days = grouped.keys.toList();
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: days.length,
          itemBuilder: (_, i) {
            final day = days[i];
            final items = grouped[day]!;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (i > 0) const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    dayFmt.format(day),
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.greenDark,
                    ),
                  ),
                ),
                ...items.map(
                  (item) => Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: Icon(item.icon, color: item.iconColor, size: 24),
                      title: Text(
                        item.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      subtitle: Text(
                        item.subtitle,
                        style: const TextStyle(fontSize: 12),
                      ),
                      trailing: Text(
                        timeFmt.format(item.time),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black45,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

/// Everything recorded about [person]: photo, name and role badges, whether
/// they are off today, then one row per field (team and horário always; the
/// rest only when filled in) under Planeamento, Datas and Notas headings.
class _DetailsTab extends StatelessWidget {
  const _DetailsTab({required this.person});

  final Person person;

  @override
  Widget build(BuildContext context) {
    final p = person;
    final dateFmt = DateFormat("d 'de' MMMM y", 'pt_PT');
    final hasPhoto = p.photoPath != null && File(p.photoPath!).existsSync();
    // The service day, so a night shift still counts as today after midnight.
    final today = currentServiceDay();
    final schedule = HorarioService.instance.index;
    final away = ausenciaOn(p, today);
    final awayTag = awayTagOn(p, today, horario: schedule);
    final offToday = offLabelOn(p, today, horario: schedule);
    final scheduleDays = [
      for (var i = 0; i < 7; i++)
        DateTime(today.year, today.month, today.day + i),
    ].where((d) => schedule.hasLine(p, d)).toList();
    final tags = roleTagsOf(p);
    final tenure = tenureTagOf(p, today);
    final upcoming = upcomingAusencias(p, today);
    final horario = horarioText(p);
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 16),
      children: [
        Center(
          child: hasPhoto
              ? CircleAvatar(
                  radius: 44,
                  backgroundImage: FileImage(File(p.photoPath!)),
                )
              : PersonInitialsBadge(name: p.fullName, size: 88),
        ),
        const SizedBox(height: 12),
        Text.rich(
          TextSpan(
            text: p.fullName,
            children: [
              if (p.genero case final g?)
                WidgetSpan(
                  alignment: PlaceholderAlignment.middle,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 6),
                    child: GeneroIcon(g, size: 22),
                  ),
                ),
            ],
          ),
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
        ),
        if (tags.isNotEmpty || tenure != null || awayTag != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: 6,
              runSpacing: 4,
              children: [
                for (final t in tags) RoleBadge(t),
                if (tenure != null) RoleBadge(tenure, tenure: true),
                if (awayTag != null) RoleBadge(awayTag, away: true),
              ],
            ),
          ),
        const SizedBox(height: 12),
        const Divider(height: 1),
        if (away != null)
          _InfoRow(
            icon: Icons.event_busy,
            label: 'Hoje',
            value: '${away.tipo.label} até ${dateFmt.format(away.end)}',
            highlight: true,
          )
        else if (offToday != null)
          _InfoRow(
            icon: Icons.event_busy,
            label: 'Hoje',
            value: offToday,
            highlight: true,
          )
        else if (_scheduleText(p, today, schedule) case final shift?)
          _InfoRow(icon: Icons.work_outline, label: 'Hoje', value: shift),
        _InfoRow(
          icon: Icons.groups_outlined,
          label: 'Equipa',
          value: _teamLine(p) ?? 'Sem equipa',
        ),
        if (p.collaboratorNumber.isNotEmpty)
          _InfoRow(
            icon: Icons.badge_outlined,
            label: 'Nº colaborador',
            value: p.collaboratorNumber,
          ),
        if (p.phoneNumber case final phone?)
          _InfoRow(
            icon: Icons.phone,
            label: 'Telefone',
            value: phone,
            onTap: () => launchUrl(Uri(scheme: 'tel', path: phone)),
          ),
        if (p.dateOfBirth case final dob?)
          _InfoRow(
            icon: Icons.cake_outlined,
            label: 'Data de nascimento',
            value: dateFmt.format(dob),
          ),
        if (scheduleDays.isNotEmpty) ...[
          const _DetailHeading('Horário'),
          for (final d in scheduleDays)
            _InfoRow(
              icon: Icons.calendar_today_outlined,
              label: _dayName(d, today),
              value: _scheduleText(p, d, schedule) ?? '—',
              highlight: offLabelOn(p, d, horario: schedule) != null,
            ),
        ],
        const _DetailHeading('Planeamento'),
        _InfoRow(
          icon: Icons.schedule,
          label: 'Horário',
          value: [
            p.partTime ? 'Tempo parcial' : 'Tempo inteiro',
            if (p.weeklyHours case final h?) '$h h/semana',
          ].join(' · '),
        ),
        if (horario != null)
          _InfoRow(
            icon: Icons.access_time,
            label: 'Entrada e saída',
            value: horario,
          ),
        if (p.folgas.isNotEmpty)
          _InfoRow(
            icon: Icons.weekend_outlined,
            label: 'Folgas',
            value: folgasText(p.folgas),
          ),
        for (final a in upcoming)
          _InfoRow(
            icon: Icons.event_busy,
            label: a.tipo.label,
            value: ausenciaRangeText(a),
          ),
        if (p.storeStartDate != null || p.hireDate != null)
          const _DetailHeading('Datas'),
        if (p.storeStartDate case final since?)
          _InfoRow(
            icon: Icons.storefront_outlined,
            label: 'Na loja · desde ${dateFmt.format(since)}',
            value: tenureText(since, today),
          ),
        if (p.hireDate case final since?)
          _InfoRow(
            icon: Icons.work_outline,
            label: 'No Pingo Doce · desde ${dateFmt.format(since)}',
            value: tenureText(since, today),
          ),
        if (p.notes.isNotEmpty) const _DetailHeading('Notas'),
        for (final note in p.notes)
          ListTile(
            leading: const Icon(Icons.notes, color: AppColors.greenDark),
            title: Text(note),
          ),
      ],
    );
  }
}

/// [p]'s horário on [day]: "H73 · 07:00–16:00 (pausa 12:00–13:00)", the
/// absence's name ("Folga", "Férias"), or null without a line that month.
String? _scheduleText(Person p, DateTime day, HorarioIndex schedule) {
  final code = schedule.codeOn(p, day);
  if (code == null) return null;
  if (schedule.horarios.codigos[code] case final shift?) {
    return '$code · ${shift.timesText}';
  }
  return schedule.horarios.ausencias[code] ?? code;
}

/// "Hoje", "Amanhã" or "Sexta, 9 out".
String _dayName(DateTime day, DateTime today) {
  final diff = DateTime(
    day.year,
    day.month,
    day.day,
  ).difference(DateTime(today.year, today.month, today.day)).inDays;
  if (diff == 0) return 'Hoje';
  if (diff == 1) return 'Amanhã';
  final name = DateFormat("EEEE, d MMM", 'pt_PT').format(day);
  return name[0].toUpperCase() + name.substring(1);
}

/// A group title on the Detalhes tab.
class _DetailHeading extends StatelessWidget {
  const _DetailHeading(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 4),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.w700,
          color: AppColors.greenDark,
        ),
      ),
    );
  }
}

/// One labeled field on the Detalhes tab; tappable (e.g. to call) when
/// [onTap] is set.
class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.onTap,
    this.highlight = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final VoidCallback? onTap;

  /// Drawn in orange, for the person being off today.
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final color = highlight ? Colors.orange.shade800 : AppColors.greenDark;
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(
        value,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: highlight ? color : null,
        ),
      ),
      subtitle: Text(label),
      trailing: onTap == null
          ? null
          : const Icon(Icons.call, color: AppColors.greenDark),
      onTap: onTap,
    );
  }
}

class _ActivityItem {
  _ActivityItem({
    required this.time,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
  });
  final DateTime time;
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
}

/// "Talho", "Livre Serviço · Noite", or null for Sem equipa. Roles are shown
/// as badges instead.
String? _teamLine(Person p) {
  final team = teamById(p.team);
  if (team == null) return null;
  return [team.name, ?turnoOf(p)?.label].join(' · ');
}
