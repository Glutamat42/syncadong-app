import 'package:dio/dio.dart';
import 'package:syncadong/database/sync_timestamps.dart';
import 'package:syncadong/models/customer.dart';
import 'package:syncadong/database/customer_dao.dart';
import 'package:syncadong/models/transaction_log.dart';
import 'package:syncadong/network/request_helper.dart';
import 'package:syncadong/utils/helpers.dart';

class CustomerService {
  Dio _dio = RequestHelper.initDio();
  String endpoint = 'customers';
  CustomerDao _customerDao = CustomerDao();
  SyncTimestamps _syncTimestamps = SyncTimestamps();

  Future<List<Customer>> get() async {
    List<Customer> data;
    await _dio.get(endpoint).then((Response response) async {
      data = response.data.map<Customer>((item) => Customer.fromMap(item)).toList();
      _customerDao.insertAll(data);
      _syncTimestamps.update(endpoint, DateTime.now().toUtc());
    }).catchError((_) async {
      data = await _customerDao.getAllSortedByName();
    });
    return data;
  }

  Future<List<Customer>> post(Customer customer) async {
    Customer data;
    await _dio.post(endpoint, data: customer.toMap()).then((Response response) {
      data = Customer.fromMap(response.data);
    }).catchError((_) async {
      data = customer;
      data.id = await _customerDao.getInternalId();
      data.createdAt = DateTime.now();
      data.updatedAt = DateTime.now();
    });
    await _customerDao.insert(data);

    return await _customerDao.getAllSortedByName();
  }

  Future<List<Customer>> put(Customer customer) async {
    Customer data;
    await _dio.put(endpoint, data: customer.toMap()).then((Response response) {
      data = Customer.fromMap(response.data);
    }).catchError((_) async {
      data = customer;
      data.updatedAt = DateTime.now();
    });
    await _customerDao.insert(data);

    return await _customerDao.getAllSortedByName();
  }

  Future<List<Customer>> delete(Customer customer) async {
    await _dio.put('$endpoint/${customer.id}').then((Response response) async {
      await _customerDao.delete(customer);
    }).catchError((_) async {
      Customer data = customer;
      data.deletedAt = DateTime.now();
      await _customerDao.update(data);
    });

    return await _customerDao.getAllSortedByName();
  }

  Future<TransactionLog> getRemoteTransactions() async {
    TransactionLog transactionLog;
    DateTime lastSync = await _syncTimestamps.get(endpoint);
    await _dio.get('$endpoint/transactions', queryParameters: {
      'start_date': lastSync == null ? null : formatDateWithTime(lastSync)
    }).then((Response response) async {
      transactionLog = TransactionLog.fromMap(response.data);

      print(transactionLog.toMap());
    }).catchError((_) async {
      print(_);
      print('offline, cant sync');
    });
    return transactionLog;
  }

  Future<TransactionLog> getLocalTransactions() async {
    DateTime lastSync = await _syncTimestamps.get(endpoint);
    _customerDao.getTransactions(lastSync);
  }

  Future<List<Customer>> synchronize() async {
    if (await _syncTimestamps.get(endpoint) == null) {
      print('first sync -> get all');
      return null;
    }

    TransactionLog localTransactionLog;
    Future<TransactionLog> localTransactionLogFuture = getLocalTransactions();
    TransactionLog remoteTransactionLog = await getRemoteTransactions();
    List<Future> futures = <Future>[];

    //// create (first since they could also be deleted/edited)
    // remote changes
    remoteTransactionLog.created.forEach((LogEntry createdEntry) async {
      futures.add(_dio.get('$endpoint/${createdEntry.id}').then((Response response) {
        Customer createdCustomer = Customer.fromMap(response.data['data']);
        _customerDao.insert(createdCustomer);
      }));
    });

    // local changes
    localTransactionLog = await localTransactionLogFuture;
    localTransactionLog.created.forEach((LogEntry createdEntry) {
      futures.add(_customerDao.getById(createdEntry.id).then((Customer newLocalCustomer) {
        _dio.post(endpoint, data: newLocalCustomer.toMap()).then((Response response) {
          Customer createdCustomer = Customer.fromMap(response.data);
          _customerDao.update(createdCustomer);
        });
      }));
    });

    Future.wait(futures);

    //// delete
    // remote changes
    remoteTransactionLog = _removeDeleteEntriesFromUpdate(remoteTransactionLog, remoteTransactionLog.deleted);
    remoteTransactionLog.deleted.forEach((LogEntry deletedEntry) {
      futures.add(_customerDao.deleteById(deletedEntry.id).then((_) {
        // deleted entries don't have to be updated later ...
        localTransactionLog = _removeDeleteEntriesFromUpdate(localTransactionLog, [deletedEntry]);
        // prevent "double" deletion
        localTransactionLog.deleted = localTransactionLog.deleted.where((LogEntry entry) => entry.id != deletedEntry.id);
      }));
    });
    Future.wait(futures); // to prevent "double" deletion

    // local changes
    localTransactionLog.deleted.forEach((LogEntry deletedEntry) {
      futures.add(_dio.delete('$endpoint/${deletedEntry.id}').then((Response response) {
        if (response.statusCode == 200) {
          _customerDao.deleteById(deletedEntry.id);
          localTransactionLog = _removeDeleteEntriesFromUpdate(localTransactionLog, [deletedEntry]);
        } else {
          throw Exception('Deletion failed on backend');
        }
      }).catchError((_) {
        Customer customerUndeleted;
        customerUndeleted.deletedAt = null;
        _customerDao.update(customerUndeleted);
      }));
    });
    Future.wait(futures);

    //// udpate
    // remote changes
    // dont update entries which are in remote created list - they are already up to date
    // TODO
    // local changes
    // dont update entries which are in local created list - they are already up to date
    // TODO

    return _customerDao.getAllSortedByName();
  }

  TransactionLog _removeDeleteEntriesFromUpdate(TransactionLog transactionLog, List<LogEntry> deletedList) {
    for (LogEntry deletedEntry in deletedList) {
//      transactionLog.created = transactionLog.created.where((LogEntry entry) => entry.id != deletedEntry.id);
      transactionLog.updated = transactionLog.updated.where((LogEntry entry) => entry.id != deletedEntry.id);
    }
    return transactionLog;
  }
}
