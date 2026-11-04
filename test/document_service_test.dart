import 'dart:convert';
import 'dart:typed_data';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:livre_servico_app/models/app_document.dart';
import 'package:livre_servico_app/services/document_service.dart';
import 'package:livre_servico_app/services/local_db.dart';
import 'package:livre_servico_app/services/simple_pdf.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  final service = DocumentService.instance;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await LocalDb.init(executor: NativeDatabase.memory());
    service.reset();
  });
  tearDown(() => LocalDb.instance.close());

  Uint8List pdf(String title) =>
      simplePdf(title, const ['Linha', '', '# Parte']);

  test('lists the documents by title', () async {
    service.remote = MemoryDocumentRemote({
      'Regras': pdf('Regras'),
      'apresentação': pdf('apresentação'),
    });
    await service.refresh();
    expect(service.documents.map((d) => d.title), ['apresentação', 'Regras']);
  });

  test('keeps the list and the opened PDFs for offline', () async {
    final remote = MemoryDocumentRemote({'Regras': pdf('Regras')});
    service.remote = remote;
    await service.refresh();
    final doc = service.documents.single;
    expect(await service.isKept(doc), isFalse);
    final bytes = await service.open(doc);
    expect(await service.isKept(doc), isTrue);

    // Offline, on a fresh start: the list and the PDF are still here.
    remote.offline = true;
    service.reset();
    service.remote = remote;
    await expectLater(service.refresh(), throwsA(anything));
    expect(service.documents.single.title, 'Regras');
    expect(await service.open(service.documents.single), bytes);
  });

  test('drops the PDFs of documents no longer listed', () async {
    final remote = MemoryDocumentRemote({'Regras': pdf('Regras')});
    service.remote = remote;
    await service.refresh();
    final doc = service.documents.single;
    await service.open(doc);
    await service.remove(doc);
    expect(service.documents, isEmpty);
    expect(await service.isKept(doc), isFalse);
  });

  test('adds and renames', () async {
    service.remote = MemoryDocumentRemote();
    await service.add('  Novo  ', pdf('Novo'));
    expect(service.documents.single.title, 'Novo');
    await service.rename(service.documents.single, 'Outro');
    expect(service.documents.single.title, 'Outro');
  });

  test('without a store, opening a PDF not kept here fails', () async {
    final doc = AppDocument(
      id: 'x',
      title: 'X',
      fileName: 'x.pdf',
      updatedAt: DateTime(2026),
    );
    await expectLater(service.open(doc), throwsStateError);
  });

  group('simplePdf', () {
    test('is a PDF with a valid cross-reference table', () {
      final bytes = simplePdf('Receção (teste)', const ['Olá', '# Título']);
      expect(isPdf(bytes), isTrue);
      final text = latin1.decode(bytes);
      final start = int.parse(
        RegExp(r'startxref\n(\d+)').firstMatch(text)!.group(1)!,
      );
      expect(text.substring(start).startsWith('xref'), isTrue);
      // Every object starts where the table says.
      final offsets = RegExp(
        r'(\d{10}) 00000 n',
      ).allMatches(text).map((m) => int.parse(m.group(1)!)).toList();
      expect(offsets, hasLength(6));
      for (final (i, o) in offsets.indexed) {
        expect(text.substring(o).startsWith('${i + 1} 0 obj'), isTrue);
      }
      expect(text, contains(r'Receção \(teste\)'));
    });
  });

  test('documentSizeLabel', () {
    expect(documentSizeLabel(0), '');
    expect(documentSizeLabel(1000), '1 KB');
    expect(documentSizeLabel(320 * 1024), '320 KB');
    expect(documentSizeLabel((1.4 * 1024 * 1024).round()), '1,4 MB');
  });
}
