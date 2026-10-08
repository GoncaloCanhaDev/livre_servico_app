import 'package:flutter_test/flutter_test.dart';
import 'package:livre_servico_app/models/opening_list.dart';

void main() {
  OpeningList list() => OpeningList()..serviceDay = DateTime(2026, 10, 8, 5);
  final at = DateTime(2026, 10, 8, 7);

  test('a section is done once marked, the list only with all three', () {
    final l = list();
    expect(l.markSectionDone(ListSection.opls, ['Ana'], at), isFalse);
    expect(l.isSectionDone(ListSection.opls), isTrue);
    expect(l.isSectionDone(ListSection.congelados), isFalse);
    expect(l.namesOf(ListSection.opls), ['Ana']);
    expect(l.isFinalized, isFalse);

    expect(l.markSectionDone(ListSection.congelados, ['Rui'], at), isFalse);
    final later = at.add(const Duration(hours: 1));
    expect(
      l.markSectionDone(ListSection.naoPereciveis, ['Ana', 'Bia'], later),
      isTrue,
    );
    expect(l.isFinalized, isTrue);
    expect(l.finalizedAt, later);
  });

  test('the finished list credits everyone once, in section order', () {
    final l = list()
      ..markSectionDone(ListSection.naoPereciveis, ['Bia'], at)
      ..markSectionDone(ListSection.congelados, ['Ana', 'Bia'], at)
      ..markSectionDone(ListSection.opls, ['Rui'], at);
    expect(l.createdByNames, ['Ana', 'Bia', 'Rui']);
  });

  test('a list finalized before sections counts every section done', () {
    final l = list()
      ..finalizedAt = at
      ..createdByNames = ['Ana'];
    for (final s in ListSection.values) {
      expect(l.isSectionDone(s), isTrue);
    }
  });

  test('values by section', () {
    final l = list()
      ..setValue(ListSection.congelados, 3)
      ..setValue(ListSection.opls, 4)
      ..setValue(ListSection.naoPereciveis, 5);
    expect([for (final s in ListSection.values) l.valueOf(s)], [3, 4, 5]);
    expect(l.total, 12);
  });
}
