import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:provider/provider.dart';

SizedBox heightBox(double h) {
  return SizedBox(height: h);
}

SizedBox widthBox(double b) {
  return SizedBox(width: b);
}

Future<void> successSnackBar(String message) async {
  await Get.snackbar(
    "Status : Success",
    message,
    colorText: Colors.white,
    backgroundColor: Colors.black,
    margin: EdgeInsets.zero,
    borderRadius: 0,
    icon: Icon(
      Icons.check,
      color: Colors.green,
      size: 40,
    ),
  );
}

Future<void> errorSnackBar(String message) async {
  await Get.snackbar(
    duration: Duration(seconds: 3),
    "Error",
    message,
    colorText: Colors.white,
    backgroundColor: Colors.black,
    margin: EdgeInsets.zero,
    borderRadius: 0,
    icon: Icon(
      Icons.cancel,
      color: Colors.red,
      size: 40,
    ),
  );
}


Logger logger = Logger();
gotoPage(Widget widget,
    {Transition transition: Transition.native,
      Duration duration: const Duration(seconds: 1),
      bool isClosePrevious: false}) {
  if (isClosePrevious) {
    Get.offAll(() => widget, transition: transition, duration: duration);
  } else {
    Get.to(() => widget, transition: transition, duration: duration);
  }
}