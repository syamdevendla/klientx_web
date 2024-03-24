//*************   © Copyrighted by aagama_it. 

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:aagama_it/Configs/db_keys.dart';
import 'package:aagama_it/Configs/Dbpaths.dart';
import 'package:aagama_it/Configs/optional_constants.dart';
import 'package:aagama_it/Models/ticket_model.dart';
import 'package:aagama_it/Services/Providers/FirebaseDataAPIProvider.dart';
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class FirebaseTicketServices {
  Stream<List<TicketModel>> getTicketsList(String? phone) {
    return FirebaseFirestore.instance
        .collection(DbPaths.collectiontickets)
        // .where(Dbkeys.tktMEMBERSactiveList, arrayContains: phone)
        // .orderBy(Dbkeys.ticketcreatedOn, descending: true)
        .snapshots()
        .map((snapShot) => snapShot.docs
            .map((document) => TicketModel.fromJson(document.data()))
            .toList());
  }
}

//  _________ Ticket Chat Messages ____________
class FirestoreDataProviderMESSAGESforTICKETCHAT extends ChangeNotifier {
  List<DocumentSnapshot> datalistSnapshot = <DocumentSnapshot>[];
  String _errorMessage = '';
  bool _hasNext = true;
  bool _isFetchingData = false;
  String? parentid;
  String get errorMessage => _errorMessage;

  bool get hasNext => _hasNext;

  List get recievedDocs => datalistSnapshot.map((snap) {
        final recievedData = snap.data();

        return recievedData;
      }).toList();

  reset() {
    _hasNext = true;
    datalistSnapshot.clear();
    _isFetchingData = false;
    _errorMessage = '';
    recievedDocs.clear();
    notifyListeners();
  }

  Future fetchNextData(
      String? dataType, Query? refdataa, bool isAfterNewdocCreated) async {
    if (_isFetchingData) return;

    _errorMessage = '';
    _isFetchingData = true;

    try {
      final snap = isAfterNewdocCreated == true
          ? await FirebaseDataApi.getFirestoreCOLLECTIONData(
              maxChatMessageDocsLoadAtOnce,
              // startAfter: null,
              refdata: refdataa)
          : await FirebaseDataApi.getFirestoreCOLLECTIONData(
              maxChatMessageDocsLoadAtOnce,
              startAfter:
                  datalistSnapshot.isNotEmpty ? datalistSnapshot.last : null,
              refdata: refdataa);

      if (isAfterNewdocCreated == true) {
        datalistSnapshot.clear();
        datalistSnapshot.addAll(snap.docs);
      } else {
        datalistSnapshot.addAll(snap.docs);
      }
      // notifyListeners();
      if (snap.docs.length < maxChatMessageDocsLoadAtOnce) {
        _hasNext = false;
      }
      notifyListeners();
    } catch (error) {
      _errorMessage = error.toString();
      notifyListeners();
    }

    _isFetchingData = false;
  }

  addDoc(DocumentSnapshot newDoc) {
    int index = datalistSnapshot.indexWhere(
        (doc) => doc[Dbkeys.tktMssgTIME] == newDoc[Dbkeys.tktMssgTIME]);
    if (index < 0) {
      // List<DocumentSnapshot> list = datalistSnapshot.reversed.toList();
      datalistSnapshot.insert(0, newDoc);
      // datalistSnapshot = list;
      notifyListeners();
    }
  }

  bool checkIfDocAlreadyExits(
      {required DocumentSnapshot newDoc, int? timestamp}) {
    return timestamp != null
        ? datalistSnapshot.indexWhere((doc) =>
                doc[Dbkeys.tktMssgTIME] == newDoc[Dbkeys.tktMssgTIME]) >=
            0
        : datalistSnapshot.contains(newDoc);
  }

  int totalDocsLoadedLength() {
    return datalistSnapshot.length;
  }

  updateparticulardocinProvider({
    required DocumentSnapshot updatedDoc,
  }) async {
    int index = datalistSnapshot.indexWhere(
        (doc) => doc[Dbkeys.tktMssgTIME] == updatedDoc[Dbkeys.tktMssgTIME]);

    datalistSnapshot.removeAt(index);
    datalistSnapshot.insert(index, updatedDoc);
    notifyListeners();
  }

  deleteparticulardocinProvider({required DocumentSnapshot deletedDoc}) async {
    int index = datalistSnapshot.indexWhere(
        (doc) => doc[Dbkeys.tktMssgTIME] == deletedDoc[Dbkeys.tktMssgTIME]);

    if (index >= 0) {
      datalistSnapshot.removeAt(index);
      notifyListeners();
    }
  }
}
