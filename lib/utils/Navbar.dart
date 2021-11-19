import 'package:appcaia/pages/WelcomeApp.dart';
import 'package:flutter/material.dart';
import 'package:sweetalert/sweetalert.dart';

import '../main.dart';

class Navbar extends StatefulWidget {
  String title;
  bool backIcon = true;
  Function handler,exitHandler;
  Widget settings;

  Navbar({this.title, this.backIcon, this.handler, this.settings,this.exitHandler});

  @override
  _NavbarState createState() =>
      _NavbarState(title: title, backIcon: backIcon, handler: handler, settings: settings, exitHandler: exitHandler);
}

class _NavbarState extends State<Navbar> {
  String title;
  bool backIcon;
  Function handler,exitHandler;
  Widget settings;

  _NavbarState({this.title, this.backIcon, this.handler,this.settings,this.exitHandler});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[100],
      height: 55.0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Visibility(
            visible: settings != null,
            child: settings ?? Scaffold(),
          ),
          Visibility(
            visible: backIcon,
            child: GestureDetector(
              onTap: () {
                if (this.handler != null) {
                  this.handler();
                }
                Navigator.pop(context);
              },
              child: RichText(
                  text: TextSpan(children: [
                WidgetSpan(
                    child: Icon(
                  Icons.chevron_left,
                  size: 32,
                ))
              ])),
            ),
          ),
          Spacer(),
          Text(
            this.title,
            style: TextStyle(
                fontFamily: "Roboto",
                fontSize: 24.0,
                fontWeight: FontWeight.w300),
          ),
          Spacer(),
          IconButton(
              splashRadius: 1.0,
              icon: Icon(
                Icons.logout,
                size: 32,
              ),
              onPressed: () {
                SweetAlert.show(context,
                    title: "Exit",
                    subtitle: "Are you sure you want to exit?",
                    style: SweetAlertStyle.confirm,
                    showCancelButton: true, onPress: (bool isConfirm) {
                      if (isConfirm) {
                        if(exitHandler != null) exitHandler();

                        new Future.delayed(new Duration(seconds: 1),(){
                          Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(builder: (context) => BaseApp()),
                              ModalRoute.withName("/"));
                        });
                      }
                      return true;
                    });
              })
        ],
      ),
    );
  }
}
