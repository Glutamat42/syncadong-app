import 'package:dio/dio.dart';
import 'package:syncadong/customer.dart';
import 'package:syncadong/customer_dao.dart';
import 'package:syncadong/request_helper.dart';

class CustomerService {
  Dio _dio = RequestHelper.initDio();
  String endpoint = 'customer';
  CustomerDao _customerDao = CustomerDao();

  Future<List<Customer>> get() async {
    List<Customer> data;
    await _dio.get('customers').then((Response response) async {
      data = response.data.map<Customer>((item) => Customer.fromMap(item)).toList();
      _customerDao.insertAll(data);
    }).catchError((_) async {
      data = await _customerDao.getAllSortedByName();
    });
    return data;
  }

  Future<List<Customer>> post(Customer customer) async {
    Customer data;
    await _dio.post('customers', data: customer.toMap()).then((Response response) {
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
    await _dio.put('customers', data: customer.toMap()).then((Response response) {
      data = Customer.fromMap(response.data);
    }).catchError((_) async {
      data = customer;
      data.updatedAt = DateTime.now();
    });
    await _customerDao.insert(data);

    return await _customerDao.getAllSortedByName();
  }

  Future<List<Customer>> delete(Customer customer) async {
    await _dio.put('customers/${customer.id}').then((Response response) async {
      await _customerDao.delete(customer);
    }).catchError((_) async {
      Customer data = customer;
      data.deletedAt = DateTime.now();
      await _customerDao.update(data);
    });

    return await _customerDao.getAllSortedByName();
  }
}
