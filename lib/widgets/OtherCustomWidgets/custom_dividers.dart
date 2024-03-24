//*************   © Copyrighted by aagama_it. 

import 'package:aagama_it/Configs/my_colors.dart';
import 'package:flutter/material.dart';

Widget myverticaldivider(
    {double? thickness, double? marginwidth, double? height, Color? color}) {
  return Container(
    margin: EdgeInsets.only(left: marginwidth ?? 5, right: marginwidth ?? 5),
    height: height ?? 30,
    width: thickness ?? 2,
    color: color ?? Mycolors.greylight,
  );
}

Widget myvhorizontaldivider(
    {double? thickness, double? marginheight, double? width, Color? color}) {
  return Container(
    margin: EdgeInsets.only(top: marginheight ?? 5, bottom: marginheight ?? 5),
    width: width ?? 30,
    height: thickness ?? 1,
    color: color ?? Mycolors.greylight.withOpacity(0.3),
  );
}
