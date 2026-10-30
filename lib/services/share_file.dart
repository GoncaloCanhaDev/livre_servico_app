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
}) => SharePlus.instance.share(
  ShareParams(
    files: [
      XFile.fromData(
        Uint8List.fromList(utf8.encode(json)),
        name: name,
        mimeType: 'application/json',
      ),
    ],
    fileNameOverrides: [name],
    subject: subject,
  ),
);
