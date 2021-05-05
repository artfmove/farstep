import '../common.dart';
import '../model/coupon.dart';
import '../provider/data.dart';
import 'package:flutter/cupertino.dart';
import '../provider/barcode_data.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widget/barcode_item.dart';
import '../widget/timer.dart';
import '../widget/barcode_button.dart';

class CouponScreen extends StatefulWidget {
  final Coupon coupon;
  CouponScreen(this.coupon);
  @override
  _CouponScreenState createState() => _CouponScreenState();
}

class _CouponScreenState extends State<CouponScreen> {
  AppLocalizations loc;
  bool isBarcodeShowing = false;
  Future barcode;
  String userId;
  void barcodeHeight() {
    setState(() {
      isBarcodeShowing = true;
    });
  }

  @override
  void initState() {
    barcode = BarcodeData()
        .checkBarcode(FirebaseAuth.instance.currentUser.uid, widget.coupon);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    loc = AppLocalizations.of(context);
    final size = MediaQuery.of(context).size;

    return PlatformScaffold(
      iosContentPadding: true,
      iosContentBottomPadding: true,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverAppBar(
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                expandedHeight: Style.imageHeight(context),
                flexibleSpace: FlexibleSpaceBar(
                  background: CarouselSlider.builder(
                      itemCount: widget.coupon.images.length,
                      itemBuilder: (_, i, __) {
                        return widget.coupon.images[i];
                      },
                      options: CarouselOptions(
                        height: Style.imageHeight(context) + 50,
                        viewportFraction: 1,
                        enableInfiniteScroll: false,
                        pauseAutoPlayInFiniteScroll: true,
                        autoPlay: true,
                        scrollDirection: Axis.horizontal,
                      )),
                ),
              ),
              SliverList(
                delegate: SliverChildListDelegate(
                  [
                    Container(
                      //height: size.height * 0.75 - 150,
                      child: Scrollbar(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(26.0),
                          child: Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: [
                              Align(
                                alignment: Alignment.center,
                                child: Text(
                                  widget.coupon.title,
                                  style: Style(color: Colors.grey[600])
                                      .text1(context),
                                ),
                              ),
                              Row(children: [
                                Text(loc.price, style: Style().text3(context)),
                                Text(
                                  '${widget.coupon.price[0]}${loc.value}',
                                  style: new TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: size.height > 650 ? 22 : 17,
                                    decoration: TextDecoration.lineThrough,
                                  ),
                                ),
                                Text(
                                  '${widget.coupon.price[1]}${loc.value}',
                                  style: TextStyle(
                                      fontSize: size.height > 650 ? 22 : 17,
                                      color: Theme.of(context).primaryColor),
                                ),
                              ]),
                              Text(
                                widget.coupon.description,
                                style: Style(color: Colors.grey[600])
                                    .text4(context),
                              ),
                              Text(
                                '${loc.couponAlertActive}${widget.coupon.expirationMinutes}${loc.couponAlertMinutes}',
                                style: Style(color: Colors.grey[600])
                                    .text4(context),
                              ),
                              Text(
                                '${loc.couponRestart}${widget.coupon.restartHours}${loc.couponAlertHours} ${loc.couponRestart2}',
                                style: Style(color: Colors.grey[600])
                                    .text4(context),
                              ),
                              SizedBox(
                                height: 130,
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: ConstrainedBox(
              constraints: new BoxConstraints(
                minHeight: 100.0,
                minWidth: double.infinity,
              ),
              child: Container(
                color:
                    MediaQuery.platformBrightnessOf(context) == Brightness.dark
                        ? Colors.black
                        : Colors.grey[200],
                child: Data().checkIfAnonymous()
                    ? CupertinoButton(
                        onPressed: () => Data().showAuthAlert(context),
                        child: Text(
                          loc.getCoupon,
                          style: Style(color: Colors.red).text2(context),
                        ))
                    : FutureBuilder(
                        future: barcode,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                                  ConnectionState.waiting ||
                              snapshot.hasError)
                            return Container(
                                padding: EdgeInsets.only(bottom: 20),
                                alignment: Alignment.bottomCenter,
                                child: PlatformCircularProgressIndicator());
                          else {
                            if (snapshot.data['exist'] &&
                                !snapshot.data['isExpired'])
                              return BarcodeItem(snapshot.data['barcodeUsedId'],
                                  snapshot.data['expirationSeconds']);
                            else if (snapshot.data['used'])
                              return Container(
                                height: 100,
                                padding: EdgeInsets.only(bottom: 30),
                                child: Column(
                                  children: [
                                    Timer(
                                        AppLocalizations.of(context)
                                            .couponUpdateToUse,
                                        snapshot.data['restartSeconds'],
                                        Theme.of(context)
                                            .textTheme
                                            .bodyText1
                                            .color),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Text(
                                      AppLocalizations.of(context).couponUsed,
                                      style: Style(color: Colors.red)
                                          .text2(context),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              );
                            else
                              return Container(
                                width: double.infinity,
                                child: BarcodeButton(
                                    context, userId, widget.coupon),
                              );
                          }
                        }),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
