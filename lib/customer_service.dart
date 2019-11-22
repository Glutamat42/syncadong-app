import 'package:dio/dio.dart';
import 'package:syncadong/customer.dart';
import 'package:syncadong/customer_dao.dart';
import 'package:syncadong/request_helper.dart';

class CustomerService {
  Dio _dio = RequestHelper.initDio();
  String endpoint = 'customer';
  CustomerDao _customerDao = CustomerDao();

  Future<List<Customer>> get() async {
    List<Customer> _data;
    await _dio.get('customers').then((response) async {
      _data = response.data.map<Customer>((item) => Customer.fromMap(item)).toList();
      _customerDao.insertAll(_data);
    }).catchError((_) async {
      _data = await _customerDao.getAllSortedByName();
    });
    return _data;
  }
}
