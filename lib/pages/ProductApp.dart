import 'package:cached_network_image/cached_network_image.dart';
import 'package:appcaia/utils/Navbar.dart';
import 'package:flutter/material.dart';

/*This file is loaded whenever we click a menu
* it shows the ingredients, price and add/remove to cart of menu
* */
class ProductApp extends StatefulWidget {
  @override
  _ProductAppState createState() => _ProductAppState();
}

class _ProductAppState extends State<ProductApp> {
  Map payload;
  List orders = [];
  List<Map> itemOrders = [];

  @override
  Widget build(BuildContext context) {
    payload = ModalRoute.of(context).settings.arguments;
    orders = payload['orders'];
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context);
        payload['toggleFocus']();
        return false;
      },
      child: Scaffold(
        body: SafeArea(
            child: body(context)),
      ),
    );
  }

  void handleOrders(List newOrders) {
    setState(() {
      this.orders = newOrders;
    });
  }

  Widget body(BuildContext context) {
    Size screen = MediaQuery.of(context).size;
    return Stack(
      // fit: StackFit.expand,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Navbar(
              title: payload['menu']['title'],
              backIcon: true,
              handler: payload['toggleFocus'],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                SizedBox(
                  height: 20,
                ),
                ClipRRect(
                  child: Container(
                      constraints: screen.width >= 600
                          ? BoxConstraints(
                        maxHeight: 480,
                      )
                          : null,
                      alignment: Alignment.topCenter,
                      child: CachedNetworkImage(
                        imageUrl: this.payload['menu']['image_path'],
                        placeholder: (context, url) => CircularProgressIndicator(),
                        errorWidget: (context, url, error) => Icon(Icons.error),
                        fit: BoxFit.cover,
                        alignment: Alignment.center,
                      )),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                SizedBox(
                  height: 10.0,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      payload['menu']['title'],
                      style: TextStyle(
                          fontFamily: "Roboto",
                          fontWeight: FontWeight.bold,
                          fontSize: 18.0),
                    ),
                    Text(
                      "1 piece",
                      style: TextStyle(
                          fontFamily: "Roboto",
                          fontSize: 12.0,
                          fontWeight: FontWeight.w300),
                    ),
                  ],
                ),
                SizedBox(
                  height: 30.0,
                ),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        payload['orderHandler'](payload['menu'], false);
                        this.updateCount();
                      },
                      child: Container(
                        child: Icon(
                          Icons.remove,
                          color: Colors.white,
                        ),
                        height: 38,
                        width: 38,
                        decoration: BoxDecoration(
                            color: Color(0xffFF5C5C),
                            borderRadius: BorderRadius.all(Radius.circular(8))),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Text(
                        orders
                            .where(
                                (element) => element['id'] == payload['menu']['id'])
                            .length
                            .toString(),
                        // length.toString()
                        style: TextStyle(
                            fontFamily: "Roboto", fontWeight: FontWeight.w500),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        payload['orderHandler'](payload['menu'], true);
                        this.updateCount();
                      },
                      child: Container(
                        child: Icon(
                          Icons.add,
                          color: Colors.white,
                        ),
                        height: 38,
                        width: 38,
                        decoration: BoxDecoration(
                            color: Color(0xffCCDB25),
                            borderRadius: BorderRadius.all(Radius.circular(8))),
                      ),
                    ),
                    Spacer(),
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
                              text: payload['menu']['price'],
                              style: TextStyle(
                                  fontFamily: "Roboto",
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                  fontSize: 18)),
                        ]))
                  ],
                ),
                SizedBox(
                  height: 40.0,
                ),
                // SizedBox.expand(child: Text("Hello"),)
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      payload['handleRemoveToCart'](payload['menu']['id']);
                      this.updateCount();
                    },
                    child: const Text(
                      "Remove to cart",
                      style: TextStyle(
                          fontSize: 16.0,
                          fontFamily: "Roboto",
                          fontWeight: FontWeight.w500),
                    ),
                    style: ButtonStyle(
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0))),
                      padding: MaterialStateProperty.all(
                          EdgeInsets.symmetric(vertical: 20, horizontal: 40)),
                      backgroundColor: MaterialStateProperty.all(Color(0xffA175FE)),
                      foregroundColor: MaterialStateProperty.all(Colors.white),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 30.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "INGREDIENTS",
                        style:
                        TextStyle(fontWeight: FontWeight.w300, fontSize: 10.0),
                      ),
                      Text(
                        payload['menu']['ingredients'] ?? "Not Available",
                        style: TextStyle(fontSize: 12.0),
                      ),
                    ],
                  ),
                )
              ],),
            )
          ],
        ),
        // ItemsBar(),
      ],
    );
  }

  void updateCount() {
    List myOrders = payload['orders'];
    myOrders.where((order) => order['id'] == payload['menu']['id']);
    handleOrders(myOrders);
  }
}
