
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:one_clock/one_clock.dart';

class DigitalClockWidget extends StatefulWidget {
  const DigitalClockWidget({super.key});

  @override
  State<StatefulWidget> createState() => _MyDigitalClockState();
}

class _MyDigitalClockState extends State<DigitalClockWidget> {
  DateTime dateTime = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Align(
        alignment: Alignment.center,
        child: Padding(
          padding: const EdgeInsets.only(top: 100, left: 100, right: 100, bottom: 20),
          child: DigitalClock(
            digitalClockTextColor: const Color.fromARGB(255,252,161,57),
            datetime: dateTime,
            textScaleFactor: 6,
            showSeconds: true,
            isLive: true,
            format: "Hms",
            decoration: BoxDecoration(
                color: const Color.fromARGB(255,16,21,33),
                shape: BoxShape.rectangle,
                border: Border.all(width: 2.0, color: const Color.fromARGB(255,48,48,73)),
                borderRadius: const BorderRadius.all(Radius.circular(60))),
          ),
        )
    );
  }
}