import 'package:dio/dio.dart';
import 'package:syncadong/database/sync_timestamps.dart';
import 'package:syncadong/models/customer.dart';
import 'package:syncadong/database/customer_dao.dart';
import 'package:syncadong/models/transaction_log.dart';
import 'package:syncadong/network/customer_api.dart';
import 'package:syncadong/network/request_helper.dart';
import 'package:syncadong/utils/helpers.dart';

class CustomerService {
  Dio _dio = RequestHelper.initDio();
  static String endpoint = 'customers';
  CustomerDao _customerDao = CustomerDao(endpoint);
  CustomerApi _customerApi = CustomerApi(endpoint);
  SyncTimestamps _syncTimestamps = SyncTimestamps();

  Future<List<Customer>> get() async {
    List<Customer> data;
    await _customerApi.getAll().then((List<Customer> response) {
      data = response;
      _customerDao.insertAll(response);
    }).catchError((_) async {
      data = await _customerDao.getAll();
    });
    return data;
  }

  Future<List<Customer>> post(Customer customer) async {
    Customer data;

    await _customerApi.post(customer).then((Customer response) async {
      data = response;
      await _customerDao.insert(data);
    }).catchError((_) async {
      data = customer;
      data.id = await _customerDao.getInternalId();
      data.createdAt = DateTime.now().toUtc();
      data.updatedAt = DateTime.now().toUtc();
    });
//    Use this if using real sync - remove the dao.insert line above
//    await _customerDao.insert(data);

    return await _customerDao.getAll();
  }

  Future<List<Customer>> put(Customer customer) async {
    Customer data;

    await _customerApi.put(customer).then((Customer response) async {
      data = response;
      await _customerDao.update(data);
    }).catchError((_) {
      data = customer;
      data.updatedAt = DateTime.now().toUtc();
    });
//    Use this if using real sync - remove the dao.insert line above
//    await _customerDao.update(data);

    return await _customerDao.getAll();
  }

  Future<List<Customer>> delete(Customer customer) async {
    await _customerApi.delete(customer.id).then((_) async {
      await _customerDao.delete(customer);
    }).catchError((_) async {
//      enable this code if you are using a real sync
//      Customer data = customer;
//      data.deletedAt = DateTime.now().toUtc();
//      await _customerDao.update(data);
    });

    return await _customerDao.getAll();
  }

  Future<TransactionLog> getRemoteTransactions() async {
    TransactionLog transactionLog;
    DateTime lastSync = await _syncTimestamps.get(endpoint);

    _customerApi.getRemoteTransactions(lastSync).then((TransactionLog response) {
      transactionLog = response;
    }).catchError((_) {
      transactionLog = TransactionLog();
      print('offline, cant sync');
    });

    return transactionLog;
  }

  Future<TransactionLog> getLocalTransactions() async {
    DateTime lastSync = await _syncTimestamps.get(endpoint);
    return _customerDao.getTransactions(lastSync);
  }

  Future<List<Customer>> synchronize() async {
    if (await _syncTimestamps.get(endpoint) == null) {
      print('first sync -> get all');
      await get();
    } else {
      print('not first sync but since this is a stupid sync implementation i`ll just grab everything again');
      await get();
    }

    return _customerDao.getAll();
  }
}
