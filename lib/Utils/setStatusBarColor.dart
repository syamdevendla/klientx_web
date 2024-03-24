//*************   © Copyrighted by aagama_it.

import 'package:flutter/services.dart';
import 'package:aagama_it/Configs/my_colors.dart';

setStatusBarColor() {
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Mycolors.statusBarColor,
      statusBarIconBrightness: Mycolors.isdarkIconsInStatusBar
          ? Brightness.dark
          : Brightness.light));
}
