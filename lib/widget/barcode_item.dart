import '../common.dart';
import 'package:barcode/barcode.dart';
import 'package:barcode_widget/barcode_widget.dart';
import './timer.dart';
import '../anim/fade_slide.dart';

class BarcodeItem extends StatelessWidget {
  final String barcodeId;
  final int expirationSeconds;
  BarcodeItem(this.barcodeId, this.expirationSeconds);
  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    int endTime =
        DateTime.now().millisecondsSinceEpoch + expirationSeconds * 1000;

    return FadeSlide(
      isForward: true,
      beginYOffset: 0,
      endXOffset: 0,
      endYOffset: 0,
      type: 'both',
      child: Material(
        child: Container(
          width: double.infinity,
          color: Colors.white,
          padding: EdgeInsets.fromLTRB(0, 6, 0, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Timer(
                AppLocalizations.of(context).barcodeExpired,
                endTime,
                Colors.black,
              ),
              SizedBox(height: 6),
              BarcodeWidget(
                color: Colors.black,
                backgroundColor: Colors.white,
                width: width * 0.7,
                height: 100,
                style: TextStyle(color: Colors.black),
                data: barcodeId,
                barcode: Barcode.code128(),
                errorBuilder: (context, error) => Center(child: Text(error)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
