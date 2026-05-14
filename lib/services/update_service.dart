import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:open_filex/open_filex.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';

class UpdateInfo {
  UpdateInfo({
    required this.version,
    required this.notes,
    required this.apkUrl,
  });

  final String version;
  final String notes;
  final String apkUrl;
}

class UpdateService {
  UpdateService._();
  static final instance = UpdateService._();

  static const _owner = 'GoncaloCanhaDev';
  static const _repo = 'livre_servico_app';
  static final Uri _releaseUri =
      Uri.parse('https://api.github.com/repos/$_owner/$_repo/releases/latest');
  static final Uri _releasesListUri =
      Uri.parse('https://api.github.com/repos/$_owner/$_repo/releases?per_page=10');

  /// Returns the most recent release tags (newest first), e.g.
  /// `['v0.2.2', 'v0.2.1', 'v0.2.0']`. Empty on any failure.
  Future<List<String>> fetchReleaseTags() async {
    try {
      final resp = await http
          .get(_releasesListUri,
              headers: {'Accept': 'application/vnd.github+json'})
          .timeout(const Duration(seconds: 8));
      if (resp.statusCode != 200) return const [];
      final list = jsonDecode(resp.body) as List;
      return list
          .map((r) => (r as Map<String, dynamic>)['tag_name'] as String? ?? '')
          .where((t) => t.isNotEmpty)
          .toList();
    } catch (e) {
      debugPrint('UpdateService.fetchReleaseTags failed: $e');
      return const [];
    }
  }

  /// Returns an [UpdateInfo] if a newer release than the running app is
  /// available on GitHub. Returns null otherwise. Network/parsing errors
  /// are swallowed — we never want a flaky connection to block the app.
  Future<UpdateInfo?> checkForUpdate() async {
    try {
      final info = await PackageInfo.fromPlatform();
      final current = info.version;
      final resp = await http
          .get(_releaseUri, headers: {'Accept': 'application/vnd.github+json'})
          .timeout(const Duration(seconds: 8));
      if (resp.statusCode != 200) return null;
      final body = jsonDecode(resp.body) as Map<String, dynamic>;
      final tag = (body['tag_name'] as String?)?.trim();
      if (tag == null || tag.isEmpty) return null;
      final remote = _stripV(tag);
      if (_cmpSemver(remote, current) <= 0) return null;
      final assets = (body['assets'] as List?) ?? const [];
      final apk = assets.cast<Map<String, dynamic>>().firstWhere(
            (a) => (a['name'] as String?)?.toLowerCase().endsWith('.apk') ?? false,
            orElse: () => const {},
          );
      final url = apk['browser_download_url'] as String?;
      if (url == null) return null;
      return UpdateInfo(
        version: remote,
        notes: (body['body'] as String?) ?? '',
        apkUrl: url,
      );
    } catch (e) {
      debugPrint('UpdateService.checkForUpdate failed: $e');
      return null;
    }
  }

  /// Downloads the APK at [url] to a file under the app's cache directory,
  /// reporting [0..1] progress. Returns the local path on success.
  Future<String> downloadApk(
    String url, {
    required void Function(double progress) onProgress,
  }) async {
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/livre_servico_update.apk');
    if (await file.exists()) await file.delete();

    final req = http.Request('GET', Uri.parse(url));
    final resp = await req.send().timeout(const Duration(seconds: 30));
    if (resp.statusCode != 200) {
      throw HttpException('HTTP ${resp.statusCode} ao transferir.');
    }
    final total = resp.contentLength ?? 0;
    int received = 0;
    final sink = file.openWrite();
    try {
      await for (final chunk in resp.stream) {
        sink.add(chunk);
        received += chunk.length;
        if (total > 0) onProgress(received / total);
      }
    } finally {
      await sink.close();
    }
    return file.path;
  }

  /// Launches the system installer for the downloaded APK.
  Future<void> install(String path) async {
    final result = await OpenFilex.open(path,
        type: 'application/vnd.android.package-archive');
    if (result.type != ResultType.done) {
      throw Exception(result.message);
    }
  }

  String _stripV(String tag) => tag.startsWith('v') ? tag.substring(1) : tag;

  int _cmpSemver(String a, String b) {
    final ap = a.split('.').map((p) => int.tryParse(p) ?? 0).toList();
    final bp = b.split('.').map((p) => int.tryParse(p) ?? 0).toList();
    for (var i = 0; i < 3; i++) {
      final av = i < ap.length ? ap[i] : 0;
      final bv = i < bp.length ? bp[i] : 0;
      if (av != bv) return av.compareTo(bv);
    }
    return 0;
  }
}
