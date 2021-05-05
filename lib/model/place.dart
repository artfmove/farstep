import 'package:flutter/material.dart';

class Place {
  final String title;
  final String time;
  final String address;
  final String addressUrl;
  final FadeInImage addressImage;
  final String site;
  final String phone;
  final String nutrValue;
  final List<FadeInImage> images;
  final List<dynamic> types;

  Place(
      {this.title,
      this.time,
      this.address,
      this.addressUrl,
      this.addressImage,
      this.site,
      this.phone,
      this.nutrValue,
      this.images,
      this.types});
}
