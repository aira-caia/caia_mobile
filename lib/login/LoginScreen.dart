import 'package:appcaia/dashboard/AdminApp.dart';
import 'package:appcaia/login/LoginHandler.dart';
import 'package:flutter/material.dart';
import 'package:flutter_login/flutter_login.dart';


/*This is the child component of LoginApp
* it displays the forms that we see on our login page,
* such as the textboxes and buttons.
* */
class LoginScreen extends StatelessWidget {
  Duration get loginTime => Duration(milliseconds: 500);

  String token;

  Future<String> _authUser(LoginData data) {
    return Future.delayed(loginTime).then((_) async {
      Future request = loginAttempt(data.name, data.password);
      dynamic response = await request.then((value) => value);
      if(response is String){
        return response;
      }
      token = response['token'];
      return null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FlutterLogin(
      theme: LoginTheme(inputTheme: InputDecorationTheme()),
      messages: LoginMessages(
        usernameHint: "Username",
      ),
      title: 'CAIA',
      // logo: 'assets/img/ecorp.png',
      onLogin: _authUser,
      hideSignUpButton: true,
      hideForgotPasswordButton: true,
      onRecoverPassword: null,
      titleTag: "CAIA BILLING SYSTEM",
      emailValidator: (value) {
        if(value.isEmpty) {
          return "Username is required";
        }
        return null;
      },
      logoTag: "CAIA ORDERING AND BILLING SYSTEM",
      onSubmitAnimationCompleted: (){
        Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (context) => AdminApp(),
          settings: RouteSettings(arguments: {
            "token": token
          }),
        ));
      },
    );
  }
}
