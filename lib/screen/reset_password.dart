import '../common.dart';
import '../widget/loading_dialog.dart';
import 'package:flutter/cupertino.dart';
import '../provider/auth.dart';

class ResetPassword extends StatefulWidget {
  @override
  _ResetPasswordState createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword> {
  String email;
  AppLocalizations loc;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  _sendEmail() async {
    if (!_formKey.currentState.validate())
      return;
    else {
      LoadingDialog.showLoad(context);
      final reset = await Auth().resetPassword(email);
      LoadingDialog.dispLoad();
      if (reset != null)
        LoadingDialog.showError(context, reset);
      else {
        showDialog(
            context: context,
            builder: (ctx) => PlatformAlertDialog(
                  content: Text(
                    loc.verifyEmailSent,
                    style: Style().dialogContent(context),
                  ),
                  actions: [
                    PlatformDialogAction(
                        child: Text(
                          loc.ok,
                          style: Style().dialogOk(context),
                        ),
                        onPressed: () {
                          Navigator.of(ctx).pop();
                          Navigator.of(context).pop();
                        })
                  ],
                ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    loc = AppLocalizations.of(context);

    return PlatformScaffold(
      appBar: PlatformAppBar(
        title: Text(
          loc.changingPassword,
          style: Style().appBar(context),
        ),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Material(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 70),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Form(
                  key: _formKey,
                  child: TextFormField(
                    onFieldSubmitted: (_) => FocusScope.of(context).unfocus(),
                    textInputAction: TextInputAction.done,
                    decoration: Style.textField(loc.email, context),
                    validator: (v) {
                      if (v.isEmpty)
                        return loc.enterEmail;
                      else
                        return null;
                    },
                    onChanged: (value) => email = value,
                  ),
                ),
                SizedBox(
                  height: 60,
                ),
                CupertinoButton(
                  child: Text(
                    loc.sendAgainVerify,
                    textAlign: TextAlign.center,
                    style: Style().dialogOk(context),
                  ),
                  onPressed: () {
                    _sendEmail();
                  },
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
