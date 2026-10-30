import 'package:flutter_test/flutter_test.dart';
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
  });

  test("the database's own errors are shown as they are", () {
    expect(
      accountErrorText(
        const PostgrestException(
          message: 'Só o dono da loja pode adicionar pessoas.',
        ),
      ),
      'Só o dono da loja pode adicionar pessoas.',
    );
  });

  test('roles read by name; an unknown one is the least', () {
    expect(StoreRole.fromName('owner'), StoreRole.owner);
    expect(StoreRole.fromName('editor'), StoreRole.editor);
    expect(StoreRole.fromName('admin'), StoreRole.viewer);
  });
}
