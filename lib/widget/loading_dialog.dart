import '../common.dart';

class LoadingDialog {
  static BuildContext loadingCtx;
  static BuildContext errorCtx;
  AppLocalizations loc;

  static showLoad(BuildContext context) => showPlatformDialog(
      barrierDismissible: false,
      context: context,
      builder: (ctx) {
        loadingCtx = ctx;
        return Container(
            color: MediaQuery.of(context).platformBrightness == Brightness.dark
                ? Colors.black45
                : Colors.white54,
            child: Center(child: PlatformCircularProgressIndicator()));
      });

  static dispLoad() {
    Navigator.of(loadingCtx).pop();
  }

  static showError(BuildContext context, String errorMessage) =>
      showPlatformDialog(
          barrierDismissible: false,
          context: context,
          builder: (ctx) {
            errorCtx = ctx;
            return PlatformAlertDialog(
              content: Text(validation(errorMessage, context),
                  style: Style().dialogTitle(context)),
              actions: [
                TextButton(
                  child: Text(AppLocalizations.of(context).ok,
                      style: Style(color: Colors.red).dialogOk(context)),
                  onPressed: () => Navigator.of(errorCtx).pop(),
                )
              ],
            );
          });

  static String validation(String error, context) {
    AppLocalizations loc = AppLocalizations.of(context);
    String errorMessage;
    if (error == 'weak-password') {
      errorMessage = loc.weakPassword;
    } else if (error == 'email-already-in-use') {
      errorMessage = loc.emailInUse;
    } else if (error == 'user-not-found') {
      errorMessage = loc.userNotFound;
    } else if (error == 'wrong-password') {
      errorMessage = loc.wrongPassword;
    } else if (error.contains('invalid-email')) {
      errorMessage = loc.invalidEmail;
    } else if (error == 'too-many-requests') {
      errorMessage = loc.tooManyRequest;
    } else if (error == 'unverified-email') {
      errorMessage = loc.emailNotVerified;
    } else if (error == 'requires-recent-login') {
      errorMessage = loc.reqRecentLogin;
    } else {
      errorMessage = loc.error;
    }
    return errorMessage;
  }
}
