import 'package:flutter/material.dart';

class Coupon {
  final String couponId;
  final String title;
  final List<FadeInImage> images;
  final List<dynamic> price;
  final String description;
  final String restartHours;
  final String expirationMinutes;
  final String type;

  Coupon(
      {this.couponId,
      this.title,
      this.images,
      this.price,
      this.description,
      this.restartHours,
      this.expirationMinutes,
      this.type});
}
