import 'dart:async';
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:appcaia/global.dart';
import 'package:appcaia/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CustomerQueue extends StatefulWidget {
  const CustomerQueue({Key key}) : super(key: key);

  @override
  _CustomerQueueState createState() => _CustomerQueueState();
}

/*Customer queues*/
class _CustomerQueueState extends State<CustomerQueue> {
  Map payload;
  List orders = [];
  bool isPop = false;
  var is_served;
  bool initiated = false;
  String serveOption = "ALL ORDERS";
  String tableName;

  void setupSharedPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    tableName = prefs.getString("table_name");
  }

  @override
  void initState() {
    setupSharedPrefs();
    super.initState();
    Future.delayed(Duration.zero, () {
      payload = ModalRoute.of(context).settings.arguments;
      checkPayment();
    });
  }

  /*We are using a timer every 4 seconds it will check for new records
  * on our database, if there is, then it will update the Queue.
  * */
  void checkPayment() {
    Timer.periodic(new Duration(seconds: 3), (timer) {
      if (isPop) return timer.cancel();
      fetchPayments();
    });
  }

  /*Method for fetching queues using our API*/
  void fetchPayments() async {
    Uri url = Uri.parse("$urlDomain/api/orders?is_served=${is_served}");
    Response request = await get(url, headers: {
      "Accept": "application/json",
      "Content-Type": "application/json",
      "Authorization": "Bearer $appKey",
    });
    try {
      Map body = jsonDecode(request.body);
      if (body['data'] == null) return;
      setState(() {
        this.orders = body['data'];
        if (!initiated) initiated = true;
      });
    } catch (err) {
      print("timed out fetching orders");
    }
  }

  /*Function that we created that returns a list of Widget (Order Widget)*/
  List<Widget> queue(BuildContext context) {
    if (orders.isEmpty) {
      return [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 100.0),
          child: Text(
            "NO RECORDS FOUND",
            style: TextStyle(fontSize: 44.0, fontWeight: FontWeight.w300, color: Colors.red),
          ),
        )
      ].toList();
    }
    return orders.map((order) {
      List<Widget> cardsOfOrders = [];
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          color: order['table_name'].toString().toLowerCase() ==
                  tableName.toLowerCase()
              ? Colors.green[900]
              : Color(0xff1D005B),
          child: Padding(
            padding: const EdgeInsets.all(18.0),
            child: Column(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      child: Row(
                        children: [
                          Text(
                            "Order #${order['id']}",
                            style: TextStyle(
                                fontWeight: FontWeight.w300,
                                color: Colors.white,
                                fontSize: 24.0),
                          ),
                          Spacer(),
                          OutlinedButton(
                            onPressed: null,
                            child: Text(
                              order['is_served'] == true ? "Served" : "Processing",
                              style: TextStyle(
                                  fontSize: 16.0,
                                  fontFamily: "Roboto",
                                  fontWeight: FontWeight.w500),
                            ),
                            style: ButtonStyle(
                              shape: MaterialStateProperty.all(
                                  RoundedRectangleBorder(
                                      borderRadius:
                                      BorderRadius.circular(30.0))),
                              padding: MaterialStateProperty.all(
                                  EdgeInsets.symmetric(horizontal: 20)),
                              backgroundColor: order['is_served'] == true
                                  ? MaterialStateProperty.all(Colors.green)
                                  : MaterialStateProperty.all(Colors.red),
                              foregroundColor:
                              MaterialStateProperty.all(Colors.white),
                            ),
                          )
                        ],
                      ),
                    ),
                    for (var item in order['orders'])
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Card(
                          color: Colors.white,
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                CachedNetworkImage(
                                  imageUrl: item['image'],
                                  imageBuilder: (context, imageProvider) =>
                                      Container(
                                    width: 100.0,
                                    height: 100.0,
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          color: Color(0xff1D005B), width: 8.0),
                                      shape: BoxShape.circle,
                                      image: DecorationImage(
                                          image: imageProvider,
                                          fit: BoxFit.cover),
                                    ),
                                  ),
                                  placeholder: (context, url) =>
                                      CircularProgressIndicator(),
                                  errorWidget: (context, url, error) =>
                                      Icon(Icons.error),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(left: 12.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item['title'],
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 22.0),
                                      ),
                                      Text(
                                        item['count'],
                                        style: TextStyle(
                                            fontWeight: FontWeight.w300,
                                            fontSize: 18.0),
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
                                        padding:
                                            const EdgeInsets.only(bottom: 10.0),
                                        child: Text("P"),
                                      ),
                                      style: TextStyle(
                                        fontFamily: "Roboto",
                                        fontSize: 14,
                                      ),
                                    ),
                                    TextSpan(
                                        text: item['amount'],
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
                      ),
                    Divider(color: Colors.white),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      child: Row(
                        children: [
                          Text(
                            "Total",
                            style: TextStyle(
                                fontWeight: FontWeight.w300,
                                color: Colors.white,
                                fontSize: 24.0),
                          ),
                          Spacer(),
                          RichText(
                              text: TextSpan(children: [
                            WidgetSpan(
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 10.0),
                                child: Text(
                                  "P",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                              style: TextStyle(
                                fontFamily: "Roboto",
                                fontSize: 14,
                              ),
                            ),
                            TextSpan(
                                text: order['total'],
                                style: TextStyle(
                                    fontFamily: "Roboto",
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    fontSize: 24)),
                          ]))
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 20.0),
                      child: RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(children: [
                            WidgetSpan(
                                child: Padding(
                              padding: const EdgeInsets.only(right: 10.0),
                              child: Icon(
                                Icons.restaurant,
                                color: Colors.white.withOpacity(.8),
                                size: 22,
                              ),
                            )),
                            TextSpan(
                                text: /*"Date paid: April, 15, 2000 - 8:30 pm"*/ "${order['table_name']}",
                                style: TextStyle(
                                    fontFamily: "Roboto",
                                    color: Colors.white.withOpacity(.8),
                                    fontSize: 22)),
                          ])),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 20.0),
                      child: RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(children: [
                            WidgetSpan(
                                child: Padding(
                              padding: const EdgeInsets.only(right: 10.0),
                              child: Icon(
                                Icons.date_range,
                                color: Colors.white.withOpacity(.8),
                                size: 22,
                              ),
                            )),
                            TextSpan(
                                text: /*"Date paid: April, 15, 2000 - 8:30 pm"*/ order[
                                    'paid_at'],
                                style: TextStyle(
                                    fontFamily: "Roboto",
                                    color: Colors.white.withOpacity(.8),
                                    fontSize: 22)),
                          ])),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 20.0),
                      child: RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(children: [
                            WidgetSpan(
                                child: Padding(
                              padding: const EdgeInsets.only(right: 10.0),
                              child: Icon(
                                Icons.access_time_sharp,
                                color: Colors.white.withOpacity(.8),
                                size: 22,
                              ),
                            )),
                            TextSpan(
                                text: /*"Date paid: April, 15, 2000 - 8:30 pm"*/ order[
                                    'time_passed'],
                                style: TextStyle(
                                    fontFamily: "Roboto",
                                    color: Colors.white.withOpacity(.8),
                                    fontSize: 22)),
                          ])),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 20.0),
                      child: RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(children: [
                            WidgetSpan(
                                child: Padding(
                              padding: const EdgeInsets.only(right: 10.0),
                              child: Icon(
                                Icons.receipt_long,
                                color: Colors.white.withOpacity(.8),
                                size: 22,
                              ),
                            )),
                            TextSpan(
                                text: /*"Date paid: April, 15, 2000 - 8:30 pm"*/ "(Ref. #) ${order['reference']}",
                                style: TextStyle(
                                    fontFamily: "Roboto",
                                    color: Colors.white.withOpacity(.8),
                                    fontSize: 22)),
                          ])),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 20.0),
                      child: RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(children: [
                            WidgetSpan(
                                child: Padding(
                              padding: const EdgeInsets.only(right: 10.0),
                              child: Icon(
                                Icons.receipt,
                                color: Colors.white.withOpacity(.8),
                                size: 22,
                              ),
                            )),
                            TextSpan(
                                text: /*"Date paid: April, 15, 2000 - 8:30 pm"*/ "(Order Code) ${order['order_code']}",
                                style: TextStyle(
                                    fontFamily: "Roboto",
                                    color: Colors.white.withOpacity(.8),
                                    fontSize: 22)),
                          ])),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    }).toList();
  }

  showConfirmDialog(BuildContext context) {
    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      content: Text("Are you sure you want to sign out?"),
      actions: [
        TextButton(
            onPressed: () {
              this.isPop = true;
              Navigator.of(context).pop();
              Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => BaseApp()),
                  ModalRoute.withName("/"));
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
      useRootNavigator: false,
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Size screen = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: () async {
        isPop = true;
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text("Orders"),
        ),
        body: SafeArea(
            child: orders.length == 0 && !initiated
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
                            visible: orders.isEmpty,
                            child: Padding(
                              padding: const EdgeInsets.only(top: 45.0),
                              child: Text(
                                "Waiting for orders to be loaded.",
                                style: TextStyle(
                                    fontSize: 25.0,
                                    fontWeight: FontWeight.w300),
                              ),
                            ))
                      ],
                    ),
                  )
                : Column(
                    children: [
                      Container(
                        height: screen.height * .9,
                        child: SingleChildScrollView(
                          scrollDirection: Axis.vertical,
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 16.0),
                                child: Text(
                                  serveOption,
                                  style: TextStyle(fontSize: 28.0),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0, vertical: 8.0),
                                child: Row(
                                  children: [
                                    TextButton(
                                      onPressed: () {
                                        is_served = null;
                                        fetchPayments();
                                        setState(() {
                                          serveOption = "ALL ORDERS";
                                        });
                                      },
                                      child: Text("All orders"),
                                      style: ButtonStyle(
                                          textStyle: MaterialStateProperty.all(
                                              TextStyle(fontSize: 18.0)),
                                          foregroundColor:
                                              MaterialStateProperty.all(
                                                  Colors.white),
                                          backgroundColor:
                                              MaterialStateProperty.all(
                                                  Colors.deepPurple[300])),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8.0),
                                      child: TextButton(
                                        onPressed: () {
                                          is_served = 0;
                                          fetchPayments();
                                          setState(() {
                                            serveOption = "NOT SERVED ONLY";
                                          });
                                        },
                                        child: Text("Not served"),
                                        style: ButtonStyle(
                                            textStyle:
                                                MaterialStateProperty.all(
                                                    TextStyle(fontSize: 18.0)),
                                            foregroundColor:
                                                MaterialStateProperty.all(
                                                    Colors.white),
                                            backgroundColor:
                                                MaterialStateProperty.all(
                                                    Colors.deepPurple[300])),
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        is_served = 1;
                                        fetchPayments();
                                        setState(() {
                                          serveOption = "SERVED ONLY";
                                        });
                                      },
                                      child: Text("Served"),
                                      style: ButtonStyle(
                                          textStyle: MaterialStateProperty.all(
                                              TextStyle(fontSize: 18.0)),
                                          foregroundColor:
                                              MaterialStateProperty.all(
                                                  Colors.white),
                                          backgroundColor:
                                              MaterialStateProperty.all(
                                                  Colors.deepPurple[300])),
                                    ),
                                  ],
                                ),
                              ),
                              Column(children: queue(context)),
                            ],
                          ),
                        ),
                      )
                    ],
                  )),
      ),
    );
  }
}
