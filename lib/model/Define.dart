class HomeListHome {
  HomeListHome(
      {this.id = 0,
      this.imagePath = '',
      this.productName = '',
      this.productDescript = '',
      this.productPrice = '0'});

  int id;
  String imagePath;
  String productName;
  String productDescript;
  String productPrice;
  static List<HomeListHome> homeList = [];
}

class HistoryList {
  HistoryList(
      {this.id = 0,
      this.total = 0.0,
      this.shopName = '',
      this.time = '',
      this.shopAddress = '',
      this.shopPhone = ''});

  int id;
  double total;
  String shopName;
  String time;
  String shopAddress;
  String shopPhone;
  static List<HistoryList> historyList = [];
}

class HomeList {
  HomeList(
      {this.id = 0,
      this.index = 0,
      this.imagePath = '',
      this.productName = '',
      this.productDescript = '',
      this.productPrice = '0',
      this.productQuantity = '0',
      this.colorName = '',
      this.color = '',
      this.sizeName = '',
      this.size = '',
      this.materialName = '',
      this.material = '',
      this.total = '',
      this.productString = '',
      this.addin = '',
      this.addInTotalMoney = 0.0,
      this.addInSubTotal = 0.0
      });

  int id;
  int index;
  String imagePath;
  String productName;
  String productDescript;
  String productPrice;
  String productQuantity;
  String colorName;
  String color;
  String sizeName;
  String size;
  String materialName;
  String material;
  String total;
  String productString;
  String addin;
  double addInTotalMoney;
  double addInSubTotal;
  static List<HomeList> homeList = [];
}

class ShopList {
  ShopList({this.id = 0, this.name = '', this.address = '', this.phone = ''});

  int id;
  String name;
  String address;
  String phone;
}

class CatList {
  CatList(
      {this.id = 0, this.name = '', this.imageIcon = '', this.haveSub = ''});

  int id;
  String name;
  String imageIcon;
  String haveSub;
  static List<CatList> catList = [];
}

class DataList {
  DataList({
    this.id = 0,
    this.name = '',
  });

  int id;
  String name;
}

class CountryList {
  CountryList({
    this.id = 0,
    this.name = '',
  });

  int id;
  String name;
}

class StateList {
  StateList({
    this.countryID = 0,
    this.id = 0,
    this.name = '',
  });

  int countryID;
  int id;
  String name;
}

class AddINList {
  AddINList({
    this.id = 0,
    this.type = 0,
    this.name = '',
    this.sub,
  });

  int id;
  int type;
  String name;
  List<AddINListSub> sub;
}

class AddINListSub {
  AddINListSub({
    this.id = 0,
    this.name = '',
    this.price = 0.0,
    this.selected = true,
  });

  int id;
  String name;
  double price;
  bool selected;
}

class CartDataList {
  CartDataList({
    this.id = 0,
    this.index = 0,
    this.quantity = 0,
    this.color = 0,
    this.size = 0,
    this.material = 0,
    this.productPrice = 0.0,
    this.addIn,
    this.addInTotalMoney=0.0,
  });

  int id, quantity, color, size, material,index;
  double addInTotalMoney;
  double productPrice;
  Map toJson() => {
        'id': id,
        'quantity': quantity,
        'color': color,
        'size': size,
        'material': material,
        'addIn': addIn,
        'addInTotalMoney': addInTotalMoney,
        'productPrice': productPrice,
      };
  List<AddInListCart> addIn = [];
}

class AddInListCart {
  AddInListCart({this.id = 0});

  int id;

  Map toJson() => {'id': id};
}

class TopupList {
  TopupList({
    this.index = 0,
    this.name = '',
    this.selected = false,
  });

  int index;
  String name;
  bool selected;
}

