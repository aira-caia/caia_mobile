import 'dart:convert';
import 'dart:math';

import 'package:appcaia/global.dart';
import 'package:appcaia/pages/MenuApp.dart';
import 'package:appcaia/pages/ReceiptApp.dart';
import 'package:appcaia/utils/CartItem.dart';
import 'package:braintree_payment/braintree_payment.dart';
import 'package:flutter/material.dart';
import 'package:flutter_braintree/flutter_braintree.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sweetalert/sweetalert.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:http/http.dart' as http;


class PaypalEqualPayment extends StatefulWidget {
  @override
  _PaypalEqualPaymentState createState() => _PaypalEqualPaymentState();
}

class _PaypalEqualPaymentState extends State<PaypalEqualPayment> {

  List<String> receiptNumbers = [];
  List<int> paidIndexes = [];
  Map payload = {};

  String orderCode;
  String tableName;
  bool isPayingOnPaypal = false;

  static const _chars =
      'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
  Random _rnd = Random();

  String getRandomString(int length) => String.fromCharCodes(Iterable.generate(
      length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));
  WebViewController controller;

  void initOrderCode() {
    DateTime date = DateTime.now();
    orderCode = DateFormat("yMdHms").format(date) +
        getRandomString(_rnd.nextInt(8) + 3);
  }

  void setupTable() async {
    tableName  = await SharedPreferences.getInstance().then((value) => value.getString("table_name"));
  }

  void viewReceipt() {
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
            builder: (context) => ReceiptApp(),
            settings: RouteSettings(arguments: {"orderCode": orderCode})),
        ModalRoute.withName("/receipt"));
  }

  void storePayment(int index, String nonce) async {
    Uri url = Uri.parse("$urlDomain/api/payment");

    List onCart = [];
    payload['orders']['orders'].forEach((CartItem element) {
      onCart.add({
        "menu_id": element.id,
        "count": element.itemCount,
        "amount": element.totalPrice
      });
    });

    Map<String, dynamic> data = {
      "type": "split_equally",
      "split_count": payload['count'],
      "order_code": orderCode,
      "amount": (payload['orders']['price'] / int.parse(payload['count'])).toStringAsFixed(2),
      "table_name": tableName, //table
      "orders": onCart,
      "nonce": nonce,
      "method": "paypal",
    };

    http.Response response = await http.post(url,
        body: json.encode(data),
        headers: {
          "Content-type": "application/json",
          "Accept": "application/json",
          "Authorization": paymentBearerToken
        });
    setState(() {
      isPayingOnPaypal = false;
      print(response.body);
      receiptNumbers.add(jsonDecode(response.body)['receipt_number']);
      paidIndexes.add(index);
      if(int.parse(payload['count']) == paidIndexes.length) {
        viewReceipt();
      }
    });
  }

  @override
  void initState() {
    super.initState();
    setupTable();
    initOrderCode();
    Future.delayed(Duration.zero, () {
      setState(() {
        payload = new Map.from(ModalRoute.of(context).settings.arguments);
      });
    });
  }


  void makePaymentPaypal(int index) async {
    setState(() {
      isPayingOnPaypal = true;
    });
    final request = BraintreePayPalRequest(amount: (payload['orders']['price'] / int.parse(payload['count'])).toStringAsFixed(2),displayName: 'CAIA Ordering Application');
    BraintreePaymentMethodNonce result = await Braintree.requestPaypalNonce(
      'sandbox_ndp4qj7m_mhjfnw88grqcb72s',
      request,
    );
    print(request.toJson());
    if(result != null) {
      print(result.nonce);
      String clientNonce = result.nonce;

      BraintreePayment braintreePayment = new BraintreePayment();
      var data = await braintreePayment.showDropIn(
          nonce: clientNonce, amount:  (payload['orders']['price'] / int.parse(payload['count'])).toStringAsFixed(2));
      storePayment(index,clientNonce);
    }else {
      setState(() {
        isPayingOnPaypal = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    print(payload);
    return WillPopScope(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          floatingActionButton: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Visibility(
                visible: receiptNumbers.length == 0,
                child: Padding(
                  padding: const EdgeInsets.only(left: 24),
                  child: FloatingActionButton.extended(
                    heroTag: "cancelBtn",
                    label: Text("Cancel Order"),
                    backgroundColor: Colors.red,
                    onPressed: () {
                      SweetAlert.show(context,
                          title: "Are you sure you want to cancel your orders?",
                          style: SweetAlertStyle.confirm,
                          showCancelButton: true, onPress: (bool isConfirm) {
                            if (isConfirm) {
                              new Future.delayed(new Duration(seconds: 1),(){
                                Navigator.pushAndRemoveUntil(
                                    context,
                                    MaterialPageRoute(builder: (context) => MenuApp()),
                                    ModalRoute.withName("/menu"));
                              });
                              return true;
                            }else {
                              return true;
                            }
                          });
                    },
                  ),
                ),
              )
            ],
          ),
          body: payload['count'] == null || isPayingOnPaypal ? SpinKitChasingDots(
            color: Colors.deepPurpleAccent,
            size: 150.0,
          ) : SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 30.0),
                  child: Column(
                    children: [
                      SizedBox(
                        height: 20.0,
                      ),
                      Center(
                        child: Text(
                          "PAY WITH PAYPAL",
                          style: TextStyle(
                              fontSize: 40.0, fontWeight: FontWeight.w200,),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20.0),
                        child: Center(
                          child: Text(
                            "STRICTLY NO CANCELLATION OF ORDERS, IF PAYMENT WAS DONE.",
                            style: TextStyle(
                              fontSize: 20.0, fontWeight: FontWeight.w300,),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 20.0,
                      ),
                      Column(children: [
                        for(int i=0; i < int.parse(payload['count']); i++)
                        Visibility(
                          visible: !paidIndexes.contains(i),
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                makePaymentPaypal(i);
                              });
                            },
                            child: Card(
                              child: Container(
                                child: Column(
                                  children: [
                                    Text(
                                      "Account ${i+1}",
                                      style: TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold),
                                    ),
                                    Text(
                                      'You have to pay: PHP ${(payload['orders']['price'] / int.parse(payload['count'])).toStringAsFixed(2)}',
                                      style: TextStyle(fontSize: 20.0),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 5.0),
                                      child: Text(
                                        'Tap on this card, to pay.',
                                        style: TextStyle(fontSize: 16.0),
                                      ),
                                    )
                                  ],
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                ),
                                padding:
                                const EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
                                width: double.maxFinite,
                              ),
                            ),
                          ),
                        )
                      ],)
                    ],
                  ),
                ),
                SizedBox(
                  height: 20.0,
                ),
              ],
            ),
          ),
        ),
      ),
      onWillPop: () async {
        SweetAlert.show(context,
            title: "Are you sure you want to cancel your orders?",
            style: SweetAlertStyle.confirm,
            showCancelButton: true, onPress: (bool isConfirm) {
              if (isConfirm) {
                new Future.delayed(new Duration(seconds: 1),(){
                  Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => MenuApp()),
                      ModalRoute.withName("/menu"));
                });
                return true;
              }else {
                return true;
              }
            });
        return false;
      },
    );
  }
}
