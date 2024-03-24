//*************   © Copyrighted by aagama_it. 

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:aagama_it/Configs/Dbpaths.dart';
import 'package:aagama_it/Models/call.dart';

class CallMethods {
  Stream<DocumentSnapshot> callStream({String? uid}) =>
      FirebaseFirestore.instance
          .collection(DbPaths.collectioncall)
          .doc(uid)
          .snapshots();

  Future<bool> makeCall(
      {required Call call,
      required bool? isvideocall,
      required int timeepoch}) async {
    try {
      call.hasDialled = true;
      Map<String, dynamic> hasDialledMap = call.toMap(call);

      call.hasDialled = false;
      Map<String, dynamic> hasNotDialledMap = call.toMap(call);

      await FirebaseFirestore.instance
          .collection(DbPaths.collectioncall)
          .doc(call.callerId)
          .set(hasDialledMap, SetOptions(merge: true));

      await FirebaseFirestore.instance
          .collection(DbPaths.collectioncall)
          .doc(call.receiverId)
          .set(hasNotDialledMap, SetOptions(merge: true));
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future<bool> endCall({required Call call}) async {
    try {
      await FirebaseFirestore.instance
          .collection(DbPaths.collectioncall)
          .doc(call.callerId)
          .delete();
      await FirebaseFirestore.instance
          .collection(DbPaths.collectioncall)
          .doc(call.receiverId)
          .delete();
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }
}
