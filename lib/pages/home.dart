import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:logging/logging.dart';
import 'package:nfc_manager/nfc_manager.dart';
import 'package:nfc_manager/platform_tags.dart';

import '../services/api_service.dart';
import '../utils/application_settings.dart';
import '../utils/digital_clock_widget.dart';
import '../utils/api_availability_widget.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<StatefulWidget> createState() => _HomePage();
}

class _HomePage extends State<HomePage> {
  static final _log = Logger('_HomePage');
  String? _androidId;
  String? _deviceLocation;

  Timer? _nfcWatchdogTimer;
  int _watchdogRetries = 0;
  bool _isProcessingTag = false;
  int _longPressCount = 0;

  void _onLongPress() {
    setState(() {
      _longPressCount++;
      if (_longPressCount == 3) {
        _longPressCount = 0;
        Navigator.pushReplacementNamed(context, '/pin_input_page');
      }
    });

    // Reset the counter after a short delay if the presses are not consecutive
    Future.delayed(const Duration(seconds: 6), () {
      if (mounted) {
        setState(() {
          _longPressCount = 0;
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _startNfc();
    _loadAndroidID();
    _loadDeviceLocation();
    _startNfcWatchdog();
  }

  @override
  void dispose() {
    _nfcWatchdogTimer?.cancel();
    NfcManager.instance.stopSession(errorMessage: null);
    super.dispose();
  }

  void _loadDeviceLocation() async {
    String deviceLocation = await AppSettings.getDeviceLocation();
    setState(() {
      _deviceLocation = deviceLocation;
    });
  }

  void _loadAndroidID() async {
    String serial = await ApiService.androidId;
    setState(() {
      _androidId = serial;
    });
  }

  Future<void> _startNfc() async {
    await NfcManager.instance.startSession(onDiscovered: (NfcTag tag) async {
      if (_isProcessingTag) return; // Avoid double-processing
      if (ApiService.offloadingCachedData) return; // Don't process tag if cache offloading is active
      _isProcessingTag = true;
      try {
        String? hexIdentifier;
        dynamic nfcTag = readTag(tag);
        hexIdentifier = getHexIdentifier(nfcTag);
        if (hexIdentifier == null) return;

        _log.fine('_startNfc: hexIdentifier - $hexIdentifier');
        await NfcManager.instance.stopSession();
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, '/action_page', arguments: {'tagId': hexIdentifier});
      } catch (e, stackTrace) {
        _log.severe('_startNfc: NFC read error.', e, stackTrace);
      } finally {
        _isProcessingTag = false;
      }
    });
  }

  void _startNfcWatchdog() {
    _nfcWatchdogTimer = Timer.periodic(const Duration(seconds: 30), (timer) async {
      if (_isProcessingTag) {
        _log.fine('_startNfcWatchdog: Skipping restart — tag is being processed');
        return;
      }

      bool available = await NfcManager.instance.isAvailable();
      if (!available) {
        _log.warning('_startNfcWatchdog: NFC unavailable — trying to recover...');
      } else {
        _log.fine('_startNfcWatchdog: Restarting NFC session to prevent stale state...');
      }

      try {
        await NfcManager.instance.stopSession().catchError((_) {});
        await Future.delayed(const Duration(milliseconds: 300));
        await _startNfc();
        _watchdogRetries = 0;
      } catch (e) {
        _watchdogRetries++;
        _log.severe('_startNfcWatchdog: Failed to restart session. Retry $_watchdogRetries', e);

        if (_watchdogRetries >= 5 && mounted) {
          _showNfcErrorDialog();
          _nfcWatchdogTimer?.cancel();
          _watchdogRetries = 0;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255,21,27,42),
      appBar: AppBar(
        leadingWidth: 500,
        leading: const ApiAvailabilityWidget(),
        title: GestureDetector(
          onLongPress: _onLongPress,
          child: const Text('ERV', style: TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold)),
      ),
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255,21,27,42),
        elevation: 15,
        automaticallyImplyLeading: false,
    ),
      body: PopScope(
        canPop: false,
        child: Stack(children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Row(children: [SizedBox(height: 100)]),
              const Row(mainAxisAlignment: MainAxisAlignment.center, children: [DigitalClockWidget()]),
              Text(getCurrentDate(), style: const TextStyle(fontSize:24, color: Color.fromARGB(255,252,161,57)),),
              const Row(children: [SizedBox(height: 220)]),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [_deviceLocation == null
                                                                            ? const Text('')
                                                                            : Text('$_deviceLocation', style: const TextStyle(color: Colors.white,fontSize: 30, ),)]),
            ],
          ),
          Align(
              alignment: Alignment.bottomLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 10),
                child: _androidId == null
                    ? const Text('')
                    : Text('$_androidId', style: const TextStyle(fontSize: 15, color: Color.fromARGB(255,48,48,73))),
              )
          ),
          Positioned(
            left: 0,
            top: MediaQuery.of(context).size.height * 0.18,
            child: Container(
              width: 85,
              height: 400,
              decoration: BoxDecoration(
                border: const Border(
                  top: BorderSide(
                    color: Color.fromARGB(255, 252, 161, 57),
                    width: 3,
                  ),
                  right: BorderSide(
                    color: Color.fromARGB(255, 252, 161, 57),
                    width: 3,
                  ),
                  bottom: BorderSide(
                    color: Color.fromARGB(255, 252, 161, 57),
                    width: 3,
                  ),
                  left: BorderSide.none,
                ),
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
              ),
              child: Center(
                child: RotatedBox(
                  quarterTurns: 3, // 270° rotation (vertical text upwards)
                  child: const Text(
                    'PRISLONITE KARTICU',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ]),
      ),
    );
  }

  void _showNfcErrorDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevents closing by tapping outside
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.grey[900],
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Container(
            padding: const EdgeInsets.all(24),
            width: MediaQuery.of(context).size.width * 0.8,
            constraints: const BoxConstraints(minHeight: 250),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Greška',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Čitač kartice je prestao sa radom.\nPritisnite "Pokušaj ponovo" da osvežite uređaj.',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 26,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: const Color.fromARGB(255, 252, 161, 57),
                      foregroundColor: Colors.black,
                      textStyle: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop(); // Close dialog
                      Navigator.pushReplacementNamed(context, '/home_page'); // Restart page
                    },
                    child: const Text('Pokušaj ponovo'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }


  dynamic readTag(NfcTag tag) {
    dynamic nfcTag = NfcA.from(tag);
    nfcTag ??= Ndef.from(tag);
    nfcTag ??= NfcB.from(tag);
    nfcTag ??= NfcF.from(tag);
    nfcTag ??= MifareClassic.from(tag);
    nfcTag ??= MifareUltralight.from(tag);
    return nfcTag;
  }

  String? getHexIdentifier(dynamic nfcTag) {
    try {
      if (nfcTag is NfcA) {
        return (nfcTag.identifier as List<int>).map((byte) => byte.toRadixString(16).padLeft(2, '0')).join(':');
      } else if (nfcTag is Ndef) {
        if (nfcTag.additionalData.containsKey('identifier')) {
          return (nfcTag.additionalData['identifier'] as List<int>).map((byte) => byte.toRadixString(16).padLeft(2, '0')).join(':');
        }
      } else if (nfcTag is NfcB) {
        return (nfcTag.identifier as List<int>).map((byte) => byte.toRadixString(16).padLeft(2, '0')).join(':');
      } else if (nfcTag is NfcF) {
        return (nfcTag.identifier as List<int>).map((byte) => byte.toRadixString(16).padLeft(2, '0')).join(':');
      } else if (nfcTag is MifareClassic) {
        return (nfcTag.identifier as List<int>).map((byte) => byte.toRadixString(16).padLeft(2, '0')).join(':');
      } else if (nfcTag is MifareUltralight) {
        return (nfcTag.identifier as List<int>).map((byte) => byte.toRadixString(16).padLeft(2, '0')).join(':');
      }
    } catch (e) {
      return null;
    }
    return null;
  }

  String getCurrentDate() {
    const locale = Locale('sr_Latn');
    Intl.defaultLocale = locale.toString();

    final now = DateTime.now();
    final dateFormat = DateFormat('EEE d. MMMM', locale.toString());
    return dateFormat.format(now);
  }
}
