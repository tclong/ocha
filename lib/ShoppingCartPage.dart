import 'dart:async';
import 'dart:convert' as convert;
import 'dart:convert';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_money_formatter/flutter_money_formatter.dart';
import 'package:flutter_web_browser/flutter_web_browser.dart';
import 'package:http/http.dart' as http;
import 'package:ocha/StoresPage.dart';
import 'package:ocha/giftPage.dart';
import 'package:ocha/homePage.dart';
import 'package:ocha/loginPage.dart';
import 'package:ocha/model/AppTheme.dart';
import 'package:ocha/model/Define.dart';
import 'package:ocha/model/global_var.dart' as global_var;
import 'package:ocha/model/lang.dart' as lang;
import 'package:ocha/registerPage.dart';
import 'package:shared_preferences/shared_preferences.dart';

bool multiple = false;
BuildContext sysContext;
int shopID = 0;
String orderID = "";
List<CartDataList> cartDataList = [];
List<CartDataList> cartDataListTmp = [];

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

class ShoppingCartPage extends StatefulWidget {
  final int productID;

  const ShoppingCartPage(this.productID);

  @override
  _ShoppingCartPageState createState() => _ShoppingCartPageState();
}

class _ShoppingCartPageState extends State<ShoppingCartPage> with TickerProviderStateMixin {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  final List<Notification> notifications = [];
  String firebaseFCMtoken = "";
  String _message = '';

  int _selectedIndex = 1;
  int _selectedCat = 0;
  double _totalMoney = 0;
  double _orderTotalMoney = 0;
  double _taxValue = 0;
  List<HomeList> homeList = HomeList.homeList;
  List<HomeList> cartList = HomeList.homeList;
  List<HomeList> cartDetailProductList = HomeList.homeList;
  List<HomeList> featureList = HomeList.homeList;
  List<HistoryList> historyList = HistoryList.historyList;
  List<ShopList> shopList = [];

  int _selectedShopID = 0;
  String _shopName = "";
  String _shopPhone = "";
  String _shopAddress = "";

  //String _addINText = "Select add in";
  int cartNumber = 0;
  int _showDetail = 0;
  int _showMainMenu = 1;
  int _showTabBar = 1;
  int _curentProductID = 0;
  double addInPrice = 0;

  //double _catTitleHeight = 0.0;
  AnimationController animationController;

  //final _c_fullname = TextEditingController();
  //final _c_phone = TextEditingController();
  //final _c_address = TextEditingController();
  //final _c_email = TextEditingController();
  TabController tabController;

  List<CatList> _listCatData = [CatList(id: 0, name: "Menu", imageIcon: "", haveSub: "0")];

  int tabIndex = 0;
  int _selectedColor = 0;
  int _selectedSize = 0;
  int _selectedMaterial = 0;
  int _selectedQuantity = 0;
  String productName = "";
  String productImages = "";
  String productDescript = "";
  String productContent = "";
  String productPrice = "";
  String _catTitle = "";
  String colorName = "";
  bool showColor = false;
  String sizeName = "";
  bool showSize = false;
  bool showAddIN = false;
  String materialName = "";
  bool showMaterial = false;
  String email = "";
  String phone = "";
  String address = "";
  int amount = 0;
  String _displayColor = "";
  String _displaySize = "";
  String _displayMaterial = "";
  String block;
  String appTitle = "Order";
  String amountTxt = "";
  List<DataList> _optionList = [];
  List<DataList> _colorList = [];
  List<DataList> _sizeList = [];
  List<DataList> _materialList = [];
  List<String> imgList = [];
  List<Widget> addINWidget = [];
  List<AddINList> addINListMain = [];
  String tabTitle = lang.order;

  //final _quantity = TextEditingController();
  String backgroundImage = "";
  String appName = "";

  @override
  void initState() {
    animationController = AnimationController(duration: const Duration(milliseconds: 2000), vsync: this);
    super.initState();
    getCatList();
    getShopList();
    appInfo();
    getCartInfo();
    getConfig();
    if (widget.productID > 0) {
      _curentProductID = widget.productID;
      setState(() {
        _showMainMenu = 0;
        _showDetail = 1;
      });
      getContent();
    }
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
        _showInfo2("${message['notifications']['body']}", 0);
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
    tabController.dispose();
    super.dispose();
  }

  void getConfig() async {
    String url = global_var.domain + "?ss_module=mobile&option=getConfig";
    print(url);
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      var jsonResponse = convert.jsonDecode(response.body);
      setState(() {
        _taxValue = double.parse(jsonResponse['tax']);
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

  void openBrowserTab() async {
    await FlutterWebBrowser.openWebPage(
        url: global_var.domain + "?ss_module=payment&id=" + orderID + "&total=" + _totalMoney.toString(), androidToolbarColor: Colors.deepPurple);
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

  void doOrder() async {
    _processingDialog();
    String url = global_var.domain +
        "?ss_module=cart&option=mobileOrderProcess&productList=" +
        convert.jsonEncode(cartDataList) +
        "&shopID=" +
        _selectedShopID.toString() +
        "&safeCode=" +
        global_var.safeCode;
    print(url);
    final response = await http.get(Uri.parse(url));
    Navigator.of(context).pop();
    if (response.statusCode == 200) {
      var jsonResponse = json.decode(response.body);
      orderID = jsonResponse['result'];
      if (orderID == "amount") {
        _showInfo2(lang.orderNotEnoughAmount, 0);
      } else if (orderID == "noProduct") {
        _showInfo2(lang.orderNoProduct, 0);
      } else if (orderID == "noUser") {
        _showInfo2(lang.orderLoginEequired, 10);
      } else {
        _showInfo2(lang.orderSuccess, 0);
        clearCart();
        getHistoryList();
        setState(() {
          tabIndex = 3;
          tabTitle = lang.history;
        });
        //openBrowserTab();
      }
    }
  }

  void clearCart() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("cartData", "");
    setState(() {
      cartDataList = [];
    });
  }

  void getCartInfo() async {
    cartDataListTmp = [];
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var cartData = prefs.getString("cartData");
    if (cartData != null && cartData != "") {
      List jsonCartData = [];
      try {
        jsonCartData = convert.jsonDecode(cartData);
      } catch (error) {
        cartData = "";
        prefs.setString("cartData", "");
      }
      for (var i = 0; i < jsonCartData.length; i++) {
        List<AddInListCart> tmpAddin = [];
        if (jsonCartData[i]["addIn"].length > 0) {
          for (var j = 0; j < jsonCartData[i]["addIn"].length; j++) {
            List<AddInListCart> tmpAddin2 = [AddInListCart(id: jsonCartData[i]["addIn"][j]['id'])];
            tmpAddin.add(tmpAddin2[0]);
          }
        }
        List<CartDataList> tmp1 = [
          CartDataList(
              id: jsonCartData[i]["id"],
              quantity: jsonCartData[i]["quantity"],
              color: jsonCartData[i]["color"],
              size: jsonCartData[i]["size"],
              productPrice: jsonCartData[i]["productPrice"],
              addInTotalMoney: jsonCartData[i]["addInTotalMoney"],
              material: jsonCartData[i]["material"],
              addIn: tmpAddin)
        ];
        cartDataListTmp.add(tmp1[0]);
      }
      setState(() {
        cartDataList = cartDataListTmp;
        cartNumber = cartDataList.length;
      });
    } else {
      setState(() {
        cartNumber = 0;
      });
    }
  }

  void getCartList() async {
    _totalMoney = 0;
    if (cartDataList.length > 0) {
      String url = global_var.domain + "?ss_module=cart&option=mobileProductList&productList=" + convert.jsonEncode(cartDataList);
      print(url);
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        bool errorData = false;
        var jsonResponse;
        try {
          jsonResponse = convert.jsonDecode(response.body);
        } catch (error) {
          errorData = true;
        }
        if (errorData == false) {
          cartDataListTmp = [];
          List<HomeList> homeList2 = [];
          for (var i = 0; i < jsonResponse.length; i++) {
            List<AddInListCart> tmpAddin = [];
            if (jsonResponse[i]['id'] != "") {
              if (jsonResponse[i]["addInList"].length > 0) {
                for (var j = 0; j < jsonResponse[i]["addInList"].length; j++) {
                  List<AddInListCart> tmpAddin2 = [AddInListCart(id: jsonResponse[i]["addInList"][j]['id'])];
                  tmpAddin.add(tmpAddin2[0]);
                }
              }
              List<CartDataList> tmp1 = [
                CartDataList(
                    id: jsonResponse[i]["id"],
                    quantity: jsonResponse[i]["quantity"],
                    color: int.tryParse(jsonResponse[i]["color"]["id"].toString()),
                    size: int.tryParse(jsonResponse[i]["size"]["id"].toString()),
                    productPrice: jsonResponse[i]["productPrice"],
                    addInTotalMoney: double.parse(jsonResponse[i]["addInTotalMoney"].toString()),
                    material: int.tryParse(jsonResponse[i]["material"]["id"].toString()),
                    addIn: tmpAddin)
              ];
              cartDataListTmp.add(tmp1[0]);
              _totalMoney =
                  _totalMoney + double.parse(jsonResponse[i]['total'].toString()) + (jsonResponse[i]['addInTotalMoney'] * jsonResponse[i]['quantity']);
              List<HomeList> homeList3 = [
                HomeList(
                  id: jsonResponse[i]['id'],
                  imagePath: global_var.imagesURL + jsonResponse[i]['images'],
                  productName: jsonResponse[i]['name'],
                  productDescript: jsonResponse[i]['descript'],
                  total: jsonResponse[i]['total'].toString(),
                  productPrice: jsonResponse[i]['price'].toString(),
                  productQuantity: jsonResponse[i]['quantity'].toString(),
                  colorName: jsonResponse[i]['color_name'].toString(),
                  color: jsonResponse[i]['color']['name'].toString(),
                  sizeName: jsonResponse[i]['size_name'].toString(),
                  size: jsonResponse[i]['size']['name'].toString(),
                  materialName: jsonResponse[i]['material_name'].toString(),
                  material: jsonResponse[i]['material']['name'].toString(),
                  //productString: convert.jsonEncode(jsonResponse[i]['productString']),
                  index: jsonResponse[i]['index'],
                  addin: jsonResponse[i]['addin'],
                  addInTotalMoney: double.parse(jsonResponse[i]['addInTotalMoney'].toString()),
                  addInSubTotal: double.parse((jsonResponse[i]['addInTotalMoney'] * jsonResponse[i]['quantity']).toString()),
                )
              ];
              homeList2.add(homeList3[0]);
            }
          }
          setState(() {
            _totalMoney = _totalMoney;
            cartList = homeList2;
            cartDataList = cartDataListTmp;
            cartNumber = cartDataList.length;
          });
          getCartInfo();
          SharedPreferences prefs = await SharedPreferences.getInstance();
          prefs.setString('cartData', convert.jsonEncode(cartDataList));
          print(convert.jsonEncode(cartDataList));
        }
      } else {
        _showInfo2(lang.networkError, 100);
      }
    } else {
      //neu khong co san pham trong gio hang
      List<HomeList> homeList2 = [];
      setState(() {
        cartList = homeList2;
        _totalMoney = 0;
      });
      getCartInfo();
    }
  }

  void callSummery() async {
    _totalMoney = 0;
    if (cartDataList.length > 0) {
      cartDataList.forEach((item) {
        // _totalMoney = _totalMoney + item.quantity * item
      });
    }
  }

  void getShopList() async {
    String url = global_var.domain + "?ss_module=mobile&option=shopList";
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
      shopList = shopList2;
      setState(() {
        _selectedShopID = shopList[0].id;
        _shopName = shopList[0].name;
        _shopAddress = shopList[0].address;
        _shopPhone = shopList[0].phone;
      });
    }
  }

  void changeShop(int id) async {
    print(id);
    _selectedShopID = id;
    for (var i = 0; i < shopList.length; i++) {
      if (shopList[i].id == id) {
        setState(() {
          _selectedShopID = shopList[i].id;
          _shopName = shopList[i].name;
          _shopAddress = shopList[i].address;
          _shopPhone = shopList[i].phone;
        });
      }
    }
  }

  void _deleteProduct(int index) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    cartDataList.removeAt(index);
    prefs.setString('cartData', convert.jsonEncode(cartDataList));
    getCartInfo();
    getCartList();
    if (cartDataList.length == 0) {
      tabController.animateTo(0);
    }
  }

  void _deleteProductDialog(int index) {
    _showDeleteProductConfirm(index);
  }

  void getContent() async {
    String url = global_var.domain + "?ss_module=product&option=mobileProductDetail&ID=" + _curentProductID.toString();
    print(url);
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      var jsonResponse = convert.jsonDecode(response.body);
      setState(() {
        productName = jsonResponse['name'];
        productImages = global_var.imagesURL + jsonResponse['images'];
        productDescript = jsonResponse['descript'];
        productPrice = jsonResponse['price'];
        productContent = jsonResponse['content'];
        if (jsonResponse['addin'] == "1") {
          showAddIN = true;
          addINListMain = [];
          var lastA = 0;
          var tintA = 0;
          jsonResponse['addin_list'].forEach((tmp) {
            int tid = int.parse(tmp['f_id']);
            if (tid > lastA) {
              lastA = tid;
              tintA = addINListMain.length;
              for (var i = tintA; i < lastA; i++) {
                addINListMain.add(AddINList(id: 0, type: 0, name: '', sub: null));
              }
            }
            List<AddINListSub> sb = [];
            var lastB = 0;
            var tintB = 0;
            tmp['sub'].forEach((s) {
              int sid = int.parse(s['f_id']);
              if (sid > lastB) {
                lastB = sid;
                tintB = sb.length;
                for (var i = tintB; i < lastB; i++) {
                  sb.add(AddINListSub(id: 0, name: '', selected: false, price: 0));
                }
              }
              //them vao addin list
              sb.insert(sid, AddINListSub(id: sid, name: s['f_name'], selected: false, price: double.parse(s['f_price'])));
            });
            addINListMain.insert(tid, AddINList(id: tid, type: int.parse(tmp['f_type']), name: tmp['f_name'], sub: sb));
          });
        }

        List<String> imgList2 = [];
        for (var i = 0; i < jsonResponse['gallery'].length; i++) {
          List<String> imgList3 = [jsonResponse['gallery'][i]['image']];
          imgList2.add(imgList3[0]);
        }
        setState(() {
          imgList = imgList2;
        });

        colorName = jsonResponse['color_name'].trim();
        if (colorName != null && colorName != "" && colorName != "null") {
          showColor = true;
          List<DataList> _colorList2 = [];
          for (var i = 0; i < jsonResponse['color'].length; i++) {
            if (jsonResponse['color'][i]["id"] != null) {
              List<DataList> _colorList3 = [DataList(id: int.parse(jsonResponse['color'][i]["id"]), name: jsonResponse['color'][i]["name"])];
              _colorList2.add(_colorList3[0]);
            }
          }
          _colorList = _colorList2;
          _displayColor = "Select " + colorName;
        }
        sizeName = jsonResponse['size_name'];
        if (sizeName != null && sizeName != "" && sizeName != "null") {
          showSize = true;
          List<DataList> _sizeList2 = [];
          for (var i = 0; i < jsonResponse['size'].length; i++) {
            if (jsonResponse['size'][i]["id"] != null) {
              List<DataList> _sizeList3 = [DataList(id: int.parse(jsonResponse['size'][i]["id"]), name: jsonResponse['size'][i]["name"])];
              _sizeList2.add(_sizeList3[0]);
            }
          }
          _sizeList = _sizeList2;
          _displaySize = "Select " + sizeName;
        }
        materialName = jsonResponse['material_name'];
        if (materialName != null && materialName != "" && materialName != "null") {
          showMaterial = true;
          List<DataList> _materialList2 = [];
          for (var i = 0; i < jsonResponse['material'].length; i++) {
            if (jsonResponse['material'][i]["id"] != null) {
              List<DataList> _materialList3 = [DataList(id: int.parse(jsonResponse['material'][i]["id"]), name: jsonResponse['material'][i]["name"])];
              _materialList2.add(_materialList3[0]);
            }
          }
          _materialList = _materialList2;
          _displayMaterial = "Select " + materialName;
        }
      });
    }
  }

  void callSelectColor(int id) {
    setState(() {
      _selectedColor = id;
    });
  }

  void callSelectSize(int id) {
    setState(() {
      _selectedSize = id;
    });
  }

  void callSelectMaterial(int id) {
    setState(() {
      _selectedMaterial = id;
    });
  }

  void updateCartQuantity() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('cartData', convert.jsonEncode(cartDataList));
  }

  void saveCartData(int changeQuantity) async {
    //save current order item
    SharedPreferences prefs = await SharedPreferences.getInstance();
    //cartData = prefs.getString("cartData");
    bool error = false;

    if (showColor) {
      if (_selectedColor == 0) {
        _showInfo2("Please select " + colorName, 0);
        error = true;
      }
    }

    if (showSize && !error) {
      if (_selectedSize == 0) {
        _showInfo2("Please select " + sizeName, 0);
        error = true;
      }
    }

    if (showMaterial && !error) {
      if (_selectedMaterial == 0) {
        _showInfo2("Please select " + materialName, 0);
        error = true;
      }
    }

    //if (_selectedQuantity == 0) {
    //_showInfo2("Please select at least 1 product ", 0);
    //error = true;
    //}

    //_selectedQuantity = 1;

    if (!error) {
      addINListMain.forEach(
        (item) {
          if (item.type == 1 && error == false) {
            error = true;
            if (item.sub != null) {
              item.sub.forEach((it) {
                if (it.selected) {
                  error = false;
                }
              });
            }
            if (error == true) {
              _showInfo2("Please select " + item.name, 0);
            }
          }
        },
      );
      if (!error) {
        List<AddInListCart> addintmp = [];
        double addINPricetmp = 0;
        addINListMain.forEach((item) {
          if (item.sub != null) {
            item.sub.forEach((it) {
              if (it.selected) {
                addINPricetmp = addINPricetmp + it.price;
                List<AddInListCart> addintmp2 = [AddInListCart(id: it.id)];
                addintmp.add(addintmp2[0]);
              }
            });
          }
        });
        _selectedQuantity = 1;
        List<CartDataList> tmp1 = [
          CartDataList(
              id: _curentProductID,
              quantity: _selectedQuantity,
              color: _selectedColor,
              size: _selectedSize,
              material: _selectedMaterial,
              productPrice: double.parse(productPrice),
              addIn: addintmp,
              addInTotalMoney: addINPricetmp)
        ];
        var i = 0;
        var finned = -1;
        cartDataList.forEach((item) {
          if (item.id == _curentProductID && item.color == _selectedColor && item.size == _selectedSize && item.material == _selectedMaterial) {
            print("Found");
            if (item.addIn.length == addintmp.length) {
              var j = 0;
              var k = false;
              item.addIn.forEach((itm) {
                if (itm.id != addintmp[j].id) {
                  k = true;
                }
                j++;
              },);
              if (k == false) {
                finned = i;
              }
            }
          }
          i++;
        },);
        if (finned >= 0) {
          if (changeQuantity == 1) {
            cartDataList[finned].quantity += 1;
          } else if (changeQuantity == 2) {
            cartDataList[finned].quantity += 1;
          } else {
            cartDataList[finned].quantity = 1;
          }
        } else {
          cartDataList.add(tmp1[0]);
        }
        prefs.setString('cartData', convert.jsonEncode(cartDataList));
        _showInfo2("The product has been put into the cart", 1);
      }
    }
  }

  void searchProduct(int id) async {
    _selectedCat = id;
    String url = global_var.domain + "?ss_module=product&option=mobileProductList&catID=" + _selectedCat.toString();
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      var jsonResponse = convert.jsonDecode(response.body);
      List<HomeList> homeList2 = [];
      for (var i = 0; i < jsonResponse.length; i++) {
        List<HomeList> homeList3 = [
          HomeList(
            id: int.tryParse(jsonResponse[i]['id']),
            imagePath: global_var.imagesURL + jsonResponse[i]['images'],
            productName: jsonResponse[i]['name'],
            productDescript: jsonResponse[i]['descript'],
            productPrice: jsonResponse[i]['price'].toString(),
          )
        ];
        homeList2.add(homeList3[0]);
      }
      setState(() {
        homeList = homeList2;
      });
    }
  }

  void getFeatureList() async {
    String url = global_var.domain + "?ss_module=product&option=mobileFeatureList";
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      var jsonResponse = convert.jsonDecode(response.body);
      List<HomeList> homeList2 = [];
      for (var i = 0; i < jsonResponse.length; i++) {
        List<HomeList> homeList3 = [
          HomeList(
            id: int.tryParse(jsonResponse[i]['id']),
            imagePath: global_var.imagesURL + jsonResponse[i]['images'],
            productName: jsonResponse[i]['name'],
            productDescript: jsonResponse[i]['descript'],
            productPrice: jsonResponse[i]['price'].toString(),
          )
        ];
        homeList2.add(homeList3[0]);
      }
      setState(() {
        featureList = homeList2;
      });
    }
  }

  void getHistoryList() async {
    String url = global_var.domain + "?ss_module=history&safeCode=" + global_var.safeCode;
    final response = await http.get(Uri.parse(url));
    print(url);
    if (response.statusCode == 200) {
      var jsonResponse = convert.jsonDecode(response.body);
      List<HistoryList> historyList2 = [];
      for (var i = 0; i < jsonResponse.length; i++) {
        List<HistoryList> historyList3 = [
          HistoryList(
            id: int.tryParse(jsonResponse[i]['id']),
            total: double.tryParse(jsonResponse[i]['total'].toString()),
            shopName: jsonResponse[i]['shopName'],
            shopAddress: jsonResponse[i]['shopAddress'],
            shopPhone: jsonResponse[i]['shopPhone'],
            time: jsonResponse[i]['time'],
          )
        ];
        historyList2.add(historyList3[0]);
      }
      setState(() {
        historyList = historyList2;
      });
    }
  }

  void getCatList() async {
    String url = global_var.domain + "?ss_module=mobile_cat&id=" + _selectedCat.toString();
    print(url);
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      var jsonResponse = convert.jsonDecode(response.body);
      if (jsonResponse.length > 0) {
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
        setState(() {
          _listCatData = catList2;
        });
      } else {
        setState(() {
          _showMainMenu = 0;
        });
        searchProduct(_selectedCat);
      }
    }
  }

  void getcatList2() async {
    String url = global_var.domain + "?ss_module=mobile_cat&id=" + _selectedCat.toString();
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      var jsonResponse = convert.jsonDecode(response.body);
      if (jsonResponse.length > 0) {
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
        setState(() {
          _listCatData = catList2;
        });
      } else {
        searchProduct(_selectedCat);
        setState(() {
          _showMainMenu = 0;
          _showDetail = 0;
        });
      }
    }
  }

  void getOrderDetail(int orderID) async {
    String url = global_var.domain + "?ss_module=mobile&option=orderDetail&id=" + orderID.toString();
    print(url);
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      bool errorData = false;
      var jsonResponse;
      try {
        jsonResponse = convert.jsonDecode(response.body);
      } catch (error) {
        errorData = true;
      }
      if (errorData == false) {
        _orderTotalMoney = 0;
        List<HomeList> homeList2 = [];
        cartDetailProductList = [];
        for (var i = 0; i < jsonResponse['items'].length; i++) {
          if (jsonResponse['items'][i]['id'] != "") {
            _orderTotalMoney = _orderTotalMoney +
                double.parse(jsonResponse['items'][i]['total'].toString()) +
                (double.tryParse(jsonResponse['items'][i]['addInTotalMoney']) * int.parse(jsonResponse['items'][i]['quantity']));
            List<HomeList> homeList3 = [
              HomeList(
                id: int.parse(jsonResponse['items'][i]['id']),
                imagePath: global_var.imagesURL + jsonResponse['items'][i]['images'],
                productName: jsonResponse['items'][i]['name'],
                productDescript: jsonResponse['items'][i]['descript'],
                total: jsonResponse['items'][i]['total'].toString(),
                productPrice: jsonResponse['items'][i]['price'].toString(),
                productQuantity: jsonResponse['items'][i]['quantity'].toString(),
                colorName: jsonResponse['items'][i]['color_name'].toString(),
                color: jsonResponse['items'][i]['color']['name'].toString(),
                sizeName: jsonResponse['items'][i]['size_name'].toString(),
                size: jsonResponse['items'][i]['size']['name'].toString(),
                materialName: jsonResponse['items'][i]['material_name'].toString(),
                material: jsonResponse['items'][i]['material']['name'].toString(),
                //productString: convert.jsonEncode(jsonResponse[i]['productString']),
                index: jsonResponse['items'][i]['index'],
                addin: jsonResponse['items'][i]['addin'],
                addInTotalMoney: double.parse(jsonResponse['items'][i]['addInTotalMoney'].toString()),
                addInSubTotal:
                    double.parse((double.parse(jsonResponse['items'][i]['addInTotalMoney']) * int.parse(jsonResponse['items'][i]['quantity'])).toString()),
              )
            ];
            homeList2.add(homeList3[0]);
          }
        }
        setState(() {
          _orderTotalMoney = _orderTotalMoney;
          cartDetailProductList = homeList2;
        });
        _showOrderDetail();
      }
    } else {
      _showInfo2(lang.networkError, 100);
    }
  }

  void calAddInPrice() {
    String str = "";
    addInPrice = 0;
    addINListMain.forEach((item) {
      var str2 = "";
      if (item.sub != null) {
        item.sub.forEach((it) {
          if (it.selected) {
            addInPrice = addInPrice + it.price;
            if (str2 == "") {
              str2 = it.name;
            } else {
              str2 = str2 + ", " + it.name;
            }
          }
        });
      }
      if (str2 != "") {
        if (str == "") {
          str = str2;
        } else {
          str = str + "," + str2;
        }
      }
    });
    /*
    setState(() {
      addInPrice = addInPrice;
      if (str != "") {
        _addINText = str;
      } else {
        _addINText = "Select add in";
      }
    });*/
  }

  Widget productDetail() {
    // Show product detail
    return ListView(
      children: <Widget>[
        Container(
            height: 300,
            child: CarouselSlider(
              height: 400.0,
              items: imgList.map(
                (url) {
                  return Container(
                    margin: EdgeInsets.all(5.0),
                    child: ClipRRect(
                      borderRadius: BorderRadius.all(
                        Radius.circular(5.0),
                      ),
                      child: Image.network(
                        url,
                        fit: BoxFit.cover,
                        width: 1000.0,
                      ),
                    ),
                  );
                },
              ).toList(),
            )),
        Container(
          padding: AppTheme.homeScreenButtonPadding4,
          child: Text(
            productName,
            style: TextStyle(
              fontWeight: FontWeight.normal,
              color: Color(0XFFff7800),
              fontSize: 20,
            ),
          ),
        ),
        Container(
          padding: AppTheme.homeScreenButtonPadding3,
          child: Text(
            productDescript,
            style: TextStyle(
              fontWeight: FontWeight.normal,
              color: Color(0XFF597423),
              fontSize: 11,
            ),
          ),
        ),
        /*
        Container(
          padding:
              EdgeInsets.only(left: 10.0, right: 10.0, top: 20.0, bottom: 20.0),
          child: Text(
            productPrice + "\$",
            style: TextStyle(
              fontWeight: FontWeight.normal,
              color: Color(0XFFff7800),
              fontSize: 20,
            ),
          ),
        ),*/
        showSize
            ? Container(
                padding: EdgeInsets.only(top: 10.0, left: 10.0, right: 10.0, bottom: 10.0),
                child: Text(
                  sizeName,
                  style: TextStyle(
                    fontWeight: FontWeight.normal,
                    color: Color(0XFF679a00),
                    fontSize: 15,
                  ),
                ),
              )
            : Container(),
        showSize
            ? Container(
                padding: EdgeInsets.all(10.0),
                margin: EdgeInsets.only(right: 10.0, left: 10.0),
                color: Colors.white,
                child: InkWell(
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(_displaySize),
                      ),
                      Container(
                        child: Icon(Icons.keyboard_arrow_down),
                      )
                    ],
                  ),
                  onTap: () {
                    setState(() {
                      _optionList = _sizeList;
                    });
                    _showOption(2);
                  },
                ))
            : Container(),
        showMaterial
            ? Container(
                padding: EdgeInsets.only(top: 10.0, left: 10.0, right: 10.0, bottom: 10.0),
                child: Text(
                  materialName,
                  style: TextStyle(
                    fontWeight: FontWeight.normal,
                    color: Color(0XFF679a00),
                    fontSize: 15,
                  ),
                ),
              )
            : Container(),
        showMaterial
            ? Container(
                padding: EdgeInsets.all(10.0),
                margin: EdgeInsets.only(right: 10.0, left: 10.0),
                color: Colors.white,
                child: InkWell(
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(_displayMaterial),
                      ),
                      Container(
                        child: Icon(Icons.keyboard_arrow_down),
                      )
                    ],
                  ),
                  onTap: () {
                    setState(() {
                      _optionList = _materialList;
                    });
                    _showOption(3);
                  },
                ))
            : Container(),
        showAddIN
            ? Column(
                children: addINListMain.map(
                  (data) {
                    return data.name != ""
                        ? Column(
                            children: <Widget>[
                              Container(
                                padding: EdgeInsets.all(10),
                                margin: EdgeInsets.all(3),
                                color: Colors.black12,
                                child: InkWell(
                                  child: Row(
                                    children: <Widget>[
                                      Expanded(
                                        child: Text(data.name),
                                      ),
                                      Container(
                                        child: Icon(Icons.keyboard_arrow_down),
                                      )
                                    ],
                                  ),
                                  onTap: () {
                                    //Navigator.of(context).pop();
                                    //addINDropdown(data.name, data.id, data.sub);
                                  },
                                ),
                              ),
                              Column(
                                children: data.sub.map((dat) {
                                  return dat.name != ""
                                      ? InkWell(
                                          child: Container(
                                            padding: EdgeInsets.all(0),
                                            margin: EdgeInsets.all(3.0),
                                            color: Colors.white,
                                            child: data.type == 0 || data.type == 2
                                                ? Row(children: <Widget>[
                                                    Container(
                                                      width: 50,
                                                      height: 50,
                                                      child: Checkbox(
                                                        value: addINListMain[data.id].sub[dat.id].selected,
                                                        onChanged: (bool value) {
                                                          setState(
                                                            () {
                                                              if (data.type == 2) {
                                                                addINListMain.forEach((item001) {
                                                                  if (item001.id == data.id) {
                                                                    if (item001.sub != null) {
                                                                      item001.sub.forEach((item002) {
                                                                        if (item002.selected) {
                                                                          addINListMain[data.id].sub[item002.id].selected = false;
                                                                        }
                                                                      });
                                                                    }
                                                                  }
                                                                });
                                                              }
                                                              addINListMain[data.id].sub[dat.id].selected = value;
                                                              calAddInPrice();
                                                            },
                                                          );
                                                        },
                                                      ),
                                                    ),
                                                    Expanded(
                                                      child: Text(
                                                        "${dat.name}",
                                                        style: TextStyle(
                                                          fontWeight: FontWeight.normal,
                                                          color: Color(0xFF5a8308),
                                                          fontSize: 14,
                                                        ),
                                                      ),
                                                    ),
                                                    /*
                                                    Container(
                                                      padding:
                                                          EdgeInsets.all(10.0),
                                                      child: Text(
                                                        dat.price == 0.0
                                                            ? ""
                                                            : "${dat.price}${global_var.moneyUnit}",
                                                        style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.normal,
                                                          color:
                                                              Color(0xFF5a8308),
                                                          fontSize: 14,
                                                        ),
                                                      ),
                                                    ),*/
                                                  ])
                                                : Row(children: <Widget>[
                                                    Expanded(
                                                      child: RadioListTile(
                                                        groupValue: dat.selected ? dat.id : 0,
                                                        title: Text("${dat.name}"),
                                                        value: dat.id,
                                                        onChanged: (val) {
                                                          setState(
                                                            () {
                                                              addINListMain.forEach((item001) {
                                                                if (item001.id == data.id) {
                                                                  if (item001.sub != null) {
                                                                    item001.sub.forEach((item002) {
                                                                      if (item002.selected) {
                                                                        addINListMain[data.id].sub[item002.id].selected = false;
                                                                      }
                                                                    });
                                                                  }
                                                                }
                                                              });
                                                              addINListMain[data.id].sub[dat.id].selected = true;
                                                              calAddInPrice();
                                                            },
                                                          );
                                                        },
                                                      ),
                                                    ),
                                                    /*
                                                    Container(
                                                      padding:
                                                          EdgeInsets.all(10.0),
                                                      child: Text(
                                                        dat.price == 0.0
                                                            ? ""
                                                            : "${dat.price}${global_var.moneyUnit}",
                                                        style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.normal,
                                                          color:
                                                              Color(0xFF5a8308),
                                                          fontSize: 14,
                                                        ),
                                                      ),
                                                    ),*/
                                                  ]),
                                          ),
                                        )
                                      : Container();
                                }).toList(),
                              ),
                            ],
                          )
                        : Container();
                  },
                ).toList(),
              )
            : Container(),
        /*
        showAddIN
            ? Container(
                padding: EdgeInsets.all(10.0),
                margin: EdgeInsets.only(right: 10.0, left: 10.0, top: 5.0),
                color: Colors.white,
                child: InkWell(
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Text("Add in total:"),
                      ),
                      Container(
                        child: Text(addInPrice.toString() + "\$"),
                      )
                    ],
                  ),
                ))
            : Container(),*/
        showColor
            ? Container(
                padding: EdgeInsets.only(top: 10.0, left: 10.0, right: 10.0, bottom: 10.0),
                child: Text(
                  colorName,
                  style: TextStyle(
                    fontWeight: FontWeight.normal,
                    color: Color(0XFF679a00),
                    fontSize: 15,
                  ),
                ),
              )
            : Container(),
        showColor
            ? Container(
                padding: EdgeInsets.all(10.0),
                margin: EdgeInsets.only(right: 10.0, left: 10.0),
                color: Colors.white,
                child: InkWell(
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(_displayColor),
                      ),
                      Container(
                        child: Icon(Icons.keyboard_arrow_down),
                      )
                    ],
                  ),
                  onTap: () {
                    setState(() {
                      _optionList = _colorList;
                    });
                    _showOption(1);
                  },
                ))
            : Container(),
        /*Container(child: Text("Quantity:", textAlign: TextAlign.center)),
        Container(
            child: Row(
          children: <Widget>[
            InkWell(
              child: Container(
                width: 45,
                height: 45,
                margin: const EdgeInsets.only(top: 20.0, left: 80.0),
                padding: const EdgeInsets.only(top: 3.0, left: 17.0),
                decoration: AppTheme.quantityButtonDecoration,
                //       <--- BoxDecoration here
                child: Text(
                  "-",
                  style: TextStyle(fontSize: 30),
                ),
              ),
              onTap: () {
                setState(() {
                  if (_selectedQuantity > 1) {
                    _selectedQuantity = _selectedQuantity - 1;
                  }
                });
              },
            ),
            Expanded(
              child: Container(
                margin: const EdgeInsets.only(top: 15.0),
                padding: const EdgeInsets.all(2.0),
                decoration: AppTheme.quantityButtonDecoration,
                //       <--- BoxDecoration here
                child: Text(_selectedQuantity.toString(),
                    style: TextStyle(fontSize: 30),
                    textAlign: TextAlign.center),
              ),
            ),
            InkWell(
              child: Container(
                width: 45,
                height: 45,
                margin: const EdgeInsets.only(top: 20.0, right: 80.0),
                padding: const EdgeInsets.only(top: 3.0, left: 13.0),
                decoration: AppTheme.quantityButtonDecoration,
                //       <--- BoxDecoration here
                child: Text(
                  "+",
                  style: TextStyle(fontSize: 30),
                ),
              ),
              onTap: () {
                setState(() {
                  _selectedQuantity = _selectedQuantity + 1;
                });
              },
            ),
          ],
        )),*/
        Container(
          padding: AppTheme.homeScreenButtonPadding3,
          child: Html(
            data: productContent,
            padding: EdgeInsets.all(8.0),
            backgroundColor: Colors.white70,
            defaultTextStyle: TextStyle(fontFamily: 'serif'),
            linkStyle: const TextStyle(
              color: Colors.redAccent,
            ),
            onLinkTap: (url) {
              // open url in a webview
            },
            onImageTap: (src) {
              // Display the image in large form.
            },
          ),
        ),
        Container(
          padding: EdgeInsets.all(30.0),
        )
      ],
    );
  }

  Widget mainMenu() {
    //show product categogy
    return ListView(
        padding: EdgeInsets.all(0),
        //map List of our data to the ListView
        children: _listCatData.map((data) {
          return InkWell(
            child: Container(
              padding: AppTheme.homeScreenButtonPadding4,
              child: Row(children: <Widget>[
                Container(
                  width: 50,
                  height: 50,
                  decoration: new BoxDecoration(
                      shape: BoxShape.circle,
                      image: new DecorationImage(
                          fit: BoxFit.fill,
                          image: new NetworkImage(
                            data.imageIcon,
                          ))),
                ),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
                    Container(
                      padding: multiple ? AppTheme.homeScreenButtonPadding4 : AppTheme.homeScreenButtonPadding3,
                      child: Text(
                        data.name,
                        style: TextStyle(
                          fontWeight: FontWeight.normal,
                          color: Color(0xFF5a8308),
                          fontSize: multiple ? 12 : 14,
                        ),
                      ),
                    ),
                  ]),
                ),
              ]),
            ),
            onTap: () {
              //searchProduct(data.id);
              setState(() {
                _catTitle = data.name;
              });
              _selectedCat = data.id;
              getcatList2();
            },
          );
        }).toList());
  }

  Widget tabBar() {
    return Container(
        child: Row(children: <Widget>[
      Expanded(
          child: Center(
              child: InkWell(
        child: tabIndex == 0
            ? Container(
                padding: EdgeInsets.only(top: 20, left: 10, bottom: 5, right: 10),
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(width: 1.0, color: Color(0xFF2d561e)),
                  ),
                ),
                child: Text(
                  lang.menu,
                  overflow: TextOverflow.ellipsis,
                ),
              )
            : Container(
                padding: EdgeInsets.only(top: 20, left: 10, bottom: 5, right: 10),
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(width: 1.0, color: Color(0xFFFFFFFF)),
                  ),
                ),
                child: Text(
                  lang.menu,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
        onTap: () {
          setState(() {
            tabIndex = 0;
            tabTitle = lang.order;
          });
        },
      ))),
      Expanded(
          child: Center(
              child: InkWell(
        child: tabIndex == 1
            ? Container(
                padding: EdgeInsets.only(top: 20, left: 10, bottom: 5, right: 10),
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(width: 1.0, color: Color(0xFF2d561e)),
                  ),
                ),
                child: Text(
                  lang.feature,
                  overflow: TextOverflow.ellipsis,
                ),
              )
            : Container(
                padding: EdgeInsets.only(top: 20, left: 10, bottom: 5, right: 10),
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(width: 1.0, color: Color(0xFFFFFFFF)),
                  ),
                ),
                child: Text(
                  lang.feature,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
        onTap: () {
          getFeatureList();
          setState(() {
            tabIndex = 1;
            tabTitle = lang.feature;
          });
        },
      ))),
      Expanded(
          child: Center(
              child: InkWell(
        child: tabIndex == 2
            ? Container(
                padding: EdgeInsets.only(top: 20, left: 10, bottom: 5, right: 10),
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(width: 1.0, color: Color(0xFF2d561e)),
                  ),
                ),
                child: Text(
                  lang.cart + " (" + cartNumber.toString() + ")",
                  overflow: TextOverflow.ellipsis,
                ),
              )
            : Container(
                padding: EdgeInsets.only(top: 20, left: 10, bottom: 5, right: 10),
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(width: 1.0, color: Color(0xFFFFFFFF)),
                  ),
                ),
                child: Text(
                  lang.cart + " (" + cartNumber.toString() + ")",
                  overflow: TextOverflow.ellipsis,
                ),
              ),
        onTap: () {
          getCartList();
          setState(() {
            tabIndex = 2;
            tabTitle = lang.cart;
          });
        },
      ))),
      Expanded(
          child: Center(
              child: InkWell(
        child: tabIndex == 3
            ? Container(
                padding: EdgeInsets.only(top: 20, left: 10, bottom: 5, right: 10),
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(width: 1.0, color: Color(0xFF2d561e)),
                  ),
                ),
                child: Text(
                  lang.history,
                  overflow: TextOverflow.ellipsis,
                ),
              )
            : Container(
                padding: EdgeInsets.only(top: 20, left: 10, bottom: 5, right: 10),
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(width: 1.0, color: Color(0xFFFFFFFF)),
                  ),
                ),
                child: Text(
                  lang.history,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
        onTap: () {
          getHistoryList();
          setState(() {
            tabIndex = 3;
            tabTitle = lang.history;
          });
        },
      )))
    ]));
  }

  Widget cartTab() {
    //Cart tab content
    return ListView(
      padding: const EdgeInsets.all(8),
      children: <Widget>[
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: cartList.map((item) {
            return Container(
              color: Color.fromARGB(200, 255, 255, 255),
              margin: EdgeInsets.all(10.0),
              padding: EdgeInsets.all(10.0),
              child: InkWell(
                child: Stack(
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.all(10.0),
                      child: Row(children: <Widget>[
                        Container(
                          width: 100,
                          height: 100,
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
                        Expanded(
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
                            Container(
                              padding: EdgeInsets.only(bottom: 5.0),
                              margin: EdgeInsets.only(left: 10.0),
                              child: Text(
                                item.productName,
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFFff7800),
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
                              margin: EdgeInsets.only(left: 10.0),
                              padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
                              child: InkWell(
                                child: Row(
                                  children: <Widget>[
                                    Expanded(
                                      child: Text("Price:"),
                                    ),
                                    Container(
                                      child: Text(
                                        fmf.copyWith(amount: double.parse(item.productPrice)).output.symbolOnLeft,
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
                              margin: EdgeInsets.only(left: 10.0),
                              padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
                              child: InkWell(
                                child: Row(
                                  children: <Widget>[
                                    Expanded(
                                      child: Text("Quantity:"),
                                    ),
                                    Container(
                                      child: Text(
                                        item.productQuantity,
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
                              margin: EdgeInsets.only(left: 10.0),
                              child: Row(children: <Widget>[
                                InkWell(
                                  child: Container(
                                    width: 45,
                                    height: 45,
                                    margin: const EdgeInsets.only(top: 5.0),
                                    padding: const EdgeInsets.only(top: 3.0, left: 17.0),
                                    decoration: AppTheme.quantityButtonDecoration,
                                    //       <--- BoxDecoration here
                                    child: Text(
                                      "-",
                                      style: TextStyle(fontSize: 30, color: Colors.blue),
                                    ),
                                  ),
                                  onTap: () {
                                    var t = int.parse(item.productQuantity);
                                    if (t > 1) {
                                      t = t - 1;
                                    }
                                    var price = double.parse(item.productPrice);
                                    var ttal = t * price;
                                    var addInttal = t * cartDataList[item.index].addInTotalMoney;
                                    _totalMoney = _totalMoney - cartDataList[item.index].productPrice - cartDataList[item.index].addInTotalMoney;
                                    setState(() {
                                      item.productQuantity = t.toString();
                                      item.total = ttal.toString();
                                      item.addInSubTotal = addInttal;
                                      cartDataList[item.index].quantity = t;
                                      _totalMoney = _totalMoney;
                                    });
                                    updateCartQuantity();
                                  },
                                ),
                                InkWell(
                                  child: Container(
                                    width: 45,
                                    height: 45,
                                    margin: const EdgeInsets.only(top: 5.0, left: 5.0),
                                    padding: const EdgeInsets.only(top: 3.0, left: 13.0),
                                    decoration: AppTheme.quantityButtonDecoration,
                                    //       <--- BoxDecoration here
                                    child: Text(
                                      "+",
                                      style: TextStyle(fontSize: 30, color: Colors.blue),
                                    ),
                                  ),
                                  onTap: () {
                                    var t = int.parse(item.productQuantity);
                                    t = t + 1;
                                    var price = double.parse(item.productPrice);
                                    var ttal = t * price;
                                    _totalMoney = _totalMoney + cartDataList[item.index].productPrice + cartDataList[item.index].addInTotalMoney;
                                    var addInttal = t * cartDataList[item.index].addInTotalMoney;
                                    setState(() {
                                      item.productQuantity = t.toString();
                                      item.total = ttal.toString();
                                      cartDataList[item.index].quantity = t;
                                      _totalMoney = _totalMoney;
                                      item.addInSubTotal = addInttal;
                                    });
                                    updateCartQuantity();
                                  },
                                ),
                                InkWell(
                                  child: Container(
                                    width: 45,
                                    height: 45,
                                    margin: const EdgeInsets.only(top: 5.0, left: 5.0),
                                    padding: const EdgeInsets.only(top: 0, left: 0),
                                    decoration: AppTheme.quantityButtonDecoration,
                                    child: Icon(
                                      Icons.delete_forever,
                                      color: Colors.red,
                                      size: 36.0,
                                    ),
                                  ),
                                  onTap: () {
                                    _deleteProductDialog(item.index);
                                  },
                                ),
                              ]),
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
                              margin: EdgeInsets.only(left: 10.0),
                              padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
                              child: InkWell(
                                child: Row(
                                  children: <Widget>[
                                    Expanded(
                                      child: Text("Subtotal:"),
                                    ),
                                    Container(
                                      child: Text(
                                        fmf.copyWith(amount: double.parse(item.total)).output.symbolOnLeft,
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
                              margin: EdgeInsets.only(left: 10.0),
                              padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
                              child: InkWell(
                                child: Row(
                                  children: <Widget>[
                                    Expanded(
                                      child: Text("Add in:"),
                                    ),
                                    Container(
                                      child: Text(
                                        fmf.copyWith(amount: item.addInTotalMoney).output.symbolOnLeft,
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
                              margin: EdgeInsets.only(left: 10.0),
                              padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
                              child: InkWell(
                                child: Row(
                                  children: <Widget>[
                                    Expanded(
                                      child: Text("Add in subtotal:"),
                                    ),
                                    Container(
                                      child: Text(
                                        fmf.copyWith(amount: item.addInSubTotal).output.symbolOnLeft,
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
                            item.colorName != null &&
                                    item.colorName != "" &&
                                    item.colorName != "null" &&
                                    item.color != null &&
                                    item.color != "" &&
                                    item.color != "null"
                                ? Container(
                                    decoration: BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(
                                          //                    <--- top side
                                          color: Colors.black12,
                                          width: 1.0,
                                        ),
                                      ),
                                    ),
                                    margin: EdgeInsets.only(left: 10.0),
                                    padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
                                    child: InkWell(
                                      child: Row(
                                        children: <Widget>[
                                          Expanded(
                                            child: Text(
                                              "${item.colorName}" + ": ",
                                            ),
                                          ),
                                          Container(
                                            child: Text(
                                              "${item.color}",
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
                                  )
                                : Container(),
                            item.sizeName != null &&
                                    item.sizeName != "" &&
                                    item.sizeName != "null" &&
                                    item.size != null &&
                                    item.size != "" &&
                                    item.size != "null"
                                ? Container(
                                    decoration: BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(
                                          //                    <--- top side
                                          color: Colors.black12,
                                          width: 1.0,
                                        ),
                                      ),
                                    ),
                                    margin: EdgeInsets.only(left: 10.0),
                                    padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
                                    child: InkWell(
                                      child: Row(
                                        children: <Widget>[
                                          Expanded(
                                            child: Text(
                                              "${item.sizeName}" + ": ",
                                            ),
                                          ),
                                          Container(
                                            child: Text(
                                              "${item.size}",
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
                                  )
                                : Container(),
                            item.materialName != null &&
                                    item.materialName != "" &&
                                    item.materialName != "null" &&
                                    item.material != null &&
                                    item.material != "" &&
                                    item.material != "null"
                                ? Container(
                                    decoration: BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(
                                          //                    <--- top side
                                          color: Colors.black12,
                                          width: 1.0,
                                        ),
                                      ),
                                    ),
                                    margin: EdgeInsets.only(left: 10.0),
                                    padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
                                    child: InkWell(
                                      child: Row(
                                        children: <Widget>[
                                          Expanded(
                                            child: Text(
                                              "${item.materialName}" + ": ",
                                            ),
                                          ),
                                          Container(
                                            child: Text(
                                              "${item.material}",
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
                                  )
                                : Container(),
                            Html(
                              data: item.addin,
                              padding: EdgeInsets.only(top: 10.0, bottom: 10.0, left: 10.0),
                              backgroundColor: Colors.white70,
                              defaultTextStyle: TextStyle(fontFamily: 'serif'),
                              linkStyle: const TextStyle(
                                color: Colors.redAccent,
                              ),
                            ),
                          ]),
                        ),
                      ]),
                    ),
                    /*Positioned(
                      right: 0,
                      top: 0,
                      child: InkWell(
                        child: Container(
                          padding: EdgeInsets.all(10.0),
                          color: Colors.redAccent,
                          child: Text(
                            "X",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        onTap: () {
                          _deleteProductDialog(item.index);
                        },
                      ),
                    ),*/
                  ],
                ),
                onTap: () {
                  //callBack();
                },
              ),
            );
          }).toList(),
        ),
        Container(
          margin: EdgeInsets.only(top: 20.0, bottom: 20.0, left: 10.0, right: 10.0),
          padding: EdgeInsets.all(20.0),
          color: Colors.white,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
            Container(
              padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
              child: Text(
                "Summary",
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
                      child: Text("Subtotal:"),
                    ),
                    Container(
                      child: Text(
                        fmf.copyWith(amount: _totalMoney).output.symbolOnLeft,
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
                      child: Text("Tax:"),
                    ),
                    Container(
                      child: Text(
                        fmf.copyWith(amount: _totalMoney * _taxValue / 100).output.symbolOnLeft,
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
                      child: Text("Total:"),
                    ),
                    Container(
                      child: Text(
                        fmf.copyWith(amount: _totalMoney + _totalMoney * _taxValue / 100).output.symbolOnLeft,
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
          ]),
        ),
        Container(
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
                    "Shop (tap to change):",
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
                          child: Text("Name:"),
                        ),
                        Container(
                          child: Text(
                            _shopName,
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
                          child: Text("Address:"),
                        ),
                        Container(
                          child: Text(
                            _shopAddress,
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
                            _shopPhone,
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
            onTap: () {
              _showShop();
            },
          ),
        ),
        /*
              Container(
                margin: EdgeInsets.only(top: 20.0),
                padding: EdgeInsets.only(left: 10.0, right: 10.0),
                child: TextField(
                  decoration: AppTheme.InputFullnameDecoration,
                  keyboardType: TextInputType.number,
                  controller: _c_fullname,
                  onChanged: (text) {
                    _c_fullname.text = text;
                  },
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 20.0),
                padding: EdgeInsets.only(left: 10.0, right: 10.0),
                child: TextField(
                  decoration: AppTheme.InputPhoneDecoration,
                  keyboardType: TextInputType.number,
                  controller: _c_phone,
                  onChanged: (text) {
                    _c_phone.text = text;
                  },
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 20.0),
                padding: EdgeInsets.only(left: 10.0, right: 10.0),
                child: TextField(
                  decoration: AppTheme.InputEmailDecoration,
                  keyboardType: TextInputType.number,
                  controller: _c_email,
                  onChanged: (text) {
                    _c_email.text = text;
                  },
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 20.0),
                padding: EdgeInsets.only(left: 10.0, right: 10.0),
                child: TextField(
                  decoration: AppTheme.InputAddressDecoration,
                  keyboardType: TextInputType.number,
                  controller: _c_address,
                  onChanged: (text) {
                    _c_address.text = text;
                  },
                ),
              ),*/
        Container(padding: EdgeInsets.all(30.0)),
      ],
    );
  }

  Widget featureTab() {
    return ListView(
      padding: const EdgeInsets.all(8),
      children: <Widget>[
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: featureList.map((item) {
            return Container(
              color: Color.fromARGB(200, 255, 255, 255),
              margin: EdgeInsets.all(10.0),
              padding: EdgeInsets.all(10.0),
              child: InkWell(
                child: Stack(
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.all(10.0),
                      color: Color.fromARGB(200, 255, 255, 255),
                      child: Row(children: <Widget>[
                        Container(
                          width: 90,
                          height: 90,
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
                        Expanded(
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
                            Container(
                              padding: EdgeInsets.only(bottom: 5.0, left: 5.0),
                              child: Text(
                                item.productName,
                                style: TextStyle(
                                  fontWeight: FontWeight.normal,
                                  color: Color(0xFFff7800),
                                  fontSize: multiple ? 12 : 14,
                                ),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.only(top: 5.0, bottom: 5.0, left: 5.0),
                              child: Text(
                                item.productPrice + "\$",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0XFF2c3e09),
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ]),
                        ),
                      ]),
                    ),
                  ],
                ),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => ShoppingCartPage(item.id)));
                },
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget historyTab() {
    return ListView(
      padding: const EdgeInsets.all(8),
      children: <Widget>[
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: historyList.map((item) {
            return Container(
              color: Color.fromARGB(200, 255, 255, 255),
              margin: EdgeInsets.all(10.0),
              padding: EdgeInsets.all(10.0),
              child: InkWell(
                child: Stack(
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.all(10.0),
                      color: Colors.transparent,
                      child: Row(children: <Widget>[
                        Expanded(
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
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
                                    Expanded(
                                      child: Text("#ID:"),
                                    ),
                                    Container(
                                      child: Text(
                                        "${item.id.toString()}",
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
                                    Expanded(
                                      child: Text("Time:"),
                                    ),
                                    Container(
                                      child: Text(
                                        "${item.time}",
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
                                    Expanded(
                                      child: Text("Total:"),
                                    ),
                                    Container(
                                      child: Text(
                                        "${item.total.toString()}",
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
                                    Expanded(
                                      child: Text("Shop:"),
                                    ),
                                    Container(
                                      child: Text(
                                        "${item.shopName}",
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
                                    Expanded(
                                      child: Text("Address:"),
                                    ),
                                    Container(
                                      child: Text(
                                        "${item.shopAddress}",
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
                                    Expanded(
                                      child: Text("Phone:"),
                                    ),
                                    Container(
                                      child: Text(
                                        "${item.shopPhone}",
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
                          ]),
                        ),
                      ]),
                    ),
                  ],
                ),
                onTap: () {
                  getOrderDetail(item.id);
                },
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget menuTab() {
    return Container(
      //map List of our data to the ListView
      child: _showMainMenu == 1 ? mainMenu() : (_showMainMenu == 0 && _showDetail == 0 ? productList() : productDetail()),
    );
  }

  Widget productList() {
    //List of product
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
      children: homeList.map((item) {
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
                  _curentProductID = item.id;
                  setState(() {
                    _showDetail = 1;
                    _curentProductID = item.id;
                    homeList = HomeList.homeList;
                  });
                  getContent();
                },
              )),
        );
      }).toList(),
    );
  }

  Widget addINDropdown2(String name, int parent, List<AddINListSub> data) {
    return ListView(
      shrinkWrap: true,
      children: data.map((dat) {
        return dat.name != ""
            ? InkWell(
                child: Container(
                  padding: EdgeInsets.all(0),
                  margin: EdgeInsets.all(3.0),
                  color: Colors.black12,
                  child: Row(children: <Widget>[
                    Container(
                      width: 50,
                      height: 50,
                      child: Checkbox(
                        value: addINListMain[parent].sub[dat.id].selected,
                        onChanged: (bool value) {
                          setState(() {
                            addINListMain[parent].sub[dat.id].selected = value;
                            Navigator.of(context).pop();
                          });
                        },
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(10.0),
                      child: Text(
                        dat.name + " (${dat.price}${global_var.moneyUnit})",
                        style: TextStyle(
                          fontWeight: FontWeight.normal,
                          color: Color(0xFF5a8308),
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ]),
                ),
              )
            : Container(height: 0);
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    sysContext = context;
    return Container(
        decoration: new BoxDecoration(
          image: new DecorationImage(
            image: new NetworkImage(backgroundImage),
            fit: BoxFit.fill,
          ),
        ),
        child: Scaffold(
          backgroundColor: Color.fromRGBO(0, 0, 0, 0.1),
          appBar: AppBar(
            title: Text(tabTitle),
            leading: new IconButton(
              icon: new Icon(Icons.keyboard_arrow_left),
              onPressed: () {
                _selectedCat = 0;
                getcatList2();
                setState(() {
                  _showMainMenu = 1;
                  _showDetail = 0;
                  _catTitle = "";
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
          body: Column(
            children: <Widget>[
              _showTabBar == 1 ? tabBar() : Container(),
              Container(
                height: tabIndex == 0 ? 50.0 : 0,
                padding: EdgeInsets.all(10.0),
                child: Text(_catTitle,
                    style: new TextStyle(
                      fontSize: 20.0,
                      fontFamily: 'Roboto',
                      color: new Color(0xFF26C6DA),
                    )),
              ),
              tabIndex == 0 ? Expanded(child: menuTab()) : Container(),
              tabIndex == 1 ? Expanded(child: featureTab()) : Container(),
              tabIndex == 2 ? Expanded(child: cartTab()) : Container(),
              tabIndex == 3 ? Expanded(child: historyTab()) : Container(),
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
          floatingActionButton: tabIndex == 0 && _showDetail == 1
              ? FloatingActionButton.extended(
                  onPressed: () {
                    saveCartData(1);
                  },
                  label: Text('Add to cart'),
                  icon: Icon(Icons.shopping_cart),
                  backgroundColor: Colors.green,
                )
              : tabIndex == 2
                  ? FloatingActionButton.extended(
                      onPressed: () {
                        if (global_var.safeCode != "") {
                          doOrder();
                        } else {
                          _showLoginInfo();
                        }
                      },
                      label: Text('Checkout'),
                      icon: Icon(Icons.shopping_cart),
                      backgroundColor: Colors.green,
                    )
                  : Container(),
        ),);
  }

  Future<void> addINDropdown(String name, int parent, List<AddINListSub> data) async {
    return showDialog<void>(
        context: context,
        barrierDismissible: true, // user must tap button!
        builder: (BuildContext context) {
          return AlertDialog(
              contentPadding: EdgeInsets.all(5.0),
              titlePadding: EdgeInsets.only(top: 10.0, left: 5.0),
              title: Text(name),
              content: ListView(
                  shrinkWrap: true,
                  children: data.map((dat) {
                    return dat.name != ""
                        ? InkWell(
                            child: Container(
                              padding: EdgeInsets.all(0),
                              margin: EdgeInsets.all(3.0),
                              color: Colors.black12,
                              child: Row(children: <Widget>[
                                Container(
                                  width: 50,
                                  height: 50,
                                  child: Checkbox(
                                    value: addINListMain[parent].sub[dat.id].selected,
                                    onChanged: (bool value) {
                                      setState(() {
                                        addINListMain[parent].sub[dat.id].selected = value;
                                        Navigator.of(context).pop();
                                        addINDropdown(name, parent, data);
                                      });
                                    },
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.all(10.0),
                                  child: Text(
                                    dat.name + " (${dat.price}${global_var.moneyUnit})",
                                    style: TextStyle(
                                      fontWeight: FontWeight.normal,
                                      color: Color(0xFF5a8308),
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ]),
                            ),
                          )
                        : Container(height: 0);
                  }).toList()),
              actions: <Widget>[
                FlatButton(
                  child: Text('Close'),
                  onPressed: () {
                    Navigator.of(context).pop();
                    //show selected add in
                    String str = "";
                    addInPrice = 0;
                    addINListMain.forEach((item) {
                      var str2 = "";
                      if (item.sub != null) {
                        item.sub.forEach((it) {
                          if (it.selected) {
                            addInPrice = addInPrice + it.price;
                            if (str2 == "") {
                              str2 = it.name;
                            } else {
                              str2 = str2 + ", " + it.name;
                            }
                          }
                        });
                      }
                      if (str2 != "") {
                        if (str == "") {
                          str = str2;
                        } else {
                          str = str + "," + str2;
                        }
                      }
                    });
                    /*
                    setState(() {
                      addInPrice = addInPrice;
                      if (str != "") {
                        _addINText = str;
                      } else {
                        _addINText = "Select add in";
                      }
                    });
                    _showAddIN();*/
                  },
                ),
              ]);
        });
  }

  Future<void> _showOption(int type) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: EdgeInsets.all(5.0),
          titlePadding: EdgeInsets.only(top: 10.0, left: 5.0),
          title: Text(type == 1 ? colorName : (type == 2 ? sizeName : materialName)),
          content: ListView(
            shrinkWrap: true,
            padding: EdgeInsets.all(0),
            //map List of our data to the ListView
            children: _optionList.map((data) {
              return RadioListTile(
                groupValue: type == 1 ? _selectedColor : type == 2 ? _selectedSize : _selectedMaterial,
                title: Text(data.name),
                value: data.id,
                onChanged: (val) {
                  setState(() {
                    if (type == 1) {
                      _selectedColor = data.id;
                      setState(() {
                        _displayColor = data.name;
                      });
                    } else if (type == 2) {
                      _selectedSize = data.id;
                      setState(() {
                        _displaySize = data.name;
                      });
                    } else if (type == 3) {
                      _selectedMaterial = data.id;
                      setState(() {
                        _displayMaterial = data.name;
                      });
                    }
                    Navigator.of(context).pop();
                  });
                },
              );

              /* return InkWell(
                child: Container(
                  padding: EdgeInsets.all(10.0),
                  margin: EdgeInsets.only(top: 3.0, bottom: 3.0),
                  color: Colors.grey,
                  child: Text(
                    data.name,
                    style: TextStyle(
                      fontWeight: FontWeight.normal,
                      color: Color(0xFF000000),
                      fontSize: 14,
                    ),
                  ),
                ),
                onTap: () {
                  if (type == 1) {
                    _selectedColor = data.id;
                    setState(() {
                      _displayColor = data.name;
                    });
                  } else if (type == 2) {
                    _selectedSize = data.id;
                    setState(() {
                      _displaySize = data.name;
                    });
                  } else if (type == 3) {
                    _selectedMaterial = data.id;
                    setState(() {
                      _displayMaterial = data.name;
                    });
                  }
                  Navigator.of(context).pop();
                },
              );*/
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

  Future<void> _showInfo2(String content, int action) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        getCartInfo();
        return AlertDialog(
          contentPadding: EdgeInsets.all(5.0),
          titlePadding: EdgeInsets.only(top: 10.0, left: 5.0),
          title: Text('Info'),
          content: Container(
            child: Text(content),
          ),
          actions: <Widget>[
            action == 1
                ? FlatButton(
                    child: Text('Open cart'),
                    onPressed: () {
                      setState(() {
                        tabIndex = 2;
                        tabTitle = lang.cart;
                      });
                      Navigator.of(context).pop();
                      getCartList();
                    },
                  )
                : action == 2
                    ? FlatButton(
                        child: Text('Login'),
                        onPressed: () {
                          setState(() {
                            tabIndex = 0;
                            tabTitle = lang.cart;
                          });
                          Navigator.push(context, MaterialPageRoute(builder: (context) => LoginPage()));
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

  Future<void> _showDeleteProductConfirm(int index) async {
    return showDialog<void>(
      context: sysContext,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: EdgeInsets.all(5.0),
          titlePadding: EdgeInsets.only(top: 10.0, left: 5.0),
          title: Text(lang.deleteCartItemTitle),
          content: Container(
            child: Text(lang.deleteCartItemConfirm),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('No'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text('Yes'),
              onPressed: () {
                Navigator.of(context).pop();
                _deleteProduct(index);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showShop() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: EdgeInsets.all(5.0),
          titlePadding: EdgeInsets.only(top: 10.0, left: 5.0),
          title: Text('Shop list'),
          content: ListView(
            shrinkWrap: true,
            padding: EdgeInsets.all(0),
            //map List of our data to the ListView
            children: shopList.map((data) {
              return InkWell(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      width: 1,
                      color: Colors.black12,
                    ),
                    color: Color.fromARGB(200, 250, 250, 250),
                  ),
                  margin: EdgeInsets.all(10.0),
                  padding: EdgeInsets.all(20.0),
                  child: InkWell(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
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
                          padding: EdgeInsets.only(top: 0.0, bottom: 10.0),
                          child: InkWell(
                            child: Row(
                              children: <Widget>[
                                Expanded(
                                  child: Text("Name:"),
                                ),
                                Container(
                                  child: Text(
                                    "${data.name}",
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
                ),
                onTap: () {
                  changeShop(data.id);
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

/*
  Future<void> _showOrderDetail() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: EdgeInsets.all(5.0),
          titlePadding: EdgeInsets.only(top: 10.0, left: 5.0),
          title: Text('Order Detail'),
          content: ListView(
            shrinkWrap: true,
            padding: EdgeInsets.all(0),
            //map List of our data to the ListView
            children: cartDetailProductList.map((item) {
              return Container(
                color: Color.fromARGB(200, 255, 255, 255),
                margin: EdgeInsets.all(10.0),
                padding: EdgeInsets.all(10.0),
                child: InkWell(
                  child: Stack(
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.all(10.0),
                        child: Row(children: <Widget>[
                          Container(
                            width: 100,
                            height: 100,
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
                          Expanded(
                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: <Widget>[
                              Container(
                                padding: EdgeInsets.only(bottom: 5.0),
                                margin: EdgeInsets.only(left: 10.0),
                                child: Text(
                                  item.productName,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFFff7800),
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
                                margin: EdgeInsets.only(left: 10.0),
                                padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
                                child: InkWell(
                                  child: Row(
                                    children: <Widget>[
                                      Expanded(
                                        child: Text("Price:"),
                                      ),
                                      Container(
                                        child: Text(
                                          fmf.copyWith(amount: double.parse(item.productPrice)).output.symbolOnLeft,
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
                                margin: EdgeInsets.only(left: 10.0),
                                padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
                                child: InkWell(
                                  child: Row(
                                    children: <Widget>[
                                      Expanded(
                                        child: Text("Quantity:"),
                                      ),
                                      Container(
                                        child: Text(
                                          item.productQuantity,
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
                                margin: EdgeInsets.only(left: 10.0),
                                child: Row(children: <Widget>[
                                  InkWell(
                                    child: Container(
                                      width: 45,
                                      height: 45,
                                      margin: const EdgeInsets.only(top: 5.0),
                                      padding: const EdgeInsets.only(top: 3.0, left: 17.0),
                                      decoration: AppTheme.quantityButtonDecoration,
                                      //       <--- BoxDecoration here
                                      child: Text(
                                        "-",
                                        style: TextStyle(fontSize: 30, color: Colors.blue),
                                      ),
                                    ),
                                    onTap: () {
                                      var t = int.parse(item.productQuantity);
                                      if (t > 1) {
                                        t = t - 1;
                                      }
                                      var price = double.parse(item.productPrice);
                                      var ttal = t * price;
                                      var addInttal = t * cartDataList[item.index].addInTotalMoney;
                                      _totalMoney = _totalMoney - cartDataList[item.index].productPrice - cartDataList[item.index].addInTotalMoney;
                                      setState(() {
                                        item.productQuantity = t.toString();
                                        item.total = ttal.toString();
                                        item.addInSubTotal = addInttal;
                                        cartDataList[item.index].quantity = t;
                                        _totalMoney = _totalMoney;
                                      });
                                      updateCartQuantity();
                                    },
                                  ),
                                  InkWell(
                                    child: Container(
                                      width: 45,
                                      height: 45,
                                      margin: const EdgeInsets.only(top: 5.0, left: 5.0),
                                      padding: const EdgeInsets.only(top: 3.0, left: 13.0),
                                      decoration: AppTheme.quantityButtonDecoration,
                                      //       <--- BoxDecoration here
                                      child: Text(
                                        "+",
                                        style: TextStyle(fontSize: 30, color: Colors.blue),
                                      ),
                                    ),
                                    onTap: () {
                                      var t = int.parse(item.productQuantity);
                                      t = t + 1;
                                      var price = double.parse(item.productPrice);
                                      var ttal = t * price;
                                      _totalMoney = _totalMoney + cartDataList[item.index].productPrice + cartDataList[item.index].addInTotalMoney;
                                      var addInttal = t * cartDataList[item.index].addInTotalMoney;
                                      setState(() {
                                        item.productQuantity = t.toString();
                                        item.total = ttal.toString();
                                        cartDataList[item.index].quantity = t;
                                        _totalMoney = _totalMoney;
                                        item.addInSubTotal = addInttal;
                                      });
                                      updateCartQuantity();
                                    },
                                  ),
                                  InkWell(
                                    child: Container(
                                      width: 45,
                                      height: 45,
                                      margin: const EdgeInsets.only(top: 5.0, left: 5.0),
                                      padding: const EdgeInsets.only(top: 0, left: 0),
                                      decoration: AppTheme.quantityButtonDecoration,
                                      child: Icon(
                                        Icons.delete_forever,
                                        color: Colors.red,
                                        size: 36.0,
                                      ),
                                    ),
                                    onTap: () {
                                      _deleteProductDialog(item.index);
                                    },
                                  ),
                                ]),
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
                                margin: EdgeInsets.only(left: 10.0),
                                padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
                                child: InkWell(
                                  child: Row(
                                    children: <Widget>[
                                      Expanded(
                                        child: Text("Subtotal:"),
                                      ),
                                      Container(
                                        child: Text(
                                          fmf.copyWith(amount: double.parse(item.total)).output.symbolOnLeft,
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
                                margin: EdgeInsets.only(left: 10.0),
                                padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
                                child: InkWell(
                                  child: Row(
                                    children: <Widget>[
                                      Expanded(
                                        child: Text("Add in:"),
                                      ),
                                      Container(
                                        child: Text(
                                          fmf.copyWith(amount: item.addInTotalMoney).output.symbolOnLeft,
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
                                margin: EdgeInsets.only(left: 10.0),
                                padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
                                child: InkWell(
                                  child: Row(
                                    children: <Widget>[
                                      Expanded(
                                        child: Text("Add in subtotal:"),
                                      ),
                                      Container(
                                        child: Text(
                                          fmf.copyWith(amount: item.addInSubTotal).output.symbolOnLeft,
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
                              item.colorName != null &&
                                      item.colorName != "" &&
                                      item.colorName != "null" &&
                                      item.color != null &&
                                      item.color != "" &&
                                      item.color != "null"
                                  ? Container(
                                      decoration: BoxDecoration(
                                        border: Border(
                                          bottom: BorderSide(
                                            //                    <--- top side
                                            color: Colors.black12,
                                            width: 1.0,
                                          ),
                                        ),
                                      ),
                                      margin: EdgeInsets.only(left: 10.0),
                                      padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
                                      child: InkWell(
                                        child: Row(
                                          children: <Widget>[
                                            Expanded(
                                              child: Text(
                                                "${item.colorName}" + ": ",
                                              ),
                                            ),
                                            Container(
                                              child: Text(
                                                "${item.color}",
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
                                    )
                                  : Container(),
                              item.sizeName != null &&
                                      item.sizeName != "" &&
                                      item.sizeName != "null" &&
                                      item.size != null &&
                                      item.size != "" &&
                                      item.size != "null"
                                  ? Container(
                                      decoration: BoxDecoration(
                                        border: Border(
                                          bottom: BorderSide(
                                            //                    <--- top side
                                            color: Colors.black12,
                                            width: 1.0,
                                          ),
                                        ),
                                      ),
                                      margin: EdgeInsets.only(left: 10.0),
                                      padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
                                      child: InkWell(
                                        child: Row(
                                          children: <Widget>[
                                            Expanded(
                                              child: Text(
                                                "${item.sizeName}" + ": ",
                                              ),
                                            ),
                                            Container(
                                              child: Text(
                                                "${item.size}",
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
                                    )
                                  : Container(),
                              item.materialName != null &&
                                      item.materialName != "" &&
                                      item.materialName != "null" &&
                                      item.material != null &&
                                      item.material != "" &&
                                      item.material != "null"
                                  ? Container(
                                      decoration: BoxDecoration(
                                        border: Border(
                                          bottom: BorderSide(
                                            //                    <--- top side
                                            color: Colors.black12,
                                            width: 1.0,
                                          ),
                                        ),
                                      ),
                                      margin: EdgeInsets.only(left: 10.0),
                                      padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
                                      child: InkWell(
                                        child: Row(
                                          children: <Widget>[
                                            Expanded(
                                              child: Text(
                                                "${item.materialName}" + ": ",
                                              ),
                                            ),
                                            Container(
                                              child: Text(
                                                "${item.material}",
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
                                    )
                                  : Container(),
                              Html(
                                data: item.addin,
                                padding: EdgeInsets.only(top: 10.0, bottom: 10.0, left: 10.0),
                                backgroundColor: Colors.white70,
                                defaultTextStyle: TextStyle(fontFamily: 'serif'),
                                linkStyle: const TextStyle(
                                  color: Colors.redAccent,
                                ),
                              ),
                            ]),
                          ),
                        ]),
                      ),
                      /*Positioned(
                      right: 0,
                      top: 0,
                      child: InkWell(
                        child: Container(
                          padding: EdgeInsets.all(10.0),
                          color: Colors.redAccent,
                          child: Text(
                            "X",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        onTap: () {
                          _deleteProductDialog(item.index);
                        },
                      ),
                    ),*/
                    ],
                  ),
                  onTap: () {
                    //callBack();
                  },
                ),
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
*/
  Future<void> _showOrderDetail() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: EdgeInsets.all(5.0),
          titlePadding: EdgeInsets.only(top: 10.0, left: 5.0),
          title: Text('Order Detail'),
          content: ListView(
            shrinkWrap: true,
            padding: EdgeInsets.all(0),
            //map List of our data to the ListView
            children: cartDetailProductList.map((item) {
              return Container(
                color: Color.fromARGB(200, 255, 255, 255),
                margin: EdgeInsets.all(0.0),
                padding: EdgeInsets.all(10.0),
                child: InkWell(
                  child: Stack(
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.all(0.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Center(
                              child: Container(
                                width: 100,
                                height: 100,
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
                            Container(
                              padding: EdgeInsets.only(bottom: 5.0),
                              margin: EdgeInsets.only(left: 10.0),
                              child: Text(
                                item.productName,
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFFff7800),
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
                              margin: EdgeInsets.only(left: 10.0),
                              padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
                              child: InkWell(
                                child: Row(
                                  children: <Widget>[
                                    Expanded(
                                      child: Text("Price:"),
                                    ),
                                    Container(
                                      child: Text(
                                        fmf.copyWith(amount: double.parse(item.productPrice)).output.symbolOnLeft,
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
                              margin: EdgeInsets.only(left: 10.0),
                              padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
                              child: InkWell(
                                child: Row(
                                  children: <Widget>[
                                    Expanded(
                                      child: Text("Quantity:"),
                                    ),
                                    Container(
                                      child: Text(
                                        item.productQuantity,
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
                              margin: EdgeInsets.only(left: 10.0),
                              padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
                              child: InkWell(
                                child: Row(
                                  children: <Widget>[
                                    Expanded(
                                      child: Text("Add in:"),
                                    ),
                                    Container(
                                      child: Text(
                                        fmf.copyWith(amount: item.addInTotalMoney).output.symbolOnLeft,
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
                              margin: EdgeInsets.only(left: 10.0),
                              padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
                              child: InkWell(
                                child: Row(
                                  children: <Widget>[
                                    Expanded(
                                      child: Text("Add in subtotal:"),
                                    ),
                                    Container(
                                      child: Text(
                                        fmf.copyWith(amount: item.addInSubTotal).output.symbolOnLeft,
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
                              margin: EdgeInsets.only(left: 10.0),
                              padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
                              child: InkWell(
                                child: Row(
                                  children: <Widget>[
                                    Expanded(
                                      child: Text("Subtotal:"),
                                    ),
                                    Container(
                                      child: Text(
                                        fmf.copyWith(amount: double.parse(item.total)).output.symbolOnLeft,
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
                            item.colorName != null &&
                                    item.colorName != "" &&
                                    item.colorName != "null" &&
                                    item.color != null &&
                                    item.color != "" &&
                                    item.color != "null"
                                ? Container(
                                    decoration: BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(
                                          //                    <--- top side
                                          color: Colors.black12,
                                          width: 1.0,
                                        ),
                                      ),
                                    ),
                                    margin: EdgeInsets.only(left: 10.0),
                                    padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
                                    child: InkWell(
                                      child: Row(
                                        children: <Widget>[
                                          Expanded(
                                            child: Text(
                                              "${item.colorName}" + ": ",
                                            ),
                                          ),
                                          Container(
                                            child: Text(
                                              "${item.color}",
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
                                  )
                                : Container(),
                            item.sizeName != null &&
                                    item.sizeName != "" &&
                                    item.sizeName != "null" &&
                                    item.size != null &&
                                    item.size != "" &&
                                    item.size != "null"
                                ? Container(
                                    decoration: BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(
                                          //                    <--- top side
                                          color: Colors.black12,
                                          width: 1.0,
                                        ),
                                      ),
                                    ),
                                    margin: EdgeInsets.only(left: 10.0),
                                    padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
                                    child: InkWell(
                                      child: Row(
                                        children: <Widget>[
                                          Expanded(
                                            child: Text(
                                              "${item.sizeName}" + ": ",
                                            ),
                                          ),
                                          Container(
                                            child: Text(
                                              "${item.size}",
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
                                  )
                                : Container(),
                            item.materialName != null &&
                                    item.materialName != "" &&
                                    item.materialName != "null" &&
                                    item.material != null &&
                                    item.material != "" &&
                                    item.material != "null"
                                ? Container(
                                    decoration: BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(
                                          //                    <--- top side
                                          color: Colors.black12,
                                          width: 1.0,
                                        ),
                                      ),
                                    ),
                                    margin: EdgeInsets.only(left: 10.0),
                                    padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
                                    child: InkWell(
                                      child: Row(
                                        children: <Widget>[
                                          Expanded(
                                            child: Text(
                                              "${item.materialName}" + ": ",
                                            ),
                                          ),
                                          Container(
                                            child: Text(
                                              "${item.material}",
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
                                  )
                                : Container(),
                            Html(
                              data: item.addin,
                              padding: EdgeInsets.only(top: 10.0, bottom: 10.0, left: 10.0),
                              backgroundColor: Colors.white70,
                              defaultTextStyle: TextStyle(fontFamily: 'serif'),
                              linkStyle: const TextStyle(
                                color: Colors.redAccent,
                              ),
                            ),
                          ],
                        ),
                      ),
                      /*Positioned(
                      right: 0,
                      top: 0,
                      child: InkWell(
                        child: Container(
                          padding: EdgeInsets.all(10.0),
                          color: Colors.redAccent,
                          child: Text(
                            "X",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        onTap: () {
                          _deleteProductDialog(item.index);
                        },
                      ),
                    ),*/
                    ],
                  ),
                  onTap: () {
                    //callBack();
                  },
                ),
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

  Future<void> _showLoginInfo() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: EdgeInsets.all(5.0),
          titlePadding: EdgeInsets.only(top: 10.0, left: 5.0),
          title: Text('Select Option'),
          content: ListView(shrinkWrap: true, padding: EdgeInsets.all(0),
              //map List of our data to the ListView
              children: <Widget>[
                InkWell(
                  child: Container(
                    padding: EdgeInsets.all(10.0),
                    color: Colors.green,
                    margin: EdgeInsets.only(bottom: 6.0),
                    child: Text("Login"),
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                    Navigator.push(context, MaterialPageRoute(builder: (context) => LoginPage()));
                  },
                ),
                InkWell(
                  child: Container(
                    padding: EdgeInsets.all(10.0),
                    color: Colors.green,
                    margin: EdgeInsets.only(bottom: 6.0),
                    child: Text("Register"),
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                    Navigator.push(context, MaterialPageRoute(builder: (context) => RegisterPage()));
                  },
                ),
                InkWell(
                  child: Container(
                    padding: EdgeInsets.all(10.0),
                    color: Colors.green,
                    margin: EdgeInsets.only(bottom: 6.0),
                    child: Text("Guest"),
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                    doOrder();
                  },
                ),
              ]),
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

  Future<bool> getData() async {
    await Future<dynamic>.delayed(const Duration(milliseconds: 0));
    return true;
  }

/*
  Future<void> _showAddIN() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: EdgeInsets.all(5.0),
          titlePadding: EdgeInsets.only(top: 10.0, left: 5.0),
          title: Text('Add in'),
          content:
              StatefulBuilder(// You need this, notice the parameters below:
                  builder: (BuildContext context, StateSetter setState) {
            return Column(
              children: <Widget>[
                ListView(
                  shrinkWrap: true,
                  padding: EdgeInsets.all(0),
                  //map List of our data to the ListView
                  children: addINListMain.map((data) {
                    return data.name != ""
                        ? Column(
                            children: <Widget>[
                              Container(
                                padding: EdgeInsets.all(10),
                                margin: EdgeInsets.all(3),
                                color: Colors.black12,
                                child: InkWell(
                                  child: Row(
                                    children: <Widget>[
                                      Expanded(
                                        child: Text(data.name),
                                      ),
                                      Container(
                                        child: Icon(Icons.keyboard_arrow_down),
                                      )
                                    ],
                                  ),
                                  onTap: () {
                                    //Navigator.of(context).pop();
                                    //addINDropdown(data.name, data.id, data.sub);
                                  },
                                ),
                              ),
                              Column(
                                children: data.sub.map((dat) {
                                  return dat.name != ""
                                      ? InkWell(
                                          child: Container(
                                            padding: EdgeInsets.all(0),
                                            margin: EdgeInsets.all(3.0),
                                            color: Colors.white,
                                            child: Row(children: <Widget>[
                                              Container(
                                                width: 50,
                                                height: 50,
                                                child: Checkbox(
                                                  value: addINListMain[data.id]
                                                      .sub[dat.id]
                                                      .selected,
                                                  onChanged: (bool value) {
                                                    setState(
                                                      () {
                                                        addINListMain
                                                            .forEach((item001) {
                                                          if (item001.id ==
                                                              data.id) {
                                                            if (item001.sub !=
                                                                null) {
                                                              item001.sub
                                                                  .forEach(
                                                                      (item002) {
                                                                if (item002
                                                                    .selected) {
                                                                  addINListMain[
                                                                          data
                                                                              .id]
                                                                      .sub[item002
                                                                          .id]
                                                                      .selected = false;
                                                                }
                                                              });
                                                            }
                                                          }
                                                        });
                                                        addINListMain[data.id]
                                                            .sub[dat.id]
                                                            .selected = value;
                                                        //Navigator.of(context).pop();
                                                        //_showAddIN();
                                                      },
                                                    );
                                                  },
                                                ),
                                              ),
                                              Container(
                                                padding: EdgeInsets.all(10.0),
                                                child: Text(
                                                  dat.name +
                                                      " (${dat.price}${global_var.moneyUnit})",
                                                  style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.normal,
                                                    color: Color(0xFF5a8308),
                                                    fontSize: 14,
                                                  ),
                                                ),
                                              ),
                                            ]),
                                          ),
                                        )
                                      : Container(height: 0);
                                }).toList(),
                              ),
                            ],
                          )
                        : Container();
                  }).toList(),
                ),
              ],
            );
          }),
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
  }*/
}
