import '../common.dart';
import '../model/place.dart';
import 'package:url_launcher/url_launcher.dart';
import '../screen/nutr_value_screen.dart';

class PlaceSliverInfo extends StatelessWidget {
  final Place place;
  PlaceSliverInfo(this.place);
  AppLocalizations loc;

  _runSite(String url) async {
    if (await canLaunch(url)) {
      await launch('https://$url');
    } else {
      print('urlError');
    }
  }

  _location(String addressUrl) async {
    if (await canLaunch(addressUrl)) {
      await launch(addressUrl);
    }
  }

  _call(String number) async {
    number = 'tel:$number';
    if (await canLaunch(number)) {
      await launch(number);
    } else {
      print(number);
    }
  }

  @override
  Widget build(BuildContext context) {
    loc = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Wrap(
              direction: Axis.vertical,
              spacing: 20,
              children: [
                SizedBox(
                  height: 10,
                ),
                Container(
                  width: MediaQuery.of(context).size.width,
                  child: Text(
                    place.title,
                    style: Style().text1(context),
                  ),
                ),
                Row(
                  children: [
                    Icon(Icons.lock_open),
                    Text(loc.infoOpen, style: Style().placeInfo1(context)),
                    Text(place.time, style: Style().placeInfo2(context))
                  ],
                ),
                if (place.site != '')
                  GestureDetector(
                      onTap: () => _runSite(place.site),
                      child: Row(
                        children: [
                          Icon(Icons.web),
                          Text(loc.infoWeb, style: Style().placeInfo1(context)),
                          Container(
                            padding: EdgeInsets.only(
                              bottom: 1,
                            ),
                            decoration: BoxDecoration(
                                border: Border(
                                    bottom: BorderSide(
                              color:
                                  Theme.of(context).textTheme.bodyText1.color,
                              width: 0.5,
                            ))),
                            child: Text(place.site,
                                style: Style().placeInfo2(context)),
                          )
                        ],
                      )),
                GestureDetector(
                  child: Row(children: [
                    Icon(Icons.phone),
                    Text(loc.infoPhone, style: Style().placeInfo1(context)),
                    Container(
                        padding: EdgeInsets.only(
                          bottom: 1,
                        ),
                        decoration: BoxDecoration(
                            border: Border(
                                bottom: BorderSide(
                          color: Theme.of(context).textTheme.bodyText1.color,
                          width: 0.5,
                        ))),
                        child: Text(place.phone,
                            style: Style().placeInfo2(context)))
                  ]),
                  onTap: () => _call(place.phone),
                ),
                GestureDetector(
                  child: Row(
                    children: [
                      Icon(Icons.food_bank),
                      Container(
                        padding: EdgeInsets.only(
                          bottom: 1,
                        ),
                        decoration: BoxDecoration(
                            border: Border(
                                bottom: BorderSide(
                          color: Theme.of(context).textTheme.bodyText1.color,
                          width: 0.5,
                        ))),
                        child: Text(loc.infoNutr,
                            style: Style().placeInfo2(context)),
                      ),
                    ],
                  ),
                  onTap: () {
                    Navigator.of(context).push(platformPageRoute(
                        context: context,
                        builder: (_) => NutrValueScreen(place.nutrValue)));
                  },
                ),
                Text(
                  loc.findUs,
                  style: Style().text2(context),
                ),
                SizedBox(
                  height: 10,
                ),
              ],
            ),
            GestureDetector(
              onTap: () => _location(place.addressUrl),
              child: Center(
                child: Wrap(
                  runSpacing: 20,
                  children: [
                    Row(
                      // mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Icon(Icons.map),
                        Text(loc.infoAddress,
                            style: Style().placeInfo1(context)),
                        Container(
                          padding: EdgeInsets.only(
                            bottom: 1,
                          ),
                          decoration: BoxDecoration(
                              border: Border(
                                  bottom: BorderSide(
                            color: Theme.of(context).textTheme.bodyText1.color,
                            width: 0.5,
                          ))),
                          child: Text(place.address,
                              style: Style().placeInfo2(context)),
                        ),
                      ],
                    ),
                    Container(
                        alignment: Alignment.center,
                        width: MediaQuery.of(context).size.width * 0.9,
                        child: place.addressImage)
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
