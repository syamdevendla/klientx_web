//*************   © Copyrighted by aagama_it. 

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class CurrentChatPeer with ChangeNotifier {
  String? currentPageID = '';
  // String? groupChatId = '';
  // String? ticketChatId = '';

  setpeer(
    newpeerid,
    // String? newgroupChatId,
    // String? newticketChatId,
  ) {
    currentPageID = newpeerid ?? currentPageID;
    // groupChatId = newgroupChatId ?? groupChatId;
    // ticketChatId = newticketChatId ?? ticketChatId;
    notifyListeners();
  }
}
