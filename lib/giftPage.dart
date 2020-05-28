import 'dart:convert' as convert;
import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_credit_card/flutter_credit_card.dart';
import 'package:flutter_money_formatter/flutter_money_formatter.dart';
import 'package:http/http.dart' as http;
import 'package:masked_text_input_formatter/masked_text_input_formatter.dart';
import 'package:ocha/ShoppingCartPage.dart';
import 'package:ocha/StoresPage.dart';
import 'package:ocha/homePage.dart';
import 'package:ocha/loginPage.dart';
import 'package:ocha/model/AppTheme.dart';
import 'package:ocha/model/Define.dart';
import 'package:ocha/model/global_var.dart' as global_var;
import 'package:ocha/model/lang.dart' as lang;
import 'package:shared_preferences/shared_preferences.dart';

final _authorizeID = "33C6Ckjv";
final _authorizeKEY = "287t68V9TcUTFPrB";

bool multiple = true;
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

class GiftPage extends StatefulWidget {
  GiftPage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _GiftPageState createState() => _GiftPageState();
}

class _GiftPageState extends State<GiftPage> with TickerProviderStateMixin {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  final List<Notification> notifications = [];
  String firebaseFCMtoken = "";
  String _message = "";
  int _selectedIndex = 2;
  List<HomeListHome> homeList = HomeListHome.homeList;
  AnimationController animationController;
  List<ShopList> shopList = [];
  int cartNumber = 0;
  String backgroundImage = "";
  String appName = "";
  final _paymentCardNumber = TextEditingController();
  final _paymentExpYear = TextEditingController();
  final _paymentExpMonth = TextEditingController();
  final _paymentCardName = TextEditingController();
  final _paymentCardCode = TextEditingController();
  final _paymentFirstName = TextEditingController();
  final _paymentLastName = TextEditingController();
  final _paymentEmail = TextEditingController();
  final _paymentAddress = TextEditingController();
  final _paymentZipcode = TextEditingController();
  final _paymentState = TextEditingController();
  final _paymentAmount = TextEditingController();
  final _paymentCity = TextEditingController();
  final _paymentMessage = TextEditingController();
  final _paymentFrom = TextEditingController();
  final _paymentTo = TextEditingController();

  //String _displayState = "--Select State--";
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
  int step = 2;
  String stepString = "Next";
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
  String paymentAddress = "";
  String paymentCity = "";
  String paymentState = "";
  String paymentZipcode = "";
  int tabIndex = 0;
  bool showTopupForm = false;
  String barCodePath = "";
  String barcodeString = "";
  String giftCardLogo = "";
  int countryID = 0;
  int stateID = 0;

  //List<StateList> _stateList = [];
  String _cardHolder = "";
  String _cardNumber = "";
  String _cardCVN = "";
  String _cardEXP = "";
  bool _cardBackView = false;

  @override
  void initState() {
    animationController = AnimationController(duration: const Duration(milliseconds: 2000), vsync: this);
    super.initState();
    appInfo();
    getDetail();
    getStateList();

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
        backgroundColor: Color.fromARGB(200, 255, 255, 255),
        appBar: AppBar(
          title: Text(lang.gift),
          leading: new IconButton(
            icon: new Icon(Icons.keyboard_arrow_left),
            onPressed: () {
              setState(() {
                if (step > 2) {
                  step = step - 1;
                }
                if (step == 4) {
                  stepString = "Confirm";
                } else {
                  stepString = "Next";
                }
              });
            },
          ),
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
        body: ListView(
          padding: EdgeInsets.all(10.0),
          //map List of our data to the ListView
          children: <Widget>[
            step == 2
                ? new Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
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
                          "Choose Amount:",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(3.0),
                        margin: EdgeInsets.all(0),
                        child: TextField(
                          showCursor: true,
                          keyboardType: TextInputType.number,
                          decoration: AppTheme.inputGiftAmountDecoration,
                          controller: _paymentAmount,
                          onChanged: (text) {},
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
                          "Personalize:",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(3.0),
                        margin: EdgeInsets.all(0),
                        child: TextField(
                          showCursor: true,
                          decoration: AppTheme.inputFromDecoration,
                          controller: _paymentFrom,
                          onChanged: (text) {},
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(3.0),
                        margin: EdgeInsets.all(0),
                        child: TextField(
                          showCursor: true,
                          decoration: AppTheme.inputToDecoration,
                          controller: _paymentTo,
                          onChanged: (text) {},
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(3.0),
                        margin: EdgeInsets.all(0),
                        child: TextField(
                          showCursor: true,
                          decoration: AppTheme.inputEmailDecoration,
                          controller: _paymentEmail,
                          onChanged: (text) {},
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(3.0),
                        margin: EdgeInsets.all(0),
                        child: TextField(
                          keyboardType: TextInputType.multiline,
                          minLines: 1,
                          maxLines: 5,
                          showCursor: true,
                          decoration: AppTheme.inputMessageDecoration,
                          controller: _paymentMessage,
                          onChanged: (text) {},
                        ),
                      ),
                    ],
                  )
                : Container(),
            step == 3
                ? new Column(
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.all(5.0),
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                            "${_paymentMessage.text}",
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(20.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(
                            width: 1,
                            color: Color.fromRGBO(0, 0, 0, 0.2),
                          ),
                          borderRadius: BorderRadius.all(
                            Radius.circular(5.0),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.5),
                              spreadRadius: 5,
                              blurRadius: 7,
                              offset: Offset(0, 3), // changes position of shadow
                            ),
                          ],
                        ),
                        child: Column(
                          children: <Widget>[
                            Row(
                              children: <Widget>[
                                Expanded(
                                  child: Container(
                                    margin: EdgeInsets.only(right: 30.0),
                                    child: Image.network(
                                      giftCardLogo,
                                    ),
                                  ),
                                ),
                                Container(
                                    child: Column(
                                  children: <Widget>[
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: Text("Card Balance"),
                                    ),
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: Text(
                                        fmf.copyWith(amount: double.parse(_paymentAmount.text)).output.symbolOnLeft,
                                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
                                      ),
                                    ),
                                  ],
                                )),
                              ],
                            ),
                            Container(
                              padding: EdgeInsets.all(5.0),
                              child: Align(
                                alignment: Alignment.center,
                                child: Text(
                                  global_var.appName,
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20.0),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                : Container(),
            step == 4
                ? new Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      CreditCardWidget(
                        cardNumber: _cardNumber,
                        expiryDate: _cardEXP,
                        cardHolderName: _cardHolder,
                        cvvCode: _cardCVN,
                        showBackView: _cardBackView,
                        //cardbgColor: Colors.black87,
                        height: 175,
                        //textStyle: TextStyle(color: Colors.white),
                        width: MediaQuery.of(context).size.width,
                        animationDuration: Duration(milliseconds: 1000),
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
                          "Card infomation:",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(3.0),
                        margin: EdgeInsets.all(0),
                        child: TextField(
                          showCursor: true,
                          decoration: AppTheme.inputCardNameDecoration,
                          controller: _paymentCardName,
                          onChanged: (text) {
                            setState(() {
                              _cardHolder = text;
                            });
                          },
                          onTap: () {
                            setState(() {
                              _cardBackView = false;
                            });
                          },
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(3.0),
                        margin: EdgeInsets.all(0),
                        child: TextField(
                          inputFormatters: [
                            MaskedTextInputFormatter(
                              mask: 'xxxx xxxx xxxx xxxx',
                              separator: ' ',
                            ),
                          ],
                          keyboardType: TextInputType.number,
                          showCursor: true,
                          decoration: AppTheme.inputCardNumberDecoration,
                          controller: _paymentCardNumber,
                          onChanged: (text) {
                            setState(() {
                              _cardNumber = text;
                            });
                          },
                          onTap: () {
                            setState(() {
                              _cardBackView = false;
                            });
                          },
                        ),
                      ),
                      InkWell(
                        child: Row(
                          children: <Widget>[
                            Container(
                              width: 100.0,
                              padding: EdgeInsets.all(3.0),
                              margin: EdgeInsets.all(0),
                              child: TextField(
                                maxLength: 2,
                                showCursor: true,
                                keyboardType: TextInputType.number,
                                decoration: AppTheme.inputExpMonthDecoration,
                                controller: _paymentExpMonth,
                                onChanged: (text) {
                                  setState(() {
                                    _cardEXP = _paymentExpMonth.text + "/" + _paymentExpYear.text;
                                  });
                                },
                                onTap: () {
                                  setState(() {
                                    _cardBackView = false;
                                  });
                                },
                              ),
                            ),
                            Container(
                              width: 100.0,
                              padding: EdgeInsets.all(3.0),
                              margin: EdgeInsets.all(0),
                              child: TextField(
                                maxLength: 4,
                                showCursor: true,
                                keyboardType: TextInputType.number,
                                decoration: AppTheme.inputExpYearDecoration,
                                controller: _paymentExpYear,
                                onChanged: (text) {
                                  setState(() {
                                    _cardEXP = _paymentExpMonth.text + "/" + _paymentExpYear.text;
                                  });
                                },
                                onTap: () {
                                  setState(() {
                                    _cardBackView = false;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(3.0),
                        margin: EdgeInsets.all(0),
                        child: TextField(
                          showCursor: true,
                          maxLength: 3,
                          keyboardType: TextInputType.number,
                          decoration: AppTheme.inputCardCodeDecoration,
                          controller: _paymentCardCode,
                          onChanged: (text) {
                            setState(() {
                              _cardCVN = text;
                            });
                          },
                          onTap: () {
                            setState(() {
                              _cardBackView = true;
                            });
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
                  )
                : Container(),
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
          selectedItemColor: Colors.amber[800],
          onTap: _onItemTapped,
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            if (step == 4) {
              _processingDialog();
              sendInfoToPayment();
            } else if (step == 2) {
              if (_paymentAmount.text == "") {
                _showInfo2("Please input amount", 1);
              } else if (_paymentTo.text == "") {
                _showInfo2("Please input To", 1);
              } else if (_paymentFrom.text == "") {
                _showInfo2("Please input From", 1);
              } else if (_paymentEmail.text == "") {
                _showInfo2("Please input email", 1);
              } else {
                setState(() {
                  step = step + 1;
                  if (step == 4) {
                    stepString = "Confirm";
                  } else {
                    stepString = "Next";
                  }
                });
              }
            } else {
              setState(() {
                step = step + 1;
              });
              if (step == 4) {
                stepString = "Confirm";
              } else {
                stepString = "Next";
              }
            }
          },
          label: Text("$stepString"),
          icon: Icon(Icons.keyboard_arrow_right),
          backgroundColor: Colors.green,
        ),
      ),
    );
  }

  Future<bool> getData() async {
    await Future<dynamic>.delayed(const Duration(milliseconds: 0));
    return true;
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
        //_stateList = catList2;
      });
    }
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
          _paymentFirstName.text = jsonResponse['firstname'];
          _paymentLastName.text = jsonResponse['lastname'];
          _paymentFrom.text = jsonResponse['firstname'] + " " + jsonResponse['lastname'];
          email = jsonResponse['email'];
          phone = jsonResponse['phone'];
          _paymentAddress.text = jsonResponse['address'];
          address2 = jsonResponse['address2'];
          _paymentCity.text = jsonResponse['city'];
          _paymentZipcode.text = jsonResponse['zipcode'];
          birthday = jsonResponse['birthday'];
          state = jsonResponse['district'];
          _paymentState.text = state;
          //_displayState = state;
          if (state != null) {
            stateID = int.parse(jsonResponse['district_id']);
          }
          country = jsonResponse['province'];
          if (country != null) {
            countryID = int.parse(jsonResponse['province_id']);
          }
          barcodeString = jsonResponse['qrcode'];
          amountTxt = double.parse(jsonResponse['amount']).toString();
          List tmp = jsonResponse['topupList'].split("|");
          topupValueList = [];
          for (var i = 0; i < tmp.length; i++) {
            List<TopupList> topupList = [TopupList(name: tmp[i], selected: i == 0 ? true : false, index: i)];
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
                : Container(),
            FlatButton(
              child: Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
                if (action == 200) {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => GiftPage()));
                } else if (action == 101) {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => LoginPage()));
                }
              },
            ),
          ],
        );
      },
    );
  }

  void sendInfoToPayment() async {
    amountadd = _paymentAmount.text;
    paymentCardNumber = _paymentCardNumber.text.replaceAll(' ', '');
    paymentCardCode = _paymentCardCode.text;
    paymentExpYear = _paymentExpYear.text;
    paymentExpMonth = _paymentExpMonth.text;
    paymentFisrtName = _paymentFirstName.text;
    paymentLastName = _paymentLastName.text;
    paymentCity = _paymentCity.text;
    paymentAddress = _paymentAddress.text;
    paymentZipcode = _paymentZipcode.text;
    if (double.parse(amountadd) > 0 &&
        paymentCardNumber != "" &&
        paymentCardNumber != null &&
        paymentCardCode != "" &&
        paymentCardCode != null &&
        paymentExpYear != "" &&
        paymentExpYear != null &&
        paymentExpMonth != "" &&
        paymentExpMonth != null) {
      //String url = 'https://apitest.authorize.net/xml/v1/request.api';
      String url = global_var.domain + '?ss_module=mobile&option=gift&safeCode=' + global_var.safeCode + '&email=' + _paymentEmail.text;
      final http.Response response = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          "to": _paymentTo.text,
          "from": _paymentFrom.text,
          "email": _paymentEmail.text,
          "firstName": paymentFisrtName,
          "lastName": paymentLastName,
          "amount": amountadd,
          "message": _paymentMessage.text,
          "jsonContent": {
            "createTransactionRequest": {
              "merchantAuthentication": {"name": _authorizeID, "transactionKey": _authorizeKEY},
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
                  "firstName": paymentFisrtName,
                  "lastName": paymentLastName,
                  "address": paymentAddress,
                  "city": paymentCity,
                  "state": _paymentState.text,
                  "zip": paymentZipcode,
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
        if (results["result"] == "OK") {
          _showInfo2(lang.giftSuccess, 200);
          setState(() {
            step = 2;
          });
        } else {
          _showInfo2(results["result"], 0);
        }
      } else {
        // If the server did not return a 201 CREATED response,
        // then throw an exception.
        _showInfo2(lang.networkError, 0);
      }
    } else {
      Navigator.of(context).pop();
      _showInfo2("Please enter full information", 50);
    }
  }

  void appInfo() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    global_var.appName = prefs.getString("appName");
    global_var.backgroundImage = prefs.getString("backgroundImage");
    global_var.giftCardLogo = prefs.getString("giftCardLogo");
    setState(() {
      appName = global_var.appName;
      backgroundImage = global_var.backgroundImage;
      giftCardLogo = global_var.giftCardLogo;
    });
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

/*
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
*/
  Future<void> _processingDialog() async {
    print(countryID);
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
      _showInfo2("You must be logged in to use this function", 101);
    } else {}
  }
}
