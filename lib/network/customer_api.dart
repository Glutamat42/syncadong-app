import 'package:dio/dio.dart';
import 'package:syncadong/models/customer.dart';
import 'package:syncadong/models/transaction_log.dart';
import 'package:syncadong/network/request_helper.dart';
import 'package:syncadong/utils/helpers.dart';

class CustomerApi {
  Dio _dio = RequestHelper.initDio();
  final endpoint;

  CustomerApi(this.endpoint);

  Future<List<Customer>> getAll() async {
    List<Customer> data;
    await _dio
        .get(endpoint)
        .then((Response response) => data = response.data.map<Customer>((item) => Customer.fromMap(item)).toList());
    return data;
  }

  Future<Customer> getById(int id) async {
    return Customer.fromMap((await _dio.get('$endpoint/${id.toString()}')).data);
  }

  Future<Customer> post(Customer customer) async {
    return Customer.fromMap((await _dio.post(endpoint, data: customer.toMap())).data['data']);
  }

  Future<Customer> put(Customer customer) async {
    return Customer.fromMap((await _dio.put(endpoint, data: customer.toMap())).data['data']);
  }

  Future delete(int id) async {
    return await _dio.delete('$endpoint/${id.toString()}');
  }

  Future<TransactionLog> getRemoteTransactions(DateTime startDate) async {
    return TransactionLog.fromMap((await _dio.get('$endpoint/transactions',
            queryParameters: {'start_date': startDate == null ? null : formatDateWithTime(startDate)}))
        .data);
  }
}
