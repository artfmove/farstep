import '../common.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import '../provider/barcode_data.dart';
import 'package:flutter/cupertino.dart';
import './landing.dart';

class ScannerBarcodesScreen extends StatefulWidget {
  const ScannerBarcodesScreen({Key key}) : super(key: key);
  @override
  _ScannerBarcodesScreenState createState() => _ScannerBarcodesScreenState();
}

class _ScannerBarcodesScreenState extends State<ScannerBarcodesScreen> {
  String id = '-1';
  AppLocalizations loc;
  Future future;
  Widget art;
  Future<void> scan(BuildContext context) async {
    id = await FlutterBarcodeScanner.scanBarcode(
        'black', AppLocalizations.of(context).cancel, true, ScanMode.BARCODE);
    future = BarcodeData().barcodeScan(id, context);
    if (id != '-1') setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    loc = AppLocalizations.of(context);
    return PlatformScaffold(
      iosContentPadding: true,
      appBar: PlatformAppBar(
        trailingActions: [
          GestureDetector(
              child: Padding(
                padding: const EdgeInsets.only(left: 18.0),
                child: Icon(
                  PlatformIcons(context).forward,
                  color: MediaQuery.platformBrightnessOf(context) !=
                          Brightness.dark
                      ? Colors.black
                      : Colors.grey[200],
                ),
              ),
              onTap: () {
                Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
                    platformPageRoute(
                        context: context, builder: (_) => Landing()),
                    (route) => false);
              }),
        ],
        title: Text(
          loc.scan,
          style: Style().appBar(context),
        ),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Center(
          child: Stack(alignment: Alignment.bottomCenter, children: [
            ListView(
              children: [
                id != '-1'
                    ? FutureBuilder(
                        future: future,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            art = Container(
                                alignment: Alignment.center,
                                child: PlatformCircularProgressIndicator());
                          } else {
                            art = snapshot.data['isSuccess'] == true
                                ? Column(
                                    children: [
                                      snapshot.data['coupon'].images[0],
                                      Wrap(
                                        alignment: WrapAlignment.center,
                                        spacing: 20,
                                        runSpacing: 20,
                                        children: [
                                          SizedBox(
                                            height: 20,
                                          ),
                                          Text(
                                            snapshot.data['coupon'].title,
                                            style: TextStyle(
                                                fontSize: 28,
                                                color: Colors.grey),
                                          ),
                                          Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Text(loc.price),
                                                Text.rich(
                                                  TextSpan(
                                                    children: <TextSpan>[
                                                      new TextSpan(
                                                        text:
                                                            '${snapshot.data['coupon'].price[0]}${loc.value}',
                                                        style: new TextStyle(
                                                          color: Colors.grey,
                                                          fontSize: 22,
                                                          decoration:
                                                              TextDecoration
                                                                  .lineThrough,
                                                        ),
                                                      ),
                                                      new TextSpan(
                                                        style: TextStyle(
                                                            fontSize: 28,
                                                            color: Theme.of(
                                                                    context)
                                                                .primaryColor),
                                                        text:
                                                            '${snapshot.data['coupon'].price[1]}${loc.value}',
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ]),
                                        ],
                                      ),
                                    ],
                                  )
                                : Column(
                                    children: [
                                      Container(
                                          child: Icon(
                                        Icons.highlight_off,
                                        size: 170,
                                      )),
                                      Text(
                                        snapshot.data['message'],
                                        style: Theme.of(context)
                                            .textTheme
                                            .headline6,
                                      ),
                                      SizedBox(
                                        height: 20,
                                      ),
                                      Text(
                                        id,
                                        style: Theme.of(context)
                                            .textTheme
                                            .headline6,
                                      )
                                    ],
                                  );
                          }
                          return AnimatedSwitcher(
                            duration: Duration(milliseconds: 700),
                            child: art,
                          );
                        },
                      )
                    : Container()
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
              child: Wrap(
                  runSpacing: 20,
                  alignment: WrapAlignment.center,
                  children: [
                    Material(
                      child: Container(
                        width: double.infinity,
                        color: MediaQuery.of(context).platformBrightness ==
                                Brightness.dark
                            ? Colors.black
                            : Theme.of(context).scaffoldBackgroundColor,
                        child: TextFormField(
                          //key: UniqueKey(),
                          decoration: Style.textField('Штрих-код', context),

                          onFieldSubmitted: (v) {
                            future = BarcodeData().barcodeScan(id, context);
                            FocusScope.of(context).unfocus();
                            print('gg');
                            setState(() => id = v);
                          },
                        ),
                      ),
                    ),
                    TextButton(
                      child: Text(
                        loc.scan,
                        style: Style(color: Colors.red).text1(context),
                      ),
                      onPressed: () => scan(context),
                    ),
                  ]),
            ),
          ]),
        ),
      ),
    );
  }
}
