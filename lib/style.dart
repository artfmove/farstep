import 'package:flutter/material.dart';

class Style {
  final Color color;
  final FontWeight fontWeight;
  final FontStyle fontStyle;
  Style({this.color, this.fontWeight, this.fontStyle});

  static InputDecoration textField(String labelTextStr, context) {
    return InputDecoration(
      errorMaxLines: 5,
      labelStyle: TextStyle(
        fontSize: MediaQuery.of(context).size.width > 230 ? 13 : 9,
      ),
      contentPadding: EdgeInsets.fromLTRB(
          12,
          MediaQuery.of(context).size.width > 230 ? 12 : 6,
          12,
          MediaQuery.of(context).size.width > 230 ? 12 : 6),
      labelText: labelTextStr,
      focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: Colors.red,
          ),
          borderRadius: BorderRadius.circular(40)),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(40),
      ),
    );
  }

  static double imageHeight(context) =>
      MediaQuery.of(context).size.height > 650 ? 200 : 150;

  Color dialogColor(context) {
    return MediaQuery.of(context).platformBrightness == Brightness.dark
        ? Colors.grey[900]
        : Colors.grey[300];
  }

  Color contrastColor(context) {
    return MediaQuery.of(context).platformBrightness == Brightness.dark
        ? Colors.grey[300]
        : Colors.grey[600];
  }

  TextStyle placeInfo1(context) {
    return TextStyle(
        fontSize: MediaQuery.of(context).size.width > 230 ? 15 : 11,
        color: MediaQuery.of(context).platformBrightness == Brightness.dark
            ? Colors.grey
            : Colors.grey[600]);
  }

  TextStyle placeInfo2(context) {
    return TextStyle(
        fontSize: MediaQuery.of(context).size.width > 230 ? 15 : 11,
        color: color);
  }

  TextStyle text1(context) {
    return TextStyle(
        fontSize: MediaQuery.of(context).size.width > 230 ? 28 : 20,
        color: color);
  }

  TextStyle text2(context) {
    return TextStyle(
        fontSize: MediaQuery.of(context).size.width > 230 ? 25 : 19,
        color: color);
  }

  TextStyle text3(context) {
    return TextStyle(
        fontSize: MediaQuery.of(context).size.width > 230 ? 20 : 16,
        color: color);
  }

  TextStyle text4(context) {
    return TextStyle(
        fontSize: MediaQuery.of(context).size.width > 230 ? 16 : 12,
        color: color);
  }

  TextStyle text5(context) {
    return TextStyle(
        fontSize: MediaQuery.of(context).size.width > 230 ? 14 : 10,
        color: color);
  }

  TextStyle text6(context) {
    return TextStyle(
        fontSize: MediaQuery.of(context).size.width > 230 ? 12 : 8,
        color: color);
  }

  TextStyle text7(context) {
    return TextStyle(
        fontSize: MediaQuery.of(context).size.width > 230 ? 10 : 7,
        color: color);
  }

  TextStyle appBar(context) {
    return TextStyle(
      fontSize: MediaQuery.of(context).size.width > 230 ? 18 : 15,
      color: Theme.of(context).textTheme.bodyText1.color,
    );
  }

  TextStyle dialogTitle(context) {
    return TextStyle(
      fontSize: MediaQuery.of(context).size.width > 230 ? 17 : 13,
    );
  }

  TextStyle dialogContent(context) {
    return TextStyle(
      fontSize: MediaQuery.of(context).size.width > 230 ? 14 : 11,
    );
  }

  TextStyle dialogOk(context) {
    return TextStyle(
        fontSize: MediaQuery.of(context).size.width > 230 ? 16 : 12,
        color: Colors.red);
  }

  TextStyle dialogCancel(context) {
    return TextStyle(
        fontSize: MediaQuery.of(context).size.width > 230 ? 16 : 12,
        color: Theme.of(context).textTheme.bodyText1.color);
  }
}
