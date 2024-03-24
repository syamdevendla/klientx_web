//*************   © Copyrighted by aagama_it.

import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseDataApi {
  static Future<QuerySnapshot> getFirestoreCOLLECTIONData(int limit,
      {DocumentSnapshot? startAfter, String? dataType, Query? refdata}) async {
    if (startAfter == null) {
      return refdata!.get();
    } else {
      return refdata!.startAfterDocument(startAfter).get();
    }
  }
}
