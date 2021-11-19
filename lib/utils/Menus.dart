import 'dart:convert';

import 'package:appcaia/utils/MenuItem.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Menus {
  List<Padding> menus = [];
  Future<void> getMenu(Size screen) async {
    Uri uri = Uri.parse("http://127.0.0.1:8000/api/menu");
    http.Response response = await http.get(uri);
    Map data = jsonDecode(response.body);
    print(data);

    menus = [
      Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: Wrap(
          alignment: WrapAlignment.spaceBetween,
          children: [
            MenuItem(screen: screen),
            MenuItem(screen: screen),
            MenuItem(screen: screen),
            MenuItem(screen: screen),
            MenuItem(screen: screen),
            MenuItem(screen: screen),
            MenuItem(screen: screen),
          ],
        ),
      ),
    ];
  }
}