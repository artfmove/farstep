import '../common.dart';
import 'package:flutter/material.dart';
import 'coupon_item.dart';
import 'button_outline_sort.dart';
import '../model/place.dart';
import '../model/coupon.dart';
import '../provider/data.dart';

class CouponsList extends StatefulWidget {
  final List<Coupon> coupons;
  final Place place;
  CouponsList(this.coupons, this.place);
  @override
  _CouponsListState createState() => _CouponsListState();
}

class _CouponsListState extends State<CouponsList>
    with TickerProviderStateMixin {
  AppLocalizations loc;
  AnimationController _animationController;

  var currentSortCoupon = '';
  List<Coupon> specifiedCouponsList;

  @override
  void initState() {
    super.initState();
    _animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 250));
  }

  void _showSortSheet() {
    _animationController.forward();
    showPlatformModalSheet<void>(
      context: context,
      builder: (ctx) => Container(
        padding: EdgeInsets.only(bottom: 20),
        color: Style().dialogColor(context),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GridView.builder(
              padding: EdgeInsets.all(50),
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 15.0,
                childAspectRatio: 3.5,
                mainAxisSpacing: 15.0,
              ),
              itemCount: widget.place.types.length,
              itemBuilder: (ctx, i) =>
                  ButtonOutlineSort(widget.place.types[i], () {
                setState(() {
                  Navigator.of(ctx).pop();

                  currentSortCoupon = widget.place.types[i];

                  specifiedCouponsList = Data().getSpecifiedCoupons(
                      widget.place.types[i], widget.coupons);
                });
              }, currentSortCoupon),
            ),
            ButtonOutlineSort(
              loc.clear,
              () {
                setState(() {
                  currentSortCoupon = '';
                  specifiedCouponsList = null;
                  Navigator.of(ctx).pop();
                });
              },
              null,
            )
          ],
        ),
      ),
    ).whenComplete(() {
      _animationController.reverse();
    });
  }

  @override
  Widget build(BuildContext context) {
    loc = AppLocalizations.of(context);

    return SingleChildScrollView(
        child: Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: GestureDetector(
            onTap: () => _showSortSheet(),
            child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
              Text(
                loc.sortBy,
                style: Style().text4(context),
              ),
              Text(
                currentSortCoupon,
                style: Style().text4(context),
              ),
              AnimatedIcon(
                icon: AnimatedIcons.arrow_menu,
                progress: _animationController,
                semanticLabel: 'Show menu',
                size: 30,
              )
            ]),
          ),
        ),
        specifiedCouponsList != null
            ? specifiedCouponsListView()
            : couponsListView(widget.coupons)
      ],
    ));
  }

  Widget specifiedCouponsListView() => specifiedCouponsList.length == 0
      ? Padding(
          padding: EdgeInsets.only(top: 300),
          child: Text(
            loc.noFound,
            style: Style().text4(context),
          ))
      : ListView.builder(
          padding: EdgeInsets.all(0),
          shrinkWrap: true,
          physics: ClampingScrollPhysics(),
          itemBuilder: (_, index) => CouponItem(
                specifiedCouponsList[index],
              ),
          itemCount: specifiedCouponsList.length);

  Widget couponsListView(coupons) => ListView.builder(
      padding: EdgeInsets.all(0),
      shrinkWrap: true,
      physics: ClampingScrollPhysics(),
      itemBuilder: (_, index) => CouponItem(
            coupons[index],
          ),
      itemCount: coupons.length);
}
