import 'package:sembast/sembast.dart';
import 'package:syncadong/app_database.dart';
import 'package:syncadong/customer.dart';

class CustomerDao {
  static const String storeName = 'customer';

  final _store = intMapStoreFactory.store(storeName);

  Future<Database> get _db async => await AppDatabase().database;

  // TODO: insert array

  Future insertAll(List<Customer> customers) async {
    await _store.drop(await _db);
    (await _db).transaction((txn) async {
      for (Customer customer in customers) {
        await _store.record(customer.id).put(txn, customer.toMap());

      }
    });
    print('SHIT ENDED');
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

  Future delete(Customer customer) async {
    final finder = Finder(filter: Filter.byKey(customer.id));
    await _store.delete(
      await _db,
      finder: finder,
    );
  }

  Future<List<Customer>> getAllSortedByName() async {
    final finder = Finder(sortOrders: [
      SortOrder('name'),
    ]);

    final recordSnapshots = await _store.find(
      await _db,
      finder: finder,
    );

    return recordSnapshots.map((snapshot) {
      final customer = Customer.fromMap(snapshot.value);
//      customer.id = snapshot.key;
      return customer;
    }).toList();
  }

}