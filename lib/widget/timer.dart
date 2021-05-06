import 'package:flutter/material.dart';
import '../style.dart';
import 'package:flutter_countdown_timer/flutter_countdown_timer.dart';

class Timer extends StatelessWidget {
  final String text;
  final int endTime;
  final Color color;

  Timer(this.text, this.endTime, this.color);
  @override
  Widget build(BuildContext context) {
    return CountdownTimer(
        endWidget: Text(text, style: Style().text4(context)),
        textStyle: TextStyle(
          color: color,
          fontSize: MediaQuery.of(context).size.width > 360 ? 18 : 13,
        ),
        endTime: endTime);
  }
}
