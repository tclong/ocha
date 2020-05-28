import 'dart:convert' as convert;

import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:http/http.dart' as http;
import 'package:ocha/ShoppingCartPage.dart';
import 'package:ocha/StoresPage.dart';
import 'package:ocha/accountPage.dart';
import 'package:ocha/giftPage.dart';
import 'package:ocha/model/AppTheme.dart';
import 'package:ocha/model/Define.dart';
import 'package:ocha/model/global_var.dart' as global_var;
import 'package:ocha/model/lang.dart' as lang;
import 'package:shared_preferences/shared_preferences.dart';

bool multiple = true;

double _contentHeight1 = 90;
double _contentHeight2 = 135;

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

class HomePage extends StatefulWidget {
  HomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  final List<Notification> notifications = [];

  String firebaseFCMtoken = "";
  String _message = '';

  int _selectedIndex = 0;
  String backgroundImage = "";
  String appName = "";

  //double _containerHeight = 0;
  List<HomeListHome> homeList0 = HomeListHome.homeList;
  List<HomeListHome> homeList1 = HomeListHome.homeList;
  List<HomeListHome> homeList2 = HomeListHome.homeList;
  List<HomeListHome> homeList3 = HomeListHome.homeList;
  AnimationController animationController;
  List<String> imgList0 = [];
  List<String> imgList1 = [];
  List<String> imgList2 = [];
  List<String> imgList3 = [];
  List<int> productNumber = [0, 0, 0, 0];
  List<int> articleNumber = [0, 0, 0, 0];
  List<String> htmlContent = ["", "", "", ""];
  List<String> homePosType = ["", "", "", ""];
  List<String> homePosTitle = ["", "", "", ""];
  List<double> homePosHeight = [0.0, 0.0, 0.0, 0.0];

  int cartNumber = 0;

  @override
  void initState() {
    animationController = AnimationController(duration: const Duration(milliseconds: 2000), vsync: this);
    super.initState();
    localInfo();
    loadPos1();
    loadPos2();
    loadPos3();
    loadPos4();
    getCatList();
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

  Future<bool> getData() async {
    await Future<dynamic>.delayed(const Duration(milliseconds: 0));
    return true;
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
    }
  }

  void getCatList() async {
    String url = global_var.domain + "?ss_module=mobile_cat&id=0";
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      var jsonResponse = convert.jsonDecode(response.body);
      List<CatList> catList2 = [];
      for (var i = 0; i < jsonResponse.length; i++) {
        List<CatList> catList3 = [
          CatList(
            id: int.tryParse(jsonResponse[i]['id'].toString()),
            name: jsonResponse[i]['name'],
            imageIcon: jsonResponse[i]['image_icon'],
            haveSub: jsonResponse[i]['have_sub'].toString(),
          )
        ];
        catList2.add(catList3[0]);
      }
    }
  }

  void loadPos1() async {
    try {
      String url = global_var.domain + "?ss_module=mobile_widget&id=Pos1";
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        var jsonResponse = convert.jsonDecode(response.body);
        if (jsonResponse.length > 0) {
          homePosType[0] = jsonResponse["type"];
          setState(() {
            if (jsonResponse["showname"] == "1") {
              homePosTitle[0] = jsonResponse["name"];
            } else {
              homePosTitle[0] = "";
            }
          });
          if (homePosType[0] == "html") {
            setState(() {
              htmlContent[0] = jsonResponse["content"];
            });
          } else if (homePosType[0] == "slide") {
            List<String> list2 = [];
            for (var i = 0; i < jsonResponse['image'].length; i++) {
              List<String> imgList3 = [jsonResponse['image'][i]];
              list2.add(imgList3[0]);
            }
            setState(() {
              imgList0 = list2;
            });
          } else if (homePosType[0] == "product") {
            List<HomeListHome> list2 = [];
            for (var i = 0; i < jsonResponse["productList"].length; i++) {
              List<HomeListHome> list3 = [
                HomeListHome(
                  id: int.tryParse(jsonResponse["productList"][i]['id']),
                  imagePath: global_var.imagesURL + jsonResponse["productList"][i]['images'],
                  productName: jsonResponse["productList"][i]['name'],
                  productDescript: jsonResponse["productList"][i]['descript'],
                  productPrice: jsonResponse["productList"][i]['price'].toString(),
                )
              ];
              list2.add(list3[0]);
            }
            productNumber[0] = jsonResponse["productList"].length;
            setState(() {
              if (multiple) {
                var t = productNumber[0] / 2;
                homePosHeight[0] = t.round() * _contentHeight1;
              } else {
                homePosHeight[0] = productNumber[0] * _contentHeight2;
              }
              homeList0 = list2;
            });
          }
        }
      }
    } on Exception catch (_) {
      networkError();
    }
  }

  void loadPos2() async {
    try {
      String url = global_var.domain + "?ss_module=mobile_widget&id=Pos2";
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        var jsonResponse = convert.jsonDecode(response.body);
        if (jsonResponse.length > 0) {
          homePosType[1] = jsonResponse["type"];
          setState(() {
            if (jsonResponse["showname"] == "1") {
              homePosTitle[1] = jsonResponse["name"];
            } else {
              homePosTitle[1] = "";
            }
          });
          if (homePosType[1] == "html") {
            setState(() {
              htmlContent[1] = jsonResponse["content"];
            });
          } else if (homePosType[1] == "slide") {
            List<String> list2 = [];
            for (var i = 0; i < jsonResponse['image'].length; i++) {
              List<String> list3 = [jsonResponse['image'][i]];
              list2.add(list3[0]);
            }
            setState(() {
              imgList1 = list2;
            });
          } else if (homePosType[1] == "product") {
            List<HomeListHome> list2 = [];
            for (var i = 0; i < jsonResponse["productList"].length; i++) {
              List<HomeListHome> list3 = [
                HomeListHome(
                  id: int.tryParse(jsonResponse["productList"][i]['id']),
                  imagePath: global_var.imagesURL + jsonResponse["productList"][i]['images'],
                  productName: jsonResponse["productList"][i]['name'],
                  productDescript: jsonResponse["productList"][i]['descript'],
                  productPrice: jsonResponse["productList"][i]['price'].toString(),
                )
              ];
              list2.add(list3[0]);
            }
            productNumber[1] = jsonResponse["productList"].length;
            setState(() {
              if (multiple) {
                var t = productNumber[1] / 2;
                homePosHeight[1] = t.round() * _contentHeight1;
              } else {
                homePosHeight[1] = productNumber[1] * _contentHeight2;
              }
              homeList1 = list2;
            });
          }
        }
      }
    } on Exception catch (_) {
      networkError();
    }
  }

  void loadPos3() async {
    try {
      String url = global_var.domain + "?ss_module=mobile_widget&id=Pos3";
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        var jsonResponse = convert.jsonDecode(response.body);
        if (jsonResponse.length > 0) {
          homePosType[2] = jsonResponse["type"];
          setState(() {
            if (jsonResponse["showname"] == "1") {
              homePosTitle[2] = jsonResponse["name"];
            } else {
              homePosTitle[2] = "";
            }
          });
          if (homePosType[2] == "html") {
            setState(() {
              htmlContent[2] = jsonResponse["content"];
            });
          } else if (homePosType[2] == "slide") {
            List<String> list2 = [];
            for (var i = 0; i < jsonResponse['image'].length; i++) {
              List<String> list3 = [jsonResponse['image'][i]];
              list2.add(list3[0]);
            }
            setState(() {
              imgList2 = list2;
            });
          } else if (homePosType[2] == "product") {
            List<HomeListHome> list2 = [];
            for (var i = 0; i < jsonResponse["productList"].length; i++) {
              List<HomeListHome> list3 = [
                HomeListHome(
                  id: int.tryParse(jsonResponse["productList"][i]['id']),
                  imagePath: global_var.imagesURL + jsonResponse["productList"][i]['images'],
                  productName: jsonResponse["productList"][i]['name'],
                  productDescript: jsonResponse["productList"][i]['descript'],
                  productPrice: jsonResponse["productList"][i]['price'].toString(),
                )
              ];
              list2.add(list3[0]);
            }
            productNumber[2] = jsonResponse["productList"].length;
            setState(() {
              if (multiple) {
                var t = productNumber[2] / 2;
                homePosHeight[2] = t.round() * _contentHeight1;
              } else {
                homePosHeight[2] = productNumber[2] * _contentHeight2;
              }
              homeList2 = list2;
            });
          }
        }
      }
    } on Exception catch (_) {
      networkError();
    }
  }

  void loadPos4() async {
    int inx = 3;
    try {
      String url = global_var.domain + "?ss_module=mobile_widget&id=Pos4";
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        var jsonResponse = convert.jsonDecode(response.body);
        if (jsonResponse.length > 0) {
          homePosType[inx] = jsonResponse["type"];
          setState(() {
            if (jsonResponse["showname"] == "1") {
              homePosTitle[inx] = jsonResponse["name"];
            } else {
              homePosTitle[inx] = "";
            }
          });
          if (homePosType[inx] == "html") {
            setState(() {
              htmlContent[inx] = jsonResponse["content"];
            });
          } else if (homePosType[inx] == "slide") {
            List<String> list2 = [];
            for (var i = 0; i < jsonResponse['image'].length; i++) {
              List<String> list3 = [jsonResponse['image'][i]];
              list2.add(list3[0]);
            }
            setState(() {
              imgList3 = list2;
            });
          } else if (homePosType[inx] == "product") {
            List<HomeListHome> list2 = [];
            for (var i = 0; i < jsonResponse["productList"].length; i++) {
              List<HomeListHome> list3 = [
                HomeListHome(
                  id: int.tryParse(jsonResponse["productList"][i]['id']),
                  imagePath: global_var.imagesURL + jsonResponse["productList"][i]['images'],
                  productName: jsonResponse["productList"][i]['name'],
                  productDescript: jsonResponse["productList"][i]['descript'],
                  productPrice: jsonResponse["productList"][i]['price'].toString(),
                )
              ];
              list2.add(list3[0]);
            }
            productNumber[inx] = jsonResponse["productList"].length;
            setState(() {
              if (multiple) {
                var t = productNumber[inx] / 2;
                homePosHeight[inx] = t.round() * _contentHeight1;
              } else {
                homePosHeight[inx] = productNumber[inx] * _contentHeight2;
              }
              homeList3 = list2;
            });
          }
        }
      }
    } on Exception catch (_) {
      networkError();
    }
  }

  @override
  Widget build(BuildContext context) {
    _contentHeight1 = MediaQuery.of(context).size.width / 4;
    _contentHeight2 = MediaQuery.of(context).size.width / 3;
    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Container(
        decoration: new BoxDecoration(
          image: new DecorationImage(
            image: new NetworkImage(backgroundImage),
            fit: BoxFit.fill,
          ),
        ),
        child: Scaffold(
          backgroundColor: Color.fromRGBO(0, 0, 0, 0.1),
          appBar: AppBar(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              // centers horizontally
              crossAxisAlignment: CrossAxisAlignment.center,
              // centers vertically
              children: <Widget>[
                Image.network(
                  global_var.mobileLogo,
                ),
              ],
            ),
            backgroundColor: Color(0XFF2d561e),
            centerTitle: true,
            leading: new IconButton(
              icon: new Icon(Icons.account_box),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => AccountPage()));
              },
            ),
            actions: <Widget>[
              // action button
              Padding(
                padding: const EdgeInsets.only(top: 8, right: 8),
                child: Container(
                  width: AppBar().preferredSize.height - 8,
                  height: AppBar().preferredSize.height - 8,
                  color: Colors.transparent,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      child: Icon(
                        multiple ? Icons.dashboard : Icons.view_agenda,
                        color: AppTheme.white,
                      ),
                      onTap: () {
                        multiple = !multiple;
                        setState(
                          () {
                            multiple = multiple;
                            if (multiple) {
                              var t = 0.0;
                              t = productNumber[0] / 2;
                              homePosHeight[0] = t.round() * _contentHeight1;
                              t = productNumber[1] / 2;
                              homePosHeight[1] = t.round() * _contentHeight1;
                              t = productNumber[2] / 2;
                              homePosHeight[2] = t.round() * _contentHeight1;
                              t = productNumber[3] / 2;
                              homePosHeight[3] = t.round() * _contentHeight1;
                            } else {
                              homePosHeight[0] = productNumber[0] * _contentHeight2;
                              homePosHeight[1] = productNumber[1] * _contentHeight2;
                              homePosHeight[2] = productNumber[2] * _contentHeight2;
                              homePosHeight[3] = productNumber[3] * _contentHeight2;
                            }
                          },
                        );
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(8),
            children: <Widget>[
              homePosTitle[0] != ""
                  ? Container(
                      padding: EdgeInsets.only(top: 30.0, bottom: 10.0),
                      child: Text(
                        homePosTitle[0],
                        style: new TextStyle(
                          fontSize: 18.0,
                          color: Color(0XFF2d561e),
                        ),
                      ))
                  : Container(),
              homePosType[0] == "html"
                  ? Container(
                      child: Html(
                        data: htmlContent[0],
                        padding: EdgeInsets.all(8.0),
                        backgroundColor: Colors.white70,
                        defaultTextStyle: TextStyle(fontFamily: 'serif'),
                        linkStyle: const TextStyle(
                          color: Colors.redAccent,
                        ),
                      ),
                    )
                  : homePosType[0] == "slide"
                      ? Container(
                          height: 300,
                          child: CarouselSlider(
                            height: 400.0,
                            items: imgList0.map(
                              (url) {
                                return Container(
                                  margin: EdgeInsets.all(5.0),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.all(Radius.circular(5.0)),
                                    child: Image.network(
                                      url,
                                      fit: BoxFit.cover,
                                      width: 1000.0,
                                    ),
                                  ),
                                );
                              },
                            ).toList(),
                          ),
                        )
                      : homePosType[0] == "product"
                          ? /*Container(
                              child: FutureBuilder<bool>(
                                future: getData(),
                                builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
                                  if (!snapshot.hasData) {
                                    return const SizedBox();
                                  } else {
                                    return GridView.count(
                                      physics: NeverScrollableScrollPhysics(),
                                      crossAxisCount: 2,
                                      primary: false,
                                      padding: const EdgeInsets.all(20),
                                      crossAxisSpacing: 10,
                                      mainAxisSpacing: 10,
                                      shrinkWrap: true,
                                      scrollDirection: Axis.vertical,
                                      childAspectRatio: 0.8,
                                      children: homeList0.map(
                                        (item) {
                                          return Center(
                                            child: Card(
                                              color: Colors.transparent,
                                              elevation: 0,
                                              child: new InkWell(
                                                child: new Container(
                                                  alignment: Alignment.center,
                                                  child: new Column(
                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: <Widget>[
                                                      ClipRRect(
                                                        borderRadius: BorderRadius.vertical(top: Radius.circular(100.0), bottom: Radius.circular(100.0)),
                                                        child: Container(
                                                          width: 150.0,
                                                          height: 150.0,
                                                          decoration: new BoxDecoration(
                                                            shape: BoxShape.circle,
                                                            image: new DecorationImage(
                                                              fit: BoxFit.fill,
                                                              image: new NetworkImage(
                                                                item.imagePath,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      new Padding(
                                                        padding: const EdgeInsets.all(8.0),
                                                        child: new Center(
                                                          child: new Text(
                                                            item.productName,
                                                            style: new TextStyle(fontSize: 16.0),
                                                            textAlign: TextAlign.center,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                onTap: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) => ShoppingCartPage(item.id),
                                                    ),
                                                  );
                                                },
                                              ),
                                            ),
                                          );
                                        },
                                      ).toList(),
                                    );
                                  }
                                },
                              ),
                            ) */
                          Container(
                              height: homePosHeight[0],
                              child: FutureBuilder<bool>(
                                future: getData(),
                                builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
                                  if (!snapshot.hasData) {
                                    return const SizedBox();
                                  } else {
                                    return GridView(
                                      padding: const EdgeInsets.only(top: 10, left: 10, right: 10),
                                      scrollDirection: Axis.vertical,
                                      physics: NeverScrollableScrollPhysics(),
                                      //physics: const BouncingScrollPhysics(),
                                      //scrollDirection: Axis.vertical,
                                      children: List<Widget>.generate(
                                        homeList0.length,
                                        (int index) {
                                          final int count = homeList0.length;
                                          final Animation<double> animation = Tween<double>(begin: 0.0, end: 1.0).animate(
                                            CurvedAnimation(
                                              parent: animationController,
                                              curve: Interval((1 / count) * index, 1.0, curve: Curves.fastOutSlowIn),
                                            ),
                                          );
                                          animationController.forward();
                                          return HomeListHomeView(
                                            animation: animation,
                                            animationController: animationController,
                                            listData: homeList0[index],
                                            callBack: () {
                                              Navigator.push(context, MaterialPageRoute(builder: (context) => ShoppingCartPage(homeList0[index].id)));
                                            },
                                          );
                                        },
                                      ),
                                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: multiple ? 2 : 1,
                                        mainAxisSpacing: 10.0,
                                        crossAxisSpacing: 10.0,
                                        childAspectRatio: multiple ? 2 : 3,
                                      ),
                                    );
                                  }
                                },
                              ),
                            )
                          : Container(),
              /*

                                      Container(
                height: homePosHeight[0],
                child: FutureBuilder<bool>(
                  future: getData(),
                  builder: (BuildContext context,
                          AsyncSnapshot<bool> snapshot) {
                    if (!snapshot.hasData) {
                      return const SizedBox();
                    } else {
                      return GridView(
                        padding: const EdgeInsets.only(
                                top: 10, left: 10, right: 10),
                        scrollDirection: Axis.vertical,
                        physics: NeverScrollableScrollPhysics(),
                        //physics: const BouncingScrollPhysics(),
                        //scrollDirection: Axis.vertical,
                        children: List<Widget>.generate(
                          homeList0.length,
                                  (int index) {
                            final int count = homeList0.length;
                            final Animation<double> animation =
                            Tween<double>(
                                    begin: 0.0, end: 1.0)
                                    .animate(
                              CurvedAnimation(
                                parent: animationController,
                                curve: Interval(
                                        (1 / count) * index, 1.0,
                                        curve: Curves.fastOutSlowIn),
                              ),
                            );
                            animationController.forward();
                            return HomeListHomeView(
                              animation: animation,
                              animationController:
                              animationController,
                              listData: homeList0[index],
                              callBack: () {
                                Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                                builder: (context) =>
                                                        ShoppingCartPage(
                                                                homeList0[index]
                                                                        .id)));
                              },
                            );
                          },
                        ),
                        gridDelegate:
                        SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: multiple ? 2 : 1,
                          mainAxisSpacing: 10.0,
                          crossAxisSpacing: 10.0,
                          childAspectRatio: multiple ? 2 : 3,
                        ),
                      );
                    }
                  },
                ),
              )*/
              homePosTitle[1] != ""
                  ? Container(
                      padding: EdgeInsets.only(top: 30.0, bottom: 10.0),
                      child: Text(
                        homePosTitle[1],
                        style: new TextStyle(
                          fontSize: 18.0,
                          color: Color(0XFF2d561e),
                        ),
                      ))
                  : Container(),
              homePosType[1] == "html"
                  ? Container(
                      child: Html(
                        data: htmlContent[1],
                        padding: EdgeInsets.all(8.0),
                        backgroundColor: Colors.white70,
                        defaultTextStyle: TextStyle(fontFamily: 'serif'),
                        linkStyle: const TextStyle(
                          color: Colors.redAccent,
                        ),
                      ),
                    )
                  : homePosType[1] == "slide"
                      ? Container(
                          height: 300,
                          child: CarouselSlider(
                            height: 400.0,
                            items: imgList1.map(
                              (url) {
                                return Container(
                                  margin: EdgeInsets.all(5.0),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.all(Radius.circular(5.0)),
                                    child: Image.network(
                                      url,
                                      fit: BoxFit.cover,
                                      width: 1000.0,
                                    ),
                                  ),
                                );
                              },
                            ).toList(),
                          ),
                        )
                      : homePosType[1] == "product"
                          ? Container(
                              height: homePosHeight[1],
                              child: FutureBuilder<bool>(
                                future: getData(),
                                builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
                                  if (!snapshot.hasData) {
                                    return const SizedBox();
                                  } else {
                                    return GridView(
                                      padding: const EdgeInsets.only(top: 10, left: 10, right: 10),
                                      scrollDirection: Axis.vertical,
                                      physics: NeverScrollableScrollPhysics(),
                                      //physics: const BouncingScrollPhysics(),
                                      //scrollDirection: Axis.vertical,
                                      children: List<Widget>.generate(
                                        homeList1.length,
                                        (int index) {
                                          final int count = homeList1.length;
                                          final Animation<double> animation = Tween<double>(begin: 0.0, end: 1.0).animate(
                                            CurvedAnimation(
                                              parent: animationController,
                                              curve: Interval((1 / count) * index, 1.0, curve: Curves.fastOutSlowIn),
                                            ),
                                          );
                                          animationController.forward();
                                          return HomeListHomeView(
                                            animation: animation,
                                            animationController: animationController,
                                            listData: homeList1[index],
                                            callBack: () {
                                              Navigator.push(context, MaterialPageRoute(builder: (context) => ShoppingCartPage(homeList1[index].id)));
                                            },
                                          );
                                        },
                                      ),
                                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: multiple ? 2 : 1,
                                        mainAxisSpacing: 10.0,
                                        crossAxisSpacing: 10.0,
                                        childAspectRatio: multiple ? 2 : 3,
                                      ),
                                    );
                                  }
                                },
                              ),
                            )
                          : Container(),
              homePosTitle[2] != ""
                  ? Container(
                      padding: EdgeInsets.only(top: 30.0, bottom: 10.0),
                      child: Text(
                        homePosTitle[2],
                        style: new TextStyle(
                          fontSize: 18.0,
                          color: Color(0XFF2d561e),
                        ),
                      ))
                  : Container(),
              homePosType[2] == "html"
                  ? Container(
                      child: Html(
                        data: htmlContent[2],
                        padding: EdgeInsets.all(8.0),
                        backgroundColor: Colors.white70,
                        defaultTextStyle: TextStyle(fontFamily: 'serif'),
                        linkStyle: const TextStyle(
                          color: Colors.redAccent,
                        ),
                      ),
                    )
                  : homePosType[2] == "slide"
                      ? Container(
                          height: 300,
                          child: CarouselSlider(
                            height: 400.0,
                            items: imgList2.map(
                              (url) {
                                return Container(
                                  margin: EdgeInsets.all(5.0),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.all(Radius.circular(5.0)),
                                    child: Image.network(
                                      url,
                                      fit: BoxFit.cover,
                                      width: 1000.0,
                                    ),
                                  ),
                                );
                              },
                            ).toList(),
                          ),
                        )
                      : homePosType[2] == "product"
                          ? Container(
                              height: homePosHeight[2],
                              child: FutureBuilder<bool>(
                                future: getData(),
                                builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
                                  if (!snapshot.hasData) {
                                    return const SizedBox();
                                  } else {
                                    return GridView(
                                      padding: const EdgeInsets.only(top: 10, left: 10, right: 10),
                                      scrollDirection: Axis.vertical,
                                      physics: NeverScrollableScrollPhysics(),
                                      //physics: const BouncingScrollPhysics(),
                                      //scrollDirection: Axis.vertical,
                                      children: List<Widget>.generate(
                                        homeList2.length,
                                        (int index) {
                                          final int count = homeList2.length;
                                          final Animation<double> animation = Tween<double>(begin: 0.0, end: 1.0).animate(
                                            CurvedAnimation(
                                              parent: animationController,
                                              curve: Interval((1 / count) * index, 1.0, curve: Curves.fastOutSlowIn),
                                            ),
                                          );
                                          animationController.forward();
                                          return HomeListHomeView(
                                            animation: animation,
                                            animationController: animationController,
                                            listData: homeList2[index],
                                            callBack: () {
                                              Navigator.push(context, MaterialPageRoute(builder: (context) => ShoppingCartPage(homeList2[index].id)));
                                            },
                                          );
                                        },
                                      ),
                                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: multiple ? 2 : 1,
                                        mainAxisSpacing: 10.0,
                                        crossAxisSpacing: 10.0,
                                        childAspectRatio: multiple ? 2 : 3,
                                      ),
                                    );
                                  }
                                },
                              ),
                            )
                          : Container(),
              homePosTitle[3] != ""
                  ? Container(
                      padding: EdgeInsets.only(top: 30.0, bottom: 10.0),
                      child: Text(
                        homePosTitle[3],
                        style: new TextStyle(
                          fontSize: 18.0,
                          color: Color(0XFF2d561e),
                        ),
                      ))
                  : Container(),
              homePosType[3] == "html"
                  ? Container(
                      child: Html(
                        data: htmlContent[3],
                        padding: EdgeInsets.all(8.0),
                        backgroundColor: Colors.white70,
                        defaultTextStyle: TextStyle(fontFamily: 'serif'),
                        linkStyle: const TextStyle(
                          color: Colors.redAccent,
                        ),
                      ),
                    )
                  : homePosType[3] == "slide"
                      ? Container(
                          height: 300,
                          child: CarouselSlider(
                            height: 400.0,
                            items: imgList3.map(
                              (url) {
                                return Container(
                                  margin: EdgeInsets.all(5.0),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.all(Radius.circular(5.0)),
                                    child: Image.network(
                                      url,
                                      fit: BoxFit.cover,
                                      width: 1000.0,
                                    ),
                                  ),
                                );
                              },
                            ).toList(),
                          ),
                        )
                      : homePosType[3] == "product"
                          ? Container(
                              height: homePosHeight[3],
                              child: FutureBuilder<bool>(
                                future: getData(),
                                builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
                                  if (!snapshot.hasData) {
                                    return const SizedBox();
                                  } else {
                                    return GridView(
                                      padding: const EdgeInsets.only(top: 10, left: 10, right: 10),
                                      scrollDirection: Axis.vertical,
                                      physics: NeverScrollableScrollPhysics(),
                                      //physics: const BouncingScrollPhysics(),
                                      //scrollDirection: Axis.vertical,
                                      children: List<Widget>.generate(
                                        homeList3.length,
                                        (int index) {
                                          final int count = homeList3.length;
                                          final Animation<double> animation = Tween<double>(begin: 0.0, end: 1.0).animate(
                                            CurvedAnimation(
                                              parent: animationController,
                                              curve: Interval((1 / count) * index, 1.0, curve: Curves.fastOutSlowIn),
                                            ),
                                          );
                                          animationController.forward();
                                          return HomeListHomeView(
                                            animation: animation,
                                            animationController: animationController,
                                            listData: homeList3[index],
                                            callBack: () {
                                              Navigator.push(context, MaterialPageRoute(builder: (context) => ShoppingCartPage(homeList3[index].id)));
                                            },
                                          );
                                        },
                                      ),
                                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: multiple ? 2 : 1,
                                        mainAxisSpacing: 10.0,
                                        crossAxisSpacing: 10.0,
                                        childAspectRatio: multiple ? 2 : 3,
                                      ),
                                    );
                                  }
                                },
                              ),
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
            selectedItemColor: Color(0XFF2d561e),
            onTap: _onItemTapped,
          ),
        ),
      ),
    );
  }

  Future<bool> _onBackPressed() {
    return showDialog(
          context: context,
          builder: (context) => new AlertDialog(
            title: new Text('Are you sure?'),
            content: new Text('Do you want to exit an App'),
            actions: <Widget>[
              new GestureDetector(
                onTap: () => Navigator.of(context).pop(false),
                child: Text("NO"),
              ),
              SizedBox(height: 16),
              new GestureDetector(
                onTap: () => SystemNavigator.pop(),
                child: Text("YES"),
              ),
            ],
          ),
        ) ??
        false;
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
          content: Text("Unable to connect to the internet, please check the network again"),
          actions: <Widget>[
            FlatButton(
              child: Text('Retry'),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.push(context, MaterialPageRoute(builder: (context) => HomePage()));
              },
            ),
          ],
        );
      },
    );
  }

  void localInfo() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    global_var.appName = prefs.getString("appName");
    global_var.backgroundImage = prefs.getString("backgroundImage");
    global_var.mobileLogo = prefs.getString("mobileLogo");
    setState(() {
      appName = global_var.appName;
      backgroundImage = global_var.backgroundImage;
    });
  }
}

class HomeListHomeView extends StatelessWidget {
  const HomeListHomeView({Key key, this.listData, this.callBack, this.animationController, this.animation}) : super(key: key);

  final HomeListHome listData;
  final VoidCallback callBack;
  final AnimationController animationController;
  final Animation<dynamic> animation;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animationController,
      builder: (BuildContext context, Widget child) {
        return FadeTransition(
          opacity: animation,
          child: Transform(
            transform: Matrix4.translationValues(0.0, 50 * (1.0 - animation.value), 0.0),
            child: AspectRatio(
              aspectRatio: 1.5,
              child: ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(4.0)),
                child: Stack(
                  alignment: AlignmentDirectional.topCenter,
                  children: <Widget>[
                    InkWell(
                      child: Container(
                        decoration: AppTheme.homeScreenButtonDecoration,
                        margin: AppTheme.homeScreenButtonMargin,
                      ),
                      onTap: () {
                        callBack();
                      },
                    ),
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        child: Container(
                          height: multiple ? _contentHeight1 : _contentHeight2,
                          padding: AppTheme.homeScreenButtonPadding,
                          child: Row(children: <Widget>[
                            Container(
                              width: multiple ? 50 : 90,
                              height: multiple ? 50 : 90,
                              decoration: new BoxDecoration(
                                shape: BoxShape.circle,
                                image: new DecorationImage(
                                  fit: BoxFit.fill,
                                  image: new NetworkImage(
                                    listData.imagePath,
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
                                Container(
                                  padding: multiple ? AppTheme.homeScreenButtonPadding4 : AppTheme.homeScreenButtonPadding3,
                                  child: Text(
                                    listData.productName,
                                    style: TextStyle(
                                      fontWeight: FontWeight.normal,
                                      color: Color(0xFFff7800),
                                      fontSize: multiple ? 12 : 14,
                                    ),
                                  ),
                                ),
                                !multiple
                                    ? Container(
                                        padding: AppTheme.homeScreenButtonPadding3,
                                        child: Text(
                                          listData.productDescript,
                                          style: TextStyle(
                                            fontWeight: FontWeight.normal,
                                            color: Color(0XFF597423),
                                            fontSize: 11,
                                          ),
                                        ),
                                      )
                                    : Container(),
                                /*Container(
                                      padding:
                                          AppTheme.homeScreenButtonPadding5,
                                      child: Text(
                                        listData.productPrice + "\$",
                                        style: TextStyle(
                                          fontWeight: FontWeight.normal,
                                          color: Color(0XFF2c3e09),
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),*/
                              ]),
                            ),
                          ]),
                        ),
                        onTap: () {
                          callBack();
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
