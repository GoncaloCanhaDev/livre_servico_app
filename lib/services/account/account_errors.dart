part of '../account_service.dart';

/// Shown when an account is made with a disposable email.
const blockedEmailText = 'Não são aceites emails temporários. Use outro email.';

/// Whether [e] is the server refusing a disposable email: the
/// refuse_blocked_email trigger makes Supabase Auth answer this, with status
/// 500, without the trigger's own message.
bool isBlockedEmailError(Object e) =>
    e is AuthException &&
    e.message.toLowerCase().contains('database error saving new user');

/// What went wrong with an account or store action, in words for the
/// person using the app.
String accountErrorText(Object e) {
  if (isBlockedEmailError(e)) return blockedEmailText;
  if (e is AuthRetryableFetchException) return 'Sem ligação à internet.';
  if (e is AuthException) {
    final m = e.message.toLowerCase();
    if (m.contains('invalid login')) return 'Email ou palavra-passe errados.';
    if (m.contains('not confirmed')) {
      return 'Confirme primeiro o email, com a ligação que lhe foi enviada.';
    }
    if (m.contains('already registered')) {
      return 'Já existe uma conta com este email.';
    }
    if (m.contains('password')) {
      return 'A palavra-passe tem de ter pelo menos 6 caracteres.';
    }
    return e.message;
  }
  // The database's own errors (see supabase/migrations) are in Portuguese.
  if (e is PostgrestException) return e.message;
  final text = '$e';
  if (text.contains('SocketException') ||
      text.contains('ClientException') ||
      text.contains('Failed host lookup')) {
    return 'Sem ligação à internet.';
  }
  return text;
}
