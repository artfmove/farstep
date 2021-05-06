import '../common.dart';
import 'package:settings_ui/settings_ui.dart';
import '../provider/auth.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AccountSettings extends StatelessWidget {
  AppLocalizations loc;

  void dialogSignOut(context) {
    showPlatformDialog(
        context: context,
        builder: (ctx) => PlatformAlertDialog(
              title: Text(
                loc.confirmAction,
                style: Style().dialogTitle(context),
              ),
              content: Text(loc.confirmLogOutAsk,
                  style: Style().dialogContent(context)),
              actions: [
                PlatformDialogAction(
                    child:
                        Text(loc.cancel, style: Style().dialogCancel(context)),
                    onPressed: () => Navigator.pop(ctx)),
                PlatformDialogAction(
                    child: Text(loc.logOut,
                        style: Style(color: Colors.red).dialogOk(context)),
                    onPressed: () {
                      Auth().signOut(context);
                      Navigator.pop(ctx);
                    }),
              ],
            ));
  }

  @override
  Widget build(BuildContext context) {
    loc = AppLocalizations.of(context);
    return PlatformScaffold(
        iosContentPadding: true,
        appBar: PlatformAppBar(
          title: Text(loc.account, style: Style().appBar(context)),
        ),
        body: SettingsList(
            contentPadding: EdgeInsets.all(0),
            shrinkWrap: true,
            sections: [
              SettingsSection(
                tiles: [
                  if (!Data().checkIfAnonymous())
                    SettingsTile(
                        title: loc.changePassword,
                        leading: Icon(Icons.language),
                        onPressed: (BuildContext context) {
                          showPlatformDialog(
                              barrierDismissible: true,
                              context: context,
                              builder: (ctx) => PlatformAlertDialog(
                                    title: Text(loc.changingPassword,
                                        style: Style().dialogTitle(context)),
                                    content: Text(loc.sendChangePassword,
                                        style: Style().dialogContent(context)),
                                    actions: [
                                      PlatformDialogAction(
                                        onPressed: () =>
                                            Navigator.of(ctx).pop(),
                                        child: Text(loc.cancel,
                                            style:
                                                Style().dialogCancel(context)),
                                      ),
                                      PlatformDialogAction(
                                        child: Text(loc.yes,
                                            style: Style().dialogOk(context)),
                                        onPressed: () async {
                                          LoadingDialog.showLoad(context);
                                          final response = await Auth()
                                              .resetPassword(FirebaseAuth
                                                  .instance.currentUser.email);
                                          LoadingDialog.dispLoad();
                                          if (response != null)
                                            LoadingDialog.showError(
                                                context, response);
                                          Navigator.of(ctx).pop();
                                        },
                                      )
                                    ],
                                  ));
                        }),
                  if (!Data().checkIfAnonymous())
                    SettingsTile(
                        title: loc.deleteAccount,
                        leading: Icon(Icons.language),
                        onPressed: (BuildContext context) async {
                          Auth().deleteAccount(context);
                        }),
                  SettingsTile(
                      title: Data().checkIfAnonymous()
                          ? AppLocalizations.of(context).logIn
                          : AppLocalizations.of(context).logOut,
                      leading: Icon(Icons.language),
                      onPressed: (BuildContext context) {
                        Data().checkIfAnonymous()
                            ? Auth().signOut(context)
                            : dialogSignOut(context);
                      }),
                ],
              ),
            ]));
  }
}
