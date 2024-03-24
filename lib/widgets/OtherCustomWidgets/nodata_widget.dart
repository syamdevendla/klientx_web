//*************   © Copyrighted by aagama_it. 

import 'package:aagama_it/Configs/my_colors.dart';
import 'package:flutter/material.dart';

Widget noDataWidget({
  required BuildContext context,
  EdgeInsets? padding = const EdgeInsets.all(38),
  String? title = "No data",
  String? subtitle = "",
  IconData? iconData = Icons.no_accounts,
  Color? iconColor = Colors.amber,
}) {
  return Center(
    child: Padding(
      padding: padding ??
          EdgeInsets.fromLTRB(
              40, MediaQuery.of(context).size.height / 12, 40, 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(
              padding: EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              height: 100,
              width: 100,
              child: Icon(iconData ?? Icons.person,
                  size: 44, color: iconColor ?? Mycolors.yellow)),
          SizedBox(
            height: 30,
          ),
          Text(
            title ?? 'No Data',
            textAlign: TextAlign.center,
            style: TextStyle(
                color: Mycolors.black.withOpacity(0.99),
                fontSize: 16.7,
                fontWeight: FontWeight.bold),
          ),
          SizedBox(
            height: 10,
          ),
          Text(
            subtitle ?? '',
            textAlign: TextAlign.center,
            style: TextStyle(
                color: Mycolors.grey,
                fontSize: 14.5,
                fontWeight: FontWeight.w400),
          ),
          SizedBox(
            height: 30,
          ),
        ],
      ),
    ),
  );
}
