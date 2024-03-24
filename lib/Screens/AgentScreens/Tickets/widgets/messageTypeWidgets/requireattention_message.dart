//*************   © Copyrighted by aagama_it.

import 'package:aagama_it/Configs/my_colors.dart';
import 'package:aagama_it/Localization/language_constants.dart';
import 'package:aagama_it/Models/ticket_message.dart';
import 'package:aagama_it/Screens/AgentScreens/Tickets/widgets/ticketWidget.dart';
import 'package:aagama_it/Utils/formatStatusTime.dart';
import 'package:aagama_it/Services/Providers/user_registry_provider.dart';
import 'package:aagama_it/Utils/color_light_dark.dart';
import 'package:aagama_it/Utils/utils.dart';
import 'package:aagama_it/widgets/OtherCustomWidgets/mycustomtext.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

Widget getTicketRequireAttentionMessage(
    {required BuildContext context,
    required TicketMessage mssg,
    required String currentUserID,
    required String customerUID,
    required bool cuurentUserCanSeeAgentNamePhoto}) {
  bool is24hrsFormat = true;
  humanReadableTime() => DateFormat(is24hrsFormat == true ? 'HH:mm' : 'h:mm a')
      .format(DateTime.fromMillisecondsSinceEpoch(mssg.tktMssgTIME));
  final registry = Provider.of<UserRegistry>(context, listen: false);
  return customerUID == currentUserID
      ? SizedBox()
      : Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 25,
            ),
            Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                      padding: EdgeInsets.all(0),
                      onPressed: () {
                        Utils.toast(getTranslatedForCurrentUser(
                                context, 'xxonlyvisblexx')
                            .replaceAll(
                                '(####)',
                                getTranslatedForCurrentUser(
                                    context, 'xxcustomerxx'))
                            .replaceAll(
                                '(###)',
                                getTranslatedForCurrentUser(
                                    context, 'xxagentsxx')));
                      },
                      icon: Icon(
                        Icons.visibility_off_rounded,
                        size: 13,
                        color: Mycolors.greytext,
                      )),
                  Chip(
                    backgroundColor: Mycolors.yellow,
                    label: MtCustomfontBoldSemi(
                      text:
                          " ${getTranslatedForCurrentUser(context, 'xxrequireattentionfromxx').replaceAll('(####)', getTranslatedForCurrentUser(context, 'xxagentsxx'))} ",
                      color: Colors.black87,
                      fontsize: 13,
                    ),
                  ),
                  SizedBox(
                    width: 35,
                  ),
                ]),
            mssg.tktMssgCONTENT == ""
                ? SizedBox()
                : Container(
                    width: MediaQuery.of(context).size.width >
                            MediaQuery.of(context).size.height
                        ? MediaQuery.of(context).size.width / 1.7
                        : MediaQuery.of(context).size.width / 1.2,
                    decoration: boxDecoration(
                      bgColor: lighten(Colors.orange, 0.29),
                      showShadow: false,
                      radius: 10,
                    ),
                    margin: EdgeInsets.fromLTRB(15, 0, 15, 7),
                    padding: EdgeInsets.all(15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        MtCustomfontRegular(
                          text: mssg.tktMssgCONTENT,
                          fontsize: 14,
                          textalign: TextAlign.center,
                          color: Mycolors.black,
                        ),
                      ],
                    )),
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
              height: 30,
            ),
          ],
        );
}
