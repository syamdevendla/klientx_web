//*************   © Copyrighted by aagama_it.

import 'package:aagama_it/Configs/my_colors.dart';
import 'package:aagama_it/Localization/language_constants.dart';
import 'package:aagama_it/Models/ticket_message.dart';
import 'package:aagama_it/Utils/formatStatusTime.dart';
import 'package:aagama_it/Services/Providers/user_registry_provider.dart';
import 'package:aagama_it/widgets/OtherCustomWidgets/mycustomtext.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

Widget getTicketReopenedMessage(
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
      ? Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Chip(
                label: MtCustomfontBoldSemi(
                  color: Colors.white,
                  text: mssg.tktMssgSENDBY == customerUID
                      ? " ${getTranslatedForCurrentUser(context, 'xxreopenedxx').replaceAll('(####)', getTranslatedForCurrentUser(context, 'xxsupporttktxx')).replaceAll('(###)', getTranslatedForCurrentUser(context, 'xxyouxx'))} "
                      : " ${getTranslatedForCurrentUser(context, 'xxreopenedxx').replaceAll('(####)', getTranslatedForCurrentUser(context, 'xxsupporttktxx')).replaceAll('(###)', getTranslatedForCurrentUser(context, 'xxagentxx'))} ",
                  fontsize: 13,
                ),
                backgroundColor: Mycolors.cyan,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
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
                ],
              ),
              SizedBox(
                height: 10,
              )
            ],
          ),
        )
      : Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 25,
            ),
            Chip(
              backgroundColor: Mycolors.cyan,
              label: MtCustomfontBoldSemi(
                text: mssg.tktMssgSENDBY == customerUID
                    ? " ${getTranslatedForCurrentUser(context, 'xxreopenedxx').replaceAll('(####)', getTranslatedForCurrentUser(context, 'xxsupporttktxx')).replaceAll('(###)', getTranslatedForCurrentUser(context, 'xxcustomerxx'))} "
                    : " ${getTranslatedForCurrentUser(context, 'xxreopenedxx').replaceAll('(####)', getTranslatedForCurrentUser(context, 'xxsupporttktxx')).replaceAll('(###)', getTranslatedForCurrentUser(context, 'xxagentxx'))} ",
                color: Colors.white,
                fontsize: 13,
              ),
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
            mssg.tktMssgSENDBY == customerUID
                ? SizedBox()
                : SizedBox(
                    height: 30,
                  ),
          ],
        );
}
