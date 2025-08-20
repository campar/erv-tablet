import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:logging/logging.dart';
import 'package:erv/services/user_action_service.dart';

import '../model/action_type.dart';
import '../model/exceptions.dart';

class ActionPage extends StatefulWidget {
  const ActionPage({super.key});

  @override
  State<StatefulWidget> createState() => _MyActionPageState();
}

class _MyActionPageState extends State<ActionPage> {
  static final _log = Logger('_MyActionPageState');

  Timer? _timer;
  final int _timeLimit = 5;
  bool _isLoading = false;

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
      Navigator.pushReplacementNamed(context, '/home_page');
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _onButtonPressed(String tagId, ActionType actionType) async {
    _timer?.cancel();
    setState(() {
      _isLoading = true;
    });
    await processUserInput(tagId, actionType);
    await Future.delayed(Duration(milliseconds: 500));
    setState(() {
      _isLoading = false;
    });
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/home_page');
    }
  }

  @override
  Widget build(BuildContext context) {
    final arguments = (ModalRoute.of(context)?.settings.arguments ?? <String, dynamic>{}) as Map;
    final String tagId = arguments.containsKey('tagId') ? arguments['tagId'] : throw Exception();
    return Scaffold(
        backgroundColor: const Color.fromARGB(255,21,27,42),
        appBar: AppBar(
          title: const Text('ERV', style: TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold)),
          centerTitle: true,
          backgroundColor: const Color.fromARGB(255,21,27,42),
          elevation: 15,
          automaticallyImplyLeading: false,
        ),
        body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Stack(children: [
              PopScope(
                canPop: false,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          buildButton(tagId, ActionType.checkIn, const Color.fromARGB(255,147,220,50),
                              Colors.white, const Color.fromARGB(255,48,48,73), 550, 130, 35),
                          buildButton(tagId, ActionType.checkOut, const Color.fromARGB(255, 255, 0, 0),
                              Colors.white, const Color.fromARGB(255,48,48,73), 550, 130, 35),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          buildButton(tagId, ActionType.pauseStart, const Color.fromARGB(255,16,21,33),
                              const Color.fromARGB(255, 255, 189, 0), const Color.fromARGB(255,48,48,73), 400, 100, 24),
                          buildButton(tagId, ActionType.pauseEnd, const Color.fromARGB(255,16,21,33),
                              const Color.fromARGB(255, 255, 93, 0), const Color.fromARGB(255,48,48,73), 400, 100, 24),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          buildButton(tagId, ActionType.businessOut, const Color.fromARGB(255,16,21,33),
                              const Color.fromARGB(255, 0, 83, 207), const Color.fromARGB(255,48,48,73), 400, 100, 24),
                          buildButton(tagId, ActionType.businessOutEnd, const Color.fromARGB(255,16,21,33),
                              const Color.fromARGB(255, 10, 13, 211), const Color.fromARGB(255,48,48,73), 400, 100, 24),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (_isLoading) // Only show the loading overlay when needed
                Positioned.fill(
                  child: Container(
                    color: Colors.black.withValues(alpha: 0.1), // Semi-transparent overlay
                    child: const Center(
                      child: CircularProgressIndicator(), // Loading indicator in the center
                    ),
                  ),
                ),
            ])
        )
    );
  }

  Widget buildButton(String tagId, ActionType actionType, Color backgroundColor, Color textColor, Color borderColor,
      double width, double height, double fontSize) {
    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton(
        onPressed: () => {_isLoading ? null : _onButtonPressed(tagId, actionType)},
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor, //Color.fromARGB(255,16,21,33),
          textStyle: TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold),
          side: BorderSide(color: borderColor, width: 2),
        ),
        child: Text(actionType.label, style: TextStyle(color: textColor)),
      ),
    );
  }

  static void showSuccessMessage(String msg) {
    Fluttertoast.showToast(
      msg: msg,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.green,
      textColor: Colors.white,
      fontSize: 30.0,
    );
  }

  static void showErrorMessage(String msg) {
    Fluttertoast.showToast(
      msg: msg,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.red,
      textColor: Colors.white,
      fontSize: 30.0,
    );
  }

  Future<void> processUserInput(String tagId, ActionType actionType) async {
    try {
      await UserActionService.processAction(tagId, actionType);
      showSuccessMessage('Uspešno');
    } on ServiceUserError catch (e, stackTrace) {
      _log.severe('ProcessUserInput: ServiceUserError: ', e, stackTrace);
      showErrorMessage(e.message);
    } on Exception catch (e, stackTrace) {
      _log.severe('ProcessUserInput: Exception: ', e, stackTrace);
      showErrorMessage('Greška');
    }
  }
}