import '../common.dart';
import '../model/coupon.dart';
import '../provider/barcode_data.dart';
import './barcode_item.dart';
import 'package:flutter/cupertino.dart';

class BarcodeButton extends StatefulWidget {
  final BuildContext context;
  final String userId;
  final Coupon coupon;
  BarcodeButton(this.context, this.userId, this.coupon);
  @override
  _BarcodeButtonState createState() => _BarcodeButtonState();
}

class _BarcodeButtonState extends State<BarcodeButton> {
  AppLocalizations loc;
  bool gotCoupon = false;
  @override
  Widget build(BuildContext context) {
    loc = AppLocalizations.of(context);
    return gotCoupon
        ? FutureBuilder(
            future: BarcodeData().generateBarcode(widget.userId, widget.coupon),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting ||
                  snapshot.data == null)
                return ConstrainedBox(
                    constraints: new BoxConstraints(
                      maxHeight: 50.0,
                    ),
                    child: Container(
                        color: Colors.transparent,
                        padding: EdgeInsets.only(bottom: 20),
                        alignment: Alignment.bottomCenter,
                        child: PlatformCircularProgressIndicator()));
              else {
                return snapshot.data['isSuccess'] == true
                    ? BarcodeItem(snapshot.data['barcodeId'],
                        snapshot.data['expirationSeconds'])
                    : Container(
                        height: 50,
                        padding: EdgeInsets.only(bottom: 16),
                        alignment: Alignment.bottomCenter,
                        child: Text(
                          loc.error,
                          style: Style().text2(context),
                        ));
              }
            })
        : CupertinoButton(
            child: Text(
              loc.getCoupon,
              style: Style(color: Colors.red).text2(context),
            ),
            onPressed: () {
              showPlatformDialog(
                barrierDismissible: false,
                context: widget.context,
                builder: (ctx) => PlatformAlertDialog(
                  title: Text(
                    loc.getCoupon,
                  ),
                  content: Text(
                      '${loc.couponAlertActive}${widget.coupon.expirationMinutes}${loc.couponAlertMinutes}'),
                  actions: [
                    CupertinoButton(
                      child: Text(
                        loc.cancel,
                        style: Style().dialogCancel(context),
                      ),
                      onPressed: () => Navigator.of(ctx).pop(),
                    ),
                    CupertinoButton(
                        child: Text(
                          loc.getCoupon,
                          style: Style().dialogOk(context),
                        ),
                        onPressed: () => setState(() {
                              gotCoupon = true;
                              Navigator.of(ctx).pop();
                            })),
                  ],
                ),
              );
            },
          );
  }
}
