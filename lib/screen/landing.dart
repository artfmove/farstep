import 'package:flutter/material.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:flutter/cupertino.dart';
import '../provider/data.dart';
import 'package:provider/provider.dart';
import '../screen/settings_screen.dart';
import '../common.dart';
import './place_screen.dart';
import './coupons_screen.dart';
import 'feed_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class Landing extends StatefulWidget {
  @override
  _LandingState createState() => _LandingState();
}

class _LandingState extends State<Landing> {
  Future fetchData, switchActive, checkNetwork;
  PlatformTabController _tabController = PlatformTabController(initialIndex: 0);

  AppLocalizations loc;
  @override
  void initState() {
    fetchData = Provider.of<Data>(context, listen: false).fetchData(context);
    switchActive = Data().switchActive();
    checkNetwork = Data().checkNetwork(context);

    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    loc = AppLocalizations.of(context);
    final List<Map<String, Object>> items = [
      {'page': FeedScreen(), 'title': loc.start},
      {'page': CouponsScreen(), 'title': loc.coupon},
      {'page': PlaceScreen(), 'title': loc.place},
      {'page': SettingsScreen(), 'title': loc.settings}
    ];
    return FutureBuilder(
        future: Future.wait([
          switchActive,
          fetchData,
          Future.delayed(Duration(milliseconds: 500))
        ]),
        builder: (context, snapshot) {
          Data().getLocaleIndex(context);
          if (snapshot.connectionState == ConnectionState.waiting)
            return Container(
                color:
                    MediaQuery.of(context).platformBrightness == Brightness.dark
                        ? Colors.black
                        : Colors.white,
                child: Center(child: PlatformCircularProgressIndicator()));
          else if (snapshot.hasError) {
            return PlatformAlertDialog(
              content: Text(loc.error),
            );
          } else if (snapshot.data[0]['isActive'] == false)
            return PlatformAlertDialog(
              content: Column(children: [
                Icon(
                  Icons.settings_outlined,
                  size: 38,
                ),
                Text(
                  loc.techincalWork,
                  style: Style().text4(context),
                ),
              ]),
            );
          else if (snapshot.data[0]['needUpdate'] == true)
            return PlatformAlertDialog(
                content: Column(
                  children: [
                    Icon(Icons.update, size: 38),
                    Text(
                      loc.updateApp,
                      style: Style().text4(context),
                    ),
                  ],
                ),
                actions: [
                  CupertinoButton(
                      child: Text(loc.updateUrl,
                          textAlign: TextAlign.center,
                          style: Style().dialogOk(
                            context,
                          )),
                      onPressed: () async {
                        if (await canLaunch(snapshot.data[0]['urlUpdate'])) {
                          await launch(snapshot.data[0]['urlUpdate']);
                        }
                      }),
                ]);
          else
            return PlatformTabScaffold(
              materialTabs: (_, __) =>
                  MaterialNavBarData(showUnselectedLabels: true),
              iosContentBottomPadding: true,
              tabController: _tabController,
              iosContentPadding: true,
              appBarBuilder: (_, index) => _tabController.index(context) == 0 ||
                      _tabController.index(context) == 3
                  ? PlatformAppBar(
                      automaticallyImplyLeading: true,
                      title: Text(items[index]['title'],
                          style: Style().appBar(context)),
                      material: (_, __) => MaterialAppBarData(),
                    )
                  : null,
              bodyBuilder: (context, index) => items[index]['page'],
              items: [
                BottomNavigationBarItem(
                    label: loc.start, icon: Icon(CupertinoIcons.archivebox)),
                BottomNavigationBarItem(
                    icon: Icon(CupertinoIcons.square_list), label: loc.coupon),
                BottomNavigationBarItem(
                    icon: Icon(Icons.home_outlined), label: loc.place),
                BottomNavigationBarItem(
                    icon: Icon(CupertinoIcons.settings), label: loc.settings),
              ],
            );
        });
  }
}
