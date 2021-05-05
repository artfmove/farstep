import 'package:flutter/cupertino.dart';
import '../common.dart';
import '../model/coupon.dart';
import '../screen/coupon_screen.dart';

class CouponItem extends StatefulWidget {
  final Coupon coupon;

  CouponItem(this.coupon);
  @override
  _CouponItemState createState() => _CouponItemState();
}

class _CouponItemState extends State<CouponItem> {
  AppLocalizations loc;
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    loc = AppLocalizations.of(context);
    return GestureDetector(
      onTap: () => Navigator.of(context, rootNavigator: true).push(
          platformPageRoute(
              context: context, builder: (_) => CouponScreen(widget.coupon))),
      child: Container(
          padding: EdgeInsets.symmetric(vertical: 1),
          child: Row(
            children: [
              Container(
                  width: size.width * 0.5,
                  height: size.width * 0.5,
                  child: widget.coupon.images[0]),
              Container(
                color: Theme.of(context).scaffoldBackgroundColor,
                padding: EdgeInsets.all(8),
                width: size.width * 0.50,
                height: size.width * 0.50,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Text(widget.coupon.title,
                        textAlign: TextAlign.end,
                        style: Style().text3(context)),
                    Align(
                        alignment: Alignment.bottomRight,
                        child: Text.rich(
                          TextSpan(
                            children: <TextSpan>[
                              new TextSpan(
                                text: '${widget.coupon.price[0]}${loc.value}',
                                style: new TextStyle(
                                  color: Colors.grey,
                                  fontSize: size.width > 230 ? 22 : 16,
                                  decoration: TextDecoration.lineThrough,
                                ),
                              ),
                              new TextSpan(
                                style: TextStyle(
                                    fontSize: size.width > 230 ? 24 : 18,
                                    color: Colors.red),
                                text: ' ${widget.coupon.price[1]}${loc.value}',
                              ),
                            ],
                          ),
                        )),
                  ],
                ),
              )
            ],
          )),
    );
  }
}
