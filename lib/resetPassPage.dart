import 'dart:convert' as convert;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ocha/ShoppingCartPage.dart';
import 'package:ocha/StoresPage.dart';
import 'package:ocha/homePage.dart';
import 'package:ocha/loginPage.dart';
import 'package:ocha/model/AppTheme.dart';
import 'package:ocha/model/global_var.dart' as global_var;
import 'package:ocha/model/lang.dart' as lang;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:ocha/giftPage.dart';
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
final _emailController = TextEditingController();
final _newPasswordController = TextEditingController();
final _newPassword2Controller = TextEditingController();
final _resetPasswordCodeController = TextEditingController();

class ResetPassPage extends StatefulWidget {
  const ResetPassPage({Key key}) : super(key: key);

  @override
  _ResetPassPageState createState() => _ResetPassPageState();
}

class _ResetPassPageState extends State<ResetPassPage>
    with TickerProviderStateMixin {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  final List<Notification> notifications = [];
  String firebaseFCMtoken = "";
  String _message = '';

  String passWord = "";
  String passWord2 = "";
  String resetCode = "";
  String resetEmail = "";

  int _selectedIndex = 0;
  String backgroundImage = "";
  String appName = "";
  int tabIndex = 0;
  bool showTopupForm = false;

  @override
  void initState() {
    localInfo();
    appInfo();
    super.initState();
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

  void appInfo() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    global_var.appName = prefs.getString("appName");
    global_var.backgroundImage = prefs.getString("backgroundImage");
    setState(() {
      appName = global_var.appName;
      backgroundImage = global_var.backgroundImage;
    });
  }

  void clearCart() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("cartData", "");
  }

  Future<bool> getData() async {
    await Future<dynamic>.delayed(const Duration(milliseconds: 0));
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
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
            title: Text(lang.changePass),
            backgroundColor: Color(0XFF2d561e),
            centerTitle: true,
            actions: <Widget>[
              // action button
              IconButton(
                icon: Icon(Icons.home),
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => HomePage()));
                },
              ),
            ],
          ),
          body: Column(children: <Widget>[
            tabBar(),
            tabIndex == 0 ? Expanded(child: emailInputTab()) : Container(),
            tabIndex == 1 ? Expanded(child: passwordRessetTab()) : Container(),
          ]),
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
            selectedItemColor: Colors.amber[800],
            onTap: _onItemTapped,
          ),
        ),
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    if (index == 0) {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => HomePage()));
    } else if (index == 1) {
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => ShoppingCartPage(0)));
    }else if (index == 2) {
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => GiftPage()));
    } else if (index == 3) {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => StoresPage()));
    }
  }

  void localInfo() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    global_var.safeCode = prefs.getString("safeCode");
    global_var.firstName = prefs.getString("firstName");
    global_var.lastName = prefs.getString("lastName");
    global_var.userID = prefs.getString("userID");
    if (global_var.safeCode == null ||
        global_var.safeCode == "" ||
        global_var.userID == "0") {
      prefs.setString('safeCode', "");
      prefs.setString('firstName', "");
      prefs.setString('lastName', "");
      prefs.setString('userID ', "0");
      global_var.safeCode = "";
      global_var.firstName = "";
      global_var.lastName = "";
      global_var.userID = "0";
    } else {}
  }

  void sendResetCode() async {
    resetEmail = _emailController.text;
    print(resetEmail);
    if (resetEmail == "") {
      _showInfo2("Please input your email", 3);
    } else {
      final response = await http.post(
          Uri.parse(
              global_var.domain + "/?ss_module=mobile&option=resetPassCode"),
          body: {
            'email': _emailController.text,
          });
      if (response.statusCode == 200) {
        var jsonResponse = convert.jsonDecode(response.body);
        print(response.body);
        var result = jsonResponse['result'].toString();
        if (result.length > 0 && result == "OK") {
          _showInfo2(lang.resetCodeSend, 3);
        } else {
          _showInfo2(lang.emailNotExist, 3);
        }
      }
    }
  }

  void resetPassword() async {
    passWord = _newPasswordController.text;
    passWord2 = _newPassword2Controller.text;
    resetCode = _resetPasswordCodeController.text;
    if (passWord == "") {
      _showInfo2("Please input your new password", 3);
    } else if (passWord2 == "") {
      _showInfo2("Please retype your password", 3);
    } else if (resetCode == "") {
      _showInfo2("Please input your resset code", 3);
    } else if (passWord != passWord2) {
      _showInfo2("Password does not match", 3);
    } else {
      final response = await http.post(
          Uri.parse(global_var.domain + "/?ss_module=mobile&option=resetPass"),
          body: {
            'passWord': passWord,
            'resetCode': resetCode,
          });
      if (response.statusCode == 200) {
        var jsonResponse = convert.jsonDecode(response.body);
        print(response.body);
        var result = jsonResponse['result'].toString();
        if (result.length > 0 && result == "OK") {
          _showInfo2(lang.paswordChangeSuccess, 4);
        } else {
          _showInfo2(lang.emailNotExist, 3);
        }
      }
    }
  }

  Future<void> _showInfo2(String content, int action) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: EdgeInsets.all(5.0),
          titlePadding: EdgeInsets.only(top: 10.0, left: 5.0),
          title: Text('Info'),
          content: Container(
            child: Text(content),
          ),
          actions: <Widget>[
            action == 4
                ? FlatButton(
                    child: Text('Login'),
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) => LoginPage()));
                    },
                  )
                : action == 50
                    ? FlatButton(
                        child: Text('Review'),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      )
                    : Container(),
            FlatButton(
              child: Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  String format(double n) {
    return n.toStringAsFixed(n.truncateToDouble() == n ? 0 : 2);
  }

  Widget emailInputTab() {
    return Container(
      margin: EdgeInsets.only(top: 0.0, bottom: 20.0, left: 10.0, right: 10.0),
      padding: EdgeInsets.all(0),
      color: Colors.white,
      child: ListView(
        padding: EdgeInsets.all(20.0),
        children: <Widget>[
          Container(
            padding: EdgeInsets.all(0),
            margin: EdgeInsets.all(0),
            child: TextField(
              showCursor: true,
              decoration: AppTheme.inputEmailDecoration,
              controller: _emailController,
              onChanged: (text) {},
            ),
          ),
          Center(
            child: Container(
              width: 220.0,
              decoration: BoxDecoration(
                color: const Color(0xFFFFFFFF),
                border: Border.all(
                  color: Colors.black54,
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              padding: EdgeInsets.all(10.0),
              margin: EdgeInsets.only(bottom: 20.0, top: 30.0),
              child: InkWell(
                child: Row(
                  children: <Widget>[
                    Container(
                      child: Container(
                        child: Icon(
                          Icons.save,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                    Text("Send reset password code"),
                  ],
                ),
                onTap: () {
                  sendResetCode();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget passwordRessetTab() {
    return Container(
      margin: EdgeInsets.only(top: 0.0, bottom: 20.0, left: 10.0, right: 10.0),
      padding: EdgeInsets.all(0),
      color: Colors.white,
      child: ListView(
        padding: EdgeInsets.all(20.0),
        children: <Widget>[
          Container(
            padding: EdgeInsets.all(0),
            margin: EdgeInsets.all(0),
            child: TextField(
              showCursor: true,
              decoration: AppTheme.inputNewPasswordDecoration,
              controller: _newPasswordController,
              onChanged: (text) {},
            ),
          ),
          Container(
            padding: EdgeInsets.all(0),
            margin: EdgeInsets.all(0),
            child: TextField(
              showCursor: true,
              decoration: AppTheme.inputNewPassword2Decoration,
              controller: _newPassword2Controller,
              onChanged: (text) {},
            ),
          ),
          Container(
            padding: EdgeInsets.all(0),
            margin: EdgeInsets.all(0),
            child: TextField(
              showCursor: true,
              decoration: AppTheme.inputRessetCodeDecoration,
              controller: _resetPasswordCodeController,
              onChanged: (text) {},
            ),
          ),
          Center(
            child: Container(
              width: 150.0,
              decoration: BoxDecoration(
                color: const Color(0xFFFFFFFF),
                border: Border.all(
                  color: Colors.black54,
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              padding: EdgeInsets.all(10.0),
              margin: EdgeInsets.only(bottom: 20.0, top: 30.0),
              child: InkWell(
                child: Row(
                  children: <Widget>[
                    Container(
                      child: Container(
                        child: Icon(
                          Icons.save,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                    Text("Reset password"),
                  ],
                ),
                onTap: () {
                  resetPassword();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget tabBar() {
    return Container(
      padding: EdgeInsets.only(top: 10.0, left: 10.0, bottom: 0.0, right: 5.0),
      child: Row(
        children: <Widget>[
          Container(
            child: Center(
              child: InkWell(
                child: tabIndex == 0
                    ? Container(
                        color: Color.fromRGBO(255, 255, 255, 0.5),
                        padding: EdgeInsets.only(
                            top: 7.0, left: 5.0, bottom: 7.0, right: 5.0),
                        margin: EdgeInsets.only(left: 5.0, right: 5.0),
                        child: Text(
                          lang.inputEmail,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: Colors.black87),
                        ),
                      )
                    : Container(
                        padding: EdgeInsets.only(
                            top: 7.0, left: 5.0, bottom: 7.0, right: 5.0),
                        margin: EdgeInsets.only(left: 5.0, right: 5.0),
                        child: Text(
                          lang.inputEmail,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                onTap: () {
                  setState(
                    () {
                      tabIndex = 0;
                    },
                  );
                },
              ),
            ),
          ),
          Container(
            child: Center(
              child: InkWell(
                child: tabIndex == 1
                    ? Container(
                        color: Color.fromRGBO(255, 255, 255, 0.5),
                        padding: EdgeInsets.only(
                            top: 7.0, left: 5.0, bottom: 7.0, right: 5.0),
                        margin: EdgeInsets.only(left: 5.0, right: 5.0),
                        child: Text(
                          lang.changePass,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: Colors.black87),
                        ),
                      )
                    : Container(
                        padding: EdgeInsets.only(
                            top: 5.0, left: 5, bottom: 5, right: 5),
                        margin: EdgeInsets.only(left: 5, right: 5),
                        child: Text(
                          lang.changePass,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                onTap: () {
                  setState(
                    () {
                      tabIndex = 1;
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
