import 'package:firebase_auth/firebase_auth.dart';
import '../common.dart';
import '../screen/authentication_screen.dart';
import '../screen/landing.dart';
import '../screen/auth_verify.dart';
import '../widget/loading_dialog.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Auth with ChangeNotifier {
  FirebaseAuth auth = FirebaseAuth.instance;
  User user;
  String getUserId() => FirebaseAuth.instance.currentUser.uid;
  User get getCurrentUser => FirebaseAuth.instance.currentUser;
  FirebaseMessaging messaging = FirebaseMessaging.instance;

  Future<bool> checkEmailVerified() async {
    bool verified;
    await getCurrentUser.reload().catchError((e) {
      verified = false;
    });
    if (getCurrentUser != null && getCurrentUser.emailVerified) {
      verified = true;
    } else
      verified = false;
    return verified;
  }

  Widget authentication() {
    if (FirebaseAuth.instance.currentUser != null &&
            FirebaseAuth.instance.currentUser.emailVerified ||
        (FirebaseAuth.instance.currentUser != null &&
            FirebaseAuth.instance.currentUser.isAnonymous))
      return Landing();
    else if (FirebaseAuth.instance.currentUser != null &&
        !FirebaseAuth.instance.currentUser.emailVerified)
      return AuthVerify(true);
    else if (FirebaseAuth.instance.currentUser == null)
      return AuthenticationScreen();
    else
      return AuthenticationScreen();
  }

  Future<bool> sendEmail(context) async {
    bool success = true;
    await getCurrentUser
        .sendEmailVerification()
        .catchError((e) => success = false);
    return success;
  }

  Future<void> subscribeTopic() async {
    await FirebaseMessaging.instance
        .unsubscribeFromTopic('allUsersru')
        .catchError((e) {
      print(e);
    });
    await FirebaseMessaging.instance
        .unsubscribeFromTopic('allUsersuk')
        .catchError((e) {
      print(e);
    });
    await FirebaseMessaging.instance
        .subscribeToTopic('allUsers${FirebaseAuth.instance.languageCode}')
        .catchError((e) {
      print(e);
    });
  }

  Future<String> signUpWithEmail(
      String email, String password, String confirmedPassword, context) async {
    String errorMessage = 'success';

    await auth
        .createUserWithEmailAndPassword(email: email, password: password)
        .catchError((e) {
      errorMessage = e.code;
    });

    if (errorMessage != 'success') return errorMessage;

    await sendEmail(context).catchError((e) {
      print(e);
    });

    if (errorMessage == 'success') {
      await subscribeTopic();

      await Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => AuthVerify(false)),
          (route) => false);
    }
    return errorMessage;
  }

  Future<String> signInWithEmail(String email, String password) async {
    String errorMessage = 'success';
    await auth
        .signInWithEmailAndPassword(email: email, password: password)
        .catchError((e) {
      errorMessage = e.code;
    });
    await subscribeTopic();
    return errorMessage;
  }

  Future<bool> continueAuth() async {
    await FirebaseAuth.instance.currentUser.reload();
    bool success = true;
    await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser.uid)
        .set({'id': FirebaseAuth.instance.currentUser.uid}).catchError((e) {
      success = false;
    });
    return success;
  }

  Future<bool> signOut(BuildContext context) async {
    bool success = true;
    user = getCurrentUser;
    if (user == null)
      Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
          platformPageRoute(
              context: context, builder: (_) => AuthenticationScreen()),
          (route) => false);
    if (user.isAnonymous)
      await user
          .delete()
          .then((value) => print('deleted'))
          .catchError((e) => success = false);
    if (!success) return success;

    await auth
        .signOut()
        .then((value) => print('signedOut'))
        .catchError((e) => success = false);
    if (!success) return success;

    Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
        platformPageRoute(
            context: context, builder: (_) => AuthenticationScreen()),
        (route) => false);
    return success;
  }

  Future<bool> signInAnonymously(BuildContext context) async {
    bool success = true;
    await auth.signInAnonymously().catchError((e) {
      success = false;
    });

    if (!success) return success;
    await subscribeTopic();
    Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
        platformPageRoute(context: context, builder: (_) => Landing()),
        (route) => false);
    return success;
  }

  Future<String> resetPassword(String email) async {
    String errorMessage;
    await FirebaseAuth.instance
        .sendPasswordResetEmail(email: email)
        .catchError((e) => errorMessage = e.code);
    return errorMessage;
  }

  Future<void> deleteAccount(context) async {
    bool success = false;
    String errorMessage;
    final loc = AppLocalizations.of(context);
    showPlatformDialog(
        barrierDismissible: true,
        context: context,
        builder: (ctx) => PlatformAlertDialog(
              title:
                  Text(loc.confirmAction, style: Style().dialogTitle(context)),
              content: Text(loc.confirmDeletion,
                  style: Style().dialogContent(context)),
              actions: [
                PlatformDialogAction(
                    child:
                        Text(loc.cancel, style: Style().dialogCancel(context)),
                    onPressed: () => Navigator.pop(ctx)),
                PlatformDialogAction(
                    child: Text(loc.deleteAccount,
                        style: Style().dialogOk(context)),
                    onPressed: () {
                      Navigator.pop(ctx);
                      showPlatformDialog(
                          barrierDismissible: true,
                          context: context,
                          builder: (ctx) => PlatformAlertDialog(
                                title: Text(loc.confirmAction,
                                    style: Style().dialogTitle(context)),
                                content: Text(loc.deleteForeverAsk,
                                    style: Style().dialogContent(context)),
                                actions: [
                                  PlatformDialogAction(
                                      child: Text(loc.cancel,
                                          style: Style().dialogCancel(context)),
                                      onPressed: () => Navigator.pop(ctx)),
                                  PlatformDialogAction(
                                      child: Text(loc.deleteForever,
                                          style: Style().dialogOk(context)),
                                      onPressed: () async {
                                        LoadingDialog.showLoad(context);

                                        await auth.currentUser
                                            .delete()
                                            .catchError((e) {
                                          errorMessage = e.code;
                                          success = false;
                                        });
                                        LoadingDialog.dispLoad();
                                        Navigator.pop(ctx);
                                        if (!success)
                                          LoadingDialog.showError(
                                              context, errorMessage);
                                        else
                                          Navigator.of(context,
                                                  rootNavigator: true)
                                              .pushAndRemoveUntil(
                                                  MaterialPageRoute(
                                                      builder: (_) =>
                                                          AuthenticationScreen()),
                                                  (route) => false);
                                      }),
                                ],
                              ));
                    }),
              ],
            ));
  }
}
