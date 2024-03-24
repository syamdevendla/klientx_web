//*************   © Copyrighted by aagama_it. 

import 'package:aagama_it/Configs/my_colors.dart';
import 'package:aagama_it/Configs/app_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Splashscreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarIconBrightness: Brightness.dark,
      statusBarColor:
          Mycolors.whiteDynamic, //or set color with: Color(0xFF0000FF)
    ));
    return Scaffold(
      backgroundColor: Mycolors.splashBackgroundSolidColor,
      body: Center(
          child: Image.asset(
        '$SplashPath',
        width: double.infinity,
        fit: BoxFit.cover,
      )),
    );
  }
}
