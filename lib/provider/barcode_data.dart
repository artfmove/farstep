import '../common.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/coupon.dart';

import 'package:firebase_auth/firebase_auth.dart';

class BarcodeData with ChangeNotifier {
  FirebaseFunctions functions = FirebaseFunctions.instance;
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<bool> couponExist(couponId) async {
    bool exists = false;
    await firestore.collection('coupons').doc(couponId).get().then((doc) {
      if (doc.exists)
        exists = true;
      else
        exists = false;
    }).catchError((e) => exists = false);
    return exists;
  }

  Future<Map> checkBarcode(String userId, Coupon coupon) async {
    var barcodeUsedId, isExpired, exist, used;
    HttpsCallable callable =
        FirebaseFunctions.instanceFor(region: 'europe-west1').httpsCallable(
      'currentTime',
    );
    final results = await callable().catchError((e) {
      print(e);
    });

    DateTime now =
        new DateTime.fromMillisecondsSinceEpoch(results.data['response']);
    int expirationSeconds, restartSeconds;

    await firestore
        .collection('users')
        .doc(userId)
        .collection('coupons')
        .doc(coupon.couponId)
        .get()
        .then((snapshot) {
      exist = true;
      final doc = snapshot.data();
      if (doc['used'] == false) {
        used = false;
        if (doc['expirationDate'].toDate().isAfter(now)) {
          DateTime expirationDate = doc['expirationDate'].toDate();
          expirationSeconds = expirationDate.difference(now).inSeconds;
          barcodeUsedId = doc['barcodeId'];
          isExpired = false;
          exist = true;
        } else {
          isExpired = true;
          exist = true;
        }
      } else {
        DateTime restartDate = doc['restartAt'].toDate();
        restartSeconds = restartDate.millisecondsSinceEpoch;
        isExpired = true;
        exist = true;
        used = true;
      }
    }).catchError((e) {
      isExpired = true;
      exist = false;
      used = false;
    });

    return {
      'used': used,
      'exist': exist,
      'isExpired': isExpired,
      'barcodeUsedId': barcodeUsedId,
      'expirationSeconds': expirationSeconds,
      'restartSeconds': restartSeconds,
    };
  }

  Future<Map> generateBarcode(String userId, Coupon coupon) async {
    await FirebaseAuth.instance.currentUser.reload();
    final check = await checkBarcode(userId, coupon);
    if (check['exist'] == true) return {'isSuccess': false};
    if (!await couponExist(coupon.couponId)) return {'isSuccess': false};

    HttpsCallable callable =
        FirebaseFunctions.instanceFor(region: 'europe-west1').httpsCallable(
      'GenerateBarcode',
    );
    bool isSuccessFunction = true;
    final results = await callable(<String, dynamic>{
      'couponId': coupon.couponId,
      'userId': userId,
    }).catchError((e) {
      isSuccessFunction = false;
    });
    print(results.data);

    if (!isSuccessFunction || results.data['isSuccess'] == false)
      return {'isSuccess': false};

    return {
      'barcodeId': results.data['barcodeId'],
      'isSuccess': results.data['isSuccess'],
      'expirationSeconds': results.data['expirationSeconds'] ~/ 1000
    };
  }

  Future<dynamic> barcodeScan(String barcodeScanId, context) async {
    final loc = AppLocalizations.of(context);
    String message;

    var currentCoupon = Coupon();
    HttpsCallable callable =
        FirebaseFunctions.instanceFor(region: 'europe-west1').httpsCallable(
      'ScanBarcode',
    );

    final results = await callable(<String, dynamic>{
      'barcodeId': barcodeScanId.toUpperCase(),
    }).catchError((e) {
      message = 'error';
    });

    print(results.data);

    if (results.data['message'] == 'success') {
      List<FadeInImage> image = [
        FadeInImage.assetNetwork(
            fit: BoxFit.cover,
            height: 300,
            width: double.infinity,
            placeholder: 'assets/images/loading.png',
            image: results.data['coupon']['images'][0])
      ];
      currentCoupon = Coupon(
          couponId: results.data['coupon']['couponId'],
          images: image,
          price: results.data['coupon']['price'],
          title: results.data['coupon']['title'][0]);
    }

    switch (results.data['message']) {
      case 'notfound':
        message = loc.barcodeNotFound;
        break;
      case 'success':
        message = loc.barcodeSuccess;
        break;
      case 'expired':
        message = loc.barcodeExpired;
        break;
      case 'error':
        message = loc.error;
        break;

      default:
        message = loc.error;
        break;
    }
    return {
      'message': message,
      'isSuccess': results.data['message'] == 'success' ? true : false,
      'coupon': currentCoupon,
    };
  }
}
