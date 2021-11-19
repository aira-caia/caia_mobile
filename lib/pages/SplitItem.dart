import 'dart:convert';
import 'dart:math';
import 'package:braintree_payment/braintree_payment.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:appcaia/global.dart';
import 'package:appcaia/pages/ByItemPayment.dart';
import 'package:appcaia/pages/MenuApp.dart';
import 'package:appcaia/utils/CartItem.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_braintree/flutter_braintree.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sweetalert/sweetalert.dart';

import 'ReceiptApp.dart';

class SplitItem extends StatefulWidget {
  @override
  _SplitItemState createState() => _SplitItemState();
}

class _SplitItemState extends State<SplitItem> {
  List<String> receiptLists = [], paidAccounts = [];

  String currentAccount = "ACCOUNT 1";
  Map payload = {
    "orders": {"orders": []},
    "count": '0'
  };
  List<CartItem> customerOrders = [];
  Map<String, List<CartItem>> distributedOrders = {};
  bool canPay = false;
  Map<String, Map> gatewayApis = {};
  static const _chars =
      'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
  Random _rnd = Random();

  bool isPayingOnPaypal = false;



  String getRandomString(int length) => String.fromCharCodes(Iterable.generate(
      length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));
  String referenceNumber,orderCode;

  bool isGenerated = false;

  String tableName;
  void setupTable() async {
    tableName  = await SharedPreferences.getInstance().then((value) => value.getString("table_name"));
  }

  void initOrderCode() {
    DateTime date = DateTime.now();
    orderCode = DateFormat("yMdHms").format(date) +
        getRandomString(_rnd.nextInt(8) + 3);
  }

  @override
  void initState() {
    distributedOrders[currentAccount] = [];
    Future.delayed(Duration.zero, () {
      initOrderCode();
      setupTable();
      payload = ModalRoute.of(context).settings.arguments;
      for (int i = 0; i < int.parse(payload['count']); i++) {
        distributedOrders["ACCOUNT ${i + 1}"] = [];
      }
      setState(() {
        customerOrders = payload['orders']['orders'];
      });
    });
  }

  void makePaymentPaymaya() async {
    var data;
    if (gatewayApis[
    currentAccount] ==
        null) {
      data = await generatePayment(
          true);
    } else {
      data = await gotoPayment();
    }
    setState(() {
      receiptLists = data['receipts'];
      paidAccounts = data['accounts'];
    });
    if(receiptLists.length == int.parse(payload['count'])) {
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
              builder: (ctx) => ReceiptApp(),
              settings: RouteSettings(arguments: {"orderCode": orderCode})),
          ModalRoute.withName("/receipt"));
    }
  }



  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        SweetAlert.show(context,
            title: "Exit",
            subtitle: "Are you sure you want to cancel splitting of orders?",
            style: SweetAlertStyle.confirm,
            showCancelButton: true, onPress: (bool isConfirm) {
              if (isConfirm) {
                new Future.delayed(new Duration(seconds: 1),(){
                  Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => MenuApp()),
                      ModalRoute.withName("/menu"));
                });
                // return false to keep dialog
                return true;
              }else {
                return true;
              }
            });
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text("Split Orders"),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed:() {
              SweetAlert.show(context,
                  title: "Exit",
                  subtitle: "Are you sure you want to cancel your orders?",
                  style: SweetAlertStyle.confirm,
                  showCancelButton: true, onPress: (bool isConfirm) {
                    if (isConfirm) {
                      new Future.delayed(new Duration(seconds: 1),(){
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
        ),
        body: isPayingOnPaypal ? SpinKitChasingDots(
          color: Colors.deepPurpleAccent,
          size: 150.0,
        ) : SingleChildScrollView(
          child: Padding(
              padding: EdgeInsets.only(top: 15),
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                        color: Colors.white38,
                        borderRadius: BorderRadius.circular(24)),
                    child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          children: [
                            Text(
                              "Distribute your orders",
                              style: TextStyle(
                                  fontSize: 24.0, fontWeight: FontWeight.bold),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                "Tap on each item to add/remove on your selected account.",
                                style: TextStyle(fontSize: 16.0),
                              ),
                            ),
                            Visibility(
                              visible: customerOrders
                                      .where(
                                          (element) => element.itemCount == 0)
                                      .length !=
                                  customerOrders.length,
                              child: Card(
                                child: Container(
                                  constraints: BoxConstraints(maxHeight: 450.0),
                                  child: SingleChildScrollView(
                                    child: Column(
                                      children: [
                                        for (int i = 0;
                                            i < customerOrders.length;
                                            i++) ...[
                                          orderItem(customerOrders[i])
                                        ]
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 34.0),
                              child: Card(
                                child: Container(
                                  child: Column(
                                    children: [
                                      SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        child: Row(
                                          children: [
                                            for (int i = 0;
                                                i < int.parse(payload['count']);
                                                i++) ...[
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: TextButton.icon(
                                                    onPressed: () {
                                                      setState(() {
                                                        currentAccount =
                                                            "ACCOUNT ${i + 1}";
                                                      });
                                                    },
                                                    icon: Icon(Icons
                                                        .account_box_sharp),
                                                    style: ButtonStyle(
                                                        backgroundColor: currentAccount ==
                                                                "ACCOUNT ${i + 1}"
                                                            ? MaterialStateProperty.all(
                                                                Colors.lightBlueAccent[
                                                                    400])
                                                            : MaterialStateProperty
                                                                .all(Colors
                                                                    .lightBlueAccent),
                                                        foregroundColor:
                                                            MaterialStateProperty.all(
                                                                Colors.white),
                                                        textStyle:
                                                            MaterialStateProperty.all(
                                                                TextStyle(fontSize: 18.0))),
                                                    label: Text("Account ${i + 1}")),
                                              ),
                                            ]
                                          ],
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Row(children: <Widget>[
                                          Expanded(child: Divider()),
                                          Text(
                                            "ORDERS DISTRIBUTION",
                                            style: TextStyle(
                                                fontSize: 18.0,
                                                fontWeight: FontWeight.w300),
                                          ),
                                          Expanded(child: Divider()),
                                        ]),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Text(
                                          currentAccount,
                                          style: TextStyle(fontSize: 22.0),
                                        ),
                                      ),
                                      for (int i = 0;
                                          i <
                                              distributedOrders[currentAccount]
                                                  .length;
                                          i++) ...[
                                        customerItem(
                                            distributedOrders[currentAccount]
                                                [i])
                                      ],
                                      Visibility(
                                        visible: gatewayApis.isNotEmpty && !paidAccounts.contains(currentAccount),
                                        child: Padding(
                                          padding: const EdgeInsets.all(20.0),
                                          child: SizedBox(
                                            width: double.maxFinite,
                                            child: TextButton(
                                              child: Text(
                                                "MAKE PAYMENT",
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 20.0),
                                              ),
                                              style: ButtonStyle(
                                                  backgroundColor:
                                                      MaterialStateProperty.all(
                                                          Color(0xff3CCC7E)),
                                                  padding:
                                                      MaterialStateProperty.all(
                                                          EdgeInsets.symmetric(
                                                              vertical: 15))),
                                              onPressed: () async {
                                                if(payload['method'] == 'paymaya') {
                                                  makePaymentPaymaya();
                                                }else{
                                                  makePaymentPaypal();
                                                }
                                              },
                                            ),
                                          ),
                                        ),
                                      ),
                                      Visibility(
                                        visible: paidAccounts.contains(currentAccount),
                                        child: Padding(
                                          padding: const EdgeInsets.all(20.0),
                                          child: SizedBox(
                                            width: double.maxFinite,
                                            child: TextButton(
                                              child: Text(
                                                "PAYMENT SUCCESSFUL",
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 20.0),
                                              ),
                                              style: ButtonStyle(
                                                  backgroundColor:
                                                      MaterialStateProperty.all(
                                                          Colors.grey[500]),
                                                  padding:
                                                      MaterialStateProperty.all(
                                                          EdgeInsets.symmetric(
                                                              vertical: 15))),
                                              onPressed: null,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Visibility(
                              visible: canPay && gatewayApis.isEmpty,
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 10.0),
                                child: SizedBox(
                                  width: double.maxFinite,
                                  child: TextButton(
                                    child: Text(
                                      "GENERATE PAYMENT",
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 20.0),
                                    ),
                                    style: ButtonStyle(
                                        backgroundColor:
                                            MaterialStateProperty.all(
                                                Colors.deepOrangeAccent),
                                        padding: MaterialStateProperty.all(
                                            EdgeInsets.symmetric(
                                                vertical: 15))),
                                    onPressed: () {
                                      bool payTest = true;
                                      distributedOrders.forEach((key, lists) {
                                        if (lists.isEmpty) {
                                          payTest = false;
                                          SweetAlert.show(context,
                                              title: "Distribution Failed",
                                              subtitle: "$key has no orders to make payment.",
                                              style: SweetAlertStyle.error,
                                              );
                                          return;
                                        }
                                      });

                                      if (payTest) {
                                        SweetAlert.show(context,
                                            title: "Confirmation",
                                            subtitle: "Are you sure? You wont be able to make changes on your orders.",
                                            style: SweetAlertStyle.confirm,
                                            showCancelButton: true, onPress: (bool isConfirm) {
                                              if (isConfirm) {
                                                if(payload['method'] == 'paymaya') {
                                                  generatePayment();
                                                }else{
                                                  generatePaymentPaypal();
                                                }
                                                // return false to keep dialog
                                                return true;
                                              }else {
                                                return true;
                                              }
                                            });
                                      }
                                    },
                                  ),
                                ),
                              ),
                            ),
                            Visibility(
                              visible: gatewayApis.isNotEmpty,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 8.0, horizontal: 6.0),
                                child: Container(
                                  width: double.maxFinite,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(15.0),
                                      border: Border.all(
                                          width: 5.0,
                                          color: Colors.deepPurple[400])),
                                  child: Padding(
                                    padding: const EdgeInsets.all(18.0),
                                    child: Column(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              bottom: 10.0),
                                          child: Text(
                                            "Payment Generated",
                                            style: TextStyle(
                                                fontSize: 24.0,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        Text(
                                          "Please proceed to payment on each accounts. "
                                          "Kindly navigate to different account to make the payment.",
                                          style: TextStyle(fontSize: 18.0),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            )
                          ],
                        )),
                  ),
                ],
              )),
        ),
      ),
    );
  }


  void makePaymentPaypal() async {
    setState(() {
      isPayingOnPaypal = true;
    });
    double totalAmount = 0;
    distributedOrders[currentAccount].forEach((element) {
      totalAmount += double.parse(element.totalPrice);
    });
    setState(() {
      gatewayApis[currentAccount] = {"url" : null, "amount" : totalAmount.toStringAsFixed(2)};
    });

    final request = BraintreePayPalRequest(amount: gatewayApis[currentAccount]['amount'].toString(),displayName: 'CAIA Ordering Application');
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
          nonce: clientNonce, amount: gatewayApis[currentAccount]['amount'].toString());
      storePaymentPaypal(clientNonce);

    }else {
      print("error");
      setState(() {
        isPayingOnPaypal = false;
      });
    }
  }

  //for paymaya payment
  generatePayment([bool hasResponse = false]) async {
    isGenerated = true;
    Uri uri =
        Uri.parse("https://pg-sandbox.paymaya.com/payby/v2/paymaya/payments");
    DateTime date = DateTime.now();
    if (referenceNumber == null)
      referenceNumber = DateFormat("yMdHms").format(date) +
          getRandomString(_rnd.nextInt(8) + 3) +
          "_R";

    double totalAmount = 0;
    distributedOrders[currentAccount].forEach((element) {
      totalAmount += double.parse(element.totalPrice);
    });
    Map<String, dynamic> body = {
      "totalAmount": {
        "currency": "PHP",
        "value": totalAmount.toStringAsFixed(2)
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
          "Authorization": postRequestPaymayaBearer,
          "Content-type": "application/json"
        },
        body: jsonEncode(body));
    Map responseBody = jsonDecode(response.body);

    setState(() {
      gatewayApis[currentAccount] = {"url" : responseBody['redirectUrl'], "amount" : totalAmount.toStringAsFixed(2)};
    });
    if (hasResponse) {
      return await gotoPayment();
    }
  }
  /*Username: 09193890579
  Password: Password123
  OTP: 123456*/
  generatePaymentPaypal() async {
    isGenerated = true;
    double totalAmount = 0;
    distributedOrders[currentAccount].forEach((element) {
      totalAmount += double.parse(element.totalPrice);
    });
    print("done");
    setState(() {
      gatewayApis[currentAccount] = {"url" : null, "amount" : totalAmount.toStringAsFixed(2)};
    });
    print(currentAccount);
  }

  void storePaymentPaypal(String nonce) async {
    Uri url = Uri.parse("$urlDomain/api/payment");

    print(distributedOrders[currentAccount]);
    print('hehehe');
    List onCart = [];
    distributedOrders[currentAccount].forEach((CartItem element) {
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
      "amount": gatewayApis[currentAccount]['amount'].toString(),
      "table_name": tableName, //table
      "orders": onCart,
      "nonce": nonce,
      "method": "paypal",
    };

    http.Response response = await http.post(url,
        body: json.encode(data),
        headers: {
          "Content-type": "application/json",
          "Authorization": paymentBearerToken
        });

    setState(() {
      isPayingOnPaypal = false;
      paidAccounts.add(currentAccount);
      if(paidAccounts.length == int.parse(payload['count'])) {
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
                builder: (ctx) => ReceiptApp(),
                settings: RouteSettings(arguments: {"orderCode": orderCode})),
            ModalRoute.withName("/receipt"));
      }
    });
  }

  gotoPayment() async {
    return await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => ByItemPayment(),
          settings: RouteSettings(arguments: {
            "receipts": receiptLists,
            "accounts": paidAccounts,
            "name": currentAccount,
            "url": gatewayApis[currentAccount]['url'],
            "reference": referenceNumber,
            "code": orderCode,
            "count" : payload['count'],
            "orders": distributedOrders[currentAccount],
            "amount" : gatewayApis[currentAccount]['amount']
          }))
    );
  }

  Widget orderItem(CartItem cartItem) {
    return Visibility(
      visible: cartItem.itemCount > 0,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 20.0),
        child: Card(
          color: Colors.deepPurple[300],
          child: InkWell(
            onTap: () {
              setState(() {
                if (distributedOrders[currentAccount] == null)
                  distributedOrders[currentAccount] = [];

                if (cartItem.itemCount == 0) return;

                if (distributedOrders[currentAccount]
                        .indexWhere((element) => cartItem.id == element.id) ==
                    -1) {
                  CartItem newItem = CartItem(
                    initPrice: cartItem.initPrice,
                    title: cartItem.title,
                    id: cartItem.id,
                    image_path: cartItem.image_path,
                    totalPrice: cartItem.initPrice,
                    itemCount: 1,
                  );
                  distributedOrders[currentAccount].add(newItem);
                } else {
                  int index = distributedOrders[currentAccount]
                      .indexWhere((element) => cartItem.id == element.id);
                  distributedOrders[currentAccount][index].itemCount =
                      distributedOrders[currentAccount][index].itemCount + 1;
                  distributedOrders[currentAccount][index].totalPrice =
                      (double.parse(cartItem.initPrice) *
                              distributedOrders[currentAccount]
                                  .firstWhere(
                                      (element) => cartItem.id == element.id)
                                  .itemCount)
                          .toStringAsFixed(2);
                }
                cartItem.itemCount--;
                cartItem.totalPrice = (double.parse(cartItem.initPrice) *
                        customerOrders
                            .firstWhere((element) => cartItem.id == element.id)
                            .itemCount)
                    .toStringAsFixed(2);

                if (customerOrders
                        .where((element) => element.itemCount == 0)
                        .length ==
                    customerOrders.length) {
                  canPay = true;
                }
              });
            },
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CachedNetworkImage(
                    imageUrl:
                        "https://images.pexels.com/photos/842519/pexels-photo-842519.jpeg?auto=compress&cs=tinysrgb&dpr=1&w=500",
                    imageBuilder: (context, imageProvider) => Container(
                      width: 100.0,
                      height: 100.0,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white, width: 8.0),
                        shape: BoxShape.circle,
                        image: DecorationImage(
                            image: imageProvider, fit: BoxFit.cover),
                      ),
                    ),
                    placeholder: (context, url) => CircularProgressIndicator(),
                    errorWidget: (context, url, error) => Icon(Icons.error),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          cartItem.title,
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 22.0),
                        ),
                        Text(
                          "${cartItem.itemCount} ${cartItem.itemCount == 1 ? "piece" : "pieces"} left",
                          style: TextStyle(
                              fontWeight: FontWeight.w300, fontSize: 18.0),
                        )
                      ],
                    ),
                  ),
                  Spacer(),
                  Container(
                    height: 60,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RichText(
                            text: TextSpan(children: [
                          WidgetSpan(
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 10.0),
                              child: Text("P"),
                            ),
                            style: TextStyle(
                              fontFamily: "Roboto",
                              fontSize: 14,
                            ),
                          ),
                          TextSpan(
                              text: cartItem.totalPrice,
                              style: TextStyle(
                                  fontFamily: "Roboto",
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                  fontSize: 24)),
                        ])),
                        RichText(
                            text: TextSpan(children: [
                          WidgetSpan(
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 10.0),
                              child: Text("P"),
                            ),
                            style: TextStyle(
                              fontFamily: "Roboto",
                              fontSize: 14,
                            ),
                          ),
                          TextSpan(
                              text: "${cartItem.initPrice} each",
                              style: TextStyle(
                                  fontFamily: "Roboto",
                                  fontWeight: FontWeight.w300,
                                  color: Colors.black,
                                  fontSize: 20)),
                        ]))
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget customerItem(CartItem cartItem) {
    return Visibility(
      // visible: cartItem.itemCount > 0,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 20.0),
        child: Card(
          color: Colors.deepPurple[300],
          child: InkWell(
            onTap: () {
              if (gatewayApis.isNotEmpty || isGenerated) return;
              setState(() {
                int index = customerOrders
                    .indexWhere((element) => cartItem.id == element.id);
                customerOrders[index].itemCount =
                    customerOrders[index].itemCount + 1;
                customerOrders[index]
                    .totalPrice = (double.parse(cartItem.initPrice) *
                        customerOrders
                            .firstWhere((element) => cartItem.id == element.id)
                            .itemCount)
                    .toStringAsFixed(2);
                /*=================================*/
                cartItem.itemCount--;
                cartItem.totalPrice =
                    (double.parse(cartItem.initPrice) * cartItem.itemCount)
                        .toStringAsFixed(2);
                if (cartItem.itemCount < 1) {
                  distributedOrders[currentAccount].remove(cartItem);
                }
                canPay = false;
              });
            },
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CachedNetworkImage(
                    imageUrl:
                        "https://images.pexels.com/photos/842519/pexels-photo-842519.jpeg?auto=compress&cs=tinysrgb&dpr=1&w=500",
                    imageBuilder: (context, imageProvider) => Container(
                      width: 100.0,
                      height: 100.0,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white, width: 8.0),
                        shape: BoxShape.circle,
                        image: DecorationImage(
                            image: imageProvider, fit: BoxFit.cover),
                      ),
                    ),
                    placeholder: (context, url) => CircularProgressIndicator(),
                    errorWidget: (context, url, error) => Icon(Icons.error),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          cartItem.title,
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 22.0),
                        ),
                        Text(
                          "${cartItem.itemCount} ${cartItem.itemCount == 1 ? "piece" : "pieces"}",
                          style: TextStyle(
                              fontWeight: FontWeight.w300, fontSize: 18.0),
                        )
                      ],
                    ),
                  ),
                  Spacer(),
                  Container(
                    height: 60,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RichText(
                            text: TextSpan(children: [
                          WidgetSpan(
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 10.0),
                              child: Text("P"),
                            ),
                            style: TextStyle(
                              fontFamily: "Roboto",
                              fontSize: 14,
                            ),
                          ),
                          TextSpan(
                              text: cartItem.totalPrice,
                              style: TextStyle(
                                  fontFamily: "Roboto",
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                  fontSize: 24)),
                        ])),
                        RichText(
                            text: TextSpan(children: [
                          WidgetSpan(
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 10.0),
                              child: Text("P"),
                            ),
                            style: TextStyle(
                              fontFamily: "Roboto",
                              fontSize: 14,
                            ),
                          ),
                          TextSpan(
                              text: "${cartItem.initPrice} each",
                              style: TextStyle(
                                  fontFamily: "Roboto",
                                  fontWeight: FontWeight.w300,
                                  color: Colors.black,
                                  fontSize: 20)),
                        ]))
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
