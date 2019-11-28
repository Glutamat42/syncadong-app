import 'package:syncadong/database/base_local_dao.dart';
import 'package:syncadong/models/customer.dart';

class CustomerDao extends BaseLocalDao<Customer> {
  CustomerDao(String storeName) : super(storeName);

  @override
  Customer fromMap(Map<String, dynamic> json) => Customer.fromMap(json);
}
