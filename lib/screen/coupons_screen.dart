import '../common.dart';
import '../widget/coupons_list.dart';
import 'package:provider/provider.dart';
import '../provider/data.dart';
import '../model/coupon.dart';
import '../model/place.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class CouponsScreen extends StatefulWidget {
  @override
  _CouponsScreenState createState() => _CouponsScreenState();
}

class _CouponsScreenState extends State<CouponsScreen> {
  List<Coupon> coupons;
  Place place;
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  void _onRefresh() async {
    await Provider.of<Data>(context, listen: false).fetchCoupons(context);
    await Provider.of<Data>(context, listen: false).fetchPlace(context);
    coupons = Provider.of<Data>(context, listen: false).getCoupons;
    place = Provider.of<Data>(context, listen: false).getPlace;

    setState(() {});
    _refreshController.refreshCompleted();
  }

  @override
  void initState() {
    coupons = Provider.of<Data>(context, listen: false).getCoupons;
    place = Provider.of<Data>(context, listen: false).getPlace;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return PlatformScaffold(
        iosContentPadding: true,
        appBar: PlatformAppBar(
          title: Text(
            loc.coupon,
            style: Style().appBar(context),
          ),
        ),
        body: SmartRefresher(
          controller: _refreshController,
          onRefresh: _onRefresh,
          child: CouponsList(coupons, place),
        ));
  }
}
