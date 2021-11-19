import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class MenuItem extends StatelessWidget {
  Size screen;
  String title;
  String price;
  String quantity;
  String image_path;
  String ingredients;
  int id;
  Map handler;
  List orders = [];

  MenuItem(
      {@required this.screen,
      @required this.title,
      @required this.image_path,
      this.price,
      this.id,
      this.quantity,
      this.ingredients,
      this.orders,
      this.handler});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        this.handler['toggleFocus']();
        this.handler['menuHandler']({
          screen: this.screen,
          image_path: this.image_path,
          title: this.title,
          price: this.price,
          ingredients: this.ingredients,
          handler: this.handler,
          id: id
        });
        Navigator.pushNamed(context, '/product', arguments: {
          "orderHandler": this.handler['orderHandler'],
          "menu": {
            "screen": this.screen,
            "image_path": this.image_path,
            "title": this.title,
            "ingredients": this.ingredients,
            "price": this.price,
            "id": id
          },
          "toggleFocus": this.handler['toggleFocus'],
          "handleRemoveToCart": this.handler['handleRemoveToCart'],
          "orders": this.orders
        });
      },
      hoverColor: Colors.transparent,
      child: Container(
        clipBehavior: Clip.hardEdge,
        constraints: BoxConstraints(maxWidth: 300, minWidth: 200),
        width: screen.width * .42,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(25)),
        child: Card(
            child: Container(
          child: Container(
            child: Column(
              children: [
                Container(
                  constraints: BoxConstraints(maxHeight: 220, minHeight: 80),
                  child: CachedNetworkImage(
                    imageUrl: this.image_path,
                    httpHeaders: {'Keep-Alive': 'timeout=50000'},
                    placeholder: (context, url) => CircularProgressIndicator(),
                    errorWidget: (context, url, error) => Icon(Icons.error),
                    fit: BoxFit.cover,
                    alignment: Alignment.center,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 15.0, horizontal: 10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            title,
                            style: TextStyle(
                                fontFamily: "Roboto",
                                fontWeight: FontWeight.w600,
                                fontSize: 18.0),
                          ),
                          Text(
                            "1 pc",
                            style:
                                TextStyle(fontFamily: "Roboto", fontSize: 14.0),
                          )
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          "Stocks: ${this.quantity}",
                          style: TextStyle(
                              fontFamily: "Roboto",
                              fontSize: 16.0),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          this.price,
                          style: TextStyle(
                              fontFamily: "Roboto",
                              fontWeight: FontWeight.bold,
                              fontSize: 22.0),
                        ),
                      )
                    ],
                  ),
                )
              ],
            ),
          ),
        )),
      ),
    );
  }
}
