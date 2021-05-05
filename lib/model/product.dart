import 'package:flutter/material.dart';

class Product {
  final String productId;
  final String title;
  final String price;
  final List<FadeInImage> images;
  final String description;
  final String type;
  Product(
      {this.productId,
      this.title,
      this.price,
      this.images,
      this.description,
      this.type});
}
