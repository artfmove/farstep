import '../common.dart';

class AuthMethod extends StatefulWidget {
  final String imagePath;
  final String text;
  final bool isMail;
  final Function function;

  AuthMethod(this.imagePath, this.text, this.isMail, this.function);

  @override
  _AuthMethodState createState() => _AuthMethodState();
}

class _AuthMethodState extends State<AuthMethod> {
  bool isSelected = false;
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
      child: FlatButton(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(40.0),
            side: BorderSide(color: Colors.grey[300])),
        onPressed: () async {
          setState(() {
            isSelected = !isSelected;
          });

          await widget.function().catchError((v) {
            setState(() {
              isSelected = !isSelected;
            });
          });
        },
        child: Container(
          width: double.infinity,
          //padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
          height: size.width > 360 ? 55 : 45,
          child: isSelected
              ? Center(
                  child: PlatformCircularProgressIndicator(),
                )
              : Row(
                  children: [
                    SizedBox(
                      width: 10,
                    ),
                    Image(
                      image: AssetImage(widget.imagePath),
                      height: size.width > 360 ? 40 : 30,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: Text(
                        widget.text,
                        style: Style().text3(context),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
