//*************   © Copyrighted by aagama_it. 

import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';

pageNavigator(BuildContext context, Widget widget) {
  Navigator.push(context,
      PageTransition(type: PageTransitionType.rightToLeft, child: widget));
}

pageOpenOnTop(BuildContext context, Widget widget) {
  Navigator.push(context,
      PageTransition(type: PageTransitionType.bottomToTop, child: widget));
}
