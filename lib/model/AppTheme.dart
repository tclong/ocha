import 'package:flutter/material.dart';
import 'package:ocha/model/lang.dart' as lang;

class AppTheme {
  AppTheme._();

  static const Color notWhite = Color(0xFFEDF0F2);
  static const Color nearlyWhite = Color(0xFFFEFEFE);
  static const Color white = Color(0xFFFFFFFF);
  static const Color nearlyBlack = Color(0xFF213333);
  static const Color grey = Color(0xFF3A5160);
  static const Color red = Color(0xFFFF0000);
  static const Color blue = Color(0xFF0000FF);
  static const Color dark_grey = Color(0xFF313A44);
  static const Color nearlyDarkBlue = Color(0xFF2633C5);
  static const Color background = Color(0xFFF2F3F8);
  static const Color darkText = Color(0xFF253840);
  static const Color darkerText = Color(0xFF17262A);
  static const Color lightText = Color(0xFF4A6572);
  static const Color deactivatedText = Color(0xFF767676);
  static const Color dismissibleBackground = Color(0xFF364A54);
  static const Color chipBackground = Color(0xFFEEF1F3);
  static const Color spacer = Color(0xFFF2F2F2);
  static const Color textfield_focus = Color(0xFF0095ff);
  static const Color textfield_Color = white;
  static const Color textFillColor = Color(0xFFEFEFEF);
  static const Color inputBorderColor = Color.fromRGBO(0, 0, 0, 0.1);
  static const String fontName = 'Roboto';
  static const double paddingTextField = 10.0;
  static const Color labelColor =  Color(0XFF365418);
  static const Color hintColor =  Color(0XFF365418);
  static const Color suffixColor =  Colors.green;

  static const TextTheme textTheme =
      TextTheme(display1: display1, headline: headline, title: title, subtitle: subtitle, body2: body2, body1: body1, caption: caption);

  static const TextStyle error = TextStyle(
    fontFamily: fontName,
    fontWeight: FontWeight.normal,
    fontSize: 15,
    color: red,
  );

  static const TextStyle link = TextStyle(
    fontFamily: fontName,
    fontWeight: FontWeight.normal,
    fontSize: 14,
    color: white,
  );

  static const TextStyle display1 = TextStyle(
    // h4 -> display1
    fontFamily: fontName,
    fontWeight: FontWeight.bold,
    fontSize: 36,
    letterSpacing: 0.4,
    height: 0.9,
    color: darkerText,
  );

  static const TextStyle headline = TextStyle(
    // h5 -> headline
    fontFamily: fontName,
    fontWeight: FontWeight.bold,
    fontSize: 24,
    letterSpacing: 0.27,
    color: darkerText,
  );

  static const TextStyle headline_title = TextStyle(
    // h5 -> headline
    fontFamily: fontName,
    fontWeight: FontWeight.bold,
    fontSize: 24,
    letterSpacing: 0.27,
    color: Colors.white,
  );

  static const TextStyle title = TextStyle(
    // h6 -> title
    fontFamily: fontName,
    fontWeight: FontWeight.bold,
    fontSize: 16,
    letterSpacing: 0.18,
    color: darkerText,
  );

  static const TextStyle subtitle = TextStyle(
    // subtitle2 -> subtitle
    fontFamily: fontName,
    fontWeight: FontWeight.w400,
    fontSize: 14,
    letterSpacing: -0.04,
    color: darkText,
  );

  static const TextStyle body2 = TextStyle(
    // body1 -> body2
    fontFamily: fontName,
    fontWeight: FontWeight.w400,
    fontSize: 14,
    letterSpacing: 0.2,
    color: darkText,
  );

  static const TextStyle body1 = TextStyle(
    // body2 -> body1
    fontFamily: fontName,
    fontWeight: FontWeight.w400,
    fontSize: 16,
    letterSpacing: -0.05,
    color: darkText,
  );

  static const TextStyle caption = TextStyle(
    // Caption -> caption
    fontFamily: fontName,
    fontWeight: FontWeight.w400,
    fontSize: 12,
    letterSpacing: 0.2,
    color: lightText, // was lightText
  );

  static const TextStyle txt1 = TextStyle(
    // Caption -> caption
    fontFamily: fontName,
    fontWeight: FontWeight.bold,
    fontSize: 12,
    letterSpacing: 0.2,
    color: Colors.black, // was lightText
  );

  static const TextStyle txt2 = TextStyle(
    // Caption -> caption
    fontFamily: fontName,
    fontWeight: FontWeight.w400,
    fontSize: 12,
    letterSpacing: 0.2,
    color: Colors.black, // was lightText
  );

  static const BoxShadow field_shadow = BoxShadow(
    color: Colors.red,
    blurRadius: 20.0, // has the effect of softening the shadow
    spreadRadius: 5.0, // has the effect of extending the shadow
    offset: Offset(
      10.0, // horizontal, move right 10
      10.0, // vertical, move down 10
    ),
  );

  static const OutlineInputBorder field_OutlineInputBorder = OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(4)),
      borderSide: BorderSide(
        width: 1,
      ));

  static const OutlineInputBorder field_focusedBorder = OutlineInputBorder(
    borderSide: BorderSide(width: 1, color: textfield_focus),
  );

  static const OutlineInputBorder field_focusedBorder2 = OutlineInputBorder(
    borderSide: BorderSide(width: 1, color: Colors.green),
  );

  static const OutlineInputBorder field_disabledBorder = OutlineInputBorder(
    borderSide: BorderSide(width: 1, color: Colors.orange),
  );

  static const OutlineInputBorder field_enabledBorder = OutlineInputBorder(
    borderSide: BorderSide(width: 1, color: Colors.white),
  );

  static const UnderlineInputBorder fieldBorder = UnderlineInputBorder(
    borderRadius: const BorderRadius.all(
      const Radius.circular(0.0),
    ),
    borderSide: BorderSide(
      width: 1,
      color: Color(0XFFCECECE),
    ),
  );

  static const UnderlineInputBorder fieldBorder1 = UnderlineInputBorder(
    borderRadius: const BorderRadius.all(
      const Radius.circular(0.0),
    ),
    borderSide: BorderSide(
      width: 1,
      color: Color(0XFFCECECE),
    ),
  );

  static const UnderlineInputBorder fieldBorder2 = UnderlineInputBorder(
    borderRadius: const BorderRadius.all(
      const Radius.circular(0.0),
    ),
    borderSide: BorderSide(
      width: 1,
      color: Color(0XFFCECECE),
    ),
  );

  static const OutlineInputBorder field_enabledBorder2 = OutlineInputBorder(
    borderSide: BorderSide(width: 1, color: Colors.grey),
  );

  static const OutlineInputBorder field_errorBorder = OutlineInputBorder(
    borderSide: BorderSide(width: 1, color: Colors.red),
  );

  static const OutlineInputBorder field_focusedErrorBorder = OutlineInputBorder(
    borderSide: BorderSide(width: 1, color: Colors.yellowAccent),
  );

  static final inputUsernameDecoration = new InputDecoration(
    contentPadding: const EdgeInsets.only(left: paddingTextField),
    filled: true,
    fillColor: textFillColor,
    labelStyle: TextStyle(fontSize: 15.0, color: labelColor),
    hintStyle: TextStyle(fontSize: 15.0, color: hintColor),
    labelText: lang.username,
    enabledBorder: fieldBorder2,
    focusedBorder: fieldBorder1,
    border: fieldBorder,
    suffixStyle: const TextStyle(color: suffixColor),
  );

  static final inputPaymentNumberDecoration = new InputDecoration(
    //isDense: true,
    contentPadding: const EdgeInsets.only(left: paddingTextField),
    focusedBorder: fieldBorder1,
    enabledBorder: fieldBorder2,
    border: fieldBorder,
    filled: true,
    fillColor: textFillColor,
    labelText: "",
  );

  static final inputEmailDecoration = new InputDecoration(
    contentPadding: const EdgeInsets.only(left: paddingTextField),
    focusedBorder: fieldBorder1,
    enabledBorder: fieldBorder2,
    border: fieldBorder,
    filled: true,
    fillColor: textFillColor,
    labelStyle: TextStyle(fontSize: 15.0, color: labelColor),
    hintStyle: TextStyle(fontSize: 15.0, color: hintColor),
    labelText: lang.email,
    suffixStyle: const TextStyle(color: suffixColor),
  );

  static final inputEmailDecorationLogin = new InputDecoration(
    contentPadding: const EdgeInsets.only(left: paddingTextField),
    focusedBorder: fieldBorder1,
    enabledBorder: fieldBorder2,
    border: fieldBorder,
    filled: true,
    fillColor: textFillColor,
    labelStyle: TextStyle(fontSize: 15.0, color: labelColor),
    hintStyle: TextStyle(fontSize: 15.0, color: hintColor),
    labelText: lang.email,
  );

  static final inputNameOfCardDecoration = new InputDecoration(
    contentPadding: const EdgeInsets.only(left: paddingTextField),
    focusedBorder: fieldBorder1,
    enabledBorder: fieldBorder2,
    border: fieldBorder,
    filled: true,
    fillColor: textFillColor,
    labelStyle: TextStyle(fontSize: 15.0, color: labelColor),
    hintStyle: TextStyle(fontSize: 15.0, color: hintColor),
    labelText: lang.cardName,
  );

  static final inputPhoneDecoration = new InputDecoration(
    focusedBorder: fieldBorder1,
    enabledBorder: fieldBorder2,
    border: fieldBorder,
    contentPadding: const EdgeInsets.only(left: paddingTextField),
    filled: true,
    fillColor: textFillColor,
    labelStyle: TextStyle(fontSize: 15.0, color: labelColor),
    hintStyle: TextStyle(fontSize: 15.0, color: hintColor),
    labelText: lang.phone,
  );

  static final inputAddressDecoration = new InputDecoration(
    focusedBorder: fieldBorder1,
    enabledBorder: fieldBorder2,
    border: fieldBorder,
    contentPadding: const EdgeInsets.only(left: paddingTextField),
    filled: true,
    fillColor: textFillColor,
    labelStyle: TextStyle(fontSize: 15.0, color: labelColor),
    hintStyle: TextStyle(fontSize: 15.0, color: hintColor),
    labelText: lang.address,
  );

  static final inputAddress2Decoration = new InputDecoration(
    focusedBorder: fieldBorder1,
    enabledBorder: fieldBorder2,
    border: fieldBorder,
    contentPadding: const EdgeInsets.only(left: paddingTextField),
    filled: true,
    fillColor: textFillColor,
    labelStyle: TextStyle(fontSize: 15.0, color: labelColor),
    hintStyle: TextStyle(fontSize: 15.0, color: hintColor),
    labelText: lang.address2,
  );

  static final inputCityDecoration = new InputDecoration(
    focusedBorder: fieldBorder1,
    enabledBorder: fieldBorder2,
    border: fieldBorder,
    contentPadding: const EdgeInsets.only(left: paddingTextField),
    filled: true,
    fillColor: textFillColor,
    labelStyle: TextStyle(fontSize: 15.0, color: labelColor),
    hintStyle: TextStyle(fontSize: 15.0, color: hintColor),
    labelText: lang.city,
  );

  static final inputFullnameDecoration = new InputDecoration(
    focusedBorder: fieldBorder1,
    enabledBorder: fieldBorder2,
    border: fieldBorder,
    contentPadding: const EdgeInsets.only(left: paddingTextField),
    filled: true,
    fillColor: textFillColor,
    labelStyle: TextStyle(fontSize: 15.0, color: labelColor),
    hintStyle: TextStyle(fontSize: 15.0, color: hintColor),
    labelText: lang.fullname,
  );

  static final inputFromDecoration = new InputDecoration(
    focusedBorder: fieldBorder1,
    enabledBorder: fieldBorder2,
    border: fieldBorder,
    contentPadding: const EdgeInsets.only(left: paddingTextField),
    filled: true,
    fillColor: textFillColor,
    labelStyle: TextStyle(fontSize: 15.0, color: labelColor),
    hintStyle: TextStyle(fontSize: 15.0, color: hintColor),
    labelText: lang.giftFrom,
  );

  static final inputToDecoration = new InputDecoration(
    focusedBorder: fieldBorder1,
    enabledBorder: fieldBorder2,
    border: fieldBorder,
    contentPadding: const EdgeInsets.only(left: paddingTextField),
    filled: true,
    fillColor: textFillColor,
    labelStyle: TextStyle(fontSize: 15.0, color: labelColor),
    hintStyle: TextStyle(fontSize: 15.0, color: hintColor),
    labelText: lang.giftTo,
  );

  static final inputFirstnameDecoration = new InputDecoration(
    focusedBorder: fieldBorder1,
    enabledBorder: fieldBorder2,
    border: fieldBorder,
    contentPadding: const EdgeInsets.only(left: paddingTextField),
    filled: true,
    fillColor: textFillColor,
    labelStyle: TextStyle(fontSize: 15.0, color: labelColor),
    hintStyle: TextStyle(fontSize: 15.0, color: hintColor),
    labelText: lang.firstName,
    suffixStyle: const TextStyle(color: suffixColor),
  );

  static final inputLastnameDecoration = new InputDecoration(
    focusedBorder: fieldBorder1,
    enabledBorder: fieldBorder2,
    border: fieldBorder,
    contentPadding: const EdgeInsets.only(left: paddingTextField),
    filled: true,
    fillColor: textFillColor,
    labelStyle: TextStyle(fontSize: 15.0, color: labelColor),
    hintStyle: TextStyle(fontSize: 15.0, color: hintColor),
    labelText: lang.lastName,
    suffixStyle: const TextStyle(color: suffixColor),
  );

  static final inputCardNameDecoration = new InputDecoration(
    focusedBorder: fieldBorder1,
    enabledBorder: fieldBorder2,
    border: fieldBorder,
    contentPadding: const EdgeInsets.only(left: paddingTextField),
    filled: true,
    fillColor: textFillColor,
    labelStyle: TextStyle(fontSize: 15.0, color: labelColor),
    hintStyle: TextStyle(fontSize: 15.0, color: hintColor),
    labelText: lang.cardName,
  );

  static final inputCardNumberDecoration = new InputDecoration(
    focusedBorder: fieldBorder1,
    enabledBorder: fieldBorder2,
    border: fieldBorder,
    contentPadding: const EdgeInsets.only(left: paddingTextField),
    filled: true,
    fillColor: textFillColor,
    labelStyle: TextStyle(fontSize: 15.0, color: labelColor),
    hintStyle: TextStyle(fontSize: 15.0, color: hintColor),
    labelText: lang.cardNumber,
  );

  static final inputCardCodeDecoration = new InputDecoration(
    focusedBorder: fieldBorder1,
    enabledBorder: fieldBorder2,
    border: fieldBorder,
    contentPadding: const EdgeInsets.only(left: paddingTextField),
    filled: true,
    fillColor: textFillColor,
    labelStyle: TextStyle(fontSize: 15.0, color: labelColor),
    hintStyle: TextStyle(fontSize: 15.0, color: hintColor),
    labelText: lang.cardCVN,
  );

  static final inputZipcodeDecoration = new InputDecoration(
    focusedBorder: fieldBorder1,
    enabledBorder: fieldBorder2,
    border: fieldBorder,
    contentPadding: const EdgeInsets.only(left: paddingTextField),
    filled: true,
    fillColor: textFillColor,
    labelStyle: TextStyle(fontSize: 15.0, color: labelColor),
    hintStyle: TextStyle(fontSize: 15.0, color: hintColor),
    labelText: lang.zipcode,
  );

  static final inputExpMonthDecoration = new InputDecoration(
    focusedBorder: fieldBorder1,
    enabledBorder: fieldBorder2,
    border: fieldBorder,
    contentPadding: const EdgeInsets.only(left: paddingTextField),
    filled: true,
    fillColor: textFillColor,
    labelStyle: TextStyle(fontSize: 15.0, color: labelColor),
    hintStyle: TextStyle(fontSize: 15.0, color: hintColor),
    labelText: lang.expMonth,
  );

  static final inputExpYearDecoration = new InputDecoration(
    focusedBorder: fieldBorder1,
    enabledBorder: fieldBorder2,
    border: fieldBorder,
    contentPadding: const EdgeInsets.only(left: paddingTextField),
    filled: true,
    fillColor: textFillColor,
    labelStyle: TextStyle(fontSize: 15.0, color: labelColor),
    hintStyle: TextStyle(fontSize: 15.0, color: hintColor),
    labelText: lang.expYear,
  );

  static final inputPasswordDecoration = new InputDecoration(
    focusedBorder: fieldBorder1,
    enabledBorder: fieldBorder2,
    border: fieldBorder,
    contentPadding: const EdgeInsets.only(left: paddingTextField),
    filled: true,
    fillColor: textFillColor,
    labelStyle: TextStyle(fontSize: 15.0, color: labelColor),
    hintStyle: TextStyle(fontSize: 15.0, color: hintColor),
    labelText: lang.password,
  );

  static final inputPasswordDecorationLogin = new InputDecoration(
    focusedBorder: fieldBorder1,
    enabledBorder: fieldBorder2,
    border: fieldBorder,
    contentPadding: const EdgeInsets.only(left: paddingTextField),
    filled: true,
    fillColor: textFillColor,
    labelStyle: TextStyle(fontSize: 15.0, color: labelColor),
    hintStyle: TextStyle(fontSize: 15.0, color: hintColor),
    labelText: lang.password,
  );

  static final inputGiftAmountDecoration = new InputDecoration(
    focusedBorder: fieldBorder1,
    enabledBorder: fieldBorder2,
    border: fieldBorder,
    contentPadding: const EdgeInsets.only(left: paddingTextField),
    filled: true,
    fillColor: textFillColor,
    labelStyle: TextStyle(fontSize: 15.0, color: labelColor),
    hintStyle: TextStyle(fontSize: 15.0, color: hintColor),
    labelText: lang.amount,
  );

  static final inputMessageDecoration = new InputDecoration(
    focusedBorder: fieldBorder1,
    enabledBorder: fieldBorder2,
    border: fieldBorder,
    contentPadding: const EdgeInsets.only(left: paddingTextField),
    filled: true,
    fillColor: textFillColor,
    labelStyle: TextStyle(fontSize: 15.0, color: labelColor),
    hintStyle: TextStyle(fontSize: 15.0, color: hintColor),
    labelText: lang.giftMessage,
  );

  static final inputNewPasswordDecoration = new InputDecoration(
    focusedBorder: fieldBorder1,
    enabledBorder: fieldBorder2,
    border: fieldBorder,
    contentPadding: const EdgeInsets.only(left: paddingTextField),
    filled: true,
    fillColor: textFillColor,
    labelStyle: TextStyle(fontSize: 15.0, color: labelColor),
    hintStyle: TextStyle(fontSize: 15.0, color: hintColor),
    labelText: lang.newPassword,
  );

  static final inputNewPassword2Decoration = new InputDecoration(
    focusedBorder: fieldBorder1,
    enabledBorder: fieldBorder2,
    border: fieldBorder,
    contentPadding: const EdgeInsets.only(left: paddingTextField),
    filled: true,
    fillColor: textFillColor,
    labelStyle: TextStyle(fontSize: 15.0, color: labelColor),
    hintStyle: TextStyle(fontSize: 15.0, color: hintColor),
    labelText: lang.newPassword2,
  );

  static final inputRessetCodeDecoration = new InputDecoration(
    focusedBorder: fieldBorder1,
    enabledBorder: fieldBorder2,
    border: fieldBorder,
    contentPadding: const EdgeInsets.only(left: paddingTextField),
    filled: true,
    fillColor: textFillColor,
    labelStyle: TextStyle(fontSize: 15.0, color: labelColor),
    hintStyle: TextStyle(fontSize: 15.0, color: hintColor),
    labelText: lang.resetPassCode2,
  );

  static final inputStateDecoration = new InputDecoration(
    focusedBorder: fieldBorder1,
    enabledBorder: fieldBorder2,
    border: fieldBorder,
    contentPadding: const EdgeInsets.only(left: paddingTextField),
    filled: true,
    fillColor: textFillColor,
    labelStyle: TextStyle(fontSize: 15.0, color: labelColor),
    hintStyle: TextStyle(fontSize: 15.0, color: hintColor),
    labelText: lang.state,
  );

  static final homeScreenButtonDecoration = new BoxDecoration(
    border: Border.all(
      color: white,
      width: 1,
    ),
    borderRadius: BorderRadius.circular(4),
    color: Color.fromARGB(200, 255, 255, 255),
  );

  static final contentButtonDecoration = new BoxDecoration(
    border: Border.all(
      color: white,
      width: 1,
    ),
    borderRadius: BorderRadius.circular(4),
    color: Color.fromARGB(200, 255, 255, 255),
  );

  static final quantityButtonDecoration = new BoxDecoration(
    border: Border.all(
      color: Colors.black12,
      width: 1,
    ),
    borderRadius: BorderRadius.circular(50),
    color: Color.fromARGB(200, 255, 255, 255),
  );

  static final homeScreenButtonMargin = const EdgeInsets.only(left: 0, right: 0, top: 0, bottom: 0);
  static final homeScreenButtonPadding = const EdgeInsets.only(left: 10.0, right: 0, top: 0, bottom: 0);
  static final homeScreenButtonPadding2 = const EdgeInsets.only(left: 5.0, right: 0, top: 0, bottom: 0);
  static final homeScreenButtonPadding3 = const EdgeInsets.only(left: 10.0, right: 5.0, top: 5, bottom: 0);
  static final homeScreenButtonPadding4 = const EdgeInsets.only(left: 10.0, right: 5.0, top: 10, bottom: 0);
  static final homeScreenButtonPadding5 = const EdgeInsets.only(left: 10.0, right: 5.0, top: 15, bottom: 0);
}

class HexColor extends Color {
  HexColor(final String hexColor) : super(_getColorFromHex(hexColor));

  static int _getColorFromHex(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll('#', '');
    if (hexColor.length == 6) {
      hexColor = 'FF' + hexColor;
    }
    return int.parse(hexColor, radix: 16);
  }
}
