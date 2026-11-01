import 'package:flutter/material.dart';

import 'tabs/custom_tasks_tab.dart';
import 'tabs/daily_tasks_tab.dart';
import 'tabs/weekly_tasks_tab.dart';
import 'widgets/wide_layout.dart';

class TasksScreen extends StatelessWidget {
  const TasksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ResponsiveTabs(
      title: Text('Tarefas'),
      tabs: [
        ('Diárias', DailyTasksTab()),
        ('Semanais', WeeklyTasksTab()),
        ('Personalizadas', CustomTasksTab()),
      ],
    );
  }
}
