import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:appcaia/pages/PaypalEqualPayment.dart';
import 'package:appcaia/pages/ReceiptApp.dart';
import 'package:appcaia/utils/CartItem.dart';
import 'package:braintree_payment/braintree_payment.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:appcaia/global.dart';
import 'package:appcaia/pages/EqualPayment.dart';
import 'package:appcaia/pages/FullPaymentApp.dart';
import 'package:appcaia/pages/SplitItem.dart';
import 'package:appcaia/utils/Navbar.dart';
import 'package:appcaia/utils/SeparatorOne.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_braintree/flutter_braintree.dart';
import 'package:intl/intl.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sweetalert/sweetalert.dart';

/*This file is loaded whenever we click
* the checkout button on our menu module
*
* the user are able to choose his payment method.
* */
class PaymentApp extends StatefulWidget {
  @override
  _PaymentAppState createState() => _PaymentAppState();
}

class _PaymentAppState extends State<PaymentApp> {
  String paymentMethod = "paymaya";
  String modeOfPayment = "full";
  String splitMethod = "equal";
  Map payload = {};
  bool hasNumberOfAccounts = false;
  bool isPaid = false;
  bool isPayingOnPaypal = false;
  String orderCode;

  TextEditingController numberOfAccountsController =
      new TextEditingController();

  static const _chars =
      'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
  Random _rnd = Random();
  String getRandomString(int length) => String.fromCharCodes(Iterable.generate(
      length, (_) => _chars.codeUnitAt(_rnd.nextInt(_chars.length))));

  String tableName;
  void setupTable() async {
    tableName  = await SharedPreferences.getInstance().then((value) => value.getString("table_name"));
  }

  String fullPaymentUrl;

  @override
  void initState() {
    super.initState();
    setupTable();
    Future.delayed(Duration.zero, () {
      payload = new Map.from(ModalRoute.of(context).settings.arguments);
      print(payload['orders'][0].itemCount);
      print("Hello");
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return true;
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: SafeArea(
            child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
          child: body(context),
        )),
      ),
    );
  }

  Widget body(BuildContext context) {
    Size screen = MediaQuery.of(context).size;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Navbar(
          title: "Payment",
          backIcon: true,
        ),
        Container(
          height: screen.height * .9,
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(
                  height: 25.0,
                ),
                Text(
                  "Confirm order and pay",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(
                  height: 8.0,
                ),
                Text(
                  "Please make the payment, after that your order will be on process.",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w300),
                ),
                SizedBox(
                  height: 25.0,
                ),
                Container(
                  width: double.infinity,
                  height: modeOfPayment == "full" ? 355 : 500,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 2,
                          blurRadius: 4,
                          offset: Offset(0, 1), //
                        )
                      ]),
                  child: boxDetails(context),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget orderItem() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 20.0),
      child: Card(
        color: Colors.deepPurple[300],
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
                      "Title",
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 22.0),
                    ),
                    Text(
                      "4 pieces left",
                      style: TextStyle(
                          fontWeight: FontWeight.w300, fontSize: 18.0),
                    )
                  ],
                ),
              ),
              Spacer(),
              Container(
                height: 50,
                child: RichText(
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
                      text: "1386.00",
                      style: TextStyle(
                          fontFamily: "Roboto",
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          fontSize: 24)),
                ])),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget boxDetails(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 10.0,
          ),
          Text(
            "MODE OF PAYMENT",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          SizedBox(
            height: 10.0,
          ),
          Row(
            children: [
              TextButton(
                onPressed: () {
                  setState(() {
                    modeOfPayment = "full";
                  });
                },
                child: Text("Full"),
                style: ButtonStyle(
                    textStyle:
                        MaterialStateProperty.all(TextStyle(fontSize: 12.0)),
                    padding: MaterialStateProperty.all(
                        EdgeInsets.symmetric(horizontal: 40.0)),
                    backgroundColor: modeOfPayment == "full"
                        ? MaterialStateProperty.all(Color(0xff262626))
                        : MaterialStateProperty.all(Color(0xffBABABA)),
                    foregroundColor: MaterialStateProperty.all(Colors.white),
                    shape: MaterialStateProperty.all(RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25)))),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 10.0),
                child: TextButton(
                  onPressed: () {
                    setState(() {
                      modeOfPayment = "split";
                    });
                  },
                  child: Text("Split"),
                  style: ButtonStyle(
                      textStyle:
                          MaterialStateProperty.all(TextStyle(fontSize: 12.0)),
                      padding: MaterialStateProperty.all(
                          EdgeInsets.symmetric(horizontal: 40.0)),
                      backgroundColor: modeOfPayment == "split"
                          ? MaterialStateProperty.all(Color(0xff262626))
                          : MaterialStateProperty.all(Color(0xffBABABA)),
                      foregroundColor: MaterialStateProperty.all(Colors.white),
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25)))),
                ),
              ),
            ],
          ),
          SeparatorOne(),
          Text(
            "PAYMENT METHODS",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          SizedBox(
            height: 10.0,
          ),
          Row(
            children: [
              TextButton(
                onPressed: () {
                  setState(() {
                    paymentMethod = "paymaya";
                  });
                },
                child: Text("PAYMAYA"),
                style: ButtonStyle(
                    textStyle:
                        MaterialStateProperty.all(TextStyle(fontSize: 14.0)),
                    padding: MaterialStateProperty.all(
                        EdgeInsets.symmetric(horizontal: 40.0)),
                    backgroundColor: paymentMethod == "paymaya"
                        ? MaterialStateProperty.all(Color(0xffC1DFFB))
                        : MaterialStateProperty.all(Colors.white),
                    foregroundColor: MaterialStateProperty.all(Colors.black),
                    side: MaterialStateProperty.all(
                        BorderSide(color: Color(0xff40A3FF), width: 1)),
                    shape: MaterialStateProperty.all(RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5)))),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 10.0),
                child: TextButton(
                  onPressed: () {
                    setState(() {
                      paymentMethod = "paypal";
                    });
                  },
                  child: Text("PAYPAL"),
                  style: ButtonStyle(
                      textStyle:
                      MaterialStateProperty.all(TextStyle(fontSize: 14.0)),
                      padding: MaterialStateProperty.all(
                          EdgeInsets.symmetric(horizontal: 40.0)),
                      backgroundColor: paymentMethod == "paypal"
                          ? MaterialStateProperty.all(Color(0xffC1DFFB))
                          : MaterialStateProperty.all(Colors.white70),
                      foregroundColor: MaterialStateProperty.all(Colors.black),
                      side: MaterialStateProperty.all(
                          BorderSide(color: Color(0xff40A3FF), width: 1)),
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5)))),
                ),
              ),
              /*Padding(
                padding: const EdgeInsets.only(left: 10.0),
                child: TextButton(
                  onPressed: true
                      ? null
                      : () {
                          setState(() {
                            paymentMethod = "gcash";
                          });
                        },
                  child: Text("GCASH (Soon)"),
                  style: ButtonStyle(
                      textStyle:
                          MaterialStateProperty.all(TextStyle(fontSize: 14.0)),
                      padding: MaterialStateProperty.all(
                          EdgeInsets.symmetric(horizontal: 40.0)),
                      backgroundColor: paymentMethod == "gcash"
                          ? MaterialStateProperty.all(Color(0xffC1DFFB))
                          : MaterialStateProperty.all(Colors.white70),
                      foregroundColor: MaterialStateProperty.all(Colors.black),
                      side: MaterialStateProperty.all(
                          BorderSide(color: Color(0xff40A3FF), width: 1)),
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5)))),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 10.0),
                child: TextButton(
                  onPressed: true
                      ? null
                      : () {
                          setState(() {
                            paymentMethod = "gcash";
                          });
                        },
                  child: Text("COINS PH (Soon)"),
                  style: ButtonStyle(
                      textStyle:
                          MaterialStateProperty.all(TextStyle(fontSize: 14.0)),
                      padding: MaterialStateProperty.all(
                          EdgeInsets.symmetric(horizontal: 40.0)),
                      backgroundColor: paymentMethod == "coins"
                          ? MaterialStateProperty.all(Color(0xffC1DFFB))
                          : MaterialStateProperty.all(Colors.white70),
                      foregroundColor: MaterialStateProperty.all(Colors.black),
                      side: MaterialStateProperty.all(
                          BorderSide(color: Color(0xff40A3FF), width: 1)),
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5)))),
                ),
              ),*/
            ],
          ),
          SeparatorOne(),
          SizedBox(
            width: double.maxFinite,
            child: modeOfPayment == "full"
                ? TextButton(
                    child: Text(
                      isPayingOnPaypal ? "Please wait" : "MAKE PAYMENT",
                      style: TextStyle(color: Colors.white, fontSize: 20.0),
                    ),

                    style: ButtonStyle(
                        backgroundColor:
                        isPayingOnPaypal ? MaterialStateProperty.all(Colors.grey) : MaterialStateProperty.all(Color(0xff3CCC7E)),
                        padding: MaterialStateProperty.all(
                            EdgeInsets.symmetric(vertical: 15))),
                    onPressed: isPayingOnPaypal ? null : () => handleFullPayment(context),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 10.0,
                      ),
                      Text(
                        "SPLIT METHODS",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(
                        height: 10.0,
                      ),
                      Row(
                        children: [
                          TextButton(
                            onPressed: () {
                              setState(() {
                                splitMethod = "equal";
                              });
                            },
                            child: Text("Equal"),
                            style: ButtonStyle(
                                textStyle: MaterialStateProperty.all(
                                    TextStyle(fontSize: 14.0)),
                                padding: MaterialStateProperty.all(
                                    EdgeInsets.symmetric(horizontal: 40.0)),
                                backgroundColor: splitMethod == "equal"
                                    ? MaterialStateProperty.all(
                                        Color(0xffC1DFFB))
                                    : MaterialStateProperty.all(Colors.white),
                                foregroundColor:
                                    MaterialStateProperty.all(Colors.black),
                                side: MaterialStateProperty.all(BorderSide(
                                    color: Color(0xff40A3FF), width: 1)),
                                shape: MaterialStateProperty.all(
                                    RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(5)))),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 10.0),
                            child: TextButton(
                              onPressed: () {
                                setState(() {
                                  splitMethod = "by_item";
                                });
                              },
                              child: Text("By item"),
                              style: ButtonStyle(
                                  textStyle: MaterialStateProperty.all(
                                      TextStyle(fontSize: 14.0)),
                                  padding: MaterialStateProperty.all(
                                      EdgeInsets.symmetric(horizontal: 40.0)),
                                  backgroundColor: splitMethod == "by_item"
                                      ? MaterialStateProperty.all(
                                          Color(0xffC1DFFB))
                                      : MaterialStateProperty.all(Colors.white),
                                  foregroundColor:
                                      MaterialStateProperty.all(Colors.black),
                                  side: MaterialStateProperty.all(BorderSide(
                                      color: Color(0xff40A3FF), width: 1)),
                                  shape: MaterialStateProperty.all(
                                      RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(5)))),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 5.0,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 155.0,
                            child: TextFormField(
                              onChanged: (content) {
                                if (content.isNotEmpty) {
                                  setState(() {
                                    hasNumberOfAccounts = true;
                                  });
                                } else {
                                  setState(() {
                                    hasNumberOfAccounts = false;
                                  });
                                }
                              },
                              keyboardType: TextInputType.number,
                              controller: numberOfAccountsController,
                              inputFormatters: <TextInputFormatter>[
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(2),
                              ],
                              decoration: const InputDecoration(
                                hintText: 'Number of accounts',
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 15.0,
                          ),
                          Visibility(
                              visible: hasNumberOfAccounts,
                              child: SizedBox(
                                width: double.maxFinite,
                                child: TextButton(
                                  child: Text(
                                    splitMethod == "equal"
                                        ? "MAKE PAYMENT"
                                        : "SPLIT ORDERS",
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 20.0),
                                  ),
                                  style: ButtonStyle(
                                      backgroundColor:
                                          MaterialStateProperty.all(
                                              Color(0xff3CCC7E)),
                                      padding: MaterialStateProperty.all(
                                          EdgeInsets.symmetric(vertical: 15))),
                                  onPressed: () =>
                                      handleSplitEqualPayment(context),
                                ),
                              )),
                        ],
                      ),
                    ],
                  ),
          ),

          /* Text(
            "PAYMENT DETAILS",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          SizedBox(
            height: 10.0,
          ),
          paymentDetails()*/
        ],
      ),
    );
  }

  void handleSplitEqualPayment(BuildContext context) async {

    List<CartItem> __orders = payload['orders'];
    for(int i=0; i < __orders.length; i++) {
      CartItem item = __orders[i];
      try {
        Uri uri =
        Uri.parse("$urlDomain/api/menu/${item.id}");
        http.Response response = await http.get(uri);
        Map data = jsonDecode(response.body);
        if(data['quantity'] < item.itemCount){
          SweetAlert.show(context,
              style: SweetAlertStyle.error,
              title: "Insufficient Stocks",
              subtitle: "${item.title} has insufficient stocks to fulfill your order. ${data['quantity']} piece/s remaining.");
          return;
        }
      } catch (exception) {
        print("Error Found! $exception");
      }
    }

    if (splitMethod == "equal") {
      if(paymentMethod == 'paymaya') {
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
                builder: (context) => EqualPayment(),
                settings: RouteSettings(arguments: {
                  "count": numberOfAccountsController.text,
                  "orders": payload,
                  'method': paymentMethod
                })),
            ModalRoute.withName("/equalPayment"));
      }else{
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
                builder: (context) => PaypalEqualPayment(),
                settings: RouteSettings(arguments: {
                  "count": numberOfAccountsController.text,
                  "orders": payload,
                  'method': paymentMethod
                })),
            ModalRoute.withName("/equalPaymentPaypal"));
      }
    } else {
      SweetAlert.show(context,
          title: "Are you sure you want to split the orders?",
          subtitle: "You won't be able to make changes on your order.",
          style: SweetAlertStyle.confirm,
          showCancelButton: true, onPress: (bool isConfirm) {
            if (isConfirm) {
              new Future.delayed(new Duration(seconds: 1),(){
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                        builder: (context) => SplitItem(),
                        settings: RouteSettings(arguments: {
                          "count": numberOfAccountsController.text,
                          "orders": payload,
                          'method': paymentMethod
                        })),
                    ModalRoute.withName("/splitItem"));
              });
              // return false to keep dialog
              return true;
            }else {
              return true;
            }
          });
    }
  }

  void handleFullPayment(BuildContext context) async {
    // Navigator.pushReplacementNamed(context, "/fullPayment", arguments: payload);

    List<CartItem> __orders = payload['orders'];
    for(int i=0; i < __orders.length; i++) {
      CartItem item = __orders[i];
      try {
        Uri uri =
        Uri.parse("$urlDomain/api/menu/${item.id}");
        http.Response response = await http.get(uri);
        Map data = jsonDecode(response.body);
        if(data['quantity'] < item.itemCount){
          SweetAlert.show(context,
              style: SweetAlertStyle.error,
              title: "Insufficient Stocks",
              subtitle: "${item.title} has insufficient stocks to fulfill your order. ${data['quantity']} piece/s remaining.");
          return;
        }
      } catch (exception) {
        print("Error Found! $exception");
      }
    }

    if(paymentMethod == 'paymaya') {
      pushReplacementPage(context, FullPaymentApp(), arguments: payload);
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
              builder: (context) => FullPaymentApp(),
              settings: RouteSettings(arguments: payload)),
          ModalRoute.withName("/fullPayment"));
    }else {
      setState(() {
        isPayingOnPaypal = true;
      });
      makeFullPaymentPaypal();
    }
  }

  void makeFullPaymentPaypal() async {
    final request = BraintreePayPalRequest(amount: payload['price'].toString(),displayName: 'CAIA Ordering Application');
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
          nonce: clientNonce, amount: payload['price'].toString());
      storePayment(clientNonce);
    }else {
      print("error");
      setState(() {
        isPayingOnPaypal = false;
      });
    }
  }

  void viewReceipt() {
    Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
            builder: (context) => ReceiptApp(),
            settings: RouteSettings(arguments: {"orderCode": orderCode})),
        ModalRoute.withName("/receipt"));
  }


  void storePayment(String nonce) async {
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
      "nonce": nonce,
      "method": "paypal",
      "order_code": orderCode,
      "amount": payload['price'].toString(),
      "table_name": tableName, //table
      "orders": onCart,
    };
    http.Response response = await http.post(url,
        body: json.encode(data),
        headers: {
          "Content-type": "application/json",
          "Authorization": paymentBearerToken
        });

    setState(() {
      isPayingOnPaypal = false;
    });
    viewReceipt();
  }

  Widget paymentDetails() {
    return Column(
      children: [
        TextFormField(
          decoration: const InputDecoration(
            hintText: 'Cardholder name',
          ),
        ),
        SizedBox(
          height: 10.0,
        ),
        TextFormField(
          decoration: const InputDecoration(
              hintText: 'Card number', prefixIcon: Icon(Icons.credit_card)),
        ),
        SizedBox(
          height: 10.0,
        ),
        Row(
          children: [
            Flexible(
              child: TextField(
                inputFormatters: [MaskTextInputFormatter(mask: "##/##")],
                decoration: const InputDecoration(
                  hintText: 'MM/YY',
                ),
              ),
            ),
            SizedBox(
              width: 10.0,
            ),
            Flexible(
              child: TextField(
                inputFormatters: [MaskTextInputFormatter(mask: "###")],
                decoration: const InputDecoration(
                  hintText: 'CVV',
                ),
              ),
            )
          ],
        )
      ],
    );
  }

  showConfirmDialog(String message, Function callBack) {
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      content: Text(message),
      actions: [
        TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              callBack();
            },
            child: Text("Yes")),
        TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text("No")),
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}
