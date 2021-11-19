import 'package:cached_network_image/cached_network_image.dart';
import 'package:appcaia/login/LoginApp.dart';
import 'package:appcaia/pages/MenuApp.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_braintree/flutter_braintree.dart';
import "package:flutter_svg/flutter_svg.dart";
import 'package:shared_preferences/shared_preferences.dart';


/*
* This is the Hero section of our application
* What we see on first page of our app
* */

class WelcomeApp extends StatelessWidget {

  void lookUpSharedPrefs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getString("table_name") == null) {
      await prefs.setString('table_name', "TABLE 1");
    }

    if (prefs.getString("employee_name") == null) {
      await prefs.setString('employee_name', "EMPLOYEE 1");
    }
  }

  @override
  Widget build(BuildContext context) {
    lookUpSharedPrefs();

    return Scaffold(
      body: SafeArea(child: body(context)),
    );
  }


  Widget body(BuildContext context) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 86,
                ),
                Text(
                  "Make your order now...",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontFamily: "Roboto",
                      fontSize: 24.0),
                ),
                SizedBox(
                  height: 25,
                ),
                Text(
                  "Deliciousness jumping into the mouth!",
                  style: TextStyle(
                      fontSize: 14.0,
                      fontFamily: "Roboto",
                      fontWeight: FontWeight.w300),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 86,
          ),
          Center(child: SvgPicture.asset("assets/img/welcome_img.svg", width: 260)),
          SizedBox(
            height: 86,
          ),
          Center(
            child: TextButton(
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                        builder: (context) => MenuApp()),
                    ModalRoute.withName("/menu"));
              },
              child: Text("Order now!"),
              style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Color(0xFF3F3D56)),
                  foregroundColor: MaterialStateProperty.all(Color(0xFFFFFFFF)),
                  textStyle: MaterialStateProperty.all<TextStyle>(TextStyle(
                      fontSize: 12.0,
                      fontFamily: "Roboto",
                      fontWeight: FontWeight.bold)),
                  padding: MaterialStateProperty.all(
                      EdgeInsets.symmetric(vertical: 20.0, horizontal: 100)),
                  shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(55.0)))),
            ),
          ),
          SizedBox(
            height: 14.0,
          ),
          Center(
            child: GestureDetector(
              onTap: (){
                Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                        builder: (context) => LoginApp()),
                    ModalRoute.withName("/login"));
              },
              child: RichText(
                  text: TextSpan(
                      text: "SIGN IN",
                      style: TextStyle(
                          color: Color(0xff00B0FF),
                          fontSize: 18.0,
                          fontFamily: "Roboto",
                          letterSpacing: 2.0,
                          fontWeight: FontWeight.w300))),
            ),
          ),
        ],
      ),
    );
  }
}
