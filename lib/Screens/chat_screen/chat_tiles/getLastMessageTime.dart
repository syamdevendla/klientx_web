//*************   © Copyrighted by aagama_it.

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:aagama_it/Utils/formatStatusTime.dart';
import 'package:aagama_it/Services/Providers/Observer.dart';
import 'package:aagama_it/Localization/language_constants.dart';

final DateFormat formatter = DateFormat('dd/MM/yy');

getLastMessageTime(BuildContext context, String currentUserNo, val) {
  final observer = Provider.of<Observer>(context, listen: false);
  if (val is bool && val == true) {
    return getTranslatedForCurrentUser(context, 'xxonlinexx');
  } else if (val is int) {
    DateTime now = DateTime.now();
    DateTime date = DateTime.fromMillisecondsSinceEpoch(val);
    String at = observer.is24hrsTimeformat == false
            ? DateFormat.jm().format(date)
            : DateFormat('HH:mm').format(date),
        when = date.day == now.subtract(Duration(days: 1)).day
            ? getTranslatedForCurrentUser(context, 'xxyesterdayxx')
            : getWhen(date, context);

    return date.day == now.day ? '$at' : '$when';

    // DateTime date = DateTime.fromMillisecondsSinceEpoch(val);
    // DateTime now = DateTime.now();

    // String at = observer.is24hrsTimeformat == false
    //         ? DateFormat.jm().format(date)
    //         : DateFormat('HH:mm').format(date),
    //     when = date.day == now.subtract(Duration(days: 1)).day
    //         ? getTranslatedForCurrentUser(context, 'xxyesterdayxx')
    //         : getJoinTime(val, context);
    // return date.day == now.day ? '$at' : '$when';
  } else if (val is String) {
    if (val == currentUserNo)
      return getTranslatedForCurrentUser(context, 'xxtypingxx');
    return getTranslatedForCurrentUser(context, 'xxonlinexx');
  }
  return "";
}
