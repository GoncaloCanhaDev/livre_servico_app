/// Names to treat as "who did this": the new list if it has anything,
/// otherwise the single legacy name (wrapped in a list) if there is one,
/// otherwise empty. Read-time fallback for rows saved before this field
/// existed — old rows are never rewritten.
List<String> resolveNames(List<String> names, String? legacy) {
  if (names.isNotEmpty) return names;
  if (legacy == null || legacy.isEmpty) return [];
  return [legacy];
}

/// Portuguese-style join for display: "A", "A e B", "A, B e C".
String joinNames(List<String> names) {
  if (names.isEmpty) return '';
  if (names.length == 1) return names.first;
  return '${names.sublist(0, names.length - 1).join(', ')} e ${names.last}';
}
