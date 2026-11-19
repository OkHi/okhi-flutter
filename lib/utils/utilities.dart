import 'package:flutter/foundation.dart';

void appDebugPrint(String message) {
  if (kDebugMode) {
    // ignore: avoid_print
    print(message);
  }
}
