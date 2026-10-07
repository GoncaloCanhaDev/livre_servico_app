import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/daily_tasks.dart';
import '../models/person.dart';
import '../models/teams.dart';
import '../models/visual_list.dart';
import '../services/auto_list_service.dart';
import '../services/daily_tasks_service.dart';
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
          title: 'Camião',
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
      out.add((label: 'Verificação de Validades'));
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

/// Everything recorded about [person]: photo, name and role badges, then one
/// row per field (team and horário always; the rest only when filled in).
class _DetailsTab extends StatelessWidget {
  const _DetailsTab({required this.person});

  final Person person;

  @override
  Widget build(BuildContext context) {
    final p = person;
    final dateFmt = DateFormat("d 'de' MMMM y", 'pt_PT');
    final hasPhoto = p.photoPath != null && File(p.photoPath!).existsSync();
    final tags = roleTagsOf(p);
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
        Text(
          p.fullName,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
        ),
        if (tags.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: 6,
              runSpacing: 4,
              children: [for (final t in tags) RoleBadge(t)],
            ),
          ),
        const SizedBox(height: 12),
        const Divider(height: 1),
        _InfoRow(
          icon: Icons.groups_outlined,
          label: 'Equipa',
          value: _teamLine(p) ?? 'Sem equipa',
        ),
        _InfoRow(
          icon: Icons.schedule,
          label: 'Horário',
          value: p.partTime ? 'Tempo parcial' : 'Tempo inteiro',
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
        if (p.hireDate case final hired?)
          _InfoRow(
            icon: Icons.work_outline,
            label: 'Início na empresa',
            value: dateFmt.format(hired),
          ),
      ],
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
  });

  final IconData icon;
  final String label;
  final String value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.greenDark),
      title: Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
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
