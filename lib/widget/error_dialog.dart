import '../common.dart';
import '../widget/loading_dialog.dart';
import 'package:flutter/cupertino.dart';

class ErrorDialog extends StatelessWidget {
  final String errorText;
  final BuildContext ctx;
  ErrorDialog(this.errorText, this.ctx);

  @override
  Widget build(BuildContext context) {
    return PlatformAlertDialog(
      content: Text(LoadingDialog.validation(errorText, context)),
      actions: [
        CupertinoButton(
          child: Text(
            AppLocalizations.of(context).error,
            style: Style().dialogOk(context),
          ),
          onPressed: () => Navigator.of(ctx),
        )
      ],
    );
  }
}
