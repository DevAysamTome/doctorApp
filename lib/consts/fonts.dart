import 'dart:ui';

import 'package:test_app/consts/consts.dart';

class AppSize {
  static const size12 = 12.0,
      size14 = 14.0,
      size16 = 16.0,
      size18 = 18.0,
      size20 = 20.0,
      size22 = 22.0,
      size34 = 34.0;
}

class AppStyle {
  static normal(
      {String? title,
      Color color = Colors.black,
      double? size,
      TextAlign align = TextAlign.left}) {
    return title!.text.size(size).color(color).make();
  }

  static bold(
      {String? title,
      FontWeight? weight = FontWeight.w800,
      Color color = Colors.black,
      double? size,
      TextAlign align = TextAlign.left}) {
    return title!.text
        .size(size)
        .color(color)
        .align(align)
        .fontWeight(weight!)
        .make();
  }
}
