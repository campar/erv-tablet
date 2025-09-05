import 'package:flutter/material.dart';
import '../main.dart';

Future<T?> showBlockingDialog<T>(Widget dialog) {
  return showDialog<T>(
    context: navigatorKey.currentContext!,
    barrierDismissible: false, // freeze input
    builder: (_) => dialog,
  );
}

void closeBlockingDialog() {
  if (navigatorKey.currentState?.canPop() ?? false) {
    navigatorKey.currentState?.pop();
  }
}