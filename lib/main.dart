import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import './common.dart';
import './screen/landing.dart';
import './screen/authentication_screen.dart';
import './screen/auth_verify.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import './provider/data.dart';
import './provider/auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import './screen/scanner_barcodes_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  static void setLocale(BuildContext context, Locale newLocale) async {
    _MyAppState state = context.findAncestorStateOfType<_MyAppState>();
    state.changeLanguage(newLocale);
  }

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  Brightness _brightness = WidgetsBinding.instance.window.platformBrightness;

  Locale _locale;

  void changeLanguage(Locale value) => setState(() => _locale = value);

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextTheme textTheme = theme.textTheme;
    final materialTheme = new ThemeData(
            primaryColor: Colors.red[400],
            accentColor: Colors.red[400],
            backgroundColor: Colors.white,
            canvasColor: Colors.white,
            appBarTheme: AppBarTheme(color: Colors.grey[100]),
            splashColor: Colors.grey[200],
            iconTheme: IconThemeData(color: Colors.red),
            bottomNavigationBarTheme: BottomNavigationBarThemeData(
                selectedItemColor: Colors.red,
                unselectedItemColor: Colors.grey),
            scaffoldBackgroundColor: Colors.grey[200])
        .copyWith(textTheme: textTheme);

    final ThemeData themeDark = ThemeData.dark();
    final TextTheme textThemeDark = themeDark.textTheme;
    final materialDarkTheme = new ThemeData.dark()
        .copyWith(
            primaryColor: Colors.red[400],
            accentColor: Colors.red,
            splashColor: Colors.grey[200],
            scaffoldBackgroundColor: Colors.black,
            iconTheme: IconThemeData(color: Colors.red),
            appBarTheme: AppBarTheme(color: Colors.grey[900]),
            bottomNavigationBarTheme: BottomNavigationBarThemeData(
                selectedItemColor: Colors.red,
                unselectedItemColor: Colors.grey),
            elevatedButtonTheme: ElevatedButtonThemeData(
                style: TextButton.styleFrom(primary: Colors.red)),
            buttonTheme: ButtonThemeData(buttonColor: Colors.red),
            textButtonTheme: TextButtonThemeData(
                style: TextButton.styleFrom(
              primary: Colors.red,
            )))
        .copyWith(textTheme: textThemeDark);

    final cupertinoTheme = new CupertinoThemeData(
        brightness: _brightness,
        primaryColor: CupertinoDynamicColor.withBrightness(
          color: Colors.red,
          darkColor: Colors.red,
        ),
        scaffoldBackgroundColor: CupertinoDynamicColor.withBrightness(
          color: Colors.grey[200],
          darkColor: Colors.black,
        ),
        primaryContrastingColor: CupertinoDynamicColor.withBrightness(
          color: Colors.red,
          darkColor: Colors.red,
        ),
        textTheme: CupertinoTextThemeData(
          primaryColor: CupertinoDynamicColor.withBrightness(
            color: Colors.black,
            darkColor: Colors.white,
          ),
          textStyle: TextStyle(
              color: CupertinoDynamicColor.withBrightness(
            color: Colors.black,
            darkColor: Colors.white,
          )),
        ));

    return Theme(
        data:
            _brightness == Brightness.light ? materialTheme : materialDarkTheme,
        child: MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (context) => Data()),
            ChangeNotifierProvider(create: (context) => Auth()),
          ],
          child: PlatformApp(
              locale: _locale,
              localizationsDelegates: [
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
                AppLocalizations.delegate,
                RefreshLocalizations.delegate
              ],
              supportedLocales: [
                //const Locale('en', ''),
                const Locale('ru', ''),
                const Locale('uk', ''),
              ],
              title: 'farstep',
              material: (_, __) {
                return new MaterialAppData(
                  debugShowCheckedModeBanner: false,
                  theme: materialTheme,
                  darkTheme: materialDarkTheme,
                );
              },
              cupertino: (_, __) => new CupertinoAppData(
                    routes: {
                      '/scanner': (context) => ScannerBarcodesScreen(),
                    },
                    debugShowCheckedModeBanner: false,
                    theme: cupertinoTheme,
                  ),
              home: FirebaseAuth.instance.currentUser != null
                  ? Landing()
                  : Auth().checkNotYetVerified()
                      ? AuthVerify(true)
                      : AuthenticationScreen()),
        ));
  }
}
