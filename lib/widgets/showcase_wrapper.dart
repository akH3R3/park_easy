import 'package:flutter/material.dart';
import 'package:showcaseview/showcaseview.dart';

Widget showcaseWrapper({
  required GlobalKey key,
  required Widget child,
  required String description,
}) {
  return Showcase(
    key: key,
    description: description,
    descTextStyle: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: Colors.white,
    ),
    tooltipBackgroundColor: Colors.blueAccent,
    child: child,
  );
}