import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ocha/homePage.dart';
import 'package:ocha/loginPage.dart';
import 'package:ocha/model/AppTheme.dart';
import 'package:ocha/model/global_var.dart' as global_var;
import 'package:shared_preferences/shared_preferences.dart';

class FlashScreen extends StatefulWidget {
  @override
  _FlashScreenState createState() => _FlashScreenState();
}

class _FlashScreenState extends State<FlashScreen> {
  @override
  void initState() {
    super.initState();
    loadConfig();
    saveScreen();
    _checkAuth();
  }

  void saveScreen() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('screen', 'HOME');
  }

  void _checkAuth() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    global_var.safeCode = prefs.getString("safeCode");
    if (global_var.safeCode == null || global_var.safeCode == "null") {
      prefs.setString('safeCode', "");
      global_var.fullName = "";
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => HomePage()));
    } else {
      String url = global_var.domain +
          "?ss_module=mobile&option=auth&safeCode=" +
          global_var.safeCode;
      print(url);
      String data = await http.read(Uri.parse(url));
      Map<String, dynamic> user = jsonDecode(data);
      global_var.safeCode = user['safeCode'];
      if (global_var.safeCode != "") {
        global_var.isLoggedIn = true;
        global_var.firstName = user['firstName'];
        global_var.lastName = user['lastName'];
        global_var.userID = user['id'].toString();
        prefs.setString('safeCode', global_var.safeCode);
        prefs.setString('firstName', user['firstName']);
        prefs.setString('lastName', user['lastName']);
        prefs.setString('userID', user['id'].toString());
        //Navigator.push(context,MaterialPageRoute(builder: (context) => NavigationHomeScreen(global_var.curent_state)));
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => HomePage()));
      } else {
        global_var.isLoggedIn = false;
        prefs.setString('safeCode', "");
        prefs.setString('fisrtName', "");
        prefs.setString('lastName', "");
        prefs.setString('userID', "0");
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => HomePage()));
      }
    }
  }

  void loadConfig() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    try {
      String url = global_var.domain + "?ss_module=mobile&option=config";
      String data = await http.read(Uri.parse(url));
      Map<String, dynamic> user = jsonDecode(data);
      prefs.setString('appName', user['appName']);
      prefs.setString('backgroundImage', user['backgroundImage']);
      prefs.setString('mobileLogo', user['mobileLogo']);
      prefs.setString('giftCardLogo', user['giftCardLogo']);
    } on Exception catch (_) {
      networkError();
    }
  }

  Future<void> networkError() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: EdgeInsets.all(5.0),
          titlePadding: EdgeInsets.only(top: 10.0, left: 5.0),
          title: Text('Network error'),
          content: Text(
              "Unable to connect to the internet, please check the network again"),
          actions: <Widget>[
            FlatButton(
              child: Text('Retry'),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => FlashScreen()));
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.nearlyWhite,
      child: SafeArea(
        top: false,
        child: Scaffold(
          backgroundColor: AppTheme.nearlyWhite,
          body: Column(
            children: <Widget>[
              //Container(
              //padding: EdgeInsets.only(top: 100, left: 50, right: 50),
              //child: Image.asset('assets/icons/ochalogo3.png'),
              //),
              Center(
                child: Container(
                  padding: const EdgeInsets.only(top: 100),
                  child: Text(
                    'Loading...',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
