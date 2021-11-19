import 'package:appcaia/utils/CartItem.dart';
import 'package:flutter/material.dart';

class Cart extends StatefulWidget {
  bool isOpen;
  Function setOpen;

  List<Map> orders = [];

  Cart({this.isOpen, this.setOpen, this.orders});

  @override
  _CartState createState() =>
      _CartState(isOpen: isOpen, setOpen: setOpen, orders: orders);
}

class _CartState extends State<Cart> {
  bool isOpen;
  Function setOpen;
  List<Map> orders;
  List<CartItem> cartOrders = [];
  double totalPayment = 0;

  _CartState({this.isOpen, this.setOpen, this.orders});

  @override
  void initState() {
    super.initState();
    List union = [];
    List distinct = [];
    orders.forEach((element) {
      if (!union.contains(element['id'])) {
        union.add(element['id']);
        distinct.add(element);
      }
    });
    distinct.forEach((element) {
      double total = double.parse(element['price']) *
          orders.where((i) => i['id'] == element['id']).length;
      totalPayment += total;
      element['total'] = total.toStringAsFixed(2);
      cartOrders.add(CartItem(
        itemCount: orders.where((i) => i['id'] == element['id']).length,
        title: element['title'],
        totalPrice: total.toStringAsFixed(2),
        image_path: element['image_path'],
        initPrice: element['price'],
        id: element['id'],
      ));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
            onPanDown: (context) {
              setOpen();
            },
            child: Container(
              height: 10,
              color: Colors.transparent,
              alignment: Alignment.center,
              child: Container(
                height: 4,
                width: 20,
                color: Colors.grey.withOpacity(.5),
              ),
            )),
        SizedBox(
          height: 15.0,
        ),
        RichText(
            text: TextSpan(
                text: "Cart",
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 28.0),
                children: [
              WidgetSpan(child: SizedBox(width: 8.0)),
              WidgetSpan(
                  child: Image.asset(
                'assets/img/food_cart.png',
                height: 30.0,
                width: 30.0,
              ))
            ])),
        Container(
          height: 380,
          child: SingleChildScrollView(
            child: Column(
              children: cartOrders,
            ),
          ),
        ),
        SizedBox(
          height: 15.0,
        ),
        Divider(
          color: Colors.white,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Total",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 24,
                    color: Colors.white)),
            RichText(
                text: TextSpan(children: [
              WidgetSpan(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Text(
                    "P",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                style: TextStyle(
                    fontFamily: "Roboto", fontSize: 18, color: Colors.white),
              ),
              TextSpan(
                  text: totalPayment.toStringAsFixed(2),
                  style: TextStyle(
                      fontFamily: "Roboto",
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 28)),
            ]))
          ],
        ),
        SizedBox(
          height: 8.0,
        ),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () {
              int itemCount = 0;
              cartOrders.forEach((element) {
                itemCount += element.itemCount;
              });
              Navigator.pushNamed(context, "/purchase",
                  arguments: {"itemCount": itemCount, "price" : totalPayment, "orders" : cartOrders});
            },
            child: const Text(
              "Checkout",
              style: TextStyle(
                  fontSize: 20.0,
                  fontFamily: "Roboto",
                  fontWeight: FontWeight.w400),
            ),
            style: ButtonStyle(
              shape: MaterialStateProperty.all(RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0))),
              padding: MaterialStateProperty.all(
                  EdgeInsets.symmetric(vertical: 20, horizontal: 40)),
              backgroundColor: MaterialStateProperty.all(Color(0xffFF5C5C)),
              foregroundColor: MaterialStateProperty.all(Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}
