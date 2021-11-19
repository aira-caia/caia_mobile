import 'dart:convert';

import 'package:appcaia/global.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CategoryNav extends StatefulWidget {
  int selected;
  Function handler;

  CategoryNav({@required this.selected, @required this.handler});

  @override
  _CategoryNavState createState() =>
      _CategoryNavState(selected: selected, handler: handler);
}

class _CategoryNavState extends State<CategoryNav> {
  int selected;
  Function handler;


  _CategoryNavState({this.selected, this.handler});

  List categories = [];

  Future<void> fetchData() async {
    Uri url = Uri.parse('$urlDomain/api/categories');
    http.Response response = await http.get(url);
    Map data = jsonDecode(response.body);

    setState(() {
      categories.add({"title": "All", "value": 0});
      categories.addAll(data['data']);
    });
  }

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  @override
  Widget build(BuildContext context) {
    Size screen = MediaQuery.of(context).size;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: categories
              .map(
                (category) => category['value'] != selected
                    ? Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: InkWell(
                          child: Text(
                            category['title'],
                            style: TextStyle(
                                color: Colors.white,
                                fontFamily: "Roboto",
                                fontSize: 18,
                                fontWeight: FontWeight.w300),
                          ),
                          onTap: () {
                            setState(() {
                              selected = category['value'];
                            });
                            handler(selected);
                          },
                        ),
                      )
                    : Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: InkWell(
                          child: Text(
                            category['title'],
                            style: TextStyle(
                                color: Colors.white,
                                fontFamily: "Roboto",
                                fontSize: 22,
                                fontWeight: FontWeight.bold),
                          ),
                          onTap: () {
                            setState(() {
                              selected = 0;
                            });
                          },
                        ),
                      ),
              )
              .toList()),
    );
  }
}
