import '../common.dart';
import 'package:carousel_slider/carousel_slider.dart';
import '../model/place.dart';
import '../widget/place_sliver_info.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:provider/provider.dart';
import '../provider/data.dart';
import '../widget/product_item.dart';
import '../widget/button_outline.dart';
import '../model/product.dart';
import '../widget/button_outline_sort.dart';
import 'dart:io' show Platform;

enum mode { info, menu }

class PlaceScreen extends StatefulWidget {
  @override
  _PlaceScreenState createState() => _PlaceScreenState();
}

class _PlaceScreenState extends State<PlaceScreen>
    with TickerProviderStateMixin {
  AppLocalizations loc;
  AnimationController _animationController;

  List<Product> products;
  Place place;
  var currentMode = mode.info;

  var currentSortProduct = '';

  List<Product> specifiedProductsList;

  void toggleMenu() => setState(() => currentMode = mode.menu);
  void toggleInfo() => setState(() => currentMode = mode.info);

  @override
  void initState() {
    super.initState();
    print('build_place');
    _animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 250));
    place = Provider.of<Data>(context, listen: false).getPlace;

    products = Provider.of<Data>(context, listen: false).getProducts;
  }

  void _showSortSheet() {
    _animationController.forward();
    showPlatformModalSheet<void>(
      context: context,
      builder: (ctx) => Container(
        padding: EdgeInsets.only(bottom: 20),
        color: Style().dialogColor(context),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GridView.builder(
              padding: EdgeInsets.all(50),
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 15.0,
                childAspectRatio: 3.5,
                mainAxisSpacing: 15.0,
              ),
              itemCount: place.types.length,
              itemBuilder: (ctx, i) => ButtonOutlineSort(place.types[i], () {
                setState(() {
                  Navigator.of(ctx).pop();

                  currentSortProduct = place.types[i];
                  specifiedProductsList =
                      Data().getSpecifiedProducts(place.types[i], products);
                });
              }, currentSortProduct),
            ),
            ButtonOutlineSort(
              loc.clear,
              () {
                setState(() {
                  currentSortProduct = '';
                  specifiedProductsList = null;
                  Navigator.of(ctx).pop();
                });
              },
              null,
            )
          ],
        ),
      ),
    ).whenComplete(() {
      _animationController.reverse();
    });
  }

  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  void _onRefresh() async {
    await Provider.of<Data>(context, listen: false).fetchPlace(context);
    place = Provider.of<Data>(context, listen: false).getPlace;
    setState(() {});
    _refreshController.refreshCompleted();
  }

  @override
  Widget build(BuildContext context) {
    loc = AppLocalizations.of(context);
    final size = MediaQuery.of(context).size;
    return PlatformScaffold(
        body: RefreshConfiguration(
            headerBuilder: () => Platform.isIOS
                ? ClassicHeader(
                    height: 80,
                    outerBuilder: (child) => Padding(
                      padding: EdgeInsets.fromLTRB(0, 15, 0, 15),
                      child: child,
                    ),
                  )
                : MaterialClassicHeader(
                    height: 80,
                  ),
            child: SmartRefresher(
                controller: _refreshController,
                onRefresh: _onRefresh,
                child: CustomScrollView(slivers: [
                  SliverAppBar(
                    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                    expandedHeight: Style.imageHeight(context),
                    flexibleSpace: FlexibleSpaceBar(
                      centerTitle: true,
                      background: Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          CarouselSlider.builder(
                              itemCount: place.images.length,
                              itemBuilder: (_, i, __) {
                                return place.images[i];
                              },
                              options: CarouselOptions(
                                height: Style.imageHeight(context) + 50,
                                viewportFraction: 1,
                                autoPlay: true,
                                autoPlayInterval: Duration(seconds: 3),
                                autoPlayAnimationDuration:
                                    Duration(milliseconds: 1200),
                                autoPlayCurve: Curves.fastOutSlowIn,
                              )),
                        ],
                      ),
                    ),
                  ),
                  SliverList(
                      delegate: SliverChildListDelegate(
                    [
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Container(
                            width: size.width * 0.4,
                            child: ButtonOutline(
                                loc.info, toggleInfo, currentMode, mode.info),
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          Container(
                            width: size.width * 0.4,
                            child: ButtonOutline(
                                loc.menu, toggleMenu, currentMode, mode.menu),
                          ),
                        ],
                      ),
                      currentMode == mode.menu
                          ? Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: GestureDetector(
                                onTap: () => _showSortSheet(),
                                child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Text(loc.sortBy,
                                          style: Style().text4(context)),
                                      Text(currentSortProduct,
                                          style: Style().text4(context)),
                                      AnimatedIcon(
                                        icon: AnimatedIcons.arrow_menu,
                                        progress: _animationController,
                                        semanticLabel: 'Show menu',
                                        size: 30,
                                      )
                                    ]),
                              ),
                            )
                          : Container(),
                      currentMode == mode.menu
                          ? specifiedProductsList != null
                              ? specifiedProductsListView()
                              : productsListView(products)
                          : PlaceSliverInfo(place)
                    ],
                  ))
                ]))));
  }

  Widget specifiedProductsListView() => specifiedProductsList.length == 0
      ? Container(
          alignment: Alignment.center,
          padding: EdgeInsets.only(top: 30),
          child: Text(
            loc.noFound,
            style: Style().text4(context),
          ))
      : ListView.builder(
          padding: EdgeInsets.all(0),
          shrinkWrap: true,
          physics: ClampingScrollPhysics(),
          itemBuilder: (_, index) => ProductItem(
                specifiedProductsList[index],
              ),
          itemCount: specifiedProductsList.length);

  Widget productsListView(products) => ListView.builder(
        padding: EdgeInsets.all(0),
        physics: ClampingScrollPhysics(),
        itemBuilder: (_, index) => ProductItem(products[index]),
        itemCount: products.length,
        shrinkWrap: true,
      );
}
