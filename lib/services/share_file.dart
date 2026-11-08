import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:share_plus/share_plus.dart';

/// Shares [json] as a file called [name]: the share sheet on the phone, a
/// download in a browser that can't share files. Made in memory, so it works
/// where there is no file system (the web).
Future<ShareResult> shareJsonFile(
  String json, {
  required String name,
  required String subject,
}) => _shareFile(
  json,
  name: name,
  subject: subject,
  mimeType: 'application/json',
);

/// Shares [text] as a plain text file called [name], like [shareJsonFile].
Future<ShareResult> shareTextFile(
  String text, {
  required String name,
  required String subject,
}) => _shareFile(text, name: name, subject: subject, mimeType: 'text/plain');

Future<ShareResult> _shareFile(
  String content, {
  required String name,
  required String subject,
  required String mimeType,
}) => SharePlus.instance.share(
  ShareParams(
    files: [
      XFile.fromData(
        Uint8List.fromList(utf8.encode(content)),
        name: name,
        mimeType: mimeType,
      ),
    ],
    fileNameOverrides: [name],
    subject: subject,
  ),
);
