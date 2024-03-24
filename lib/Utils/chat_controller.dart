//*************   © Copyrighted by aagama_it. 

import 'dart:core';
import 'package:aagama_it/Configs/db_keys.dart';
import 'package:aagama_it/Configs/Dbpaths.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:aagama_it/Utils/utils.dart';
import 'package:aagama_it/Configs/enum.dart';

class ChatController {
  static request(currentUserNo, peerNo, chatid) async {
    FirebaseFirestore.instance
        .collection(DbPaths.collectionagents)
        .doc(currentUserNo)
        .collection(Dbkeys.chatsWith)
        .doc(Dbkeys.chatsWith)
        .set({'$peerNo': ChatStatus.accepted.index}, SetOptions(merge: true));
    FirebaseFirestore.instance
        .collection(DbPaths.collectionagents)
        .doc(peerNo)
        .collection(Dbkeys.chatsWith)
        .doc(Dbkeys.chatsWith)
        .set({'$currentUserNo': ChatStatus.accepted.index},
            SetOptions(merge: true));
    var doc = await FirebaseFirestore.instance
        .collection(DbPaths.collectionagents)
        .doc('$peerNo')
        .get();
    FirebaseFirestore.instance
        .collection(DbPaths.collectionAgentIndividiualmessages)
        .doc(chatid)
        .update(
      {'$peerNo': doc[Dbkeys.lastSeen]},
    );
  }

  static accept(currentUserNo, peerNo) {
    FirebaseFirestore.instance
        .collection(DbPaths.collectionagents)
        .doc(currentUserNo)
        .collection(Dbkeys.chatsWith)
        .doc(Dbkeys.chatsWith)
        .update(
      {'$peerNo': ChatStatus.accepted.index},
    );

    //   FirebaseFirestore.instance
    //       .collection(DbPaths.collectionusers)
    //       .doc(peerNo)
    //       .collection(Dbkeys.chatsWith)
    //       .doc(Dbkeys.chatsWith)
    //       .update(
    //     {'$currentUserNo': ChatStatus.accepted.index},
    //   );
  }

  static block(currentUserNo, peerNo) {
    FirebaseFirestore.instance
        .collection(DbPaths.collectionagents)
        .doc(currentUserNo)
        .collection(Dbkeys.chatsWith)
        .doc(Dbkeys.chatsWith)
        .set({'$peerNo': ChatStatus.blocked.index}, SetOptions(merge: true));
    FirebaseFirestore.instance
        .collection(DbPaths.collectionAgentIndividiualmessages)
        .doc(Utils.getChatId(currentUserNo, peerNo))
        .set({'$currentUserNo': DateTime.now().millisecondsSinceEpoch},
            SetOptions(merge: true));
    // Utils.toast('Blocked.');
  }

  static Future<ChatStatus> getStatus(currentUserNo, peerNo) async {
    var doc = await FirebaseFirestore.instance
        .collection(DbPaths.collectionagents)
        .doc(currentUserNo)
        .collection(Dbkeys.chatsWith)
        .doc(Dbkeys.chatsWith)
        .get();
    return ChatStatus.values[doc[peerNo]];
  }

  static hideChat(currentUserNo, peerNo) {
    FirebaseFirestore.instance
        .collection(DbPaths.collectionagents)
        .doc(currentUserNo)
        .set({
      Dbkeys.hidden: FieldValue.arrayUnion([peerNo])
    }, SetOptions(merge: true));
    // Utils.toast(  'Chat hidden.');
  }

  static unhideChat(currentUserNo, peerNo) {
    FirebaseFirestore.instance
        .collection(DbPaths.collectionagents)
        .doc(currentUserNo)
        .set({
      Dbkeys.hidden: FieldValue.arrayRemove([peerNo])
    }, SetOptions(merge: true));
    // Utils.toast('Chat is visible.');
  }

  static lockChat(currentUserNo, peerNo) {
    FirebaseFirestore.instance
        .collection(DbPaths.collectionagents)
        .doc(currentUserNo)
        .set({
      Dbkeys.locked: FieldValue.arrayUnion([peerNo])
    }, SetOptions(merge: true));
    // Utils.toast('Chat locked.');
  }

  static unlockChat(currentUserNo, peerNo) {
    FirebaseFirestore.instance
        .collection(DbPaths.collectionagents)
        .doc(currentUserNo)
        .set({
      Dbkeys.locked: FieldValue.arrayRemove([peerNo])
    }, SetOptions(merge: true));
    // Utils.toast('Chat unlocked.');
  }
}
