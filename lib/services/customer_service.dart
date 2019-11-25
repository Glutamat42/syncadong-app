import 'package:dio/dio.dart';
import 'package:syncadong/database/sync_timestamps.dart';
import 'package:syncadong/models/customer.dart';
import 'package:syncadong/database/customer_dao.dart';
import 'package:syncadong/models/transaction_log.dart';
import 'package:syncadong/network/request_helper.dart';
import 'package:syncadong/utils/helpers.dart';

class CustomerService {
  Dio _dio = RequestHelper.initDio();
  String endpoint = 'customer'; // TODO make api endpoints consistent to be able to use one variable for the endpoint names
  CustomerDao _customerDao = CustomerDao();
  SyncTimestamps _syncTimestamps = SyncTimestamps();

  Future<List<Customer>> get() async {
    List<Customer> data;
    await _dio.get('customers').then((Response response) async {
      data = response.data.map<Customer>((item) => Customer.fromMap(item)).toList();
      _customerDao.insertAll(data);
      _syncTimestamps.update(endpoint, DateTime.now());
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

  Future<TransactionLog> getTransactions() async {
    TransactionLog transactionLog;
    String lastSync = formatDateWithTime(await _syncTimestamps.get(endpoint));
    print(lastSync);
    await _dio.get('customers/transactions',queryParameters: {'start_date': lastSync}).then((Response response) async {
      transactionLog = TransactionLog.fromMap(response.data);

      print(transactionLog.toMap());
      // TODO do sync stuff here incl updating syncTimestamps entry
    }).catchError((_) async {print(_);
      print('offline, cant sync');
    });
    return transactionLog;
  }
}
