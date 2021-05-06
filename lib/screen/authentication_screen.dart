import '../common.dart';
import '../widget/auth_method.dart';
import 'package:provider/provider.dart';
import '../provider/auth.dart';
import '../widget/loading_dialog.dart';
import './reset_password.dart';
import '../screen/auth_verify.dart';
import './landing.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthenticationScreen extends StatefulWidget {
  @override
  _AuthenticationScreenState createState() => _AuthenticationScreenState();
}

class _AuthenticationScreenState extends State<AuthenticationScreen>
    with TickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  AppLocalizations loc;

  AnimationController _animController;
  Animation<Offset> _slideAnimation;
  Animation<double> _opacityAnimation;
  var auth, size;

  bool isMailSelected = false, isLogin = true;
  double opacityLevel = 0;

  Map<String, String> authData = {
    'email': '',
    'password': '',
    'confirmedPassword': ''
  };

  @override
  void initState() {
    _animController =
        AnimationController(duration: Duration(milliseconds: 360), vsync: this);
    _slideAnimation = Tween<Offset>(begin: Offset(0, -0.7), end: Offset(0, 0.5))
        .animate(CurvedAnimation(
            curve: Curves.fastOutSlowIn, parent: _animController));
    _opacityAnimation = Tween(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _animController, curve: Curves.easeIn));
    super.initState();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void setMailSelected() {
    setState(() {
      isMailSelected = !isMailSelected;
    });
  }

  void toggleAuthMode() {
    isLogin ? _animController.forward() : _animController.reverse();
    isLogin = !isLogin;
    setState(() {
      opacityLevel = opacityLevel == 1.0 ? 0 : 1.0;
    });
  }

  void _authenticate() async {
    if (!_formKey.currentState.validate())
      return;
    else {
      if (isLogin) {
        LoadingDialog.showLoad(context);
        final loginResponse = await Auth()
            .signInWithEmail(authData['email'], authData['password']);
        if (loginResponse == 'success') {
          final check = await Auth().checkEmailVerified();
          LoadingDialog.dispLoad();
          if (FirebaseAuth.instance.currentUser != null && check)
            Navigator.of(context).pushAndRemoveUntil(
                platformPageRoute(context: context, builder: (_) => Landing()),
                (route) => false);
          else if (FirebaseAuth.instance.currentUser != null && !check)
            Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
                platformPageRoute(
                    context: context, builder: (_) => AuthVerify(true)),
                (route) => false);
        }
        if (loginResponse != 'success') {
          LoadingDialog.dispLoad();
          LoadingDialog.showError(context, loginResponse);
        }
      } else {
        LoadingDialog.showLoad(context);
        final terms = await Data().loadTerms(context);
        LoadingDialog.dispLoad();
        if (terms == null)
          LoadingDialog.showError(context, AppLocalizations.of(context).error);
        else {
          showPlatformDialog(
              barrierDismissible: true,
              context: context,
              builder: (ctx) => PlatformAlertDialog(
                    content: Container(
                      height: 500,
                      child: SingleChildScrollView(
                        child: Text(
                          terms,
                          style: Style().text4(context),
                        ),
                      ),
                    ),
                    actions: [
                      TextButton(
                          child: Text(
                            loc.acceptTerms,
                            textAlign: TextAlign.center,
                            style: Style(color: Colors.red).dialogOk(context),
                          ),
                          onPressed: () async {
                            Navigator.of(ctx).pop();
                            LoadingDialog.showLoad(context);
                            final responseSignUp = await Auth().signUpWithEmail(
                                authData['email'],
                                authData['password'],
                                authData['confirmedPassword'],
                                context);
                            LoadingDialog.dispLoad();
                            if (responseSignUp != 'success')
                              LoadingDialog.showError(context, responseSignUp);
                          }),
                      TextButton(
                        child: Text(
                          loc.cancel,
                          style: Style().dialogCancel(context),
                        ),
                        onPressed: () => Navigator.of(ctx).pop(),
                      )
                    ],
                  ));
        }
      }
    }
  }

  @override
  void didChangeDependencies() {
    Data().getLocaleIndex(context);
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final node = FocusScope.of(context);
    loc = AppLocalizations.of(context);
    size = MediaQuery.of(context).size;
    auth = Provider.of<Auth>(context, listen: false);

    return PlatformScaffold(
      material: (_, __) => MaterialScaffoldData(resizeToAvoidBottomInset: true),
      iosContentPadding: false,
      iosContentBottomPadding: false,
      appBar: PlatformAppBar(
        title: Text(
          loc.authentication,
          style: Style().appBar(context),
        ),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Material(
          child: Stack(
            alignment:
                size.width > 360 ? Alignment.center : Alignment.topCenter,
            children: [
              SingleChildScrollView(
                child: Column(
                  children: [
                    Container(
                      alignment: Alignment.center,
                      padding: size.width > 360
                          ? const EdgeInsets.fromLTRB(70, 0, 70, 0)
                          : const EdgeInsets.fromLTRB(70, 50, 70, 0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            loc.authChooseMethod,
                            textAlign: TextAlign.center,
                            style: Style(color: Colors.grey).text3(context),
                          ),
                          SizedBox(
                            height: 30,
                          ),
                          FlatButton(
                            color: isMailSelected ? Colors.grey[300] : null,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(40.0),
                                side: BorderSide(color: Colors.grey[300])),
                            onPressed: () => setState(() {
                              isMailSelected = !isMailSelected;
                            }),
                            child: Container(
                              height: size.width > 360 ? 55 : 45,
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: 10,
                                  ),
                                  Image(
                                    image:
                                        AssetImage('./assets/images/mail.png'),
                                    height: size.height > 360 ? 40 : 30,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 10),
                                    child: Text(
                                      loc.mail,
                                      style: Style().text3(context),
                                    ),
                                  ),
                                  Spacer(),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: isMailSelected
                                        ? Icon(
                                            Icons.keyboard_arrow_down,
                                          )
                                        : null,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          AnimatedCrossFade(
                            firstCurve: Curves.fastOutSlowIn,
                            duration: const Duration(milliseconds: 500),
                            firstChild: AuthMethod(
                                './assets/images/guest.png',
                                AppLocalizations.of(context).guest,
                                false, () async {
                              await auth.signInAnonymously(context);
                            }),
                            secondChild: Form(
                              key: _formKey,
                              child: Wrap(
                                alignment: WrapAlignment.center,
                                spacing: 12,
                                runSpacing: 12,
                                children: [
                                  SizedBox(
                                    height: 8,
                                  ),
                                  TextFormField(
                                    textInputAction: TextInputAction.next,
                                    keyboardType: TextInputType.emailAddress,
                                    onFieldSubmitted: (value) =>
                                        node.nextFocus(),
                                    onChanged: (value) =>
                                        authData['email'] = value,
                                    decoration:
                                        Style.textField(loc.email, context),
                                    validator: (v) =>
                                        v.isEmpty ? loc.enterEmail : null,
                                  ),
                                  TextFormField(
                                    obscureText: true,
                                    textInputAction: TextInputAction.next,
                                    decoration:
                                        Style.textField(loc.password, context),
                                    onFieldSubmitted: (value) => isLogin
                                        ? FocusScope.of(context).unfocus()
                                        : FocusScope.of(context).nextFocus(),
                                    onChanged: (value) =>
                                        authData['password'] = value,
                                    validator: (v) =>
                                        v.length < 6 ? loc.shortPassword : null,
                                  ),
                                  FadeTransition(
                                    opacity: _opacityAnimation,
                                    child: TextFormField(
                                        onFieldSubmitted: (_) => node.unfocus(),
                                        obscureText: true,
                                        textInputAction: TextInputAction.done,
                                        decoration: Style.textField(
                                            loc.confirmPassword, context),
                                        onChanged: (value) =>
                                            authData['confirmedPassword'] =
                                                value,
                                        validator: (v) => !isLogin &&
                                                v != authData['password']
                                            ? loc.differentPasswords
                                            : null),
                                  ),
                                ],
                              ),
                            ),
                            crossFadeState: isMailSelected
                                ? CrossFadeState.showSecond
                                : CrossFadeState.showFirst,
                          ),
                        ],
                      ),
                    ),
                    if (isMailSelected)
                      Container(
                        padding: EdgeInsets.only(top: 10),
                        child: SlideTransition(
                            position: _slideAnimation,
                            child: TextButton(
                              onPressed: () {
                                _authenticate();
                              },
                              child: Text(
                                isLogin ? loc.logIn : loc.signUp,
                                style: Style(color: Colors.red).text1(context),
                                textAlign: TextAlign.center,
                              ),
                            )),
                      ),
                  ],
                ),
              ),
              MediaQuery.of(context).viewInsets.bottom == 0
                  ? Container(
                      padding: EdgeInsets.fromLTRB(10, 0, 10, 20),
                      alignment: Alignment.bottomCenter,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          GestureDetector(
                            onTap: () => toggleAuthMode(),
                            child: Container(
                              width: size.width * 0.4,
                              child: Text(
                                isLogin ? loc.orCreate : loc.orLogin,
                                textAlign: TextAlign.center,
                                maxLines: 3,
                                style: Style().text4(context),
                              ),
                            ),
                          ),
                          TextButton(
                            child: Text(
                              loc.forgotPassword,
                              style: Style(color: Colors.red).text4(context),
                            ),
                            onPressed: () => Navigator.of(context).push(
                                platformPageRoute(
                                    context: context,
                                    builder: (_) => ResetPassword())),
                          ),
                        ],
                      ),
                    )
                  : Container()
            ],
          ),
        ),
      ),
    );
  }
}
