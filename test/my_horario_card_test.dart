import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:livre_servico_app/models/horario.dart';
import 'package:livre_servico_app/models/person.dart';
import 'package:livre_servico_app/screens/widgets/my_horario_card.dart';
import 'package:livre_servico_app/theme.dart';

import 'helpers/app_db.dart';
import 'helpers/pump.dart';

void main() {
  setUp(openAppDb);
  tearDown(closeAppDb);

  final ana = Person()
    ..fullName = 'Ana Lopes'
    ..syncUuid = 'ana'
    ..createdAt = DateTime(2026);

  // January 2027 from 31/12: Ana on G82, a folga on the 2nd, nothing the 3rd.
  final index = HorarioIndex([
    HorarioMes()
      ..month = DateTime(2027, 1)
      ..firstDay = DateTime(2026, 12, 31)
      ..codigos = {'G82': (entrada: 360, saida: 900)}
      ..linhas = [
        HorarioLinha()
          ..nome = 'Ana Lopes'
          ..personId = 'ana'
          ..codigos = ['G82', 'G82', 'FO', '', 'G82'],
      ]
      ..importedAt = DateTime(2026, 12, 20),
  ]);

  Widget app(Widget child) => MaterialApp(
    theme: buildAppTheme(Brightness.light),
    home: Scaffold(body: child),
  );

  testWidgets('lists the days the horário has, from the first one', (
    tester,
  ) async {
    await pumpApp(
      tester,
      app(
        HorarioDaysList(
          person: ana,
          index: index,
          from: DateTime(2027, 1, 1),
          days: 7,
        ),
      ),
    );
    expect(find.text('Sex 1'), findsOneWidget);
    expect(find.text('06:00–15:00'), findsNWidgets(2));
    expect(find.text('Sáb 2'), findsOneWidget);
    expect(find.text('Folga'), findsOneWidget);
    expect(find.text('Dom 3'), findsNothing);
  });

  testWidgets('the card is hidden without a linked person', (tester) async {
    await pumpApp(tester, app(const MyHorarioCard()));
    expect(find.text('Os meus próximos dias'), findsNothing);
  });
}
