//*************   © Copyrighted by aagama_it. 

import 'package:aagama_it/Configs/db_keys.dart';
import 'package:aagama_it/Localization/language_constants.dart';
import 'package:flutter/material.dart';

String underconstructionmessage =
    'App under maintainance & will be right back.';

Map getTranslateNotificationStringsMap(BuildContext context) {
  Map map = {
    Dbkeys.notificationStringNewTextMessage:
        getTranslatedForCurrentUser(context, 'xxntmxx'),
    Dbkeys.notificationStringNewImageMessage:
        getTranslatedForCurrentUser(context, 'xxnimxx'),
    Dbkeys.notificationStringNewVideoMessage:
        getTranslatedForCurrentUser(context, 'xxnvmxx'),
    Dbkeys.notificationStringNewAudioMessage:
        getTranslatedForCurrentUser(context, 'xxnamxx'),
    Dbkeys.notificationStringNewContactMessage:
        getTranslatedForCurrentUser(context, 'xxncmxx'),
    Dbkeys.notificationStringNewDocumentMessage:
        getTranslatedForCurrentUser(context, 'xxndmxx'),
    Dbkeys.notificationStringNewLocationMessage:
        getTranslatedForCurrentUser(context, 'xxnlmxx'),
    Dbkeys.notificationStringNewIncomingAudioCall:
        getTranslatedForCurrentUser(context, 'xxniacxx'),
    Dbkeys.notificationStringNewIncomingVideoCall:
        getTranslatedForCurrentUser(context, 'xxnivcxx'),
    Dbkeys.notificationStringCallEnded:
        getTranslatedForCurrentUser(context, 'xxcexx'),
    Dbkeys.notificationStringMissedCall:
        getTranslatedForCurrentUser(context, 'xxmcxx'),
    Dbkeys.notificationStringAcceptOrRejectCall:
        getTranslatedForCurrentUser(context, 'xxaorcxx'),
    Dbkeys.notificationStringCallRejected:
        getTranslatedForCurrentUser(context, 'xxcrxx'),
  };
  return map;
}
