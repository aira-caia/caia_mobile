import 'package:appcaia/utils/Cart.dart';
import 'package:flutter/material.dart';

class ItemsBar extends StatefulWidget {
  List<Map> orders;
  Function queueToggler;
  ItemsBar({this.orders, this.queueToggler});

  @override
  _ItemsBarState createState() =>
      _ItemsBarState(orders: orders,queueToggler: queueToggler);
}

class _ItemsBarState extends State<ItemsBar> {
  bool isCheckout = false;
  List<Map> orders;
  Function queueToggler;

  _ItemsBarState({this.orders,this.queueToggler});

  @override
  Widget build(BuildContext context) {
    return Positioned(
        bottom: 0,
        left: 0,
        right: 0,
        child: Container(
          height: isCheckout ? 600.0 : 50.0,
          decoration: BoxDecoration(
              color: Color(0xff1D005B),
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16), topRight: Radius.circular(18))),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 30),
            child: isCheckout
                ? Cart(
                    isOpen: isCheckout,
                    orders: orders,
                    setOpen: () {
                      setState(() {
                        queueToggler();
                        isCheckout = !isCheckout;
                      });
                    },
                  )
                : Visibility(
                    visible: !isCheckout,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        RichText(
                          text: TextSpan(
                            children: [
                              WidgetSpan(
                                child: Icon(
                                  Icons.shopping_cart,
                                  size: 18,
                                  color: Colors.white,
                                ),
                              ),
                              WidgetSpan(child: SizedBox(width: 10.0)),
                              TextSpan(
                                  text: "${orders.length} Items",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontFamily: "Roboto",
                                      fontSize: 18.0)),
                            ],
                          ),
                        ),
                        Visibility(
                            visible: orders.length > 0,
                            child: OutlinedButton(
                          onPressed: () {
                            setState(() {
                              isCheckout = !isCheckout;
                              queueToggler();
                            });
                          },
                          child: const Text("View orders"),
                          style: ButtonStyle(
                            shape: MaterialStateProperty.all(
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30.0))),
                            padding: MaterialStateProperty.all(
                                EdgeInsets.symmetric(horizontal: 40)),
                            side: MaterialStateProperty.all(
                                BorderSide(color: Color(0xffB2ED34))),
                            foregroundColor:
                            MaterialStateProperty.all(Colors.white),
                            textStyle: MaterialStateProperty.all(
                                TextStyle(fontSize: 12)),
                          ),
                        ))
                      ],
                    ),
                  ),
          ),
        ));
  }
}
