import 'package:flutter/foundation.dart';
import 'package:supabase/supabase.dart';

import 'photo_store.dart';
import 'sync_engine.dart';

/// [SyncRemote] on the Supabase database in `supabase/migrations`: pushes
/// through `push_records`, pulls from `records`. [client] must be signed in
/// as a member of [storeId].
class SupabaseSyncRemote implements SyncRemote {
  SupabaseSyncRemote(this.client, this.storeId);

  final SupabaseClient client;
  final String storeId;

  @override
  Future<List<SyncRecord>> push(List<SyncRecord> rows) async {
    final newer = await client.rpc<List<dynamic>>(
      'push_records',
      params: {
        'p_store': storeId,
        'p_rows': [for (final r in rows) r.toPushJson()],
      },
    );
    return [
      for (final r in newer)
        SyncRecord.fromServerJson(Map<String, dynamic>.from(r as Map)),
    ];
  }

  @override
  Future<List<SyncRecord>> pull({DateTime? since, required int limit}) async {
    var query = client.from('records').select().eq('store_id', storeId);
    if (since != null) {
      query = query.gte('server_updated_at', since.toUtc().toIso8601String());
    }
    final rows = await query
        .order('server_updated_at', ascending: true)
        .limit(limit);
    return [for (final r in rows) SyncRecord.fromServerJson(r)];
  }
}

/// [PhotoRemote] on the `photos` bucket in Supabase Storage, one folder per
/// store (see `supabase/migrations`).
class SupabasePhotoRemote implements PhotoRemote {
  SupabasePhotoRemote(this.client, this.storeId);

  final SupabaseClient client;
  final String storeId;

  StorageFileApi get _bucket => client.storage.from('photos');

  @override
  Future<void> upload(String name, Uint8List bytes) => _bucket.uploadBinary(
    '$storeId/$name',
    bytes,
    fileOptions: FileOptions(
      upsert: true,
      contentType: name.endsWith('.png') ? 'image/png' : 'image/jpeg',
    ),
  );

  @override
  Future<Uint8List> download(String name) => _bucket.download('$storeId/$name');
}
