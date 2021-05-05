import 'package:settings_ui/settings_ui.dart';
import '../common.dart';
import './account_settings.dart';
import '../provider/data.dart';
import 'package:provider/provider.dart';
import 'dart:io';

import 'scanner_barcodes_screen.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String locale;
  AppLocalizations loc;
  int tapOwners = 0;

  Future<void> showTerms() async {
    LoadingDialog.showLoad(context);
    final loadTerms = await Data().loadTerms(context);
    LoadingDialog.dispLoad();

    if (loadTerms != 'error')
      showPlatformDialog(
          barrierDismissible: true,
          context: context,
          builder: (ctx) => Padding(
                padding: EdgeInsets.symmetric(vertical: 50),
                child: PlatformAlertDialog(
                    content: SingleChildScrollView(
                  child: Text(loadTerms),
                )),
              ));
    else
      LoadingDialog.showError(context, loc.error);
  }

  @override
  void didChangeDependencies() {
    loc = AppLocalizations.of(context);
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return PlatformScaffold(
      body: Column(
        children: [
          SettingsList(
            darkBackgroundColor:
                Platform.isAndroid ? Colors.grey[900] : Colors.black,
            shrinkWrap: true,
            contentPadding: EdgeInsets.all(0),
            sections: [
              SettingsSection(
                  title: loc.settings,
                  titlePadding: EdgeInsets.all(10),
                  subtitlePadding: EdgeInsets.all(100),
                  tiles: [
                    SettingsTile(
                        leading: Icon(Icons.info),
                        title: loc.terms,
                        onPressed: (_) => showTerms()),
                    SettingsTile(leading: Icon(Icons.book), title: loc.offer),
                    SettingsTile(
                        leading: Icon(Icons.account_box),
                        title: loc.account,
                        onPressed: (_) => Navigator.push(
                              context,
                              platformPageRoute(
                                context: context,
                                builder: (_) => AccountSettings(),
                              ),
                            )),
                    if (tapOwners > 5)
                      SettingsTile(
                        switchActiveColor: Platform.isAndroid
                            ? Colors.grey[900]
                            : Colors.black,
                        leading: Icon(Icons.search),
                        title: loc.scan,
                        onPressed: (_) async {
                          final isOwner =
                              await Provider.of<Data>(context, listen: false)
                                  .checkAccess();
                          if (isOwner) {
                            Navigator.of(context, rootNavigator: true)
                                .pushAndRemoveUntil(
                                    platformPageRoute(
                                        fullscreenDialog: true,
                                        context: context,
                                        builder: (context) =>
                                            ScannerBarcodesScreen()),
                                    (route) => false);
                          }
                        },
                      )
                  ])
            ],
          ),
          Expanded(
            child: GestureDetector(onTap: () => setState(() => tapOwners++)),
          )
        ],
      ),
    );
  }
}
