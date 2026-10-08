import 'package:flutter_test/flutter_test.dart';
import 'package:livre_servico_app/models/info_contacts.dart';
import 'package:livre_servico_app/models/info_entry.dart';

InfoEntry _e(
  String bucket, {
  String title = 'Ana',
  String description = '',
  String? contact,
  String? group,
  String? phone,
  String? email,
}) => InfoEntry()
  ..bucket = bucket
  ..title = title
  ..description = description
  ..contact = contact
  ..group = group
  ..phone = phone
  ..email = email
  ..createdAt = DateTime(2026, 10, 8);

void main() {
  group('contacts', () {
    test('new contacts keep their own group, phone and email', () {
      final e = _e(
        contactsBucket,
        group: 'Fornecedores',
        phone: '912 345 678',
        email: 'a@b.pt',
      );
      expect(isContact(e), isTrue);
      expect(contactGroupOf(e), 'Fornecedores');
      expect(contactPhoneOf(e), '912 345 678');
      expect(contactEmailOf(e), 'a@b.pt');
    });

    test('older contacts take their group from the bucket', () {
      expect(
        contactGroupOf(_e('contactos_responsavel')),
        'Responsável de Loja',
      );
      expect(contactGroupOf(_e('contactos_suporte')), 'Suporte Técnico');
      expect(isContact(_e('protocolos')), isFalse);
    });

    test('an older contact text becomes the phone, email or note', () {
      final phone = _e('contactos_suporte', contact: '+351 912 345 678');
      expect(contactPhoneOf(phone), '+351 912 345 678');
      expect(contactEmailOf(phone), isNull);

      final email = _e('contactos_suporte', contact: 'suporte@loja.pt');
      expect(contactEmailOf(email), 'suporte@loja.pt');
      expect(contactPhoneOf(email), isNull);

      final other = _e(
        'contactos_suporte',
        description: 'Só dias úteis',
        contact: 'Pedir ao balcão',
      );
      expect(contactPhoneOf(other), isNull);
      expect(contactEmailOf(other), isNull);
      expect(contactNoteOf(other), 'Só dias úteis\nPedir ao balcão');
    });

    test('normalizeContact moves an older contact to the new fields', () {
      final e = _e(
        'contactos_responsavel',
        description: 'Gerente',
        contact: '912345678',
      )..normalizeContactInPlace();
      expect(e.bucket, contactsBucket);
      expect(e.group, 'Responsável de Loja');
      expect(e.phone, '912345678');
      expect(e.email, isNull);
      expect(e.contact, isNull);
      expect(e.description, 'Gerente');
    });
  });

  group('whatsAppNumber', () {
    test('adds the Portuguese prefix to 9-digit numbers', () {
      expect(whatsAppNumber('912 345 678'), '351912345678');
    });

    test('keeps an international number', () {
      expect(whatsAppNumber('+351 912-345-678'), '351912345678');
      expect(whatsAppNumber('0034 600 123 456'), '34600123456');
    });

    test('null without digits', () {
      expect(whatsAppNumber('sem número'), isNull);
    });
  });

  group('splitPhones', () {
    test('finds Portuguese numbers inside text', () {
      expect(splitPhones('Ligar 912 345 678 ou 210-123-456.'), [
        (text: 'Ligar ', phone: false),
        (text: '912 345 678', phone: true),
        (text: ' ou ', phone: false),
        (text: '210-123-456', phone: true),
        (text: '.', phone: false),
      ]);
    });

    test('with the country code', () {
      expect(splitPhones('+351 912345678'), [
        (text: '+351 912345678', phone: true),
      ]);
    });

    test('leaves other numbers alone', () {
      expect(splitPhones('Código 1234, lote 55'), [
        (text: 'Código 1234, lote 55', phone: false),
      ]);
    });
  });

  test('share text', () {
    final contact = _e(
      contactsBucket,
      title: 'Rui',
      group: 'Técnicos de frio',
      phone: '912345678',
      description: 'Urgências',
    );
    expect(
      infoShareText(contact),
      '👤 Rui (Técnicos de frio)\n📞 912345678\nUrgências',
    );
    final entry = _e(
      'protocolos',
      title: 'Fecho de caixa',
      description: 'Contar duas vezes.',
    );
    expect(infoShareText(entry), 'ℹ️ Fecho de caixa\nContar duas vezes.');
  });
}
