/// One of the Documentos: a PDF kept by the app's admin for every store.
/// Not a local row: the list comes from the online `documents` table (and
/// is kept on the device to show offline); the PDF is downloaded the first
/// time it is opened. A new version of a document gets a new [fileName].
class AppDocument {
  const AppDocument({
    required this.id,
    required this.title,
    required this.fileName,
    this.size = 0,
    required this.updatedAt,
  });

  final String id;
  final String title;

  /// The PDF's object in the `documents` bucket, and its key on the device.
  final String fileName;

  /// In bytes.
  final int size;
  final DateTime updatedAt;

  AppDocument copyWith({String? title, DateTime? updatedAt}) => AppDocument(
    id: id,
    title: title ?? this.title,
    fileName: fileName,
    size: size,
    updatedAt: updatedAt ?? this.updatedAt,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'file_name': fileName,
    'size': size,
    'updated_at': updatedAt.toUtc().toIso8601String(),
  };

  factory AppDocument.fromJson(Map<String, dynamic> j) => AppDocument(
    id: j['id'] as String,
    title: j['title'] as String? ?? '',
    fileName: j['file_name'] as String,
    size: (j['size'] as num?)?.toInt() ?? 0,
    updatedAt:
        DateTime.tryParse(j['updated_at'] as String? ?? '')?.toLocal() ??
        DateTime.fromMillisecondsSinceEpoch(0),
  );
}

/// [docs] by title, ignoring case.
List<AppDocument> sortedDocuments(Iterable<AppDocument> docs) =>
    [...docs]
      ..sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));

/// "320 KB", "1,4 MB": a PDF's size for the list.
String documentSizeLabel(int bytes) {
  if (bytes <= 0) return '';
  if (bytes < 1024 * 1024) return '${(bytes / 1024).ceil()} KB';
  final mb = bytes / (1024 * 1024);
  return '${mb.toStringAsFixed(1).replaceAll('.', ',')} MB';
}

/// Whether [bytes] look like a PDF (they start with `%PDF-`).
bool isPdf(List<int> bytes) =>
    bytes.length > 4 &&
    bytes[0] == 0x25 &&
    bytes[1] == 0x50 &&
    bytes[2] == 0x44 &&
    bytes[3] == 0x46 &&
    bytes[4] == 0x2D;
