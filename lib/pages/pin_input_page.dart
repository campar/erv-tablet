import 'package:flutter/material.dart';

import '../utils/pin_input_widget.dart';

class PinInputPage extends StatefulWidget {
  const PinInputPage({super.key});

  @override
  State<StatefulWidget> createState() => _PinInputPage();
}

class _PinInputPage extends State<PinInputPage> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [PinInputWidget()],
      )
    );
  }
}