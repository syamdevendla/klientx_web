//*************   © Copyrighted by aagama_it.

import 'package:aagama_it/Configs/enum.dart';
import 'package:aagama_it/Localization/language_constants.dart';
import 'package:aagama_it/Screens/AgentScreens/Tickets/TicketUtils/ticket_utils.dart';
import 'package:aagama_it/Services/Providers/Observer.dart';
import 'package:aagama_it/widgets/WarningWidgets/warning_tile.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

reopenWidget(BuildContext context) {
  var observer = Provider.of<Observer>(context, listen: false);
  return observer.userAppSettingsDoc!.reopenTicketTillDays == 0
      ? SizedBox()
      : Container(
          alignment: Alignment.center,
          padding: EdgeInsets.fromLTRB(14, 7, 14, 7),
          color: Colors.white,
          height: 100,
          width: MediaQuery.of(context).size.width,
          child: warningTile(
              isstyledtext: true,
              title:
                  // "Ticket is <bold>Closed</bold>. You can reopen the ticket till <bold>${TicketUtils.totalReopenDays(context)}${TicketUtils.totalReopenDays(context) < 2 ? " Day" : " Days"}</bold> after Closing.",
                  getTranslatedForCurrentUser(
                          context, 'xxtktclosedreopentillxx')
                      .replaceAll('(####)',
                          getTranslatedForCurrentUser(context, 'xxtktsxx'))
                      .replaceAll('(###)',
                          TicketUtils.totalReopenDays(context).toString()),
              warningTypeIndex: WarningType.alert.index));
}

mediadeletenotificationWidget(BuildContext context) {
  var observer = Provider.of<Observer>(context, listen: false);
  return observer
              .userAppSettingsDoc!.defaultTicketMssgsDeletingTimeAfterClosing ==
          0
      ? SizedBox()
      : Container(
          alignment: Alignment.center,
          padding: EdgeInsets.fromLTRB(14, 7, 14, 7),
          color: Colors.white,
          height: 100,
          width: MediaQuery.of(context).size.width,
          child: warningTile(
              isstyledtext: true,
              title:
                  // "Ticket Media data will be <bold>Deleted</bold> after <bold>${TicketUtils.totalDeletingdays(context)}${TicketUtils.totalDeletingdays(context) < 2 ? " Day" : " Days"}</bold> of Closing. ",
                  getTranslatedForCurrentUser(context, 'xxtktmediadltxx')
                      .replaceAll('(####)',
                          getTranslatedForCurrentUser(context, 'xxtktsxx'))
                      .replaceAll('(###)',
                          TicketUtils.totalDeletingdays(context).toString()),
              warningTypeIndex: WarningType.alert.index));
}
