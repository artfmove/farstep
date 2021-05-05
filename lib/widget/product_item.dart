import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../common.dart';
import '../model/product.dart';

class ProductItem extends StatelessWidget {
  final Product product;

  ProductItem(this.product);
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return GestureDetector(
      child: Container(
          padding: EdgeInsets.symmetric(vertical: 1),
          child: Row(
            children: [
              Container(
                width: size.width * 0.5,
                height: size.width * 0.5,
                child: product.images[0],
              ),
              Container(
                color: Theme.of(context).scaffoldBackgroundColor,
                padding: EdgeInsets.all(8),
                width: size.width * 0.50,
                height: size.width * 0.50,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Text(product.title,
                        textAlign: TextAlign.end,
                        style: TextStyle(
                          fontSize: size.height > 650 ? 28 : 21,
                        )),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Text(
                        '${product.price} ${AppLocalizations.of(context).value}',
                        style: TextStyle(
                            fontSize: size.height > 650 ? 22 : 16,
                            color: Colors.red),
                      ),
                    ),
                  ],
                ),
              )
            ],
          )),
    );
  }
}
