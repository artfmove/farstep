import '../common.dart';
import '../model/feed.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';

class FeedItem extends StatefulWidget {
  final Feed feed;
  FeedItem(this.feed, {Key key}) : super(key: key);

  @override
  _FeedItemState createState() => _FeedItemState();
}

class _FeedItemState extends State<FeedItem> {
  String firstHalf;
  String secondHalf;

  bool flag = true;

  @override
  void initState() {
    if (widget.feed.description.length > 300) {
      firstHalf = widget.feed.description.substring(0, 300);
      secondHalf = widget.feed.description
          .substring(300, widget.feed.description.length);
    } else {
      firstHalf = widget.feed.description;
      secondHalf = "";
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        setState(() {
          flag = !flag;
        });
      },
      child: Container(
          padding: EdgeInsets.only(bottom: 10),
          color: Colors.transparent,
          child: Column(children: [
            CarouselSlider.builder(
                itemCount: widget.feed.images.length,
                itemBuilder: (_, i, ii) => Container(
                    width: MediaQuery.of(context).size.width,
                    child: widget.feed.images[i]),
                options: CarouselOptions(
                    viewportFraction: 1.0, enableInfiniteScroll: false)),
            Container(
              padding: EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  secondHalf.isEmpty
                      ? new Text(firstHalf)
                      : new Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            new Text(
                                flag
                                    ? (firstHalf + "...")
                                    : (firstHalf + secondHalf),
                                style: Style(
                                        fontWeight: FontWeight.w200,
                                        fontStyle: FontStyle.italic)
                                    .text4(context)),
                            Align(
                              alignment: Alignment.centerRight,
                              child: CupertinoButton(
                                padding: EdgeInsets.all(0),
                                child: Container(
                                  padding: EdgeInsets.only(
                                    bottom: 1,
                                  ),
                                  decoration: BoxDecoration(
                                      border: Border(
                                          bottom: BorderSide(
                                    color: Theme.of(context)
                                        .textTheme
                                        .bodyText1
                                        .color,
                                    width: 0.5,
                                  ))),
                                  child: Text(
                                    flag
                                        ? AppLocalizations.of(context).showMore
                                        : AppLocalizations.of(context).showLess,
                                    style: Style(color: Colors.grey[500])
                                        .text5(context),
                                  ),
                                ),
                                onPressed: () {
                                  setState(() {
                                    flag = !flag;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        widget.feed.startDateString,
                        style: Style().text4(context),
                      ),
                      Text(widget.feed.title, style: Style().text4(context)),
                    ],
                  ),
                ],
              ),
            )
          ])),
    );
  }
}
