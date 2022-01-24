import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class MenuItem extends StatelessWidget {
  Size screen;
  String title;
  String price;
  String quantity;
  String previous_price;
  bool best_seller = false;
  int purchases;
  int preparation_time;
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
      this.previous_price,
      this.best_seller=false,
      this.purchases,
      this.preparation_time,
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
          previous_price: this.previous_price,
          best_seller: this.best_seller,
          purchases: this.purchases,
          preparation_time: this.preparation_time,
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
                          style:
                              TextStyle(fontFamily: "Roboto", fontSize: 16.0),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          "Waiting Time (AVG): ${this.preparation_time} minute/s",
                          style:
                          TextStyle(fontFamily: "Roboto", fontSize: 16.0),
                        ),
                      ),
                      Visibility(
                        visible: this.previous_price != null && double.parse(this.previous_price) > double.parse(this.price),
                          child: Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          "Previous Price: ${this.previous_price}",
                          style: TextStyle(
                              fontFamily: "Roboto",
                              fontSize: 18.0,
                              decoration: TextDecoration.lineThrough),
                        ),
                      )),
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          this.price,
                          style: TextStyle(
                              fontFamily: "Roboto",
                              fontWeight: FontWeight.bold,
                              fontSize: 22.0),
                        ),
                      ),
                      Visibility(
                          visible: this.best_seller,
                          child: Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Row(children: [
                          Chip(label: Text(
                            "Best Seller",
                            style: TextStyle(
                                fontFamily: "Roboto",
                                fontWeight: FontWeight.bold,
                                fontSize: 12.0,
                                color: Colors.white),
                          ),backgroundColor: Colors.blue,
                              avatar: Icon(Icons.star, color: Colors.white,),padding: EdgeInsets.only(left: 1.0)),
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0),
                            child: Chip(label: Text(
                              this.purchases.toString() + " Purchases",
                              style: TextStyle(
                                  fontFamily: "Roboto",
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12.0,
                                  color: Colors.white),
                            ),backgroundColor: Colors.deepOrangeAccent, avatar: Icon(Icons.shopping_cart, color: Colors.white,),padding: EdgeInsets.only(left: 4.0),),
                          )
                        ],),
                      )),

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
