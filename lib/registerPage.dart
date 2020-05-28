import 'dart:convert' as convert;

import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:http/http.dart' as http;
import 'package:ocha/ShoppingCartPage.dart';
import 'package:ocha/StoresPage.dart';
import 'package:ocha/homePage.dart';
import 'package:ocha/model/AppTheme.dart';
import 'package:ocha/model/Define.dart';
import 'package:ocha/model/global_var.dart' as global_var;
import 'package:ocha/model/lang.dart' as lang;
import 'package:shared_preferences/shared_preferences.dart';

import 'giftPage.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class RegisterPage extends StatefulWidget {
  @override
  _RegisterPageState createState() => _RegisterPageState();
}
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
//final _usernameController = TextEditingController();
final _addressController = TextEditingController();
final _emailController = TextEditingController();
final _phoneController = TextEditingController();
final _passwordController = TextEditingController();
//final _fullNameController = TextEditingController();
final _firstNameController = TextEditingController();
final _lastNameController = TextEditingController();
final _address2Controller = TextEditingController();
final _zipcodeController = TextEditingController();
final _cityController = TextEditingController();

class _RegisterPageState extends State<RegisterPage> {

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  final List<Notification> notifications = [];
  String firebaseFCMtoken = "";
  String _message = '';

  String registerInfo = '';
  String backgroundImage = "";
  String appName = "";

  List<CountryList> _countryList = [];
  List<StateList> _stateList = [];

  int _selectedIndex = 0;
  String _displayState = "--Select State--";
  int stateID = 0;

  //String _displayCountry = "--Select Country--";
  String _displayBirthday = "--Select Birthday--";
  int countryID = 0;
  String birthday = "";

  @override
  void initState() {
    super.initState();
    getCountryList();
    getStateList();
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

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    if (index == 1) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => ShoppingCartPage(0)));
    } else if (index == 2) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => GiftPage()));
    } else if (index == 3) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => StoresPage()));
    } else if (index == 0) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => HomePage()));
    }
  }

  Future<bool> _onBackPressed() {
    Navigator.push(context, MaterialPageRoute(builder: (context) => HomePage()));
    return null;
  }

  void getCountryList() async {
    String url = global_var.domain + "?ss_module=mobile&option=provinceList";
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      var jsonResponse = convert.jsonDecode(response.body);
      List<CountryList> catList2 = [];
      for (var i = 0; i < jsonResponse.length; i++) {
        if (i == 0) {
          countryID = int.parse(jsonResponse[i]['f_id'].toString());
        }
        List<CountryList> catList3 = [
          CountryList(
            id: int.tryParse(jsonResponse[i]['f_id'].toString()),
            name: jsonResponse[i]['f_name'],
          )
        ];
        catList2.add(catList3[0]);
      }
      setState(() {
        _countryList = catList2;
      });
    }
  }

  void getStateList() async {
    String url = global_var.domain + "?ss_module=mobile&option=districtList";
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      var jsonResponse = convert.jsonDecode(response.body);
      List<StateList> catList2 = [];
      for (var i = 0; i < jsonResponse.length; i++) {
        List<StateList> catList3 = [
          StateList(
            id: int.tryParse(jsonResponse[i]['f_id'].toString()),
            name: jsonResponse[i]['f_name'],
            countryID: int.tryParse(jsonResponse[i]['f_province'].toString()),
          )
        ];
        catList2.add(catList3[0]);
      }
      setState(() {
        _stateList = catList2;
      });
    }
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

  void clearData() async {
    global_var.isLoggedIn = false;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('safeCode', '');
    prefs.setString('fullName', '');
    global_var.safeCode = '';
    global_var.fullName = '';
  }

  void saveScreen() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('screen', 'HOME');
  }

  void doRegister() async {
    if (stateID == 0) {
      _showInfo("Please select your state");
    } else if (birthday == "") {
      _showInfo("Please select your birthday");
    } else if (countryID == 0) {
      _showInfo("Please select your Country");
    } else {
      final response = await http.post(Uri.parse(global_var.domain + "/?ss_module=mobile&option=register"), body: {
        'password': _passwordController.text,
        'firstname': _firstNameController.text,
        'lastname': _lastNameController.text,
        'email': _emailController.text,
        'phone': _phoneController.text,
        'address': _addressController.text,
        'address2': _address2Controller.text,
        'city': _cityController.text,
        'birthday': birthday,
        'zipcode': _zipcodeController.text,
        'district': stateID.toString(),
        'province': countryID.toString()
      });
      if (response.statusCode == 200) {
        var jsonResponse = convert.jsonDecode(response.body);
        print(response.body);
        var safeCode = jsonResponse['safeCode'].toString();
        if (safeCode != "email" && safeCode != "zipcode" && safeCode.length > 0) {
          global_var.isLoggedIn = true;
          final SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setString('safeCode', jsonResponse['safeCode'].toString());
          prefs.setString('firstName', jsonResponse['firstName'].toString());
          prefs.setString('lastName', jsonResponse['lastName'].toString());
          prefs.setString('userID', jsonResponse['userID'].toString());
          global_var.safeCode = jsonResponse['safeCode'].toString();
          global_var.fullName = jsonResponse['fullName'].toString();
          Navigator.push(context, MaterialPageRoute(builder: (context) => HomePage()));
        } else if (safeCode == "email") {
          setState(() => registerInfo = lang.registerFalse_2);
          global_var.isLoggedIn = false;
          final SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setString('safeCode', '');
          prefs.setString('firstName', '');
          prefs.setString('lastName', '');
          prefs.setString('userID', '0');
          global_var.safeCode = '';
          global_var.fullName = '';
        } else if (safeCode == "zipcode") {
          setState(() => registerInfo = lang.registerFalse_4);
          global_var.isLoggedIn = false;
          final SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setString('safeCode', '');
          prefs.setString('firstName', '');
          prefs.setString('lastName', '');
          prefs.setString('userID', '0');
          global_var.safeCode = '';
          global_var.fullName = '';
        } else {
          setState(() => registerInfo = lang.registerFalse_3);
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
            appBar: AppBar(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                // centers horizontally
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                // centers vertically
                children: <Widget>[
                  Text("Register"),
                ],
              ),
              backgroundColor: Color(0XFF2d561e),
              centerTitle: true,
            ),
            backgroundColor: Colors.transparent,
            body: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.only(top: 5),
                  ),
                  Center(
                    child: Text(registerInfo, style: AppTheme.error, textAlign: TextAlign.center),
                  ),
                  Container(
                    padding: EdgeInsets.all(10),
                    margin: EdgeInsets.all(0),
                    child: TextField(
                      showCursor: true,
                      decoration: AppTheme.inputEmailDecoration,
                      controller: _emailController,
                      onChanged: (text) {},
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(10),
                    margin: EdgeInsets.all(0),
                    child: TextField(
                      showCursor: true,
                      decoration: AppTheme.inputPasswordDecoration,
                      obscureText: true,
                      controller: _passwordController,
                      onChanged: (text) {},
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(10),
                    margin: EdgeInsets.all(0),
                    child: TextField(
                      showCursor: true,
                      decoration: AppTheme.inputFirstnameDecoration,
                      controller: _firstNameController,
                      onChanged: (text) {},
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(10),
                    margin: EdgeInsets.all(0),
                    child: TextField(
                      showCursor: true,
                      decoration: AppTheme.inputLastnameDecoration,
                      controller: _lastNameController,
                      onChanged: (text) {},
                    ),
                  ),
                  Container(
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(width: 1.0, color: Colors.grey),
                        ),
                        //borderRadius: BorderRadius.circular(4),
                        color: Color.fromARGB(30, 255, 255, 255),
                      ),
                      padding: EdgeInsets.all(10.0),
                      margin: EdgeInsets.only(right: 10.0, left: 10.0, top: 15.0),
                      child: InkWell(
                        child: Row(
                          children: <Widget>[
                            Expanded(
                              child: Text(_displayBirthday),
                            ),
                            Container(
                              child: Icon(Icons.keyboard_arrow_down),
                            )
                          ],
                        ),
                        onTap: () {
                          DatePicker.showDatePicker(context,
                              showTitleActions: true,
                              minTime: DateTime(1920, 1, 1),
                              maxTime: DateTime(int.parse(formatDate(DateTime.now(), [yyyy])), int.parse(formatDate(DateTime.now(), [mm])),
                                  int.parse(formatDate(DateTime.now(), [dd]))), onChanged: (date) {
                            //print('change $date');
                          }, onConfirm: (date) {
                            setState(() {
                              birthday = date.day.toString() + "/" + date.month.toString() + "/" + date.year.toString();
                              _displayBirthday = date.year.toString() + "/" + date.month.toString() + "/" + date.day.toString();
                            });
                          }, currentTime: DateTime.now(), locale: LocaleType.en);
                        },
                      )),
                  Container(
                    padding: EdgeInsets.all(10),
                    margin: EdgeInsets.all(0),
                    child: TextField(
                      showCursor: true,
                      decoration: AppTheme.inputPhoneDecoration,
                      controller: _phoneController,
                      onChanged: (text) {
                        //print("First text field: $text");
                      },
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(10),
                    margin: EdgeInsets.all(0),
                    child: TextField(
                      showCursor: true,
                      decoration: AppTheme.inputAddressDecoration,
                      controller: _addressController,
                      onChanged: (text) {},
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(10),
                    margin: EdgeInsets.all(0),
                    child: TextField(
                      showCursor: true,
                      decoration: AppTheme.inputAddress2Decoration,
                      controller: _address2Controller,
                      onChanged: (text) {},
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(10),
                    margin: EdgeInsets.all(0),
                    child: TextField(
                      showCursor: true,
                      decoration: AppTheme.inputCityDecoration,
                      controller: _cityController,
                      onChanged: (text) {},
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(10),
                    margin: EdgeInsets.all(0),
                    child: TextField(
                      showCursor: true,
                      decoration: AppTheme.inputZipcodeDecoration,
                      controller: _zipcodeController,
                      onChanged: (text) {},
                    ),
                  ),
                  /*Container(
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(width: 1.0, color: Color(0XFF365418)),
                          left:
                              BorderSide(width: 1.0, color: Color(0XFF365418)),
                          right:
                              BorderSide(width: 1.0, color: Color(0XFF365418)),
                          bottom:
                              BorderSide(width: 1.0, color: Color(0XFF365418)),
                        ),
                        borderRadius: BorderRadius.circular(4),
                        color: Color.fromARGB(200, 255, 255, 255),
                      ),
                      padding: EdgeInsets.all(10.0),
                      margin: EdgeInsets.only(
                          right: 10.0, left: 10.0, bottom: 5.0, top: 10.0),
                      child: InkWell(
                        child: Row(
                          children: <Widget>[
                            Expanded(
                              child: Text(_displayCountry),
                            ),
                            Container(
                              child: Icon(Icons.keyboard_arrow_down),
                            )
                          ],
                        ),
                        onTap: () {
                          _showCountry();
                        },
                      )),*/
                  Container(
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(width: 1.0, color: Colors.grey),
                        ),
                        //borderRadius: BorderRadius.circular(4),
                        color: Color.fromARGB(30, 255, 255, 255),
                      ),
                      padding: EdgeInsets.all(10.0),
                      margin: EdgeInsets.only(right: 10.0, left: 10.0, top: 15.0),
                      child: InkWell(
                        child: Row(
                          children: <Widget>[
                            Expanded(
                              child: Text(_displayState),
                            ),
                            Container(
                              child: Icon(Icons.keyboard_arrow_down),
                            )
                          ],
                        ),
                        onTap: () {
                          _showState();
                        },
                      )),
                  Container(
                    padding: EdgeInsets.only(top: 20),
                    margin: EdgeInsets.only(bottom: 20),
                    child: RaisedButton(
                      color: Colors.blue,
                      onPressed: () {
                        doRegister();
                      },
                      child: Text(lang.register, style: TextStyle(color: Colors.white)),
                    ),
                  )
                ],
              ),
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

  Future<void> _showCountry() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: EdgeInsets.all(5.0),
          titlePadding: EdgeInsets.only(top: 10.0, left: 5.0),
          title: Text("Select your country"),
          content: ListView(
            shrinkWrap: true,
            padding: EdgeInsets.all(0),
            //map List of our data to the ListView
            children: _countryList.map((data) {
              return InkWell(
                child: Container(
                  padding: EdgeInsets.all(10.0),
                  margin: EdgeInsets.only(top: 3.0, bottom: 3.0),
                  color: Colors.green,
                  child: Text(
                    data.name,
                    style: TextStyle(
                      fontWeight: FontWeight.normal,
                      color: Color(0xFFFFFFFF),
                      fontSize: 14,
                    ),
                  ),
                ),
                onTap: () {
                  print(data.id);
                  if (countryID != data.id) {
                    setState(() {
                      stateID = 0;
                      countryID = data.id;

                      //_displayCountry = data.name;
                      _displayState = "--Select state--";
                    });
                  }
                  Navigator.of(context).pop();
                },
              );
            }).toList(),
          ),
          actions: <Widget>[
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

  Future<void> _showState() async {
    print(countryID);
    return showDialog<void>(
      context: context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: EdgeInsets.all(5.0),
          titlePadding: EdgeInsets.only(top: 10.0, left: 5.0),
          title: Text("Select your state"),
          content: ListView(
            shrinkWrap: true,
            padding: EdgeInsets.all(0),
            //map List of our data to the ListView
            children: _stateList.map((data) {
              return data.countryID == countryID
                  ? InkWell(
                      child: Container(
                        padding: EdgeInsets.all(10.0),
                        margin: EdgeInsets.only(top: 3.0, bottom: 3.0),
                        color: Colors.green,
                        child: Text(
                          data.name,
                          style: TextStyle(
                            fontWeight: FontWeight.normal,
                            color: Color(0xFFFFFFFF),
                            fontSize: 14,
                          ),
                        ),
                      ),
                      onTap: () {
                        setState(() {
                          stateID = data.id;
                          _displayState = data.name;
                          print(countryID);
                        });
                        Navigator.of(context).pop();
                      },
                    )
                  : Container();
            }).toList(),
          ),
          actions: <Widget>[
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

  Future<void> _showInfo(String content) async {
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
}
