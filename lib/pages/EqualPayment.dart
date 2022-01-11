import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:appcaia/global.dart';
import 'package:appcaia/pages/ReceiptApp.dart';
import 'package:appcaia/utils/CartItem.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sweetalert/sweetalert.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'MenuApp.dart';

/*This file is loaded when we proceed to split equal payment*/
class EqualPayment extends StatefulWidget {
  @override
  _EqualPaymentState createState() => _EqualPaymentState();
}

class _EqualPaymentState extends State<EqualPayment> {
  Map payload = {};
  List<String> paymentUrls = [];
  List<String> receiptNumbers = [];
  int counter = 0;
  int paidCounter = 0;
  int totalPaymentCount = 0;
  String referenceNumber;
  String orderCode;
  bool onLoad = true;
  bool isCancelled = false;
  String tableName;

  static const _chars =
      'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
  Random _rnd = Random();

  String getRandomString(int length) => String.fromCharCodes(Iterable.generate(
      length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));
  WebViewController controller;

  @override
  void initState() {
    super.initState();
    setupTable();
    initOrderCode();
    Future.delayed(Duration.zero, () {
      setState(() {
        payload = ModalRoute.of(context).settings.arguments;
      });
      createPayment();
    });
  }

  void setupTable() async {
    tableName  = await SharedPreferences.getInstance().then((value) => value.getString("table_name"));
  }

  void initOrderCode() {
    DateTime date = DateTime.now();
    orderCode = DateFormat("yMdHms").format(date) +
        getRandomString(_rnd.nextInt(8) + 3);
  }

  void checkPayment() {
    Timer.periodic(new Duration(seconds: 2), (timer) {
      if (isCancelled) timer.cancel();
      if (paidCounter == totalPaymentCount) {
        //paid
        timer.cancel();
        viewReceipt();
      } else {
        if (paymentUrls.length > 0) checkApi();
      }
    });
  }

  /* void fetchData(String orderCode) async {
    Uri uri = Uri.parse("$urlDomain/api/payment/${payload['orderCode']}");
    http.Response data = await http.get(uri, headers: {
      "Authorization":
      paymentBearerToken,
    });

  }*/

  void viewReceipt() {
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
            builder: (context) => ReceiptApp(),
            settings: RouteSettings(arguments: {"orderCode": orderCode})),
        ModalRoute.withName("/receipt"));
  }

  bool hasFailed = false;
  void checkApi() async {
    Uri uri = Uri.parse(
        "https://pg-sandbox.paymaya.com/payments/v1/payment-rrns/$referenceNumber");
    http.Response response = await http.get(uri, headers: {
      "Authorization": postPaymentGatewayToken,
    });

    if(response.statusCode == 404 && !hasFailed) {
      print("Failed to initialize");
      hasFailed = true;
      this.isCancelled = true;
      showAlert("Failed to create payment. There is a problem with the internet connection, please re-order.", context);
    }

    final List responseBody = json.decode(response.body);
    responseBody.forEach((r) {
      if (r['isPaid'] && !receiptNumbers.contains(r['receiptNumber'])) { //wala pang receipt
        storePayment(r['requestReferenceNumber'], r['receiptNumber'], r['id']);
      }
    });
  }

  void storePayment(refID, receiptNumber, paymentID) async {
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
      "amount": payload['orders']['price'] / int.parse(payload['count']),
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

    setState(() {
      receiptNumbers.add(receiptNumber);
      paidCounter++;
      paymentUrls.remove(paymentUrls[counter]);
    });


    if (paymentUrls.length == 1) {
      this.counter = 0;
      controller.loadUrl(paymentUrls[0]);
    }else{
      counter = 0;
    }
  }

  void createPayment() async {
    List<String> gatewayApis = [];
    Uri uri =
        Uri.parse("https://pg-sandbox.paymaya.com/payby/v2/paymaya/payments");
    DateTime date = DateTime.now();
    referenceNumber = DateFormat("yMdHms").format(date) +
        getRandomString(_rnd.nextInt(8) + 3) +
        "_R";
    for (int i = 0; i < int.parse(payload['count']); i++) {
      Map<String, dynamic> body = {
        "totalAmount": {
          "currency": "PHP",
          "value": payload['orders']['price'] / int.parse(payload['count'])
        },
        "redirectUrl": {
          "success": "$urlDomain/success",
          "failure": "$urlDomain/failed",
          "cancel": "$urlDomain/cancel"
        },
        "requestReferenceNumber": referenceNumber,
        "metadata": {}
      };
      http.Response response = await http.post(uri,
          headers: {
            "Authorization":
                "Basic cGstTU9mTkt1M0ZtSE1WSHRqeWpHN3Zocjd2RmV2UmtXeG14WUwxWXE2aUZrNTo=",
            "Content-type": "application/json"
          },
          body: jsonEncode(body));
      Map responseBody = jsonDecode(response.body);
      gatewayApis.add(responseBody['redirectUrl']);
    }

    setState(() {
      paymentUrls.addAll(gatewayApis);
      totalPaymentCount = paymentUrls.length;
    });
    checkPayment();
  }

  showLoading(BuildContext context) {
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      content: LoadingUI(),
    );

    // show the dialog
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  Widget showUI(context) {
    if (totalPaymentCount != 0 && paymentUrls.length > 0) {
      return Container(
          height: 800,
          child: WebView(
            initialUrl: paymentUrls[counter],
            onPageStarted: (web) {},
            onWebViewCreated: (WebViewController webController) {
              controller = webController;
            },
            onPageFinished: (web) {},
            userAgent:
                "Mozilla/5.0 (X11; U; Linux i686; en-US; rv:1.9.0.4) Gecko/20100101 Firefox/4.0",
            javascriptMode: JavascriptMode.unrestricted,
          ));
    } else {
      return Text("");
    }
  }

  Widget LoadingUI() {
    return Container(
      width: double.maxFinite,
      height: 240.0,
      child: SpinKitFoldingCube(
        color: Colors.lightBlue,
        size: 120.0,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          floatingActionButton: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                  padding: const EdgeInsets.only(left: 40.0),
                  child: FloatingActionButton(
                    heroTag: "refreshBtn",
                    child: Icon(Icons.refresh),
                    onPressed: () {
                      controller.loadUrl(paymentUrls[counter]);
                    },
                  )),
              Visibility(
                visible: receiptNumbers.length == 0,
                child: FloatingActionButton.extended(
                  heroTag: "cancelBtn",
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
                              Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(builder: (context) => MenuApp()),
                                  ModalRoute.withName("/menu"));
                            });
                          }
                          return true;
                        });
                  },
                ),
              )
            ],
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 30.0),
                  child: Column(
                    children: [
                      SizedBox(
                        height: 20.0,
                      ),
                      Text(
                        "SCAN TO PAY",
                        style: TextStyle(
                            fontSize: 40.0, fontWeight: FontWeight.w200),
                      ),
                      SizedBox(
                        height: 20.0,
                      ),
                      Text(
                        "You have ${paymentUrls.length} pending payments",
                        style: TextStyle(
                            fontSize: 22.0, fontWeight: FontWeight.w300),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 20.0,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 20.0),
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 20.0),
                    child: Row(
                      children: [
                        Visibility(
                          visible: paymentUrls.length > 1,
                          child: TextButton(
                            onPressed: () {
                              if (counter != 0) {
                                setState(() {
                                  counter--;
                                  controller.loadUrl(paymentUrls[counter]);
                                });
                              }
                            },
                            child: Icon(Icons.arrow_back_ios),
                            style: TextButton.styleFrom(
                                backgroundColor: Colors.grey[300],
                                padding: EdgeInsets.symmetric(
                                    horizontal: 30.0, vertical: 10.0)),
                          ),
                        ),
                        SizedBox(
                          width: 20.0,
                        ),
                        Visibility(
                          visible: paymentUrls.length > 1,
                          child: Text(
                            (counter + 1).toString(),
                            style: TextStyle(fontSize: 32.0),
                          ),
                        ),
                        SizedBox(
                          width: 20.0,
                        ),
                        Visibility(
                          visible: paymentUrls.length > 1,
                          child: TextButton(
                            onPressed: () {
                              if (counter < paymentUrls.length - 1) {
                                setState(() {
                                  counter++;
                                  controller.loadUrl(paymentUrls[counter]);
                                });
                              }
                            },
                            child: Icon(Icons.arrow_forward_ios),
                            style: TextButton.styleFrom(
                                backgroundColor: Colors.grey[300],
                                padding: EdgeInsets.symmetric(
                                    horizontal: 30.0, vertical: 10.0)),
                          ),
                        ),
                        Spacer(),
                        Padding(
                          padding: const EdgeInsets.only(right: 10.0),
                          child: Text(
                            "Payment Received: ${receiptNumbers.length} / ${payload['count']}",
                            style: TextStyle(fontSize: 24.0),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                showUI(context)
              ],
            ),
          ),
        ),
      ),
      onWillPop: () async {
        SweetAlert.show(context,
            title: "Cancel",
            subtitle: "Are you sure you want to cancel your orders?",
            style: SweetAlertStyle.confirm,
            showCancelButton: true, onPress: (bool isConfirm) {
              if (isConfirm) {
                new Future.delayed(new Duration(seconds: 1),(){
                  isCancelled = true;
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
    );
  }
}

// pushAndRemoveUntilPage(context, MenuApp());
