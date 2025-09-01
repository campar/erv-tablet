import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pinput/pinput.dart';

class PinInputWidget extends StatefulWidget {
  const PinInputWidget({super.key});

  @override
  State<StatefulWidget> createState() => _PinInputWidgetState();
}

class _PinInputWidgetState extends State<PinInputWidget> {
  Timer? _timer;
  final int _timeLimit = 30;

  final pinController = TextEditingController();
  final focusNode = FocusNode();
  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer(Duration(seconds: _timeLimit), _navigateToHomePage);
  }

  void _navigateToHomePage() {
    if (mounted) {
      FocusScope.of(context).unfocus();
      Navigator.pushReplacementNamed(context, '/home_page');
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    pinController.dispose();
    focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const focusedBorderColor = Color.fromRGBO(23, 171, 144, 1);
    const fillColor = Color.fromRGBO(243, 246, 249, 0);
    const borderColor = Color.fromRGBO(23, 171, 144, 0.4);

    final defaultPinTheme = PinTheme(
      width: 72,
      height: 72,
      textStyle: GoogleFonts.poppins(
        fontSize: 26,
        color: const Color.fromRGBO(30, 60, 87, 1),
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(19),
        border: Border.all(color: borderColor),
      ),
    );

    return PopScope(
      canPop: false,
      child: Form(
        key: formKey,
        child: Column(
          children: [
            const Text('Unesite PIN kod'),
            const SizedBox(height: 20),
            Directionality(
              textDirection: TextDirection.ltr,
              child: Pinput(
                length: 6,
                controller: pinController,
                focusNode: focusNode,
                defaultPinTheme: defaultPinTheme,
                validator: (value) {
                  return value == dotenv.env['SECURITY_PIN_CODE'] ? null : 'Netačan pin';
                },
                onCompleted: (pin) {
                  debugPrint('onCompleted: $pin');
                  if (formKey.currentState!.validate()) {
                    Navigator.pushReplacementNamed(context, '/settings_page');
                  }
                },
                onChanged: (value) {
                  debugPrint('onChanged: $value');
                },
                closeKeyboardWhenCompleted: true,
                pinputAutovalidateMode: PinputAutovalidateMode.disabled,
                cursor: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(bottom: 9),
                      width: 22,
                      height: 1,
                      color: focusedBorderColor,
                    ),
                  ],
                ),
                focusedPinTheme: defaultPinTheme.copyWith(
                  decoration: defaultPinTheme.decoration!.copyWith(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: focusedBorderColor),
                  ),
                ),
                submittedPinTheme: defaultPinTheme.copyWith(
                  decoration: defaultPinTheme.decoration!.copyWith(
                    color: fillColor,
                    borderRadius: BorderRadius.circular(19),
                    border: Border.all(color: focusedBorderColor),
                  ),
                ),
                errorPinTheme: defaultPinTheme.copyBorderWith(
                  border: Border.all(color: Colors.redAccent),
                ),
              ),
            ),
            const SizedBox(height: 30),
            TextButton(
              onPressed: () => {
                if (formKey.currentState!.validate()) {
                  Navigator.pushReplacementNamed(context, '/settings_page')
                }
              },
              style: TextButton.styleFrom(
                backgroundColor: Colors.green, // Background color
                side: const BorderSide(color: Colors.green, width: 2), // Border color and width
                padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 20.0), // Padding
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8), // Rounded corners
                ),
              ),
              child: const Text('Potvrdi', style: TextStyle(color: Colors.white, fontSize: 22)),
            ),
          ],
        ),
      ),
    );
  }
}