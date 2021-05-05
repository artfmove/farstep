import '../common.dart';
import '../screen/place_screen.dart';

import '../model/place.dart';

import 'package:carousel_slider/carousel_slider.dart';

class PlaceItem extends StatefulWidget {
  final Place place;
  final bool isFav;

  PlaceItem(this.place, this.isFav);

  @override
  _PlaceItemState createState() => _PlaceItemState();
}

class _PlaceItemState extends State<PlaceItem> with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10.0),
            child: Container(
              decoration: BoxDecoration(border: Border.all(width: 1)),
              child: Material(
                color: Colors.transparent,
                child: Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    Column(children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.of(context, rootNavigator: true).push(
                              MaterialPageRoute(builder: (_) => PlaceScreen()));
                        },
                        child: Container(
                          color: Colors.transparent,
                          width: double.infinity,
                          child: CarouselSlider.builder(
                            itemCount: widget.place.images.length,
                            options: CarouselOptions(
                              viewportFraction: 1,
                              enableInfiniteScroll: true,
                            ),
                            itemBuilder: (context, index, i) =>
                                widget.place.images[index],
                          ),
                        ),
                      ),
                    ]),
                  ],
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  widget.place.title,
                  style: Style().text4(context),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
