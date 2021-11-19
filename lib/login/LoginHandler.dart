import 'dart:convert';

import 'package:appcaia/global.dart';
import 'package:http/http.dart';

/*This function is implemented on our login screen file
* this is responsible for every login attempts that we made
* */
loginAttempt(String username, String password) async {
  Uri uri = Uri.parse("$urlDomain/api/login");
  Response request =
      await post(uri, body: {"username": username, "password": password});
  Map body = jsonDecode(request.body);
  if (request.statusCode == 200) {
    return body;
  } else {
    return body['message'];
  }
}
