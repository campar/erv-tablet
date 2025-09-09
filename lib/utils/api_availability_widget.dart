import 'dart:async';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:erv/services/api_service.dart';

class ApiAvailabilityWidget extends StatefulWidget {
  const ApiAvailabilityWidget({super.key});

  @override
  State<ApiAvailabilityWidget> createState() => _ApiAvailabilityWidgetState();
}

class _ApiAvailabilityWidgetState extends State<ApiAvailabilityWidget> {
  static final _log = Logger('ApiAvailabilityWidget');
  late Timer _timer;
  bool _isVisible = false;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _refreshData();
    _log.fine('InitState: Initializing timer.');
    _timer = Timer.periodic(const Duration(seconds: 10), (timer) {
      if (!_isRefreshing) {
        _refreshData();
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _refreshData() async {
    _isRefreshing = true;
    bool backendAvailable = await ApiService.isBackendAvailable();
    setState(() {
      _isVisible = !backendAvailable;
    });
    _isRefreshing = false;
  }

  @override
  Widget build(BuildContext context) {
    return _isVisible ? const Text('  Nije uspostavljena veza sa serverom!',
        style: TextStyle(color: Color.fromRGBO(255, 112, 63, 1),
            fontSize: 22,
            fontWeight: FontWeight.bold
        ))
            : const Text('');
  }
}
