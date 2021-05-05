import '../common.dart';

class ButtonOutlineSort extends StatelessWidget {
  final String text;
  final dynamic function;
  final String currentType;
  ButtonOutlineSort(this.text, this.function, this.currentType);
  @override
  Widget build(BuildContext context) {
    return IntrinsicWidth(
        child: TextButton(
      style: TextButton.styleFrom(
        shape: new RoundedRectangleBorder(
          borderRadius: new BorderRadius.circular(20.0),
        ),
        primary: Theme.of(context).textTheme.bodyText2.color,
        backgroundColor: text == currentType
            ? Colors.red
            : currentType == null
                ? Colors.grey[500]
                : Colors.red[200],
      ),
      onPressed: () {
        function();
      },
      child: Container(
        child: Text(
          text,
          style: TextStyle(
              fontSize: currentType == null
                  ? MediaQuery.of(context).size.width > 230
                      ? 14
                      : 10
                  : MediaQuery.of(context).size.width > 230
                      ? 16
                      : 12),
        ),
      ),
    ));
  }
}
