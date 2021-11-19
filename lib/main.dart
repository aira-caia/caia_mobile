import 'package:appcaia/login/LoginApp.dart';
import 'package:appcaia/login/LoginScreen.dart';
import 'package:appcaia/pages/EqualPayment.dart';
import 'package:appcaia/pages/FullPaymentApp.dart';
import 'package:appcaia/pages/MenuApp.dart';
import 'package:appcaia/pages/PaymentApp.dart';
import 'package:appcaia/pages/PaypalEqualPayment.dart';
import 'package:appcaia/pages/ProductApp.dart';
import 'package:appcaia/pages/ReceiptApp.dart';
import 'package:appcaia/pages/SplitItem.dart';
import 'package:appcaia/pages/WelcomeApp.dart';
import 'package:flutter/material.dart';
/*
* This is our main file, this is what's called whenever we run our application.
* */
void main() {
  runApp(BaseApp());
}

class BaseApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    /*Our application theme is set to material design, called MaterialApp*/
    return MaterialApp(
      initialRoute: "/",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: "Roboto"),
      /*These are the lists of our routes (url)*/
      routes: {
        "/": (ctx) => WelcomeApp(),
        "/menu": (ctx) => MenuApp(),
        "/product": (ctx) => ProductApp(),
        "/purchase": (ctx) => PaymentApp(),
        "/fullPayment": (ctx) => FullPaymentApp(),
        "/equalPayment": (ctx) => EqualPayment(),
        "/equalPaymentPaypal": (ctx) => PaypalEqualPayment(),
        "/login": (ctx) => LoginApp(),
        "/receipt": (ctx) => ReceiptApp(),
        "/splitItem": (ctx) => SplitItem(),
      },
    );
  }
}
