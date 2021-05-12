import '../common.dart';
import '../widget/feed_item.dart';
import '../provider/data.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../model/feed.dart';
import 'package:provider/provider.dart';

class FeedScreen extends StatefulWidget {
  @override
  _FeedScreenState createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  Future<List<Feed>> futureList;
  List<Feed> list = [];

  void _onRefresh() async {
    await Provider.of<Data>(context, listen: false).fetchFeeds(context);
    list = Provider.of<Data>(context, listen: false).getFeeds;
    setState(() {});
    _refreshController.refreshCompleted();
  }

  @override
  void didChangeDependencies() {
    list = Provider.of<Data>(context, listen: false).getFeeds;
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SmartRefresher(
            controller: _refreshController,
            onRefresh: _onRefresh,
            child: ListView.builder(
              itemBuilder: (_, i) => FeedItem(
                list[i],
                key: UniqueKey(),
              ),
              padding: EdgeInsets.all(0),
              itemCount: list.length,
            )),
      ],
    );
  }
}
