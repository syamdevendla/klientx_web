//*************   © Copyrighted by aagama_it.

import 'dart:math';
import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:aagama_it/Configs/db_keys.dart';
import 'package:aagama_it/Configs/enum.dart';
import 'package:aagama_it/Screens/AgentScreens/calls/audio_call.dart';
import 'package:aagama_it/Screens/AgentScreens/calls/video_call.dart';
import 'package:flutter/material.dart';
import 'package:aagama_it/Models/call.dart';
import 'package:aagama_it/Models/call_methods.dart';
import 'package:aagama_it/Configs/app_constants.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:cloud_functions/cloud_functions.dart';
import 'package:aagama_it/Utils/utils.dart';

class CallUtils {
  static final CallMethods callMethods = CallMethods();

  static dial(
      {String? fromUID,
      String? fromFullname,
      String? fromDp,
      required SharedPreferences prefs,
      required int callTypeindex,
      required bool isShowCallernameAndPhotoToDialler,
      required bool isShowCallernameAndPhotoToReciever,
      required String callSessionID,
      required String callSessionInitatedBy,
      String? ticketCustomerID,
      String? toFullname,
      String? toDp,
      String? toUID,
      bool? isvideocall,
      String? ticketID,
      String? tickettitle,
      String? ticketidfiltered,
      required String? currentUserID,
      context}) async {
    int timeepoch = DateTime.now().millisecondsSinceEpoch;

    Call call = new Call();

    if (kIsWeb) {
      Map<String, dynamic>? res = await FunctionCall().makeCloudCall();
      if (res == null) {
        Utils.toast("Failed to Dial Call. res == null Please try again !");
      } else {
        call = Call(
            ticketCustomerID: ticketCustomerID,
            ticketIDfiltered: ticketidfiltered,
            ticketTitle: tickettitle,
            callSessionID: callSessionID,
            callSessionInitiatedBy: callSessionInitatedBy,
            callTypeIndex: callTypeindex,
            isShowNameAndPhotoToDialer: isShowCallernameAndPhotoToDialler,
            isShowCallernameAndPhotoToReciever:
                isShowCallernameAndPhotoToReciever,
            timeepoch: timeepoch,
            callerId: fromUID,
            callerName: fromFullname,
            callerPic: fromDp,
            receiverId: toUID,
            receiverName: toFullname,
            receiverPic: toDp,
            channelId: res['channelId'],
            isvideocall: isvideocall,
            ticketID: ticketID);
      }
    } else {
      call = Call(
          ticketCustomerID: ticketCustomerID,
          ticketIDfiltered: ticketidfiltered,
          ticketTitle: tickettitle,
          callSessionID: callSessionID,
          callSessionInitiatedBy: callSessionInitatedBy,
          callTypeIndex: callTypeindex,
          isShowNameAndPhotoToDialer: isShowCallernameAndPhotoToDialler,
          isShowCallernameAndPhotoToReciever:
              isShowCallernameAndPhotoToReciever,
          timeepoch: timeepoch,
          callerId: fromUID,
          callerName: fromFullname,
          callerPic: fromDp,
          receiverId: toUID,
          receiverName: toFullname,
          receiverPic: toDp,
          channelId: Random().nextInt(1000).toString(),
          isvideocall: isvideocall,
          ticketID: ticketID);
    }

    print("syam prints: callMethods.makeCall() - before");
    ClientRole _role = ClientRole.Broadcaster;
    bool callMade = await callMethods.makeCall(
        call: call, isvideocall: isvideocall, timeepoch: timeepoch);
    print("syam prints: callMethods.makeCall() - after callMade: $callMade");
    call.hasDialled = true;
    if (isvideocall == false) {
      print("syam prints: isvideocall == false");
      if (callMade) {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AudioCall(
              currentUserisAgent: prefs.getInt(Dbkeys.userLoginType) ==
                          Usertype.customer.index ||
                      prefs.getInt(Dbkeys.userLoginType) == null
                  ? false
                  : true,
              callTypeindex: callTypeindex,
              isShownamePhotoToCaller: call.isShowNameAndPhotoToDialer!,
              currentUserID: currentUserID,
              call: call,
              channelName: call.channelId,
              role: _role,
            ),
          ),
        );
      }
    } else {
      print("syam prints: isvideocall == true");
      if (callMade) {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VideoCall(
              currentUserisAgent: prefs.getInt(Dbkeys.userLoginType) ==
                          Usertype.customer.index ||
                      prefs.getInt(Dbkeys.userLoginType) == null
                  ? false
                  : true,
              callTypeindex: callTypeindex,
              isShownamePhotoToCaller: call.isShowNameAndPhotoToDialer!,
              currentUserID: currentUserID,
              call: call,
              channelName: call.channelId!,
              role: _role,
            ),
          ),
        );
      }
    }
  }
}

class FunctionCall {
  Future<Map<String, dynamic>?> makeCloudCall() async {
    try {
      print("---syam prints----- makeCloudCall 00");
      HttpsCallable callable =
          FirebaseFunctions.instance.httpsCallable('createCallsWithTokens');
      dynamic resp = await callable.call(
        {
          "appId": Agora_APP_IDD,
          "appCertificate": Agora_Primary_Certificate,
        },
      );

      print("---syam prints----- makeCloudCall 01");
      if (resp.data != null) {
        Map<String, dynamic> res = {
          'token': resp.data['data']['token'],
          'channelId': resp.data['data']['channelId'],
        };
        print(
            "---syam prints----- makeCloudCall  channelId: $res['channelId']");
        print("---syam prints----- makeCloudCall  token: $res['token']");
        return res;
      } else {
        print("---syam prints----- makeCloudCall 03");
        return null;
      }
    } catch (e) {
      print("Failed to makeCloudCall -- $e");
      return null;
    }
  }
}
