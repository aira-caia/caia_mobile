import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:appcaia/global.dart';
import 'package:appcaia/pages/PrintableReceipt.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart';

import 'MenuApp.dart';

/*
* This file is loaded for every successful transactions
* Which the users are able to review his orders and payments.
* */
class ReceiptApp extends StatefulWidget {
  @override
  _ReceiptAppState createState() => _ReceiptAppState();
}

class _ReceiptAppState extends State<ReceiptApp> {
  TextStyle cardTitle() {
    return TextStyle(fontSize: 22.0, fontWeight: FontWeight.bold);
  }

  TextStyle cardSubtitle() {
    return TextStyle(fontSize: 20.0);
  }

  Map response;
  Map payload;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      payload = ModalRoute.of(context).settings.arguments;
      fetchData(payload['orderCode']);
    });
  }

  //20215842719EVbaNK08AQ_code
  //20215824517ABK_code
  void fetchData(String orderCode) async {
    Uri uri = Uri.parse("$urlDomain/api/payment/$orderCode");
    Response data = await get(uri, headers: {
      "Authorization": paymentBearerToken,
      "Accept": "application/json",
      "Content-Type": "application/json",
    });
    setState(() {
      response = jsonDecode(data.body);
    });
  }

  List<Widget> receiptNumbers(screen) {
    List receipts = response['receiptNumbers'];
    if(response['paymentType'] == "SPLIT EQUALLY"){
      String element = receipts.first;
      return [
        InkWell(
          onTap: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => PrintableReceipt(), settings: RouteSettings(arguments: element)));
            print("Hello");
          },
          child: Card(
            child: Container(
              child: Column(
                children: [
                  Text(
                    "MAIN RECEIPT",
                    style: cardTitle(),
                  ),
                  Text(
                    element,
                    style: cardSubtitle(),
                  )
                ],
                crossAxisAlignment: CrossAxisAlignment.start,
              ),
              padding:
              const EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
              width: screen * .40,
            ),
          ),
        )
      ];
    }
    List data = receipts.map((element) {
      return InkWell(
        onTap: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => PrintableReceipt(), settings: RouteSettings(arguments: element)));
          print("Hello");
        },
        child: Card(
          child: Container(
            child: Column(
              children: [
                Text(
                  "RECEIPT NUMBER",
                  style: cardTitle(),
                ),
                Text(
                  element,
                  style: cardSubtitle(),
                )
              ],
              crossAxisAlignment: CrossAxisAlignment.start,
            ),
            padding:
                const EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
            width: screen * .40,
          ),
        ),
      );
    }).toList();
    return data;
  }

  List<Widget> orderCards(screen) {
    double c_width = MediaQuery.of(context).size.width*0.5;
    List orders = response['orders'];
    List data = orders.map((element) {
      return Card(
        child: Container(
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Chip(
                        avatar: CircleAvatar(
                          backgroundColor: Colors.grey.shade800,
                          child: Icon(Icons.shopping_cart),
                        ),
                        label: Text(element['count'].toString()),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 20.0),
                        child: Chip(
                          avatar: CircleAvatar(
                            backgroundColor: Colors.grey.shade800,
                            child: Icon(Icons.payments_rounded),
                          ),
                          label: Text(element['amount'].toString()),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 20.0,
                  ),
                  Text(
                    element['title'],
                    style: cardTitle(),
                  ),
                  SizedBox(
                    height: 10.0,
                  ),
                   Container (
                      width: c_width,
                      child: new Column (
                        children: <Widget>[
                          Text(
                            element['ingredients'] ?? "",
                            style: cardSubtitle(),
                            softWrap: true,
                          )
                        ],
                      ),
                    ),
                ],
              ),
              Spacer(),
              Container(
                width: 140.0,
                height: 140.0,
                child: CachedNetworkImage(
                    imageUrl: element['image'],
                    placeholder: (context, url) => CircularProgressIndicator(),
                    errorWidget: (context, url, error) => Icon(Icons.error),
                    fit: BoxFit.cover,
                    alignment: Alignment.center,
                    imageBuilder: (context, imageProvider) => Container(
                          decoration: BoxDecoration(
                            borderRadius:
                                BorderRadius.all(Radius.circular(12.0)),
                            image: DecorationImage(
                                image: imageProvider, fit: BoxFit.cover),
                          ),
                        )),
              ),
            ],
            crossAxisAlignment: CrossAxisAlignment.start,
          ),
          padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0),
          width: screen * .80,
        ),
      );
    }).toList();
    return data;
  }

  @override
  Widget build(BuildContext context) {
    print(payload);
    final screen = MediaQuery.of(context).size.width;
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        floatingActionButton: FloatingActionButton.extended(
          label: Text("New Order"),
          backgroundColor: Colors.lightBlue,
          onPressed: () {
            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => MenuApp()),
                ModalRoute.withName("/menu"));
          },
        ),
        body: SafeArea(
          child: response != null
              ? SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 20.0,
                      ),
                      Center(
                          child: Text(
                        "ORDER PAYMENT SUMMARY",
                        style: TextStyle(
                            fontSize: 24.0, fontWeight: FontWeight.bold),
                      )),
                      SizedBox(
                        height: 20.0,
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 10.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Card(
                              child: Container(
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.check_circle,
                                      color: Colors.green,
                                      size: 85.0,
                                    ),
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(left: 20.0),
                                      child: Text(
                                        "Payment has been successful",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 24.0),
                                      ),
                                    )
                                  ],
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                ),
                                padding: const EdgeInsets.symmetric(
                                    vertical: 15.0, horizontal: 20.0),
                                width: double.maxFinite,
                              ),
                            ),
                            Row(
                              children: [
                                Card(
                                  child: Container(
                                    child: Column(
                                      children: [
                                        Text(
                                          "PAYMENT TYPE",
                                          style: cardTitle(),
                                        ),
                                        Text(
                                          response['paymentType'],
                                          style: cardSubtitle(),
                                        )
                                      ],
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 15.0, horizontal: 20.0),
                                    width: screen * .40,
                                  ),
                                ),
                                Card(
                                  child: Container(
                                    child: Column(
                                      children: [
                                        Text(
                                          "ORDER CODE",
                                          style: cardTitle(),
                                        ),
                                        Text(
                                          response['orderCode'],
                                          style: cardSubtitle(),
                                        )
                                      ],
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 15.0, horizontal: 20.0),
                                    width: screen * .55,
                                  ),
                                )
                              ],
                            ),
                            SizedBox(
                              height: 10.0,
                            ),
                            Row(
                              children: [
                                Card(
                                  child: Container(
                                    child: Column(
                                      children: [
                                        Text(
                                          "NUMBER OF ACCOUNTS",
                                          style: cardTitle(),
                                        ),
                                        Text(
                                          response['numberOfAccounts']
                                              .toString(),
                                          style: cardSubtitle(),
                                        )
                                      ],
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 15.0, horizontal: 20.0),
                                    width: screen * .40,
                                  ),
                                ),
                                Card(
                                  child: Container(
                                    child: Column(
                                      children: [
                                        Text(
                                          "REFERENCE NUMBER",
                                          style: cardTitle(),
                                        ),
                                        Text(
                                          response['refNumber'],
                                          style: cardSubtitle(),
                                        )
                                      ],
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 15.0, horizontal: 20.0),
                                    width: screen * .55,
                                  ),
                                )
                              ],
                            ),
                            SizedBox(
                              height: 10.0,
                            ),
                            Row(
                              children: [
                                Card(
                                  child: Container(
                                    child: Column(
                                      children: [
                                        Text(
                                          "TOTAL AMOUNT",
                                          style: cardTitle(),
                                        ),
                                        Text(
                                          "${response['total']} PESO",
                                          style: cardSubtitle(),
                                        )
                                      ],
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 15.0, horizontal: 20.0),
                                    width: screen * .40,
                                  ),
                                ),
                                Visibility(
                                  visible: response['paymentType'] !=
                                          "FULL PAYMENT" &&
                                      response['paymentType'] !=
                                          "SPLIT BY ITEM",
                                  child: Card(
                                    child: Container(
                                      child: Column(
                                        children: [
                                          Text(
                                            "DISTRIBUTION AMOUNT",
                                            style: cardTitle(),
                                          ),
                                          Text(
                                            "${response['distribution']} PESO",
                                            style: cardSubtitle(),
                                          )
                                        ],
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 15.0, horizontal: 20.0),
                                      width: screen * .55,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              height: 20.0,
                            ),
                            Text("RECEIPT NUMBERS", style: cardTitle()),
                            SizedBox(
                              height: 15.0,
                            ),
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(children: receiptNumbers(screen)),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 20.0,
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 20.0),
                        height: screen * .5,
                        width: double.maxFinite,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(25.0),
                              topRight: Radius.circular(25.0)),
                          color: Color(0xffab97f3),
                        ),
                        child: SingleChildScrollView(
                          child: Column(
                            children: orderCards(screen),
                          ),
                        ),
                      )
                    ],
                  ),
                )
              : SpinKitChasingDots(
                  color: Colors.deepPurpleAccent,
                  size: 150.0,
                ),
        ),
      ),
    );
  }
}
