import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:livre_servico_app/screens/documents_screen.dart';
import 'package:livre_servico_app/services/document_service.dart';
import 'package:livre_servico_app/services/simple_pdf.dart';
import 'package:livre_servico_app/theme.dart';

import 'helpers/app_db.dart';
import 'helpers/pump.dart';

Widget _app() => MaterialApp(
  theme: buildAppTheme(Brightness.light),
  home: const DocumentsScreen(),
);

void main() {
  setUp(() async {
    await openAppDb();
    DocumentService.instance.reset();
  });
  tearDown(() async {
    DocumentService.instance.reset();
    await closeAppDb();
  });

  testWidgets('without a store, says where the documents come from', (
    tester,
  ) async {
    await pumpApp(tester, _app());
    expect(find.textContaining('depois de entrar numa loja'), findsOneWidget);
    expect(find.text('Adicionar PDF'), findsNothing);
  });

  testWidgets('lists the documents; only the admin manages them', (
    tester,
  ) async {
    DocumentService.instance.remote = MemoryDocumentRemote({
      'Regras de segurança': simplePdf('Regras', const ['Linha']),
    });
    await pumpApp(tester, _app());
    expect(find.text('Regras de segurança'), findsOneWidget);
    expect(find.text('Adicionar PDF'), findsNothing);
    expect(find.byTooltip('Opções'), findsNothing);
  });

  testWidgets('the admin sees Adicionar PDF and the options', (tester) async {
    DocumentService.instance
      ..remote = MemoryDocumentRemote({
        'Regras de segurança': simplePdf('Regras', const ['Linha']),
      })
      ..canManage = true;
    await pumpApp(tester, _app());
    expect(find.text('Adicionar PDF'), findsOneWidget);
    await tapAndSettle(tester, find.byTooltip('Opções'));
    expect(find.text('Renomear'), findsOneWidget);
    expect(find.text('Remover'), findsOneWidget);
  });
}
