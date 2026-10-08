import 'package:flutter/material.dart';

import 'tabs/custom_tasks_tab.dart';
import 'tabs/daily_tasks_tab.dart';
import 'tabs/weekly_tasks_tab.dart';

class TasksScreen extends StatelessWidget {
  const TasksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const tabs = [
      Tab(text: 'Diárias'),
      Tab(text: 'Semanais'),
      Tab(text: 'Personalizadas'),
    ];
    return DefaultTabController(
      length: tabs.length,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Tarefas'),
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
            tabs: tabs,
          ),
        ),
        body: const TabBarView(
          children: [DailyTasksTab(), WeeklyTasksTab(), CustomTasksTab()],
        ),
      ),
    );
  }
}
