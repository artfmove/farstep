import 'package:flutter/material.dart';

class Feed {
  final String feedId;
  final String title;
  final String description;
  final DateTime startDate;
  String startDateString;
  final List<FadeInImage> images;

  Feed(
      {this.feedId,
      this.title,
      this.description,
      this.startDate,
      this.startDateString,
      this.images});
}
