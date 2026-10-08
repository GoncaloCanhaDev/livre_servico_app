import 'info_entry.dart';

/// Bucket of the Contactos Úteis entries, grouped by [InfoEntry.group].
const contactsBucket = 'contactos';

/// The fixed contact buckets used before groups existed, and the group each
/// one reads as.
const legacyContactGroups = {
  'contactos_responsavel': 'Responsável de Loja',
  'contactos_suporte': 'Suporte Técnico',
};

bool isContact(InfoEntry e) =>
    e.bucket == contactsBucket || legacyContactGroups.containsKey(e.bucket);

String contactGroupOf(InfoEntry e) =>
    e.group ?? legacyContactGroups[e.bucket] ?? 'Outros';

bool _looksLikePhone(String s) =>
    RegExp(r'^\+?[\d\s().-]{6,}$').hasMatch(s.trim());

/// An older contact's free text, when it is neither a phone nor an email.
String? _legacyLeftover(InfoEntry e) {
  final c = e.contact?.trim() ?? '';
  if (c.isEmpty || _looksLikePhone(c) || c.contains('@')) return null;
  return c;
}

String? contactPhoneOf(InfoEntry e) {
  if (e.phone case final p? when p.trim().isNotEmpty) return p;
  final c = e.contact?.trim() ?? '';
  return _looksLikePhone(c) ? c : null;
}

String? contactEmailOf(InfoEntry e) {
  if (e.email case final m? when m.trim().isNotEmpty) return m;
  final c = e.contact?.trim() ?? '';
  return c.contains('@') ? c : null;
}

/// The note, with an older contact's leftover text on its own line.
String contactNoteOf(InfoEntry e) => [
  if (e.description.trim().isNotEmpty) e.description.trim(),
  ?_legacyLeftover(e),
].join('\n');

extension NormalizeContact on InfoEntry {
  /// Moves an older contact into the [contactsBucket] fields (group, phone,
  /// email, note); a no-op for contacts already there.
  void normalizeContactInPlace() {
    if (bucket == contactsBucket) return;
    final g = contactGroupOf(this);
    final p = contactPhoneOf(this);
    final m = contactEmailOf(this);
    final note = contactNoteOf(this);
    bucket = contactsBucket;
    group = g;
    phone = p;
    email = m;
    description = note;
    contact = null;
  }
}

/// [phone] as wa.me wants it: digits with the country code, adding 351 to a
/// 9-digit Portuguese number. Null without digits.
String? whatsAppNumber(String phone) {
  var digits = phone.replaceAll(RegExp(r'\D'), '');
  if (digits.isEmpty) return null;
  if (digits.startsWith('00')) digits = digits.substring(2);
  if (digits.length == 9) digits = '351$digits';
  return digits;
}

final _phoneInText = RegExp(
  r'(?<!\d)(?:(?:\+|00)351[\s-]?)?[289]\d{2}[\s-]?\d{3}[\s-]?\d{3}(?!\d)',
);

/// [text] cut into plain parts and Portuguese phone numbers, in order, so
/// the numbers can be made tappable.
List<({String text, bool phone})> splitPhones(String text) {
  final out = <({String text, bool phone})>[];
  var at = 0;
  for (final m in _phoneInText.allMatches(text)) {
    if (m.start > at) {
      out.add((text: text.substring(at, m.start), phone: false));
    }
    out.add((text: m.group(0)!, phone: true));
    at = m.end;
  }
  if (at < text.length) out.add((text: text.substring(at), phone: false));
  return out;
}

/// The WhatsApp / share text for an entry or contact.
String infoShareText(InfoEntry e) {
  if (isContact(e)) {
    return [
      '👤 ${e.title} (${contactGroupOf(e)})',
      if (contactPhoneOf(e) case final p?) '📞 $p',
      if (contactEmailOf(e) case final m?) '✉️ $m',
      if (contactNoteOf(e) case final n when n.isNotEmpty) n,
    ].join('\n');
  }
  return [
    'ℹ️ ${e.title}',
    if (e.description.trim().isNotEmpty) e.description.trim(),
  ].join('\n');
}
