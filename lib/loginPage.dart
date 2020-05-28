import 'dart:convert' as convert;
import 'dart:convert';
import 'package:intl/intl.dart';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ocha/ShoppingCartPage.dart';
import 'package:ocha/StoresPage.dart';
import 'package:ocha/homePage.dart';
import 'package:ocha/model/AppTheme.dart';
import 'package:ocha/model/global_var.dart' as global_var;
import 'package:ocha/model/lang.dart' as lang;
import 'package:ocha/registerPage.dart';
import 'package:ocha/resetPassPage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_messaging/firebase_messaging.dart';


import 'package:ocha/giftPage.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

final _usernameController = TextEditingController();
final _passwordController = TextEditingController();
Future<dynamic> myBackgroundMessageHandler(Map<String, dynamic> message) {
  if (message.containsKey('data')) {
    // Handle data message
    final dynamic data = message['data'];
  }

  if (message.containsKey('notification')) {
    // Handle notification message
    final dynamic notification = message['notification'];
  }

  // Or do other work.
}
class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  final List<Notification> notifications = [];
  String firebaseFCMtoken = "";
  String _message = '';

  String loginInfo = '';
  String _username = '';
  String _password = '';
  String backgroundImage = "";
  String appName = "";
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    saveScreen();
    appInfo();
    clearData();
    _firebaseMessaging.requestNotificationPermissions();
    firebaseFCMtoken = _register();
    _firebaseMessaging.subscribeToTopic("ChauLong");
    getMessage();
  }

  _register() {
    _firebaseMessaging.getToken().then((token){
      print(token);
      firebaseFCMtoken = token;
      return token;
    });
  }

  void getMessage() {
    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        print("onMessage: $message");
      },
      onBackgroundMessage: myBackgroundMessageHandler,
      onLaunch: (Map<String, dynamic> message) async {
        print("onLaunch: $message");
      },
      onResume: (Map<String, dynamic> message) async {
        print("onResume: $message");
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  void appInfo() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    global_var.appName = prefs.getString("appName");
    global_var.backgroundImage = prefs.getString("backgroundImage");
    setState(() {
      appName = global_var.appName;
      backgroundImage = global_var.backgroundImage;
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    if (index == 1) {
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => ShoppingCartPage(0)));
    } else if (index == 2) {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => GiftPage()));
    } else if (index == 3) {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => StoresPage()));
    } else if (index == 0) {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => HomePage()));
    }
  }

  void clearData() async {
    global_var.isLoggedIn = false;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('safeCode', '');
    prefs.setString('firstName', '');
    prefs.setString('lastName', '');
    prefs.setString('userID', '0');
    global_var.safeCode = '';
    global_var.firstName = '';
    global_var.lastName = '';
  }

  void saveScreen() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('screen', 'HOME');
  }

  void doLogin(String username, String password) async {
    String url = global_var.domain +
        "/?ss_module=mobile&option=login&email=" +
        username +
        "&password=" +
        password + "&fireBasetoken=" + firebaseFCMtoken.toString();
    print(url);
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      print(response.body);
      var jsonResponse = convert.jsonDecode(response.body);
      var safeCode = jsonResponse['safeCode'].toString();
      if (safeCode != "loginfalse") {
        global_var.isLoggedIn = true;
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('safeCode', jsonResponse['safeCode'].toString());
        prefs.setString('firstName', jsonResponse['firstName'].toString());
        prefs.setString('lastName', jsonResponse['lastName'].toString());
        prefs.setString('userID', jsonResponse['userID'].toString());
        global_var.safeCode = jsonResponse['safeCode'].toString();
        global_var.firstName = jsonResponse['firstName'].toString();
        global_var.lastName = jsonResponse['lastName'].toString();

        Navigator.push(
            context, MaterialPageRoute(builder: (context) => HomePage()));
      } else {
        setState(() => loginInfo = "Email and password are incorrect!");
        global_var.isLoggedIn = false;
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('safeCode', '');
        prefs.setString('firstName', '');
        prefs.setString('lastName', '');
        prefs.setString('userID', '0');
        global_var.safeCode = '';
        global_var.fullName = '';
      }
    }
  }

  Future<bool> _onBackPressed() {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => HomePage()));
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onBackPressed,
      child: GestureDetector(
        onTap: () {
          FocusScopeNode currentFocus = FocusScope.of(context);
          if (!currentFocus.hasPrimaryFocus) {
            currentFocus.unfocus();
          }
        },
        child: Container(
          decoration: new BoxDecoration(
            image: new DecorationImage(
              image: new NetworkImage(backgroundImage),
              fit: BoxFit.fill,
            ),
          ),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                // centers horizontally
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                // centers vertically
                children: <Widget>[
                  Text(lang.login),
                ],
              ),
              backgroundColor: Color(0XFF2d561e),
              centerTitle: true,
            ),
            body: Column(
              children: <Widget>[
                Container(
                  padding: EdgeInsets.only(top: 70, left: 50, right: 50),
                ),
                Center(
                  child: Text(loginInfo,
                      style: AppTheme.error, textAlign: TextAlign.center),
                ),
                Container(
                  padding: EdgeInsets.only(
                      left: 10.0, right: 10.0, top: 10.0, bottom: 0),
                  child: TextField(
                    showCursor: true,
                    decoration: AppTheme.inputEmailDecorationLogin,
                    controller: _usernameController,
                    onChanged: (text) {
                      //print("First text field: $text");
                    },
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(
                      left: 10.0, right: 10.0, top: 10.0, bottom: 0),
                  child: TextField(
                    showCursor: true,
                    decoration: AppTheme.inputPasswordDecorationLogin,
                    obscureText: true,
                    controller: _passwordController,
                    onChanged: (text) {},
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(
                      left: 10.0, right: 10.0, top: 10.0, bottom: 0),
                  child: RaisedButton(
                    color: Colors.blue,
                    onPressed: () {
                      _username = _usernameController.text;
                      _password = _passwordController.text;
                      doLogin(_username, _password);
                    },
                    child:
                        Text(lang.login, style: TextStyle(color: Colors.white)),
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(top: 20),
                  child: InkWell(
                    child: Text(lang.resetPass, style: AppTheme.link),
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ResetPassPage()));
                    },
                  ),
                ),
                Container(
                  padding: EdgeInsets.only(top: 20),
                  child: InkWell(
                    child: Text(lang.registerLinkText, style: AppTheme.link),
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => RegisterPage()));
                    },
                  ),
                ),
              ],
            ),
            bottomNavigationBar: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              items: <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  title: Text(lang.home),
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.list),
                  title: Text(lang.menu),
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.card_giftcard),
                  title: Text(lang.gift),
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.location_on),
                  title: Text(lang.stores),
                )
              ],
              currentIndex: _selectedIndex,
              selectedItemColor: Color(0XFF2d561e),
              onTap: _onItemTapped,
            ),
          ),
        ),
      ),
    );
  }
}
