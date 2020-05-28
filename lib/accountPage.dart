import 'dart:convert' as convert;
import 'dart:convert';
import 'dart:io';

import 'package:barcode/barcode.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_money_formatter/flutter_money_formatter.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_web_browser/flutter_web_browser.dart';
import 'package:http/http.dart' as http;
import 'package:masked_text_input_formatter/masked_text_input_formatter.dart';
import 'package:ocha/ShoppingCartPage.dart';
import 'package:ocha/StoresPage.dart';
import 'package:ocha/changeAccountPage.dart';
import 'package:ocha/giftPage.dart';
import 'package:ocha/homePage.dart';
import 'package:ocha/loginPage.dart';
import 'package:ocha/model/AppTheme.dart';
import 'package:ocha/model/Define.dart';
import 'package:ocha/model/global_var.dart' as global_var;
import 'package:ocha/model/lang.dart' as lang;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_credit_card/flutter_credit_card.dart';

//final _paymentNumber = TextEditingController();
//final _paymentCardNumber = TextEditingController();
//final _paymentExpYear = TextEditingController();
//final _paymentExpMonth = TextEditingController();
//final _paymentCardCode = TextEditingController();
//final _paymentFisrtName = TextEditingController();
//final _paymentLastName = TextEditingController();
//final _paymentFullName = TextEditingController();
FlutterMoneyFormatter fmf = FlutterMoneyFormatter(amount: 12345678.9012345);
MoneyFormatterOutput fo = fmf.output;
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
class AccountPage extends StatefulWidget {
  const AccountPage({Key key}) : super(key: key);

  @override
  _AccountPageState createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> with TickerProviderStateMixin {
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
  String amountadd = "0";
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
  String barCodePath = "";
  String barcodeString = "";

  final _paymentCardNumber = TextEditingController();
  final _paymentExpYear = TextEditingController();
  final _paymentExpMonth = TextEditingController();
  final _paymentCardCode = TextEditingController();
  final _paymentFirstName = TextEditingController();
  final _paymentLastName = TextEditingController();
  final _paymentFullName = TextEditingController();
  final _paymentAddress = TextEditingController();
  final _paymentZipcode = TextEditingController();
  final _paymentCity = TextEditingController();
  final _paymentState = TextEditingController();

  @override
  void initState() {
    localInfo();
    appInfo();
    super.initState();
    getDetail();
    _firebaseMessaging.requestNotificationPermissions();
    firebaseFCMtoken = _register();
    _firebaseMessaging.subscribeToTopic("ChauLong");
    getMessage();
  }

  _register() {
    _firebaseMessaging.getToken().then((token) {
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

  void buildBarcode(
    Barcode bc,
    String data, {
    String filename,
    double width,
    double height,
  }) {
    // Create the Barcode
    final svg = bc.toSvg(data, width: width ?? 1000, height: height ?? 40);
    writeContent(svg);
  }

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    // For your reference print the AppDoc directory
    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/userBarcodep_ean13_' + barcodeString + global_var.userID + '.svg');
  }

  Future<File> writeContent(String data) async {
    final file = await _localFile;
    setState(() {
      barCodePath = file.path;
    });

    print(barCodePath);
    // Write the file
    return file.writeAsString(data);
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
    return Container(
        decoration: new BoxDecoration(
          image: new DecorationImage(
            image: new NetworkImage(backgroundImage),
            fit: BoxFit.fill,
          ),
        ),
        child: Scaffold(
          backgroundColor: Color.fromRGBO(0, 0, 0, 0.2),
          appBar: AppBar(
            title: Text(lang.account),
            backgroundColor: Color(0XFF2d561e),
            centerTitle: true,
            actions: <Widget>[
              // action button
              IconButton(
                icon: Icon(Icons.home),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => HomePage()));
                },
              ),
            ],
          ),
          body: Column(children: <Widget>[
            tabBar(),
            tabIndex == 0 ? Expanded(child: generalTab()) : Container(),
            tabIndex == 1 ? Expanded(child: contactTab()) : Container(),
            tabIndex == 2 ? Expanded(child: billingTab()) : Container(),
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
        ));
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    if (index == 0) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => HomePage()));
    } else if (index == 1) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => ShoppingCartPage(0)));
    } else if (index == 2) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => GiftPage()));
    } else if (index == 3) {
      Navigator.push(context, MaterialPageRoute(builder: (context) => StoresPage()));
    }
  }

  openBrowserTab() async {
    await FlutterWebBrowser.openWebPage(url: global_var.domain + "checkout/?id=" + uid + "&total_amount=" + amountadd, androidToolbarColor: Colors.deepPurple);
  }

  void sendInfoToPayment() async {
    if (_paymentFirstName.text == "" || _paymentFirstName.text == null) {
      _showInfo2("Please input firstname", 51);
    } else if (_paymentLastName.text == "" || _paymentLastName.text == null) {
      _showInfo2("Please input lastname", 51);
    } else if (_paymentAddress.text == "" || _paymentAddress.text == null) {
      _showInfo2("Please input address", 51);
    } else if (_paymentCity.text == "" || _paymentCity.text == null) {
      _showInfo2("Please input city", 51);
    } else if (_paymentState.text == "" || _paymentState.text == null) {
      _showInfo2("Please input stage", 51);
    } else if (_paymentZipcode.text == "" || _paymentZipcode.text == null) {
      _showInfo2("Please input zipcode", 51);
    } else {
      _processingDialog();
      //https://apitest.authorize.net/xml/v1/request.api
      String url = global_var.domain + '?ss_module=payment&option=AuthorizeNet&safeCode=' + global_var.safeCode + '&amount=' + amountadd;
      print(url);
      final http.Response response = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          "amount": amountadd,
          "safeCode": global_var.safeCode,
          "jsonContent": {
            "createTransactionRequest": {
              "merchantAuthentication": {"name": global_var.authorizeID, "transactionKey": global_var.authorizeKEY},
              "refId": global_var.userID,
              "transactionRequest": {
                "transactionType": "authCaptureTransaction",
                "amount": amountadd,
                "currencyCode": "USD",
                "payment": {
                  "creditCard": {"cardNumber": paymentCardNumber, "expirationDate": paymentExpYear + "-" + paymentExpMonth, "cardCode": paymentCardCode}
                },
                "lineItems": {
                  "lineItem": {"itemId": "1", "name": "Top up", "description": "Top up to user acount at Ocha", "quantity": "1", "unitPrice": amountadd}
                },
                "billTo": {
                  "firstName": _paymentFirstName.text,
                  "lastName": _paymentLastName.text,
                  "address": _paymentAddress.text,
                  "city": _paymentCity.text,
                  "state": _paymentState.text,
                  "zip": _paymentZipcode.text,
                  "country": "USA"
                }
              }
            }
          }
        }),
      );
      if (response.statusCode == 200) {
        Navigator.of(context).pop();
        var results = json.decode(response.body);
        print(results);
        if (results['result'] == "OK") {
          _showInfo2("Deposit successful. Current balance is:" + results['amount'].toString(), 5);
          setState(() {
            amountTxt = results['amount'].toString();
            _paymentFullName.text = "";
            _paymentExpMonth.text = "";
            _paymentExpYear.text = "";
            _paymentCardCode.text = "";
            _paymentCardNumber.text = "";
            amountadd = "0";
          });
        } else if (results['result'] == "user") {
          _showInfo2("The account is not logged in or the login session has expired. Please log in again", 5);
        } else {
          _showInfo2(results['result'], 50);
        }
        /*
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
        }*/
      } else {
        Navigator.of(context).pop();
        // If the server did not return a 201 CREATED response,
        // then throw an exception.
        _showInfo2(lang.networkError, 0);
      }
    }
  }

  Future<void> popupAmountList() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10.0))),
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
                        borderRadius: BorderRadius.all(Radius.circular(5.0) //         <--- border radius here
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10.0))),
          contentPadding: EdgeInsets.all(20.0),
          titlePadding: EdgeInsets.only(top: 20.0, left: 20.0),
          title: Text('Card infomation:'),
          content: Scrollbar(
            child: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.all(3.0),
                    margin: EdgeInsets.only(top: 10.0),
                    decoration: BoxDecoration(
                      border: Border(
                          bottom: BorderSide(
                        color: Color(0xFF444444),
                        width: 1.0,
                      )),
                    ),
                    child: Text(
                      "Card infomation:",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(left: 0, right: 0, top: 5.0, bottom: 10.0),
                    child: TextField(
                      showCursor: true,
                      decoration: AppTheme.inputCardNameDecoration,
                      controller: _paymentFullName,
                      onChanged: (text) {
                        paymentFullName = _paymentFullName.text;
                      },
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(left: 0, right: 0, top: 5.0, bottom: 10.0),
                    child: TextField(
                      inputFormatters: [
                        MaskedTextInputFormatter(
                          mask: 'xxxx xxxx xxxx xxxx',
                          separator: ' ',
                        ),
                      ],
                      showCursor: true,
                      decoration: AppTheme.inputCardNumberDecoration,
                      controller: _paymentCardNumber,
                      onChanged: (text) {
                        paymentCardNumber = _paymentCardNumber.text.replaceAll(' ', '');
                      },
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(left: 0, right: 0, top: 5.0, bottom: 10.0),
                    child: TextField(
                      showCursor: true,
                      decoration: AppTheme.inputCardCodeDecoration,
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
                      Container(
                        width: 100.0,
                        padding: EdgeInsets.only(left: 0, right: 10.0, top: 5.0, bottom: 10.0),
                        child: TextField(
                          showCursor: true,
                          decoration: AppTheme.inputExpMonthDecoration,
                          controller: _paymentExpMonth,
                          keyboardType: TextInputType.number,
                          onChanged: (text) {
                            paymentExpMonth = _paymentExpMonth.text;
                          },
                        ),
                      ),
                      Container(
                        width: 100.0,
                        padding: EdgeInsets.only(left: 0, right: 0, top: 5.0, bottom: 10.0),
                        child: TextField(
                          showCursor: true,
                          keyboardType: TextInputType.number,
                          decoration: AppTheme.inputExpYearDecoration,
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
                    padding: EdgeInsets.all(10.0),
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
                  Container(
                    padding: EdgeInsets.all(3.0),
                    margin: EdgeInsets.only(top: 10.0),
                    decoration: BoxDecoration(
                      border: Border(
                          bottom: BorderSide(
                        color: Color(0xFF444444),
                        width: 1.0,
                      )),
                    ),
                    child: Text(
                      "Billing address:",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(3.0),
                    margin: EdgeInsets.all(0),
                    child: TextField(
                      showCursor: true,
                      decoration: AppTheme.inputFirstnameDecoration,
                      controller: _paymentFirstName,
                      onChanged: (text) {},
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(3.0),
                    margin: EdgeInsets.all(0),
                    child: TextField(
                      showCursor: true,
                      decoration: AppTheme.inputLastnameDecoration,
                      controller: _paymentLastName,
                      onChanged: (text) {},
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(3.0),
                    margin: EdgeInsets.all(0),
                    child: TextField(
                      showCursor: true,
                      decoration: AppTheme.inputAddressDecoration,
                      controller: _paymentAddress,
                      onChanged: (text) {},
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(3.0),
                    margin: EdgeInsets.all(0),
                    child: TextField(
                      showCursor: true,
                      decoration: AppTheme.inputCityDecoration,
                      controller: _paymentCity,
                      onChanged: (text) {},
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(3.0),
                    margin: EdgeInsets.all(0),
                    child: TextField(
                      showCursor: true,
                      decoration: AppTheme.inputStateDecoration,
                      controller: _paymentState,
                      onChanged: (text) {},
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(3.0),
                    margin: EdgeInsets.all(0),
                    child: TextField(
                      showCursor: true,
                      decoration: AppTheme.inputZipcodeDecoration,
                      controller: _paymentZipcode,
                      onChanged: (text) {},
                    ),
                  )
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
                if (double.parse(amountadd) <= 0) {
                  _showInfo2("Please enter the correct amount number", 50);
                } else if (paymentCardNumber == "" || paymentCardNumber == null) {
                  _showInfo2("Please enter the correct card number", 50);
                } else if (paymentCardCode == "" || paymentCardCode == null) {
                  _showInfo2("Please enter the correct CVN number", 50);
                } else if (paymentExpYear == "" || paymentExpYear == null) {
                  _showInfo2("Please enter the correct Exp.Year", 50);
                } else if (paymentExpMonth == "" || paymentExpMonth == null) {
                  _showInfo2("Please enter the correct Exp.Month", 50);
                } else {
                  sendInfoToPayment();
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showDialogBillingAddress() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10.0))),
          contentPadding: EdgeInsets.all(20.0),
          titlePadding: EdgeInsets.only(top: 20.0, left: 20.0),
          title: Text('Billing address'),
          content: Scrollbar(
            child: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.all(3.0),
                    margin: EdgeInsets.all(0),
                    child: TextField(
                      showCursor: true,
                      decoration: AppTheme.inputFirstnameDecoration,
                      controller: _paymentFirstName,
                      onChanged: (text) {},
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(3.0),
                    margin: EdgeInsets.all(0),
                    child: TextField(
                      showCursor: true,
                      decoration: AppTheme.inputLastnameDecoration,
                      controller: _paymentLastName,
                      onChanged: (text) {},
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(3.0),
                    margin: EdgeInsets.all(0),
                    child: TextField(
                      showCursor: true,
                      decoration: AppTheme.inputAddressDecoration,
                      controller: _paymentAddress,
                      onChanged: (text) {},
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(3.0),
                    margin: EdgeInsets.all(0),
                    child: TextField(
                      showCursor: true,
                      decoration: AppTheme.inputCityDecoration,
                      controller: _paymentCity,
                      onChanged: (text) {},
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(3.0),
                    margin: EdgeInsets.all(0),
                    child: TextField(
                      showCursor: true,
                      decoration: AppTheme.inputStateDecoration,
                      controller: _paymentState,
                      onChanged: (text) {},
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(3.0),
                    margin: EdgeInsets.all(0),
                    child: TextField(
                      showCursor: true,
                      decoration: AppTheme.inputZipcodeDecoration,
                      controller: _paymentZipcode,
                      onChanged: (text) {},
                    ),
                  )
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
    String url = global_var.domain + "?ss_module=mobile&option=account&safeCode=" + global_var.safeCode;
    final response = await http.get(Uri.parse(url));
    print(url);
    if (response.statusCode == 200) {
      try {
        var jsonResponse = convert.jsonDecode(response.body);
        setState(() {
          username = jsonResponse['username'];
          uid = jsonResponse['id'].toString();
          global_var.userID = uid;
          firstName = jsonResponse['firstname'];
          _paymentFirstName.text = firstName;
          lastName = jsonResponse['lastname'];
          _paymentLastName.text = lastName;
          email = jsonResponse['email'];
          phone = jsonResponse['phone'];
          address = jsonResponse['address'];
          _paymentAddress.text = address;
          address2 = jsonResponse['address2'];
          city = jsonResponse['city'];
          _paymentCity.text = city;
          zipcode = jsonResponse['zipcode'];
          _paymentZipcode.text = zipcode;
          birthday = jsonResponse['birthday'];
          state = jsonResponse['district'];
          _paymentState.text = state;
          country = jsonResponse['province'];
          barcodeString = jsonResponse['qrcode'];
          amountTxt = double.parse(jsonResponse['amount']).toString();
          List tmp = jsonResponse['topupList'].split("|");
          topupValueList = [];
          for (var i = 0; i < tmp.length; i++) {
            List<TopupList> topupList = [TopupList(name: tmp[i], selected: i == 0 ? true : false, index: i)];
            topupValueList.add(topupList[0]);
          }
        });
        buildBarcode(Barcode.upcA(), barcodeString, height: 120, width: 300);
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
    if (global_var.safeCode == null || global_var.safeCode == "" || global_var.userID == "0") {
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
            child: Text("$content"),
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
                    : action == 51
                        ? FlatButton(
                            child: Text('Review'),
                            onPressed: () {
                              Navigator.of(context).pop();
                              _showDialogBillingAddress();
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
          /*
          Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Colors.black12,
                  width: 1.0,
                ),
              ),
            ),
            padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
            child: InkWell(
              child: Row(
                children: <Widget>[
                  Icon(Icons.card_membership, size: 13, color: Colors.black45),
                  Expanded(
                    child: Text(lang.idText),
                  ),
                  Container(
                    child: Text(
                      " $uid",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0XFF2c3e09),
                        fontSize: 13,
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
          */
          Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Colors.black12,
                  width: 1.0,
                ),
              ),
            ),
            padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
            child: InkWell(
              child: Row(
                children: <Widget>[
                  //Icon(Icons.account_box, size: 13, color: Colors.black45),
                  Expanded(
                    child: Text(lang.firstName),
                  ),
                  Container(
                    child: Text(
                      " $firstName",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0XFF2c3e09),
                        fontSize: 13,
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Colors.black12,
                  width: 1.0,
                ),
              ),
            ),
            padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
            child: InkWell(
              child: Row(
                children: <Widget>[
                  //Icon(Icons.account_box, size: 13, color: Colors.black45),
                  Expanded(
                    child: Text(lang.lastName),
                  ),
                  Container(
                    child: Text(
                      " $lastName",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0XFF2c3e09),
                        fontSize: 13,
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Colors.black12,
                  width: 1.0,
                ),
              ),
            ),
            padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
            child: InkWell(
              child: Row(
                children: <Widget>[
                  //Icon(Icons.today, size: 13, color: Colors.black45),
                  Expanded(
                    child: Text(lang.birthday),
                  ),
                  Container(
                    child: Text(
                      " $birthday",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0XFF2c3e09),
                        fontSize: 13,
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
          Container(padding: EdgeInsets.only(top: 10.0)),
          SvgPicture.file(File(barCodePath),
              //width: MediaQuery.of(context).size.width * 0.5,
              height: 120.0),
          /*
          Center(
            child: Container(
              padding: EdgeInsets.only(top: 0.0),
              child: Text(
                "$barcodeString",
                style: TextStyle(
                  fontWeight: FontWeight.normal,
                  color: Color(0XFF2c3e09),
                  fontSize: 18,
                ),
              ),
            ),
          )*/
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
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Colors.black12,
                  width: 1.0,
                ),
              ),
            ),
            padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
            child: InkWell(
              child: Row(
                children: <Widget>[
                  //Icon(Icons.email, size: 13, color: Colors.black45),
                  Expanded(
                    child: Text(lang.email),
                  ),
                  Container(
                    child: Text(
                      " $email",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0XFF2c3e09),
                        fontSize: 13,
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Colors.black12,
                  width: 1.0,
                ),
              ),
            ),
            padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
            child: InkWell(
              child: Row(
                children: <Widget>[
                  //Icon(Icons.stay_current_portrait, size: 13, color: Colors.black45),
                  Expanded(
                    child: Text(lang.phone),
                  ),
                  Container(
                    child: Text(
                      " $phone",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0XFF2c3e09),
                        fontSize: 13,
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Colors.black12,
                  width: 1.0,
                ),
              ),
            ),
            padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
            child: InkWell(
              child: Row(
                children: <Widget>[
                  //Icon(Icons.place, size: 13, color: Colors.black45),
                  Expanded(
                    child: Text(lang.address),
                  ),
                  Container(
                    child: Text(
                      " $address",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0XFF2c3e09),
                        fontSize: 13,
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Colors.black12,
                  width: 1.0,
                ),
              ),
            ),
            padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
            child: InkWell(
              child: Row(
                children: <Widget>[
                  //Icon(Icons.place, size: 13, color: Colors.black45),
                  Expanded(
                    child: Text(lang.address2),
                  ),
                  Container(
                    child: Text(
                      " $address2",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0XFF2c3e09),
                        fontSize: 13,
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Colors.black12,
                  width: 1.0,
                ),
              ),
            ),
            padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
            child: InkWell(
              child: Row(
                children: <Widget>[
                  //Icon(Icons.location_city, size: 13, color: Colors.black45),
                  Expanded(
                    child: Text(lang.city),
                  ),
                  Container(
                    child: Text(
                      " $city",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0XFF2c3e09),
                        fontSize: 13,
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Colors.black12,
                  width: 1.0,
                ),
              ),
            ),
            padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
            child: InkWell(
              child: Row(
                children: <Widget>[
                  //Icon(Icons.contact_mail, size: 13, color: Colors.black45),
                  Expanded(
                    child: Text(lang.zipcode),
                  ),
                  Container(
                    child: Text(
                      " $zipcode",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0XFF2c3e09),
                        fontSize: 13,
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Colors.black12,
                  width: 1.0,
                ),
              ),
            ),
            padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
            child: InkWell(
              child: Row(
                children: <Widget>[
                  //Icon(Icons.location_city, size: 13, color: Colors.black45),
                  Expanded(
                    child: Text(lang.state),
                  ),
                  Container(
                    child: Text(
                      " $state",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0XFF2c3e09),
                        fontSize: 13,
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget billingTab() {
    return Container(
      margin: EdgeInsets.only(top: 0.0, bottom: 20.0, left: 10.0, right: 10.0),
      padding: EdgeInsets.all(0),
      color: Colors.white,
      child: ListView(
        padding: EdgeInsets.all(20.0),
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: Colors.black12,
                  width: 1.0,
                ),
              ),
            ),
            padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
            margin: EdgeInsets.only(bottom: 30.0),
            child: InkWell(
              child: Row(
                children: <Widget>[
                  //Icon(Icons.attach_money, size: 13, color: Colors.black45),
                  Expanded(
                    child: Text(lang.amount),
                  ),
                  Container(
                    child: Text(
                      fmf.copyWith(amount: double.parse(amountTxt)).output.symbolOnLeft,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0XFF2c3e09),
                        fontSize: 13,
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
          RaisedButton(
            onPressed: () {
              _showDialogPayment();
            },
            textColor: Color(0XFF365418),
            padding: const EdgeInsets.all(0.0),
            child: const Text('Recharge account', style: TextStyle(fontSize: 20)),
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
                        padding: EdgeInsets.only(top: 7.0, left: 5.0, bottom: 7.0, right: 5.0),
                        margin: EdgeInsets.only(left: 5.0, right: 5.0),
                        child: Text(
                          lang.accountGeneral,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: Colors.black87),
                        ),
                      )
                    : Container(
                        padding: EdgeInsets.only(top: 7.0, left: 5.0, bottom: 7.0, right: 5.0),
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
                        padding: EdgeInsets.only(top: 7.0, left: 5.0, bottom: 7.0, right: 5.0),
                        margin: EdgeInsets.only(left: 5.0, right: 5.0),
                        child: Text(
                          lang.contactInfo,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: Colors.black87),
                        ),
                      )
                    : Container(
                        padding: EdgeInsets.only(top: 5.0, left: 5, bottom: 5, right: 5),
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
          Container(
            child: Center(
              child: InkWell(
                child: tabIndex == 2
                    ? Container(
                        color: Color.fromRGBO(255, 255, 255, 0.5),
                        padding: EdgeInsets.only(top: 7.0, left: 5.0, bottom: 7.0, right: 5.0),
                        margin: EdgeInsets.only(left: 5.0, right: 5.0),
                        child: Text(
                          lang.billingInfo,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: Colors.black87),
                        ),
                      )
                    : Container(
                        padding: EdgeInsets.only(top: 7.0, left: 5.0, bottom: 7.0, right: 5.0),
                        margin: EdgeInsets.only(left: 5.0, right: 5.0),
                        child: Text(
                          lang.billingInfo,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                onTap: () {
                  setState(
                    () {
                      tabIndex = 2;
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
    return Container(
      padding: EdgeInsets.only(top: 0.0, left: 5.0, right: 5.0, bottom: 5.0),
      margin: EdgeInsets.only(bottom: 10.0, left: 5.0),
      child: Row(
        children: <Widget>[
          Container(
            child: InkWell(
              child: Container(
                padding: EdgeInsets.only(top: 5.0, left: 5.0, bottom: 5.0, right: 5.0),
                margin: EdgeInsets.only(right: 5.0),
                child: Icon(
                  Icons.edit,
                  color: Colors.black54,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFFFF),
                  border: Border.all(
                    color: Colors.black54,
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onTap: () {
                setState(
                  () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => ChangeAccountPage()));
                  },
                );
              },
            ),
          ),
          Container(
            child: InkWell(
              child: Container(
                padding: EdgeInsets.only(top: 5.0, left: 5.0, bottom: 5.0, right: 5.0),
                margin: EdgeInsets.only(right: 5.0),
                child: Icon(
                  Icons.sync,
                  color: Colors.black54,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFFFF),
                  border: Border.all(
                    color: Colors.black54,
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onTap: () {
                setState(
                  () {
                    getDetail();
                  },
                );
              },
            ),
          ),
          /*
          Container(
            child: InkWell(
              child: Container(
                padding: EdgeInsets.only(
                    top: 5.0, left: 5.0, bottom: 5.0, right: 5.0),
                margin: EdgeInsets.only(right: 5.0),
                child: Icon(
                  Icons.remove_shopping_cart,
                  color: Colors.black54,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFFFF),
                  border: Border.all(
                    color: Colors.black54,
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onTap: () {
                setState(
                  () {
                    clearCart();
                  },
                );
              },
            ),
          ),*/
          Container(
            child: InkWell(
              child: Container(
                padding: EdgeInsets.only(top: 5.0, left: 5.0, bottom: 5.0, right: 5.0),
                margin: EdgeInsets.only(right: 5.0),
                child: Icon(
                  Icons.exit_to_app,
                  color: Colors.black54,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFFFF),
                  border: Border.all(
                    color: Colors.black54,
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onTap: () {
                setState(
                  () {
                    logOut();
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _processingDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: EdgeInsets.all(5.0),
          titlePadding: EdgeInsets.only(top: 10.0, left: 5.0),
          content: Container(
            height: 100.0,
            padding: EdgeInsets.all(0),
            child: Align(
              alignment: Alignment.center,
              child: Text(
                "Processing, please wait...",
                style: TextStyle(
                  fontWeight: FontWeight.normal,
                  color: Color(0xFF444444),
                  fontSize: 20.0,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
