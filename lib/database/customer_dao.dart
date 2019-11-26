import 'package:sembast/sembast.dart';
import 'package:syncadong/database/app_database.dart';
import 'package:syncadong/models/customer.dart';
import 'package:syncadong/models/transaction_log.dart';

class CustomerDao {
  static const String storeName = 'customer';

  final _store = intMapStoreFactory.store(storeName);

  Future<Database> get _db async => await AppDatabase().database;

  Future insertAll(List<Customer> customers) async {
    await _store.drop(await _db);
    (await _db).transaction((txn) async {
      for (Customer customer in customers) {
        await _store.record(customer.id).put(txn, customer.toMap());
      }
    });
  }

  Future insert(Customer customer) async {
    await _store.record(customer.id).put(await _db, customer.toMap());
  }

  Future update(Customer customer) async {
    final finder = Finder(filter: Filter.byKey(customer.id));
    await _store.update(
      await _db,
      customer.toMap(),
      finder: finder,
    );
  }

  Future delete(Customer customer) => deleteById(customer.id);

  Future deleteById(int id) async {
    final finder = Finder(filter: Filter.byKey(id));
    await _store.delete(
      await _db,
      finder: finder,
    );
  }

  Future<List<Customer>> getAllSortedByName() async {
    final finder = Finder(
      sortOrders: [SortOrder('name')],
      filter: Filter.isNull('deleted_at'),
    );

    final recordSnapshots = await _store.find(
      await _db,
      finder: finder,
    );

    return recordSnapshots.map((snapshot) {
      final customer = Customer.fromMap(snapshot.value);
      return customer;
    }).toList();
  }

  Future<Customer> getById(int id) async {
    final finder = Finder(filter: Filter.byKey(id));
    final List<RecordSnapshot<int, Map<String, dynamic>>> recordSnapshot = await _store.find(await _db, finder: finder);
    return Customer.fromMap(recordSnapshot.first.value);
  }

  Future<int> getInternalId() async {
    final finder = Finder(
      limit: 1,
      filter: Filter.isNull('deleted_at'),
    );
    int id = (await _store.find(await _db, finder: finder)).first.key - 1;
    if (id >= 0) id = -1;
    return id;
  }

  Future<TransactionLog> getTransactions(DateTime startDate) async {
    TransactionLog transactionLog = TransactionLog();
    List<Customer> allData = await getAllSortedByName();

    transactionLog.created = allData
        .where((Customer customer) => customer.createdAt.compareTo(startDate) > 0)
        .map((Customer customer) => LogEntry(id: customer.id, timestamp: customer.createdAt))
        .toList();

    transactionLog.updated = allData
        .where((Customer customer) => customer.updatedAt != customer.createdAt && customer.updatedAt.isAfter(startDate))
        .map((Customer customer) => LogEntry(id: customer.id, timestamp: customer.updatedAt))
        .toList();

    transactionLog.deleted = allData
        .where((Customer customer) => customer.deletedAt.isAfter(startDate))
        .map((Customer customer) => LogEntry(id: customer.id, timestamp: customer.deletedAt))
        .toList();

    return transactionLog;
  }
}
