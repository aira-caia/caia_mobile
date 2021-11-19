import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:appcaia/global.dart';
import 'package:appcaia/utils/CartItem.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:http/http.dart' as http;
import 'MenuApp.dart';

class ByItemPayment extends StatefulWidget {
  const ByItemPayment({Key key}) : super(key: key);

  @override
  _ByItemPaymentState createState() => _ByItemPaymentState();
}

class _ByItemPaymentState extends State<ByItemPayment> {
  bool isPaid = false;
  String myUrl;
  Timer clock;
  String referenceNumber;
  String orderCode;
  String accountName;
  Map payload;
  List<String> listOfReceipts = [],paidAccounts = [];
  String tableName;

  void checkPayment() {
    Timer.periodic(new Duration(seconds: 2), (Timer timer) {
      if(clock == null) clock = timer;
      checkApi();
    });
  }

  void checkApi() async {
    Uri uri = Uri.parse(
        "https://pg-sandbox.paymaya.com/payments/v1/payment-rrns/$referenceNumber");
    http.Response response = await http.get(uri, headers: {
      "Authorization": postPaymentGatewayToken,
    });

    if(response.statusCode == 404) {
      print("Failed to initialize");
      // showDialogMessage("Failed to create payment. There is a problem with the internet connection, please re-order.");
    }

    final List responseBody = jsonDecode(response.body);
    responseBody.forEach((r) {
      if (r['isPaid'] && !listOfReceipts.contains(r['receiptNumber'])) {
        paymentDone(r);
      }
    });
  }

  void paymentDone(Map r){
    /*Make store payment, copy from equal payment*/
    storePayment(r['requestReferenceNumber'], r['receiptNumber'], r['id']);
    clock.cancel();
    Navigator.pop(context, {"receipts":[...listOfReceipts,r['receiptNumber'].toString()],"accounts": [...paidAccounts,accountName]});
  }

  void storePayment(refID, receiptNumber, paymentID) async {
    Uri url = Uri.parse("$urlDomain/api/payment");

    List onCart = [];
    payload['orders'].forEach((CartItem element) {
      onCart.add({
        "menu_id": element.id,
        "count": element.itemCount,
        "amount": element.totalPrice
      });
    });

    Map<String, dynamic> data = {
      "type": "split_item",
      "split_count": payload['count'],
      "order_code": orderCode,
      "amount": payload['amount'],
      "table_name": tableName, //table
      "reference_number": refID,
      "receipt_number": receiptNumber,
      "payment_id": paymentID,
      "orders": onCart
    };

    http.Response response = await http.post(url,
        body: json.encode(data),
        headers: {
          "Content-type": "application/json",
          "Authorization": paymentBearerToken
        });

  }


  void setupTable() async {
    tableName  = await SharedPreferences.getInstance().then((value) => value.getString("table_name"));
  }

  @override
  void initState() {
    super.initState();
    setupTable();
    Future.delayed(Duration.zero, () {
      setState(() {
        payload = ModalRoute.of(context).settings.arguments;
        listOfReceipts = payload['receipts'];
        print(payload);
        paidAccounts = payload['accounts'];
        myUrl = payload['url'];
        accountName = payload['name'];
        referenceNumber = payload['reference'];
        orderCode = payload['code'];
        print(payload);
      });
      checkPayment();
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        clock.cancel();
        Navigator.pop(context, {"receipts":listOfReceipts,"accounts": paidAccounts});
        return false;
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
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
        appBar: AppBar(
          title: Text("PAYMENT PAGE OF $accountName"),
        ),
      ),
    );
  }
}
