import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:appcaia/pages/MenuApp.dart';
import 'package:appcaia/utils/CartItem.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sweetalert/sweetalert.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:http/http.dart' as http;

import '../global.dart';
import 'ReceiptApp.dart';

/*This file is loaded when we proceed to full payment
* it fetches the API from paymaya, and will display it
* to our application that allows the user to pay for his orders.
* */
class FullPaymentApp extends StatefulWidget {
  @override
  _FullPaymentAppState createState() => _FullPaymentAppState();
}

// 09193890579
class _FullPaymentAppState extends State<FullPaymentApp> {
  bool isPaid = false;
  bool isCancelled = false;
  String orderCode;
  static const _chars =
      'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
  Random _rnd = Random();
  String myUrl;
  Map payload;
  String tableName;
  void setupTable() async {
    tableName  = await SharedPreferences.getInstance().then((value) => value.getString("table_name"));
  }
  @override
  void initState() {
    super.initState();
    setupTable();
    Future.delayed(Duration.zero, () {
      payload = ModalRoute.of(context).settings.arguments;
      handleWebPayment();
    });
  }

  String getRandomString(int length) => String.fromCharCodes(Iterable.generate(
      length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));

  void handleWebPayment() async {
    isPaid = false; //reset paid status

    Uri url =
        Uri.parse('https://pg-sandbox.paymaya.com/payby/v2/paymaya/payments');
    DateTime date = DateTime.now();
    String refID = DateFormat("yMdHms").format(date) +
        getRandomString(_rnd.nextInt(8) + 3) +
        "_R";
    Map<String, dynamic> body = {
      "totalAmount": {"currency": "PHP", "value": payload['price']},
      "redirectUrl": {
        "success": "$urlDomain/success",
        "failure": "$urlDomain/failed",
        "cancel": "$urlDomain/cancel"
      },
      "requestReferenceNumber": refID,
      "metadata": {}
    };

    http.Response response = await http.post(url,
        // encoding: Encoding.getByName("utf-8"),
        body: json.encode(body),
        headers: {
          "Authorization":
              "Basic cGstTU9mTkt1M0ZtSE1WSHRqeWpHN3Zocjd2RmV2UmtXeG14WUwxWXE2aUZrNTo=",
        });
    Map responseBody = json.decode(response.body);

    if(this.isCancelled) return;

    setState(() {
      myUrl = responseBody['redirectUrl'];
    });

    this.checkPayment(refID);
  }

  void viewReceipt() {
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
            builder: (context) => ReceiptApp(),
            settings: RouteSettings(arguments: {"orderCode": orderCode})),
        ModalRoute.withName("/receipt"));
  }

  void checkPayment(String refID) async {
    await Timer.periodic(new Duration(seconds: 2), (timer) {
      if (isCancelled) timer.cancel();

      if (isPaid) {
        timer.cancel();
        print("Paid!");
        viewReceipt();
      } else {
        print("Not paid $isPaid");
        if (myUrl != null) checkApi(refID);
      }
    });
  }

  void checkApi(refID) async {
    Uri uri = Uri.parse(
        "https://pg-sandbox.paymaya.com/payments/v1/payment-rrns/$refID");
    http.Response response = await http.get(uri, headers: {
      "Authorization":
          postPaymentGatewayToken,
    });
    final Map responseBody = json.decode(response.body)[0];
    if (responseBody['isPaid']) {
      setState(() {
        isPaid = true;
      });
      storePayment(refID,responseBody['receiptNumber'],responseBody['id']);
    }
  }

  void storePayment(refID,receiptNumber,paymentId) async {
    Uri url = Uri.parse("$urlDomain/api/payment");
    DateTime date = DateTime.now();
     orderCode = DateFormat("yMdHms").format(date) +
        getRandomString(_rnd.nextInt(8) + 3);

    List onCart = [];
    payload['orders'].forEach((CartItem element) {
      onCart.add({
        "menu_id": element.id,
        "count": element.itemCount,
        "amount": element.totalPrice
      });
    });

    Map<String, dynamic> data = {
      "type": "full",
      "order_code": orderCode,
      "amount": payload['price'],
      "table_name": tableName, //table
      "reference_number": refID,
      "receipt_number": receiptNumber,
      "payment_id": paymentId,
      "orders": onCart
    };
    http.Response response = await http.post(url,
        body: json.encode(data),
        headers: {
          "Content-type": "application/json",
          "Authorization": paymentBearerToken
        });
  }
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        SweetAlert.show(context,
            title: "Cancel",
            subtitle: "Are you sure you want to cancel your orders?",
            style: SweetAlertStyle.confirm,
            showCancelButton: true, onPress: (bool isConfirm) {
              if (isConfirm) {
                new Future.delayed(new Duration(seconds: 1),(){
                  isCancelled = true;
                  Navigator.of(context).pop();
                  Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => MenuApp()),
                      ModalRoute.withName("/menu"));
                });
              }
              return true;
            });
        return false;
      },
      child: MaterialApp(
        title: "Full Payment",
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          floatingActionButton: !isPaid ? FloatingActionButton.extended(
            label: Text("Cancel Order"),
            backgroundColor: Colors.red,
            onPressed: () {
              SweetAlert.show(context,
                  title: "Cancel",
                  subtitle: "Are you sure you want to cancel your orders?",
                  style: SweetAlertStyle.confirm,
                  showCancelButton: true, onPress: (bool isConfirm) {
                    if (isConfirm) {
                      new Future.delayed(new Duration(seconds: 1),(){
                        isCancelled = true;
                        Navigator.of(context).pop();
                        Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (context) => MenuApp()),
                            ModalRoute.withName("/menu"));
                      });
                    }
                    return true;
                  });
            },
          ) :
          FloatingActionButton.extended(
            label: Text("New Order"),
            backgroundColor: Colors.lightBlue,
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                      builder: (context) => MenuApp()),
                  ModalRoute.withName("/menu"));
            },
          ) ,
          resizeToAvoidBottomInset: false,
          appBar: AppBar(title: Text("Full Payment Transaction")),
          body: myUrl != null
              ? Column(
                  children: [
                    Expanded(
                        child: WebView(
                      initialUrl: myUrl,
                      userAgent:
                          "Mozilla/5.0 (X11; U; Linux i686; en-US; rv:1.9.0.4) Gecko/20100101 Firefox/4.0",
                      javascriptMode: JavascriptMode.unrestricted,
                    )),
                  ],
                )
              : SpinKitFoldingCube(
            color: Colors.lightBlue,
            size: 120.0,
          ),
        ),
      ),
    );
  }
}
