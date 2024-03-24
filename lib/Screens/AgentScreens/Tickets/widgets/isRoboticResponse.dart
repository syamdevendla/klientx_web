//*************   © Copyrighted by aagama_it.

import 'package:aagama_it/Configs/enum.dart';

bool isRobotic(int i) {
  return i == MessageType.audio.index ||
          i == MessageType.video.index ||
          i == MessageType.doc.index ||
          i == MessageType.image.index ||
          i == MessageType.location.index ||
          i == MessageType.contact.index ||
          i == MessageType.text.index
      ? false
      : true;
}
