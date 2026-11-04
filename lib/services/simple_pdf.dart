import 'dart:convert';
import 'dart:typed_data';

/// A one-page A4 PDF with a bold [title] and the [lines] under it, in
/// Helvetica (Latin-1 text, so Portuguese accents work). Used for the demo's
/// example Documentos, so the website needs no PDF files of its own.
/// An empty line in [lines] is a gap; a line starting with `# ` is a bold
/// heading.
Uint8List simplePdf(String title, List<String> lines) {
  String esc(String s) =>
      s.replaceAll(r'\', r'\\').replaceAll('(', r'\(').replaceAll(')', r'\)');
  final content = StringBuffer()
    ..writeln('BT')
    ..writeln('/F2 20 Tf')
    ..writeln('56 780 Td')
    ..writeln('(${esc(title)}) Tj')
    ..writeln('0 -34 Td');
  for (final line in lines) {
    if (line.startsWith('# ')) {
      content
        ..writeln('/F2 13 Tf')
        ..writeln('(${esc(line.substring(2))}) Tj');
    } else {
      content
        ..writeln('/F1 11 Tf')
        ..writeln('(${esc(line)}) Tj');
    }
    content.writeln('0 -17 Td');
  }
  content.writeln('ET');
  final stream = latin1.encode(content.toString());

  final out = BytesBuilder();
  final offsets = <int>[];
  void add(String s) => out.add(latin1.encode(s));
  void obj(String body) {
    offsets.add(out.length);
    add('${offsets.length} 0 obj\n$body\nendobj\n');
  }

  add('%PDF-1.4\n');
  obj('<< /Type /Catalog /Pages 2 0 R >>');
  obj('<< /Type /Pages /Kids [3 0 R] /Count 1 >>');
  obj(
    '<< /Type /Page /Parent 2 0 R /MediaBox [0 0 595 842] /Contents 4 0 R '
    '/Resources << /Font << /F1 5 0 R /F2 6 0 R >> >> >>',
  );
  offsets.add(out.length);
  add('4 0 obj\n<< /Length ${stream.length} >>\nstream\n');
  out.add(stream);
  add('\nendstream\nendobj\n');
  obj(
    '<< /Type /Font /Subtype /Type1 /BaseFont /Helvetica '
    '/Encoding /WinAnsiEncoding >>',
  );
  obj(
    '<< /Type /Font /Subtype /Type1 /BaseFont /Helvetica-Bold '
    '/Encoding /WinAnsiEncoding >>',
  );
  final xref = out.length;
  add('xref\n0 ${offsets.length + 1}\n0000000000 65535 f \n');
  for (final o in offsets) {
    add('${o.toString().padLeft(10, '0')} 00000 n \n');
  }
  add(
    'trailer\n<< /Size ${offsets.length + 1} /Root 1 0 R >>\n'
    'startxref\n$xref\n%%EOF\n',
  );
  return out.toBytes();
}
