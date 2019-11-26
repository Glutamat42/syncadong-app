import 'package:flutter/material.dart';
import 'package:syncadong/models/customer.dart';
import 'package:syncadong/models/transaction_log.dart';
import 'package:syncadong/services/customer_service.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
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
              customerService.post(newCustomer).then((List<Customer> newData) => setState(() => _customers = newData));
            },
          ),
          RaisedButton(
            child: Text('refresh list'),
            onPressed: () {
              _updateCustomers();
            },
          ),
          RaisedButton(
            child: Text('get transactions log'),
            onPressed: () {
              print(customerService.getRemoteTransactions().then((TransactionLog log) {
                print(log.toJson());
              }));
            },
          ),
          RaisedButton(
            child: Text('sync'),
            onPressed: () {
              print(customerService.synchronize());
            },
          ),
          Expanded(
            child: ListView.builder(
              itemBuilder: (BuildContext context, int index) =>
                  ListTile(
                    title: Text(_customers[index].name),
                    subtitle: Text('number: ${_customers[index].randomNumber.toString()}'),
                    leading: IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () {
                        customerService.delete(_customers[index]).then((List<Customer> newData) =>
                            setState(() => _customers = newData));
                      },
                    ),
                    onTap: () {
                      Customer updateCustomer = Customer(
                        id: _customers[index].id,
                        randomNumber: _customers[index].randomNumber + 1,
                        companyId: _customers[index].companyId,
                        name: _customers[index].name,
                      );
                      customerService.put(updateCustomer).then((List<Customer> newData) =>
                          setState(() => _customers = newData));
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
