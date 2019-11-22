import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:syncadong/customer.dart';
import 'package:syncadong/customer_service.dart';
import 'package:syncadong/request_helper.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _name = '';
  int _randomNumber = 0;
  List<Customer> _customers = [];
  final Dio _dio = RequestHelper.initDio();
  final _formKey = GlobalKey<FormState>();
  CustomerService customerService = CustomerService();

  _updateCustomers() {
    customerService.get().then((List<Customer> customers) => setState(() => _customers = customers));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Syncadong'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                TextFormField(
                  initialValue: 'name',
                  onSaved: (value) => _name = value,
                ),
                TextFormField(
                  initialValue: '0',
                  onSaved: (value) => _randomNumber = int.parse(value),
                ),
              ],
            ),
          ),
          RaisedButton(
            child: Text('create'),
            onPressed: () {
              _formKey.currentState.save();
              Customer newCustomer = Customer(name: _name, companyId: 1, randomNumber: _randomNumber);
              _dio.post('customers', data: newCustomer.toMap()).then((_) => _updateCustomers());
            },
          ),
          RaisedButton(
            child: Text('refresh list'),
            onPressed: () {
              _updateCustomers();
            },
          ),
          Expanded(
            child: ListView.builder(
              itemBuilder: (BuildContext context, int index) => ListTile(
                title: Text(_customers[index].name),
                subtitle: Text('number: ${_customers[index].randomNumber.toString()}'),
                leading: IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () {
                    _dio.delete('customers/${_customers[index].id.toString()}').then((_) => _updateCustomers());
                  },
                ),
                onTap: () {
                  Customer updateCustomer = Customer(
                    id: _customers[index].id,
                    randomNumber: _customers[index].randomNumber + 1,
                    companyId: _customers[index].companyId,
                    name: _customers[index].name,
                  );
                  _dio.put('customers', data: updateCustomer.toMap()).then((_) => _updateCustomers());
                },
              ),
              itemCount: _customers.length,
            ),
          )
        ],
      ),
    );
  }
}
