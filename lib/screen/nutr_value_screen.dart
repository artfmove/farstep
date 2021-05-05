import '../common.dart';
import 'package:photo_view/photo_view.dart';

class NutrValueScreen extends StatelessWidget {
  final String nutrValue;
  NutrValueScreen(this.nutrValue);
  @override
  Widget build(BuildContext context) {
    print(nutrValue);
    return PlatformScaffold(
      appBar: PlatformAppBar(
        title: Text(AppLocalizations.of(context).infoNutr),
      ),
      body: Container(
          color: Colors.transparent,
          alignment: Alignment.center,
          child: PhotoView(
              backgroundDecoration: BoxDecoration(color: Colors.transparent),
              loadingBuilder: (ctx, _) =>
                  Center(child: PlatformCircularProgressIndicator()),
              imageProvider: NetworkImage(nutrValue))),
    );
  }
}
