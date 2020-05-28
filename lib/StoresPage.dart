import 'dart:convert' as convert;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ocha/homePage.dart';
import 'package:ocha/ShoppingCartPage.dart';
import 'package:ocha/model/global_var.dart' as global_var;
import 'package:ocha/model/lang.dart' as lang;
import 'package:ocha/model/Define.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:ocha/giftPage.dart';

bool multiple = true;
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

class StoresPage extends StatefulWidget {
  StoresPage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _StoresPageState createState() => _StoresPageState();
}

class _StoresPageState extends State<StoresPage> with TickerProviderStateMixin {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  final List<Notification> notifications = [];
  String firebaseFCMtoken = "";
  String _message = '';

  int _selectedIndex = 3;
  List<HomeListHome> homeList = HomeListHome.homeList;
  AnimationController animationController;
  List<ShopList> shopList = [];
  int cartNumber = 0;
  String backgroundImage = "";
  String appName = "";

  @override
  void initState() {
    animationController = AnimationController(
        duration: const Duration(milliseconds: 2000), vsync: this);
    super.initState();
    getShopList();
    appInfo();
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

  Future<bool> getData() async {
    await Future<dynamic>.delayed(const Duration(milliseconds: 0));
    return true;
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

  void getShopList() async {
    String url = global_var.domain + "?ss_module=mobile&option=shopList";
    print(url);
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      var jsonResponse = convert.jsonDecode(response.body);
      List<ShopList> shopList2 = [];
      for (var i = 0; i < jsonResponse.length; i++) {
        List<ShopList> shopList3 = [
          ShopList(
              id: int.tryParse(jsonResponse[i]['f_id']),
              name: jsonResponse[i]['f_name'],
              address: jsonResponse[i]['f_address'],
              phone: jsonResponse[i]['f_phone'])
        ];
        shopList2.add(shopList3[0]);
      }
      setState(() {
        shopList = shopList2;
      });

    }
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
            title: Row(
              mainAxisAlignment: MainAxisAlignment.center, // centers horizontally
              crossAxisAlignment: CrossAxisAlignment.center, // centers vertically
              children: <Widget>[
                Image.asset("assets/icons/ochalogo.png"),
              ],
            ),
            backgroundColor: Color(0XFF2d561e),
            centerTitle: true,

          ),
          body: ListView(
            padding: EdgeInsets.all(10.0),
            //map List of our data to the ListView
            children: shopList.map((data) {
              return Container(
                margin: EdgeInsets.all(10.0),
                padding: EdgeInsets.all(20.0),
                color: Color.fromARGB(200, 255, 255, 255),
                child: InkWell(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
                        child: Text(
                          "${data.name}",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Color(0XFF2c3e09),
                            fontSize: 18,
                          ),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              //                    <--- top side
                              color: Colors.black12,
                              width: 1.0,
                            ),
                          ),
                        ),
                        padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
                        child: InkWell(
                          child: Row(
                            children: <Widget>[
                              Expanded(
                                child: Text("Address:"),
                              ),
                              Container(
                                child: Text(
                                  "${data.address}",
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
                              //                    <--- top side
                              color: Colors.black12,
                              width: 1.0,
                            ),
                          ),
                        ),
                        padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
                        child: InkWell(
                          child: Row(
                            children: <Widget>[
                              Expanded(
                                child: Text("Phone:"),
                              ),
                              Container(
                                child: Text(
                                  "${data.phone}",
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
                ),
              );
            }).toList(),
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
        ));
  }
}

