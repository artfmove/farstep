import '../common.dart';
import '../model/place.dart';
import '../model/product.dart';
import '../model/coupon.dart';
import '../model/feed.dart';
import 'package:firebase_auth/firebase_auth.dart';
import './auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:connectivity/connectivity.dart';
import 'dart:io';
import 'package:package_info/package_info.dart';
import 'package:flutter/cupertino.dart';

class Data with ChangeNotifier {
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  List<Coupon> _coupons = [];
  List<Coupon> get getCoupons => _coupons;

  List<Product> _products = [];
  List<Product> get getProducts => _products;

  List<Feed> _feeds = [];
  List<Feed> get getFeeds => _feeds;

  Place _place;
  Place get getPlace => _place;

  static int localeIndex;

  int checkPl() {
    if (Platform.isAndroid)
      return 0;
    else if (Platform.isIOS)
      return 1;
    else
      return 0;
  }

  String authId() => FirebaseAuth.instance.currentUser.uid;

  Future<Map<String, dynamic>> switchActive() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();

    int version = int.tryParse(packageInfo.version.replaceAll(".", ""));
    bool isActive, needUpdate;
    String urlUpdate;

    await firestore.collection('app').doc('active').get().then((snapshot) {
      if (snapshot.data()['isActive'] == true)
        isActive = true;
      else
        isActive = false;
      if (snapshot.data()['needUpdate'] == true) {
        int serverVersion =
            int.tryParse(snapshot.data()['minVersion'].replaceAll(".", ""));
        if (serverVersion > version) {
          needUpdate = true;
          urlUpdate = snapshot.data()['urlUpdate'];
        }
      } else
        needUpdate = false;
    }).catchError((e) {
      print(e);
    });

    return {
      'isActive': isActive,
      'needUpdate': needUpdate,
      'urlUpdate': urlUpdate
    };
  }

  void getLocaleIndex(context) {
    final locale = getLocale(context);
    switch (locale) {
      case 'ru':
        localeIndex = 0;
        FirebaseAuth.instance.setLanguageCode('ru');
        break;
      case 'uk':
        localeIndex = 1;
        FirebaseAuth.instance.setLanguageCode('uk');
        break;
      default:
        localeIndex = 0;
        FirebaseAuth.instance.setLanguageCode('ru');
    }
  }

  Future<bool> checkAccess() async {
    bool hasAccess = false;
    await firestore.collection('app').doc('employers').get().then((snapshot) {
      snapshot.data()['employers'].forEach((key, value) {
        if (value[0] == FirebaseAuth.instance.currentUser.email) {
          hasAccess = true;
          return;
        }
      });
    }).catchError((e) {
      hasAccess = false;
    });
    return hasAccess;
  }

  Future<bool> checkNetwork(context) async {
    ConnectivityResult connectivityResult;
    try {
      connectivityResult = await (Connectivity().checkConnectivity());
    } catch (error) {}
    if (connectivityResult == ConnectivityResult.none ||
        connectivityResult == null) {
      showNetworkCheckMessage(context);
      return false;
    } else {
      return true;
    }
  }

  void showNetworkCheckMessage(context) {
    showPlatformDialog(
        context: context,
        builder: (ctx) => PlatformAlertDialog(
              title: Text(AppLocalizations.of(context).error),
              content: Text(AppLocalizations.of(context).noConnection),
              actions: [
                CupertinoButton(
                    child: Text(
                      AppLocalizations.of(context).tryAgain,
                      style: Style().dialogOk(context),
                    ),
                    onPressed: () async {
                      ConnectivityResult connectivityResult;
                      try {
                        connectivityResult =
                            await (Connectivity().checkConnectivity());
                      } catch (error) {}
                      if (connectivityResult != null &&
                          connectivityResult != ConnectivityResult.none)
                        Navigator.pop(ctx);
                    })
              ],
            ));
  }

  Future<String> loadTerms(context) async {
    String terms;
    await firestore.collection('app').doc('terms').get().then((snapshot) {
      terms = snapshot.data()['terms'][localeIndex];
    }).catchError((e) {
      terms = 'error';
    });
    return terms;
  }

  bool checkIfAnonymous() {
    bool isAnon;
    try {
      if (FirebaseAuth.instance.currentUser == null)
        isAnon = false;
      else if (FirebaseAuth.instance.currentUser.isAnonymous)
        isAnon = true;
      else
        isAnon = false;
    } catch (e) {}
    return isAnon;
  }

  void showAuthAlert(context) {
    final loc = AppLocalizations.of(context);
    showPlatformDialog(
        barrierDismissible: true,
        context: context,
        builder: (ctx) => PlatformAlertDialog(
              title: Text(loc.anonymusTitle),
              content: Text(loc.anonymusContent),
              actions: [
                PlatformDialogAction(
                    child: Text(
                      loc.cancel,
                      style: Style().dialogCancel(context),
                    ),
                    onPressed: () => Navigator.pop(ctx)),
                PlatformDialogAction(
                    child: Text(
                      loc.anonymusOk,
                      style: Style().dialogOk(context),
                    ),
                    onPressed: () {
                      Navigator.pop(ctx);
                      Auth().signOut(context);
                    }),
              ],
            ));
  }

  List<dynamic> sortLangPlace(Map types) {
    List<dynamic> returnList = [];
    for (var type in types.entries) returnList.add(type.value[localeIndex]);
    return returnList;
  }

  Future<void> fetchData(context) async {
    await fetchFeeds(context);
    await fetchCoupons(context);
    await fetchPlace(context);
    await fetchProducts(context);
  }

  dynamic preloadImages(list, singleImage, context) {
    List<FadeInImage> preImageList = [];

    if (list == null) {
      final preImage = FadeInImage.assetNetwork(
          fit: BoxFit.cover,
          width: double.infinity,
          fadeOutDuration: Duration(milliseconds: 10),
          placeholder: 'assets/images/loading.png',
          image: singleImage);
      precacheImage(preImage.image, context).catchError((e) {});
      return preImage;
    } else {
      for (var image in list) {
        final preImage = FadeInImage.assetNetwork(
            fadeOutDuration: Duration(milliseconds: 10),
            fit: BoxFit.cover,
            width: double.infinity,
            placeholder: 'assets/images/loading.png',
            image: image);
        precacheImage(preImage.image, context).catchError((e) {});
        preImageList.add(preImage);
      }
      return preImageList;
    }
  }

  Future<bool> fetchCoupons(context) async {
    _coupons = [];
    bool success;
    await firestore
        .collection('coupons')
        .get()
        .then((snapshot) => snapshot.docs.forEach((doc) {
              _coupons.add(Coupon(
                  couponId: doc.data()['couponId'],
                  title: doc.data()['title'][localeIndex],
                  images: preloadImages(doc.data()['images'], null, context),
                  price: doc.data()['price'],
                  description: doc.data()['description'][localeIndex],
                  type: doc.data()['type'][localeIndex],
                  restartHours: doc.data()['restartHours'],
                  expirationMinutes: doc.data()['expirationMinutes']));
              success = true;
            }))
        .catchError((e) {
      print(e);
      success = false;
    });
    return success;
  }

  Future<bool> fetchProducts(context) async {
    _products = [];
    await firestore
        .collection('products')
        .get()
        .then((snapshot) => snapshot.docs.forEach((doc) {
              _products.add(
                Product(
                  productId: doc.data()['productId'],
                  title: doc.data()['title'][localeIndex],
                  images: preloadImages(doc.data()['images'], null, context),
                  price: doc.data()['price'],
                  description: doc.data()['description'][localeIndex],
                  type: doc.data()['type'][localeIndex],
                ),
              );
            }))
        .catchError((e) {
      print(e);
    });

    return true;
  }

  Future<void> fetchPlace(context) async {
    _place = null;

    await firestore.collection('app').doc('place').get().then((snapshot) async {
      final doc = snapshot.data();

      _place = Place(
          title: doc['title'][localeIndex],
          time: doc['time'],
          images: preloadImages(doc['images'], null, context),
          address: doc['address'][localeIndex],
          addressUrl: doc['addressUrl'][checkPl()],
          addressImage:
              preloadImages(null, doc['addressImages'][localeIndex], context),
          site: doc['site'],
          phone: doc['phone'],
          nutrValue: doc['nutrValue'],
          types: sortLangPlace(doc['types']));
    }).catchError((e) {
      print(e);
    });
    print(_place.types);
  }

  List<Coupon> getSpecifiedCoupons(String type, List<Coupon> coupons) {
    final List<Coupon> list = [];
    coupons.forEach((element) {
      if (element.type == type) list.add(element);
    });
    return list;
  }

  List<Product> getSpecifiedProducts(String type, List<Product> products) {
    final List<Product> list = [];
    products.forEach((element) {
      if (element.type == type) list.add(element);
    });
    return list;
  }

  String getLocale(BuildContext context) {
    return Localizations.localeOf(context).languageCode;
  }

  Future<void> fetchFeeds(BuildContext context) async {
    _feeds = [];
    await firestore.collection('feeds').get().then((snapshot) async {
      for (var doc in snapshot.docs) {
        _feeds.add(Feed(
          feedId: doc.id,
          description: doc.data()['description'][localeIndex],
          title: doc.data()['title'][localeIndex],
          startDate: doc.data()['startDate'].toDate(),
          images: preloadImages(doc.data()['images'], null, context),
        ));
      }
    }).catchError((e) {
      print(e);
    });

    _feeds.sort((a, b) => b.startDate.millisecondsSinceEpoch
        .compareTo(a.startDate.millisecondsSinceEpoch));
    _feeds.forEach((feed) {
      feed.startDateString = DateFormat('EEE, d/M/y', getLocale(context))
          .format(DateTime.parse(feed.startDate.toIso8601String()));
    });
  }
}
