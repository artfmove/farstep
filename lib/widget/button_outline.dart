import 'package:flutter/material.dart';
import '../style.dart';

class ButtonOutline extends StatelessWidget {
  final String text;
  final Function function;
  var currentMode;
  var mode;
  ButtonOutline(this.text, this.function, this.currentMode, this.mode);
  @override
  Widget build(BuildContext context) {
    return IntrinsicWidth(
      child: TextButton(
        style: TextButton.styleFrom(
            shadowColor: Colors.transparent,
            shape: new RoundedRectangleBorder(
              borderRadius: new BorderRadius.circular(20.0),
            ),
            backgroundColor:
                mode == currentMode ? Colors.red : Colors.grey[300],
            primary: Theme.of(context).textTheme.bodyText2.color),
        onPressed: () {
          function();
        },
        child: Container(
          width: double.infinity,
          child: Text(
            text,
            style: Style(color: Colors.black).text4(context),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
