import 'package:flutter_test/flutter_test.dart';
import 'package:livre_servico_app/models/store_access.dart';
import 'package:livre_servico_app/services/account_service.dart';
import 'package:supabase/supabase.dart';

void main() {
  test('sign-in errors read in Portuguese', () {
    expect(
      accountErrorText(
        const AuthException('Invalid login credentials', statusCode: '400'),
      ),
      'Email ou palavra-passe errados.',
    );
    expect(
      accountErrorText(
        const AuthException('Email not confirmed', statusCode: '400'),
      ),
      startsWith('Confirme primeiro o email'),
    );
    expect(
      accountErrorText(
        const AuthException('User already registered', statusCode: '422'),
      ),
      'Já existe uma conta com este email.',
    );
    expect(
      accountErrorText(AuthRetryableFetchException()),
      'Sem ligação à internet.',
    );
    expect(
      accountErrorText(
        AuthRetryableFetchException(
          message:
              '{"code":"unexpected_failure","message":"Database error saving new user"}',
          statusCode: '500',
        ),
      ),
      'Não são aceites emails temporários. Use outro email.',
    );
  });

  test("the database's own errors are shown as they are", () {
    expect(
      accountErrorText(
        const PostgrestException(
          message: 'Só a gerência pode adicionar pessoas.',
        ),
      ),
      'Só a gerência pode adicionar pessoas.',
    );
  });

  test('roles read by name; an unknown one is the least', () {
    expect(StoreRole.fromName('owner'), StoreRole.owner);
    expect(StoreRole.fromName('editor'), StoreRole.editor);
    expect(StoreRole.fromName('admin'), StoreRole.viewer);
  });
  test('a saved store keeps whether it is pending and its access', () {
    const s = (
      id: 's1',
      name: 'Loja',
      role: StoreRole.editor,
      personId: 'p1',
      pending: true,
      access: StoreAccess(
        admin: false,
        level: 3,
        team: 'talho',
        personId: 'p1',
      ),
    );
    final back = storeInfoFromJson(storeInfoToJson(s));
    expect(back, s);
    expect(syncsWith(back!), isFalse);
    expect(
      syncsWith((
        id: 's1',
        name: 'Loja',
        role: StoreRole.editor,
        personId: 'p1',
        pending: false,
        access: s.access,
      )),
      isTrue,
    );
  });

  test('a store saved by an older version is approved, with no access', () {
    final s = storeInfoFromJson(
      '{"id":"s1","name":"Loja","role":"owner","personId":null}',
    )!;
    expect(s.pending, isFalse);
    expect(s.access.canApprove, isFalse);
    expect(s.access.canWipeAll, isFalse);
    expect(storeInfoFromJson('nope'), isNull);
  });
}
