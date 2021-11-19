import 'package:flutter/material.dart';

/*
* On this file this is where we set our global variables
* accessible on entire application
* */

//Set this variable to your ip address, but dont change the 8000 (port)
final String urlDomain = "http://caia-app.herokuapp.com";
//This is a token that we got from paymaya sandbox.
final String paymentBearerToken =
    "Bearer \$2y\$10\$tmoxPjspNPUZvXDUsMg.huWw4RGsaA.aiivrKs1kOhafxaMubAAZ.";
//We created this custom token, we need this to access our API
final String appKey =
    "\$2y\$10\$tmoxPjspNPUZvXDUsMg.huWw4RGsaA.aiivrKs1kOhafxaMubAAZ."; //P@$$worD123
//Paymaya gateway api token, to access their API
final String postPaymentGatewayToken =
    "Basic c2stTk1kYTYwN0ZlWk5HUnQ5eENkc0lSaVo0THF1NkxUODk4SXRIYk40cVBTZTo=";
final String postRequestPaymayaBearer =
    "Basic cGstTU9mTkt1M0ZtSE1WSHRqeWpHN3Zocjd2RmV2UmtXeG14WUwxWXE2aUZrNTo=";

//These two functions are responsible for redirecting pages
Future<T> pushPage<T>(BuildContext context, Widget page, {arguments}) {
  return Navigator.of(context).push<T>(MaterialPageRoute(
      settings: RouteSettings(arguments: arguments),
      builder: (context) => page));
}

Future<T> pushReplacementPage<T>(BuildContext context, Widget page,
    {arguments}) {
  return Navigator.of(context).pushReplacement(MaterialPageRoute(
      settings: RouteSettings(arguments: arguments),
      builder: (context) => page));
}
/*

Future<T> pushAndRemoveUntilPage<T>(BuildContext context, Widget page,
    {arguments}) {
  return Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
          settings: RouteSettings(arguments: arguments),
          builder: (context) => page),
      ModalRoute.withName("/menu"));
}
*/

showConfirmDialog(String message, Function callBack, context) {
  // set up the AlertDialog
  AlertDialog alert = AlertDialog(
    content: Text(message),
    actions: [
      TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            callBack();
          },
          child: Text("Yes")),
      TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text("No")),
    ],
  );

  // show the dialog
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}

showAlert(String message, context, [Function callBack]) {
  // set up the AlertDialog
  AlertDialog alert = AlertDialog(
    content: Text(message),
    actions: [
      TextButton(
          onPressed: () async {
            if (callBack != null) callBack();
            Navigator.of(context).pop();
          },
          child: Text("Okay")),
    ],
  );

  // show the dialog
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}
