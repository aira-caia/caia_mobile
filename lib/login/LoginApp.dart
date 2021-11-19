import 'package:appcaia/main.dart';
import 'package:appcaia/pages/WelcomeApp.dart';
import 'package:flutter/material.dart';
import 'package:flutter_login/theme.dart';

import 'LoginScreen.dart';

/*
* This is the main component of our login system,
* it has a child component which is the Login Screen
* */
class LoginApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CAIA LOGIN',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        accentColor: Colors.lightBlue,
        cursorColor: Colors.lightBlue,
        textTheme: TextTheme(
          headline3: TextStyle(
            fontFamily: 'OpenSans',
            fontSize: 45.0,
            color: Colors.white70,
          ),
          button: TextStyle(
            fontFamily: 'OpenSans',
          ),
          subtitle1: TextStyle(fontFamily: 'NotoSans'),
          bodyText2: TextStyle(fontFamily: 'NotoSans'),
        ),
      ),
      home: Scaffold(
        floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.white,
          child: Icon(Icons.keyboard_return_rounded),
          onPressed: () {
            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                    builder: (context) => BaseApp()),
                ModalRoute.withName("/"));
          },
        ),
        body: LoginScreen(),),
    );
  }
}