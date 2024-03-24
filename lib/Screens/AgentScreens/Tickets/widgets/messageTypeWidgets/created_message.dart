//*************   © Copyrighted by aagama_it.

import 'package:aagama_it/Configs/my_colors.dart';
import 'package:aagama_it/Localization/language_constants.dart';
import 'package:aagama_it/Models/ticket_message.dart';
import 'package:aagama_it/Screens/AgentScreens/Tickets/widgets/ticketWidget.dart';
import 'package:aagama_it/Utils/formatStatusTime.dart';
import 'package:aagama_it/Services/Providers/user_registry_provider.dart';
import 'package:aagama_it/Utils/color_light_dark.dart';
import 'package:aagama_it/widgets/OtherCustomWidgets/mycustomtext.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

Widget getTicketCreatedMessage(
    {required BuildContext context,
    required TicketMessage mssg,
    required String currentUserID,
    required String customerUID,
    required bool cuurentUserCanSeeAgentNamePhoto,
    required String title}) {
  bool is24hrsFormat = true;
  humanReadableTime() => DateFormat(is24hrsFormat == true ? 'HH:mm' : 'h:mm a')
      .format(DateTime.fromMillisecondsSinceEpoch(mssg.tktMssgTIME));
  final registry = Provider.of<UserRegistry>(context, listen: false);
  return customerUID == currentUserID
      ? Column(
          children: [
            Chip(
              label: MtCustomfontBoldSemi(
                color: Colors.blueGrey[700],
                text: mssg.tktMssgSENDBY == customerUID
                    ? " ${getTranslatedForCurrentUser(context, 'xxcreatedbyxx').replaceAll('(####)', getTranslatedForCurrentUser(context, 'xxsupporttktxx')).replaceAll('(###)', getTranslatedForCurrentUser(context, 'xxyouxx'))} "
                    : " ${getTranslatedForCurrentUser(context, 'xxcreatedbyxx').replaceAll('(####)', getTranslatedForCurrentUser(context, 'xxsupporttktxx')).replaceAll('(###)', getTranslatedForCurrentUser(context, 'xxagentxx'))} ",
                fontsize: 13,
              ),
              backgroundColor: Mycolors.greylightcolor,
            ),
            SizedBox(
              height: 2,
            ),
            Container(
                width: MediaQuery.of(context).size.width >
                        MediaQuery.of(context).size.height
                    ? MediaQuery.of(context).size.width / 1.7
                    : MediaQuery.of(context).size.width / 1.2,
                decoration: boxDecoration(
                  bgColor: lighten(Colors.yellow, 0.25),
                  showShadow: false,
                  radius: 10,
                ),
                margin: EdgeInsets.fromLTRB(15, 10, 15, 7),
                padding: EdgeInsets.all(15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    MtCustomfontBoldSemi(
                      text: title,
                      fontsize: 16,
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    MtCustomfontRegular(
                      text: mssg.tktMssgCONTENT,
                      color: Mycolors.black,
                      fontsize: 14,
                    )
                  ],
                )),
            SizedBox(
              height: 2,
            ),
            Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                      getWhen(
                              DateTime.fromMillisecondsSinceEpoch(
                                  mssg.tktMssgTIME),
                              context) +
                          ', ',
                      style: TextStyle(
                        color: Mycolors.greytext,
                        fontSize: 11.0,
                      )),
                  Text(' ' + humanReadableTime().toString(),
                      style: TextStyle(
                        color: Mycolors.greytext,
                        fontSize: 11.0,
                      )),
                  // isMe ? icon : SizedBox()
                  // ignore: unnecessary_null_comparison
                ].where((o) => o != null).toList()),
            SizedBox(
              height: 15,
            ),
          ],
        )
      : Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 15,
            ),
            Chip(
              backgroundColor: Mycolors.greylightcolor,
              label: MtCustomfontBoldSemi(
                text: mssg.tktMssgSENDBY == customerUID
                    ? " ${getTranslatedForCurrentUser(context, 'xxcreatedbyxx').replaceAll('(####)', getTranslatedForCurrentUser(context, 'xxsupporttktxx')).replaceAll('(###)', getTranslatedForCurrentUser(context, 'xxcustomerxx'))} "
                    : " ${getTranslatedForCurrentUser(context, 'xxcreatedbyxx').replaceAll('(####)', getTranslatedForCurrentUser(context, 'xxsupporttktxx')).replaceAll('(###)', getTranslatedForCurrentUser(context, 'xxagentxx'))} ",
                color: Colors.blueGrey[700],
                fontsize: 13,
              ),
            ),
            SizedBox(
              height: 2,
            ),
            Container(
                width: MediaQuery.of(context).size.width >
                        MediaQuery.of(context).size.height
                    ? MediaQuery.of(context).size.width / 1.7
                    : MediaQuery.of(context).size.width / 1.2,
                decoration: boxDecoration(
                  bgColor: lighten(Colors.yellow, 0.25),
                  showShadow: false,
                  radius: 10,
                ),
                margin: EdgeInsets.fromLTRB(15, 10, 15, 7),
                padding: EdgeInsets.all(15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    MtCustomfontBoldSemi(
                      text: title,
                      fontsize: 16,
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    MtCustomfontRegular(
                      text: mssg.tktMssgCONTENT,
                      color: Mycolors.black,
                      fontsize: 14,
                    )
                  ],
                )),
            SizedBox(
              height: 2,
            ),
            Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  mssg.tktMssgSENDBY == customerUID
                      ? SizedBox()
                      : Icon(
                          Icons.person,
                          color: Mycolors.greytext,
                          size: 12,
                        ),
                  mssg.tktMssgSENDBY == customerUID
                      ? SizedBox()
                      : Text(
                          cuurentUserCanSeeAgentNamePhoto
                              ? "  ${registry.getUserData(context, mssg.tktMssgSENDBY).fullname}"
                              : "  ${getTranslatedForCurrentUser(context, 'xxagentidxx')} ${registry.getUserData(context, mssg.tktMssgSENDBY).id}",
                          style:
                              TextStyle(fontSize: 12, color: Mycolors.greytext),
                        ),
                  mssg.tktMssgSENDBY == customerUID
                      ? SizedBox()
                      : SizedBox(
                          width: 30,
                        ),
                  Text(
                      getWhen(
                              DateTime.fromMillisecondsSinceEpoch(
                                  mssg.tktMssgTIME),
                              context) +
                          ', ',
                      style: TextStyle(
                        color: Mycolors.greytext,
                        fontSize: 11.0,
                      )),
                  Text(' ' + humanReadableTime().toString(),
                      style: TextStyle(
                        color: Mycolors.greytext,
                        fontSize: 11.0,
                      )),
                  // isMe ? icon : SizedBox()
                  // ignore: unnecessary_null_comparison
                ].where((o) => o != null).toList()),
            SizedBox(
              height: 15,
            ),
          ],
        );
}
