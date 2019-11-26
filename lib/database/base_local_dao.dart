import 'package:sembast/sembast.dart';
import 'package:syncadong/database/app_database.dart';
import 'package:syncadong/models/base_model.dart';
import 'package:syncadong/models/transaction_log.dart';

abstract class BaseLocalDao<T extends BaseModel> {
  final String storeName;
  final _store;

  Future<Database> get _db async => await AppDatabase().database;

  BaseLocalDao(this.storeName) : _store = intMapStoreFactory.store(storeName);

  Future insertAll(List<T> dataList) async {
    await _store.drop(await _db);
    (await _db).transaction((Transaction txn) async {
      for (T data in dataList) {
        await _store.record(data.id).put(txn, data.toMap());
      }
    });
  }

  Future insert(T data) async {
    await _store.record(data.id).put(await _db, data.toMap());
  }

  Future update(T data) async {
    await _store.update(
      await _db,
      data.toMap(),
      finder: Finder(filter: Filter.byKey(data.id)),
    );
  }

  Future delete(T data) => deleteById(data.id);

  Future deleteById(int id) async {
    await _store.delete(
      await _db,
      finder: Finder(filter: Filter.byKey(id)),
    );
  }

  Future<List<T>> getAll() async {
    final recordSnapshots = await _store.find(
      await _db,
      finder: Finder(
        filter: Filter.isNull('deleted_at'),
      ),
    );
    return recordSnapshots.map((snapshot) => this.fromMap(snapshot.value)).toList();
  }

  /// override this with T.fromMap [eg T fromMap(Map<String, dynamic> json) => T.fromMap(json)]
  T fromMap(Map<String, dynamic> json);

  Future<T> getById(int id) async {
    final List<RecordSnapshot<int, Map<String, dynamic>>> recordSnapshot = await _store.find(
      await _db,
      finder: Finder(filter: Filter.byKey(id)),
    );
    return this.fromMap(recordSnapshot.first.value);
  }

  Future<int> getInternalId() async {
    int id = (await _store.find(await _db,
                finder: Finder(
                  limit: 1,
                  filter: Filter.isNull('deleted_at'),
                )))
            .first
            .key -
        1;
    if (id >= 0) id = -1;
    return id;
  }

  Future<TransactionLog> getTransactions(DateTime startDate) async {
    TransactionLog transactionLog = TransactionLog();
    List<T> allData = await getAll();

    transactionLog.created = allData
        .where((T data) => data.createdAt.compareTo(startDate) > 0)
        .map((T data) => LogEntry(id: data.id, timestamp: data.createdAt))
        .toList();

    transactionLog.updated = allData
        .where((T data) => data.updatedAt != data.createdAt && data.updatedAt.isAfter(startDate))
        .map((T data) => LogEntry(id: data.id, timestamp: data.updatedAt))
        .toList();

    transactionLog.deleted = allData
        .where((T data) => data.deletedAt.isAfter(startDate))
        .map((T data) => LogEntry(id: data.id, timestamp: data.deletedAt))
        .toList();

    return transactionLog;
  }
}
