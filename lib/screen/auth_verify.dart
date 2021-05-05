import '../common.dart';
import '../provider/auth.dart';
import '../widget/loading_dialog.dart';

class AuthVerify extends StatefulWidget {
  final bool isAlreadySigned;
  AuthVerify(this.isAlreadySigned);
  @override
  _AuthVerifyState createState() => _AuthVerifyState();
}

class _AuthVerifyState extends State<AuthVerify> {
  var loc;

  void _tryAuth() async {
    LoadingDialog.showLoad(context);
    final isVerified = await Auth().checkEmailVerified();
    LoadingDialog.dispLoad();
    if (!isVerified)
      showPlatformDialog(
          barrierDismissible: true,
          context: context,
          builder: (ctx) => PlatformAlertDialog(
                title: Text(
                  loc.goesWrong,
                  style: Style().text3(context),
                ),
                content:
                    Text(loc.emailNotVerified, style: Style().text4(context)),
                actions: [
                  TextButton(
                      child: Text(
                        AppLocalizations.of(context).cancel,
                        textAlign: TextAlign.center,
                        style: Style().text3(context),
                      ),
                      onPressed: () async {
                        Navigator.of(ctx).pop();
                      }),
                  TextButton(
                      child: Text(loc.sendAgainVerify,
                          style: Style(color: Colors.red).text3(context)),
                      onPressed: () async {
                        Auth().sendEmail(context);
                        Navigator.of(ctx).pop();
                      }),
                ],
              ));
    else
      Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
  }

  void _breakConfirmation() async {
    LoadingDialog.showLoad(context);
    final response = await Auth().signOut(context);
    LoadingDialog.dispLoad();
    if (!response)
      LoadingDialog.showError(context, AppLocalizations.of(context).error);
  }

  @override
  void didChangeDependencies() {
    if (widget.isAlreadySigned) Auth().sendEmail(context);
    super.didChangeDependencies();
  }

  Widget outlButton(color, function, text, fontSize) => FlatButton(
        color: color,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(40.0),
            side: BorderSide(color: Colors.grey[300])),
        onPressed: () => function(),
        child: Container(
          child: Text(
            text,
            style: TextStyle(fontSize: fontSize),
            textAlign: TextAlign.center,
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    loc = AppLocalizations.of(context);
    final width = MediaQuery.of(context).size.width;
    return PlatformScaffold(
      appBar: PlatformAppBar(
        title: Text(
          loc.confirmation,
          style: Style().text2(context),
        ),
      ),
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    loc.verifyEmailSent,
                    style: Style().text3(context),
                    maxLines: 2,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  outlButton(Colors.red, _tryAuth, loc.alreadyAccepted,
                      width > 230 ? 18.0 : 13.0)
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 18.0),
            child: outlButton(Colors.black, _breakConfirmation,
                loc.breakConfirmation, width > 230 ? 14.0 : 11.0),
          ),
        ],
      ),
    );
  }
}
