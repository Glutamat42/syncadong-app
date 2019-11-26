import 'package:sembast/sembast.dart';
import 'package:syncadong/database/app_database.dart';
import 'package:syncadong/utils/helpers.dart';

class SyncTimestamps {
  static const String storeName = 'sync_timestamps';

  final _store = stringMapStoreFactory.store(storeName);

  Future<Database> get _db async => await AppDatabase().database;

  Future insert(String storeName, DateTime timestamp) async {
    await _store.record(storeName).put(await _db, {'timestamp': formatDateWithTime(timestamp)});
  }

  Future update(String storeName, DateTime timestamp) async {
    await _store.record(storeName).put(await _db, {'timestamp': formatDateWithTime(timestamp)});
  }

  Future<DateTime> get(String storeName) async {
    final finder = Finder(
      filter: Filter.byKey(storeName),
    );

    final recordSnapshots = await _store.findFirst(
      await _db,
      finder: finder,
    );

    return recordSnapshots == null ? null : parseDate(recordSnapshots.value['timestamp']);
  }
}
