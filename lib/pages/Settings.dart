import 'package:appcaia/global.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsApp extends StatefulWidget {
  @override
  _SettingsAppState createState() => _SettingsAppState();
}

class _SettingsAppState extends State<SettingsApp> {
  TextEditingController tableTxtController = new TextEditingController();
  TextEditingController employeeTxtController = new TextEditingController();
  SharedPreferences prefs;
  final _formKey = GlobalKey<FormState>();


  @override
  void initState() {
    super.initState();
    lookUpSharedPrefs();
  }

  void lookUpSharedPrefs() async {
    prefs = await SharedPreferences.getInstance();
    if (prefs.getString("table_name") == null) {
      await prefs.setString('table_name', "TABLE 1");
    }

    if (prefs.getString("employee_name") == null) {
      await prefs.setString('employee_name', "EMPLOYEE 1");
    }
    tableTxtController.text = prefs.getString("table_name");
    employeeTxtController.text = prefs.getString("employee_name");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Back"),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                style: TextStyle(fontSize: 30.0),
                controller: tableTxtController,
                validator: (text) {
                  if (text == null || text.isEmpty) {
                    return 'Table name cant be empty value.';
                  }
                  return null;
                },
                decoration: InputDecoration(
                    border: UnderlineInputBorder(),
                    labelStyle: TextStyle(fontSize: 30.0),
                    labelText: 'Table name'),
              ),
              TextFormField(
                controller: employeeTxtController,
                style: TextStyle(fontSize: 30.0),
                validator: (text) {
                  if (text == null || text.isEmpty) {
                    return 'Employee name cant be empty value.';
                  }
                  return null;
                },
                decoration: InputDecoration(
                    border: UnderlineInputBorder(),
                    labelStyle: TextStyle(fontSize: 24.0),
                    labelText: 'Assigned employee to this device'),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: TextButton(
                  onPressed: () async {
                    if(!_formKey.currentState.validate()) return;
                    await prefs.setString('table_name', tableTxtController.text);
                    await prefs.setString(
                        'employee_name', employeeTxtController.text);
                    final snackBar = SnackBar(
                      content: Text('Device configuration has been saved successfully!'),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                  },
                  child: Text("Save"),
                  style: ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all(Colors.deepPurple),
                      foregroundColor: MaterialStateProperty.all(Colors.white),
                      padding: MaterialStateProperty.all(EdgeInsets.symmetric(
                          vertical: 12.0, horizontal: 55.0))),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
