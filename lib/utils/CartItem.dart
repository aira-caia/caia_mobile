import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class CartItem extends StatefulWidget {
  int itemCount = 0;
  String title;
  String totalPrice;
  String image_path;
  String initPrice;
  int id;

  CartItem({this.itemCount, this.title, this.totalPrice,this.image_path, this.id, this.initPrice});

  @override
  _CartItemState createState() => _CartItemState(
      itemCount: this.itemCount,
      title: this.title,
      totalPrice: this.totalPrice, image_path: image_path, initPrice: initPrice);
}

class _CartItemState extends State<CartItem> {
  int itemCount = 0;
  String title;
  String totalPrice;
  String image_path;
  String initPrice;
  int id;
  _CartItemState({this.itemCount, this.title, this.totalPrice,this.image_path,this.id, this.initPrice});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 25.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
        CachedNetworkImage(
        imageUrl: image_path,
        imageBuilder: (context, imageProvider) => Container(
          width: 80.0,
          height: 80.0,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white, width: 5.0),
            shape: BoxShape.circle,
            image: DecorationImage(
                image: imageProvider, fit: BoxFit.cover),
          ),
        ),
        placeholder: (context, url) => CircularProgressIndicator(),
        errorWidget: (context, url, error) => Icon(Icons.error),
      ),
          SizedBox(
            width: 10.0,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Colors.white),
              ),
              SizedBox(
                height: 5.0,
              ),
              Text(
                "$itemCount pieces",
                style: TextStyle(fontSize: 14.0, color: Colors.white54),
              ),
            ],
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
                  fontFamily: "Roboto", fontSize: 14, color: Colors.white),
            ),
            TextSpan(
                text: totalPrice,
                style: TextStyle(
                    fontFamily: "Roboto",
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                    fontSize: 16)),
          ]))
        ],
      ),
    );
  }
}
