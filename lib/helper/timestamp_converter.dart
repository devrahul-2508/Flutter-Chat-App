import 'dart:async';

import 'package:intl/intl.dart';

class DateTimeConverter {
  static convertTimeStamp(int millis) {
    var dt = DateTime.fromMicrosecondsSinceEpoch(millis);

// 12 Hour format:
    var d12 = DateFormat('hh:mm a').format(dt);

    return d12;
  }
}
