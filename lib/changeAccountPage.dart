import 'dart:convert' as convert;
import 'dart:convert';

import 'package:date_format/date_format.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:flutter_web_browser/flutter_web_browser.dart';
import 'package:http/http.dart' as http;
import 'package:ocha/ShoppingCartPage.dart';
import 'package:ocha/StoresPage.dart';
import 'package:ocha/homePage.dart';
import 'package:ocha/loginPage.dart';
import 'package:ocha/model/AppTheme.dart';
import 'package:ocha/model/global_var.dart' as global_var;
import 'package:ocha/model/lang.dart' as lang;
import 'package:shared_preferences/shared_preferences.dart';

import 'giftPage.dart';
import 'model/Define.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

//final _paymentNumber = TextEditingController();
final _paymentCardNumber = TextEditingController();
final _paymentExpYear = TextEditingController();
final _paymentExpMonth = TextEditingController();
final _paymentCardCode = TextEditingController();
//final _paymentFisrtName = TextEditingController();
//final _paymentLastName = TextEditingController();
final _paymentFullName = TextEditingController();
final _authorizeID = "33C6Ckjv";
final _authorizeKEY = "287t68V9TcUTFPrB";

final _addressController = TextEditingController();
final _emailController = TextEditingController();
final _phoneController = TextEditingController();
//final _passwordController = TextEditingController();
//final _fullNameController = TextEditingController();
final _firstNameController = TextEditingController();
final _lastNameController = TextEditingController();
final _address2Controller = TextEditingController();
final _zipcodeController = TextEditingController();
final _cityController = TextEditingController();
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

class ChangeAccountPage extends StatefulWidget {
  const ChangeAccountPage({Key key}) : super(key: key);

  @override
  _ChangeAccountPageState createState() => _ChangeAccountPageState();
}

class _ChangeAccountPageState extends State<ChangeAccountPage>
    with TickerProviderStateMixin {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  final List<Notification> notifications = [];
  String firebaseFCMtoken = "";
  String _message = '';

  String username = "";
  String uid = "";
  String firstName = "";
  String lastName = "";
  String email = "";
  String phone = "";
  String address = "";
  String address2 = "";
  String city = "";
  String zipcode = "";
  String birthday = "";
  String state = "";
  String country = "";
  int amount = 0;
  List<TopupList> topupValueList;
  String amountTxt = "";
  String amountadd = "";
  String paymentCardNumber = "";
  String paymentExpYear = "";
  String paymentExpMonth = "";
  String paymentCardCode = "";
  String paymentFisrtName = "";
  String paymentLastName = "";
  String paymentFullName = "";
  int _selectedIndex = 0;
  String backgroundImage = "";
  String appName = "";
  int tabIndex = 0;
  bool showTopupForm = false;

  String registerInfo = '';
  List<CountryList> _countryList = [];
  List<StateList> _stateList = [];
  String _displayState = "--Select State--";
  int stateID = 0;
  //String _displayCountry = "--Select Country--";
  //String _displayBirthday = "--Select Birthday--";
  int countryID = 0;
  var birthdateL = ["2020", "05", "05"];

  @override
  void initState() {
    localInfo();
    appInfo();
    super.initState();
    getDetail();
    getCountryList();
    getStateList();
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
            title: Text(lang.accountEdit),
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
            tabIndex == 0 ? Expanded(child: generalTab()) : Container(),
            tabIndex == 1 ? Expanded(child: contactTab()) : Container(),
            actionBar(),
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
    } else if (index == 2) {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => GiftPage()));
    } else if (index == 3) {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => StoresPage()));
    }
  }

  openBrowserTab() async {
    await FlutterWebBrowser.openWebPage(
        url: global_var.domain +
            "checkout/?id=" +
            uid +
            "&total_amount=" +
            amountadd,
        androidToolbarColor: Colors.deepPurple);
  }

  void sendInfoToPayment() async {
    if (double.parse(amountadd) > 0 &&
        paymentCardNumber != "" &&
        paymentCardNumber != null &&
        paymentCardCode != "" &&
        paymentCardCode != null &&
        paymentExpYear != "" &&
        paymentExpYear != null &&
        paymentExpMonth != "" &&
        paymentExpMonth != null) {
      final http.Response response = await http.post(
        'https://apitest.authorize.net/xml/v1/request.api',
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          "createTransactionRequest": {
            "merchantAuthentication": {
              "name": _authorizeID,
              "transactionKey": _authorizeKEY
            },
            "refId": global_var.userID,
            "transactionRequest": {
              "transactionType": "authCaptureTransaction",
              "amount": amountadd,
              "currencyCode": "USD",
              "payment": {
                "creditCard": {
                  "cardNumber": paymentCardNumber,
                  "expirationDate": paymentExpYear + "-" + paymentExpMonth,
                  "cardCode": paymentCardCode
                }
              },
              "lineItems": {
                "lineItem": {
                  "itemId": "1",
                  "name": "Top up",
                  "description": "Top up to user acount at Ocha",
                  "quantity": "1",
                  "unitPrice": amountadd
                }
              },
              "tax": {
                "amount": "0",
                "name": "level2 tax",
                "description": "level2 tax"
              },
              "duty": {
                "amount": "0",
                "name": "duty name",
                "description": "duty description"
              },
              "shipping": {
                "amount": "0",
                "name": "level2 tax name",
                "description": "level2 tax"
              },
              "poNumber": global_var.userID,
              "customer": {"id": global_var.userID},
            }
          }
        }),
      );
      if (response.statusCode == 200) {
        var results = json.decode(response.body);
        print(results);
        if (results["transactionResponse"]["responseCode"] == "1") {
          String url2 = global_var.domain +
              "?ss_module=payment&option=AuthorizeNet&authCode=" +
              results["transactionResponse"]["authCode"].toString() +
              "&transId=" +
              results["transactionResponse"]["transId"].toString() +
              "&accountNumber=" +
              paymentCardNumber +
              "&accountType=" +
              results["transactionResponse"]["accountType"].toString() +
              "&networkTransId=" +
              results["transactionResponse"]["networkTransId"].toString() +
              "&refId=" +
              global_var.userID +
              "&amount=" +
              amountadd;
          final response = await http.get(Uri.parse(url2));
          print(url2);
          if (response.statusCode == 200) {
            var jsonResponse = convert.jsonDecode(response.body);
            setState(() {
              amountTxt = jsonResponse["amount"];
            });
          }
        }
      } else {
        // If the server did not return a 201 CREATED response,
        // then throw an exception.
        _showInfo2(lang.networkError, 0);
      }
    } else {
      _showInfo2("Please enter full information", 50);
    }
  }

  Future<void> popupAmountList() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10.0))),
          contentPadding: EdgeInsets.all(20.0),
          titlePadding: EdgeInsets.only(top: 20.0, left: 20.0),
          title: Text('Select topup amount'),
          content: Scrollbar(
            child: SingleChildScrollView(
              child: ListBody(
                children: topupValueList.map((item) {
                  return InkWell(
                    child: Container(
                      margin: EdgeInsets.only(right: 5.0, bottom: 5.0),
                      padding: EdgeInsets.all(3.0),
                      decoration: BoxDecoration(
                        color: item.selected ? Colors.green : Colors.white,
                        border: Border.all(width: 1.0, color: Colors.grey),
                        borderRadius: BorderRadius.all(Radius.circular(
                                5.0) //         <--- border radius here
                            ),
                      ),
                      child: Text("${item.name}"),
                    ),
                    onTap: () {
                      amountadd = item.name;
                      setState(() {
                        amountadd = amountadd;
                        for (var i = 0; i < topupValueList.length; i++) {
                          topupValueList[i].selected = false;
                        }
                        topupValueList[item.index].selected = true;
                      });
                      Navigator.of(context).pop();
                      popupAmountList();
                    },
                  );
                }).toList(),
              ),
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('Next'),
              onPressed: () {
                //openBrowserTab();
                Navigator.of(context).pop();
                _showDialogPayment();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showDialogPayment() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10.0))),
          contentPadding: EdgeInsets.all(20.0),
          titlePadding: EdgeInsets.only(top: 20.0, left: 20.0),
          title: Text('Recharge account'),
          content: Scrollbar(
            child: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text('Name of card:'),
                  Container(
                    padding: EdgeInsets.only(
                        left: 0, right: 0, top: 5.0, bottom: 10.0),
                    child: TextField(
                      showCursor: true,
                      decoration: AppTheme.inputPaymentNumberDecoration,
                      controller: _paymentFullName,
                      onChanged: (text) {
                        paymentFullName = _paymentFullName.text;
                      },
                    ),
                  ),
                  Text('Card number:'),
                  Container(
                    padding: EdgeInsets.only(
                        left: 0, right: 0, top: 5.0, bottom: 10.0),
                    child: TextField(
                      showCursor: true,
                      decoration: AppTheme.inputPaymentNumberDecoration,
                      controller: _paymentCardNumber,
                      onChanged: (text) {
                        paymentCardNumber = _paymentCardNumber.text;
                      },
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  Text('CVN:'),
                  Container(
                    padding: EdgeInsets.only(
                        left: 0, right: 0, top: 5.0, bottom: 10.0),
                    child: TextField(
                      showCursor: true,
                      decoration: AppTheme.inputPaymentNumberDecoration,
                      controller: _paymentCardCode,
                      onChanged: (text) {
                        paymentCardCode = _paymentCardCode.text;
                      },
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  InkWell(
                      child: Row(
                    children: <Widget>[
                      Container(width: 100.0, child: Text("Exp. month:")),
                      Container(child: Text("Exp. year:"))
                    ],
                  )),
                  InkWell(
                      child: Row(
                    children: <Widget>[
                      Container(
                        width: 100.0,
                        padding: EdgeInsets.only(
                            left: 0, right: 10.0, top: 5.0, bottom: 10.0),
                        child: TextField(
                          showCursor: true,
                          decoration: AppTheme.inputPaymentNumberDecoration,
                          controller: _paymentExpMonth,
                          keyboardType: TextInputType.number,
                          onChanged: (text) {
                            paymentExpMonth = _paymentExpMonth.text;
                          },
                        ),
                      ),
                      Container(
                        width: 100.0,
                        padding: EdgeInsets.only(
                            left: 0, right: 0, top: 5.0, bottom: 10.0),
                        child: TextField(
                          showCursor: true,
                          keyboardType: TextInputType.number,
                          decoration: AppTheme.inputPaymentNumberDecoration,
                          controller: _paymentExpYear,
                          onChanged: (text) {
                            paymentExpYear = _paymentExpYear.text;
                          },
                        ),
                      ),
                    ],
                  )),
                  Text('Top up amount:'),
                  Container(
                    padding: EdgeInsets.all(3.0),
                    margin: EdgeInsets.all(0.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(3.0),
                      color: Colors.grey[40],
                      border: Border(
                        left: BorderSide(width: 1, color: Colors.grey),
                        right: BorderSide(width: 1, color: Colors.grey),
                        top: BorderSide(width: 1, color: Colors.grey),
                        bottom: BorderSide(width: 1, color: Colors.grey),
                      ),
                    ),
                    child: InkWell(
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: Text("$amountadd"),
                          ),
                          Container(
                            child: Icon(Icons.keyboard_arrow_down),
                          )
                        ],
                      ),
                      onTap: () {
                        Navigator.of(context).pop();
                        popupAmountList();
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('Next'),
              onPressed: () {
                //openBrowserTab();
                Navigator.of(context).pop();
                sendInfoToPayment();
              },
            ),
          ],
        );
      },
    );
  }

  void getDetail() async {
    String url = global_var.domain +
        "?ss_module=mobile&option=account&safeCode=" +
        global_var.safeCode;
    final response = await http.get(Uri.parse(url));
    print(url);
    if (response.statusCode == 200) {
      try {
        var jsonResponse = convert.jsonDecode(response.body);
        setState(() {
          username = jsonResponse['username'];
          uid = jsonResponse['id'].toString();
          global_var.userID = uid;
          _firstNameController.text = jsonResponse['firstname'];
          _lastNameController.text = jsonResponse['lastname'];
          _emailController.text = jsonResponse['email'];
          _phoneController.text = jsonResponse['phone'];
          _addressController.text = jsonResponse['address'];
          _address2Controller.text = jsonResponse['address2'];
          _cityController.text = jsonResponse['city'];
          _zipcodeController.text = jsonResponse['zipcode'];
          birthday = jsonResponse['birthday'];
          //_displayBirthday = birthday;
          birthdateL = [];
          birthdateL = birthday.split("/");
          state = jsonResponse['district'];
          _displayState = state;
          if (state != null) {
            stateID = int.parse(jsonResponse['district_id']);
          }
          country = jsonResponse['province'];
          if (country != null) {
            countryID = int.parse(jsonResponse['province_id']);
          }
          amountTxt = double.parse(jsonResponse['amount']).toString();
          List tmp = jsonResponse['topupList'].split("|");
          topupValueList = [];
          for (var i = 0; i < tmp.length; i++) {
            List<TopupList> topupList = [
              TopupList(name: tmp[i], selected: i == 0 ? true : false, index: i)
            ];
            topupValueList.add(topupList[0]);
          }
        });
      } catch (error) {
        print(error);
      }
    } else {
      _showInfo2(lang.networkError, 100);
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
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => LoginPage(),
        ),
      );
    } else {}
  }

  void logOut() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('safeCode', "");
    prefs.setString('firstName', "");
    prefs.setString('lastName', "");
    prefs.setString('userID ', "0");
    global_var.safeCode = "";
    global_var.firstName = "";
    global_var.lastName = "";
    global_var.userID = "0";
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LoginPage(),
      ),
    );
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

  void doUpdateAcount() async {
    if (stateID == 0) {
      _showInfo2("Please select your state", 3);
    } else if (birthday == "") {
      _showInfo2("Please select your birthday", 3);
    } else if (countryID == 0) {
      _showInfo2("Please select your Country", 3);
    } else {
      final response = await http.post(
          Uri.parse(
              global_var.domain + "/?ss_module=mobile&option=updateAcount"),
          body: {
            'safeCode': global_var.safeCode,
            'firstname': _firstNameController.text,
            'lastname': _lastNameController.text,
            'phone': _phoneController.text,
            'address': _addressController.text,
            'address2': _address2Controller.text,
            'city': _cityController.text,
            //'birthday': birthday,
            'zipcode': _zipcodeController.text,
            'district': stateID.toString(),
            'province': countryID.toString()
          });
      if (response.statusCode == 200) {
        var jsonResponse = convert.jsonDecode(response.body);
        print(response.body);
        var safeCode = jsonResponse['safeCode'].toString();
        if (safeCode.length > 0 && safeCode != "zipcode") {
          global_var.isLoggedIn = true;
          final SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setString('safeCode', jsonResponse['safeCode'].toString());
          prefs.setString('firstName', jsonResponse['firstName'].toString());
          prefs.setString('lastName', jsonResponse['lastName'].toString());
          prefs.setString('userID', jsonResponse['userID'].toString());
          global_var.safeCode = jsonResponse['safeCode'].toString();
          global_var.fullName = jsonResponse['fullName'].toString();
          Navigator.push(
              context, MaterialPageRoute(builder: (context) => HomePage()));
        } else if (safeCode == "zipcode") {
          _showInfo2("Invalid zipcode", 3);
        } else {
          _showInfo2("Invalid data", 3);
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
            action == 100
                ? FlatButton(
                    child: Text('Reload'),
                    onPressed: () {
                      Navigator.of(context).pop();
                      getDetail();
                    },
                  )
                : action == 50
                    ? FlatButton(
                        child: Text('Review'),
                        onPressed: () {
                          Navigator.of(context).pop();
                          _showDialogPayment();
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

  Widget generalTab() {
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
              decoration: AppTheme.inputFirstnameDecoration,
              controller: _firstNameController,
              onChanged: (text) {},
            ),
          ),
          Container(
            padding: EdgeInsets.all(0),
            margin: EdgeInsets.all(0),
            child: TextField(
              showCursor: true,
              decoration: AppTheme.inputLastnameDecoration,
              controller: _lastNameController,
              onChanged: (text) {},
            ),
          ),
          /*
          Container(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(width: 1.0, color: Colors.grey),
                ),
                //borderRadius: BorderRadius.circular(4),
                color: Color.fromARGB(30, 255, 255, 255),
              ),
              padding: EdgeInsets.all(0.0),
              margin: EdgeInsets.only(top: 10.0),
              child: InkWell(
                child: Row(
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.only(left: 10.0, bottom: 15.0),
                      child: Icon(
                        Icons.location_city,
                        color: Color(0XFF365418),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.only(left: 10.0, bottom: 10.0),
                        child: Text(_displayBirthday),
                      ),
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
                      maxTime: DateTime(
                          int.parse(formatDate(DateTime.now(), [yyyy])),
                          int.parse(formatDate(DateTime.now(), [mm])),
                          int.parse(formatDate(DateTime.now(), [dd]))),
                      onChanged: (date) {
                    //print('change $date');
                  }, onConfirm: (date) {
                    setState(() {
                      birthday = date.day.toString() +
                          "/" +
                          date.month.toString() +
                          "/" +
                          date.year.toString();
                      _displayBirthday = date.year.toString() +
                          "/" +
                          date.month.toString() +
                          "/" +
                          date.day.toString();
                    });
                  },
                      currentTime: DateTime(int.parse(birthdateL[0]),
                          int.parse(birthdateL[1]), int.parse(birthdateL[2])),
                      locale: LocaleType.en);
                },
              )),*/
          Container(padding: EdgeInsets.only(top: 10.0)),
        ],
      ),
    );
  }

  Widget contactTab() {
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
              decoration: AppTheme.inputPhoneDecoration,
              controller: _phoneController,
              onChanged: (text) {},
            ),
          ),
          Container(
            padding: EdgeInsets.all(0),
            margin: EdgeInsets.all(0),
            child: TextField(
              showCursor: true,
              decoration: AppTheme.inputAddressDecoration,
              controller: _addressController,
              onChanged: (text) {},
            ),
          ),
          Container(
            padding: EdgeInsets.all(0),
            margin: EdgeInsets.all(0),
            child: TextField(
              showCursor: true,
              decoration: AppTheme.inputAddress2Decoration,
              controller: _address2Controller,
              onChanged: (text) {},
            ),
          ),
          Container(
            padding: EdgeInsets.all(0),
            margin: EdgeInsets.all(0),
            child: TextField(
              showCursor: true,
              decoration: AppTheme.inputCityDecoration,
              controller: _cityController,
              onChanged: (text) {},
            ),
          ),
          Container(
            padding: EdgeInsets.all(0),
            margin: EdgeInsets.all(0),
            child: TextField(
              showCursor: true,
              decoration: AppTheme.inputZipcodeDecoration,
              controller: _zipcodeController,
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
            padding: EdgeInsets.all(0),
            margin: EdgeInsets.only(top: 10.0),
            child: InkWell(
              child: Row(
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.only(left: 10.0, bottom: 15.0),
                    child: Icon(
                      Icons.location_city,
                      color: Color(0XFF365418),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.only(left: 10.0, bottom: 10.0),
                      child: Text("$_displayState"),
                    ),
                  ),
                  Container(
                    child: Icon(Icons.keyboard_arrow_down),
                  )
                ],
              ),
              onTap: () {
                _showState();
              },
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
                          lang.accountGeneral,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: Colors.black87),
                        ),
                      )
                    : Container(
                        padding: EdgeInsets.only(
                            top: 7.0, left: 5.0, bottom: 7.0, right: 5.0),
                        margin: EdgeInsets.only(left: 5.0, right: 5.0),
                        child: Text(
                          lang.accountGeneral,
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
                          lang.contactInfo,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: Colors.black87),
                        ),
                      )
                    : Container(
                        padding: EdgeInsets.only(
                            top: 5.0, left: 5, bottom: 5, right: 5),
                        margin: EdgeInsets.only(left: 5, right: 5),
                        child: Text(
                          lang.contactInfo,
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

  Widget actionBar() {
    return FittedBox(
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFFFFFFF),
          border: Border.all(
            color: Colors.black54,
            width: 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: EdgeInsets.all(10.0),
        margin: EdgeInsets.only(bottom: 20.0),
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
              Text("Save"),
            ],
          ),
          onTap: () {
            doUpdateAcount();
          },
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
}
