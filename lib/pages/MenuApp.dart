import 'dart:convert';
import 'package:appcaia/global.dart';
import 'package:appcaia/pages/CustomerQueue.dart';
import 'package:appcaia/utils/CategoryNav.dart';
import 'package:appcaia/utils/ItemsBar.dart';
import 'package:appcaia/utils/MenuItem.dart';
import 'package:appcaia/utils/Navbar.dart';
import 'package:appcaia/utils/SearchField.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http/http.dart' as http;
import 'package:sweetalert/sweetalert.dart';
import '../main.dart';

/*
* This file is also loaded in our Menu module
* It has its own methods for searching menus, handling orders, etc.
*
* */
class MenuApp extends StatefulWidget {
  @override
  _MenuAppState createState() => _MenuAppState();
}

// php artisan serve --host 0.0.0.0 --port 8000 run laravel on your IP
class _MenuAppState extends State<MenuApp> {
  List<Padding> menus = [];
  int selectedCategory = 0;

  List<Map> orders = [];
  Map selectedMenuItem = {};

  bool isFocus = true;
  bool queueSwitch = true;

  Size screen;
  String search = "";

  bool hasData = false;

  void handleMenuItem(Map item) {
    this.selectedMenuItem = item;
  }

  void handleSearch(value) {
    setState(() {
      search = value;
      getMenu();
    });
  }

  void handleOrder(Map item, bool isAdd) {
    if (isAdd) {
      setState(() {
        orders.add(item);
      });
    } else {
      if (orders.where((element) => element['id'] == item['id']).isNotEmpty) {
        Map removeItem =
            orders.lastWhere((element) => element['id'] == item['id']);
        setState(() {
          orders.remove(removeItem);
        });
      }
    }
  }

  void handleRemoveToCart(int id) {
    setState(() {
      orders.removeWhere((element) => element['id'] == id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        SweetAlert.show(context,
            title: "Exit",
            subtitle: "Are you sure you want to exit Menu?",
            style: SweetAlertStyle.confirm,
            showCancelButton: true, onPress: (bool isConfirm) {
              if (isConfirm) {
                new Future.delayed(new Duration(seconds: 1),(){
                  Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => BaseApp()),
                      ModalRoute.withName("/"));
                });
              }
              return true;
            });
        return false;
      },
      child: Scaffold(
        floatingActionButton: Container(
      padding: EdgeInsets.symmetric(vertical: 65.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Visibility(
              visible: !hasData,
              child: FloatingActionButton(
                onPressed: (){
                  Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => BaseApp()),
                      ModalRoute.withName("/"));
                },
                child: Icon(Icons.keyboard_return_rounded),
              ),
            ),
          ],
        ),
        ),
        resizeToAvoidBottomInset: false,
        body: SafeArea(child: body(context)),
      ),
    );
  }

  Future<void> getMenu() async {
    try {
      Uri uri =
          Uri.parse("$urlDomain/api/menu?query=$selectedCategory&s=$search");
      http.Response response = await http.get(uri);
      print(response.body);
      Map data = jsonDecode(response.body);
      List list = data['data'];
      if(list.length > 0) {
        hasData = true;
      }
      List<MenuItem> menuItems = list
          .map((e) => MenuItem(
                screen: screen,
                orders: this.orders,
                title: e['title'],
                price: e['price'],
                quantity: e['quantity'].toString(),
                ingredients: e['ingredients'],
                handler: {
                  "menuHandler": handleMenuItem,
                  "orderHandler": handleOrder,
                  "handleRemoveToCart": handleRemoveToCart,
                  "toggleFocus": toggleIsFocus
                },
                id: e['id'],
                image_path: e[
                    'image_path'] /*"https://images.pexels.com/photos/825661/pexels-photo-825661.jpeg?auto=compress&cs=tinysrgb&dpr=2&h=750&w=1260"*/,
              ))
          .toList();
      setState(() {
        menus = [
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Wrap(
              alignment: WrapAlignment.spaceBetween,
              children: menuItems,
            ),
          ),
        ];
      });

    } catch (exception) {
      print("Error Found! $exception");
    }
  }

  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      screen = MediaQuery.of(context).size;
      getMenu();
    });
  }

  void handleCategory(int val) {
    setState(() {
      selectedCategory = val;
    });
    getMenu();
  }

  void toggleIsFocus() {
    setState(() {
      isFocus = !isFocus;
    });
  }

  Widget body(BuildContext context) {

    // return Text('Hello');

    screen = MediaQuery.of(context).size;
    return !hasData
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
            visible: !hasData,
              child: Padding(
                padding: const EdgeInsets.only(top: 45.0),
                child: Text(
                  "Waiting for menus to be loaded.",
                  style: TextStyle(fontSize: 25.0, fontWeight: FontWeight.w300),
                ),
              ))
        ],
      ),
    )
        : Stack(
            children: [
              Column(
                children: [
                  Navbar(
                    title: "Menu",
                    backIcon: false,
                    settings: IconButton(
                      splashRadius: 1,
                      icon: Icon(Icons.category_outlined, color: Colors.red,),
                      onPressed: (){
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => CustomerQueue()),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: Column(
                      children: [
                        SizedBox(
                          height: 20,
                        ),
                        SearchField(
                          handler: handleSearch,
                        ),
                        Container(
                          height: screen.height * .75,
                          width: screen.width,
                          margin: EdgeInsets.only(top: 24.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(16)),
                            color: Color(0xff7A77F2),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CategoryNav(
                                  selected: selectedCategory,
                                  handler: handleCategory,
                                ),
                                Container(
                                    constraints: BoxConstraints(
                                        maxHeight: screen.height * .65),
                                    padding: EdgeInsets.only(top: 16.0),
                                    child: ListView(
                                      children: menus,
                                    ))
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
              Visibility(
                visible: isFocus,
                child: ItemsBar(
                  orders: orders,
                  queueToggler: toggleQueues,
                ),
              ),
            ],
          );
  }

  void toggleQueues(){
    setState(() {
      queueSwitch = !queueSwitch;
    });
  }
}
