//*************   © Copyrighted by aagama_it. 

import 'package:aagama_it/Configs/optional_constants.dart';
import 'package:flutter/foundation.dart';

class TimerProvider with ChangeNotifier {
  bool wait = false;
  int start = timeOutSeconds;
  bool isActionBarShow = false;
  startTimer() {}

  resetTimer() {
    start = timeOutSeconds;
    isActionBarShow = false;
    notifyListeners();
  }
}
