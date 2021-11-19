import 'dart:convert';

import 'package:appcaia/global.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart';

class PrintableReceipt extends StatefulWidget {
  const PrintableReceipt({Key key}) : super(key: key);

  @override
  _PrintableReceiptState createState() => _PrintableReceiptState();
}

class _PrintableReceiptState extends State<PrintableReceipt> {
  final double fontSize = 16.0;
  String payload;
  Map response = {};

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      payload = ModalRoute.of(context).settings.arguments;
      print(payload);
      fetchData(payload);
    });
  }

  void fetchData(String payload) async {
    Uri url = Uri.parse("$urlDomain/api/receipt/$payload");
    Response rp = await get(url, headers: {
      "Authorization": paymentBearerToken,
    });
    setState(() {
      response = jsonDecode(rp.body);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Receipt"),
      ),
      backgroundColor: Colors.white.withOpacity(.9),
      body: SafeArea(
        child: response.isEmpty
            ? Container(
                height: double.maxFinite,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SpinKitChasingDots(
                      color: Colors.deepPurpleAccent,
                      size: 150.0,
                    ),
                    Visibility(
                        visible: response.isEmpty,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 45.0),
                          child: Text(
                            "Preparing records of receipt",
                            style: TextStyle(
                                fontSize: 25.0, fontWeight: FontWeight.w300),
                          ),
                        ))
                  ],
                ),
              )
            : SingleChildScrollView(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24.0),
                    child: Container(
                      width: 480.0,
                      color: Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20.0, vertical: 40.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(
                              height: 20.0,
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 3.0),
                              child: Text(
                                "THE FOOD CLUB OF CAIA",
                                style: TextStyle(fontSize: fontSize),
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 3.0),
                              child: Text(
                                "7980 SOUTH STREET AVE",
                                style: TextStyle(fontSize: fontSize),
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 3.0),
                              child: Text(
                                "BALANGA, CITY BATAAN - 2100",
                                style: TextStyle(fontSize: fontSize),
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 3.0),
                              child: Text(
                                "8888 - 888 (8888)",
                                style: TextStyle(fontSize: fontSize),
                              ),
                            ),
                            SizedBox(
                              height: 24.0,
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 3.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  RichText(
                                    text: TextSpan(children: [
                                      TextSpan(
                                          text: "Table: ",
                                          style: TextStyle(
                                              fontSize: fontSize,
                                              color: Colors.black)),
                                      TextSpan(
                                          text: response['tableName'],
                                          style: TextStyle(
                                              fontSize: 24.0,
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold)),
                                    ]),
                                  ),
                                  RichText(
                                    text: TextSpan(children: [
                                      TextSpan(
                                          text: "Receipt No. ",
                                          style: TextStyle(
                                              fontSize: fontSize,
                                              color: Colors.black)),
                                      TextSpan(
                                          text: payload,
                                          style: TextStyle(
                                              fontSize: fontSize,
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold)),
                                    ]),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 3.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Ref No. ${response['refNumber']}"),
                                ],
                              ),
                            ),
                            Padding(
                              padding:
                              const EdgeInsets.symmetric(vertical: 3.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Order Code. ${response['orderCode']}"),
                                ],
                              ),
                            ),
                            Padding(
                              padding:
                              const EdgeInsets.symmetric(vertical: 3.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Payment Type: ${response['paymentType']}"),
                                ],
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 3.0),
                              child: Divider(
                                color: Colors.black,
                              ),
                            ),
                            DateWidget(),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 3.0),
                              child: Divider(
                                color: Colors.black,
                              ),
                            ),
                            for (int i = 0;
                                i < response['orders'].length;
                                i++) ...[
                              OrdersWidget(
                                  response['orders'][i]['count'],
                                  response['orders'][i]['title'],
                                  response['orders'][i]['amount'])
                            ],
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 3.0),
                              child: Divider(
                                color: Colors.black,
                              ),
                            ),
                            TotalWidget(),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 3.0),
                              child: Divider(
                                color: Colors.black,
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 3.0),
                              child: Text(
                                "THANK YOU FOR DINING WITH US!",
                                style: TextStyle(fontSize: fontSize),
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 1.0),
                              child: Text(
                                "PLEASE COME AGAIN",
                                style: TextStyle(fontSize: fontSize),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
      ),
    );
  }
  String getTotal(List orders){
    double total = 0;
    orders.forEach((element) {
      total+=element['realAmount'];
    });
    return total.toStringAsFixed(2);
  }

  Widget TotalWidget() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 3.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: Text(
                  "Total",
                  style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
                ),
              ),
              Container(
                child: Text(
                  "P${response['paymentType'] == "SPLIT EQUALLY" ? (double.parse(response['total']) * response['count']).toStringAsFixed(2) : response['total']}",
                  style: TextStyle(fontSize: 24.0),
                ),
              ),
            ],
          ),
        ),
        Visibility(
          visible: response['paymentType'] == "SPLIT EQUALLY",
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 3.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: Text(
                    "Distribution Total",
                    style: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  child: Text(
                    "P${response['total']}",
                    style: TextStyle(fontSize: 24.0),
                  ),
                ),
              ],
            ),
          ),
        ),

      ],
    );
  }

  Widget OrdersWidget(String count, String title, String price) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 90.0,
            child: Text(
              count,
              style: TextStyle(fontSize: fontSize),
            ),
          ),
          Container(
            constraints: BoxConstraints(maxWidth: 220.0),
            child: Text(
              title.toUpperCase(),
              style: TextStyle(fontSize: fontSize),
            ),
          ),
          Spacer(),
          Container(
            width: 90.0,
            child: Text(
              "P$price",
              style: TextStyle(fontSize: fontSize),
            ),
          )
        ],
      ),
    );
  }

  Widget DateWidget() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3.0),
      child: Container(
        width: 380.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(response['date'], style: TextStyle(fontSize: fontSize)),
            Text(response['time'], style: TextStyle(fontSize: fontSize)),
          ],
        ),
      ),
    );
  }
}
