import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:erv/utils/application_settings.dart';
import 'package:pinput/pinput.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<StatefulWidget> createState() => _SettingsPage();
}

class _SettingsPage extends State<SettingsPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _backendApiAddress;
  late TextEditingController _deviceId;
  late TextEditingController _deviceLocation;

  Timer? _timer;
  final int _timeLimit = 300;

  bool _isCertificateCheckActive = false;

  @override
  void initState() {
    super.initState();
    _backendApiAddress = TextEditingController();
    _deviceId = TextEditingController();
    _deviceLocation = TextEditingController();
    _startTimer();
    _loadPageData();
  }

  void _startTimer() {
    _timer = Timer(Duration(seconds: _timeLimit), _navigateToHomePage);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _backendApiAddress.dispose();
    _deviceId.dispose();
    _deviceLocation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Podešavanja', style: TextStyle(fontWeight: FontWeight.bold)),
        automaticallyImplyLeading: false,
        toolbarHeight: 20.0,
        centerTitle: true,
      ),
      body: PopScope(
        canPop: false,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          TextFormField(
                            decoration: const InputDecoration(labelText: 'Adresa servera', hintText: '(npr. 192.168.1.1:8080)'),
                            controller: _backendApiAddress,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Unesite adresu servera';
                              }
                              return null;
                            },
                          ),
                          TextFormField(
                            decoration: const InputDecoration(labelText: 'Lokacija uređaja', hintText: 'npr. Direkcija - Industrijska 1'),
                            controller: _deviceLocation,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 50.0),
                    Expanded(
                      child: Column(
                        children: [
                          TextFormField(
                            decoration: const InputDecoration(labelText: 'Identifikator uređaja'),
                            controller: _deviceId,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Unesite identifikator uređaja';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 15.0),
                          SwitchListTile(
                            title: const Text('Provera sertifikata'),
                            value: _isCertificateCheckActive,
                            onChanged: (value) async {
                              setState(() {
                                _isCertificateCheckActive = value;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton(
                      onPressed: () => {
                        FocusScope.of(context).unfocus(),
                        Navigator.pushReplacementNamed(context, '/home_page')
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.grey.shade300, // Background color
                        side: const BorderSide(color: Colors.grey, width: 2), // Border color and width
                        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 20.0), // Padding
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8), // Rounded corners
                        ),
                      ),
                      child: const Text('Nazad', style: TextStyle(color: Colors.white, fontSize: 22)),
                    ),
                    ElevatedButton(
                      onPressed: _saveForm,
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.green,
                        side: const BorderSide(color: Colors.lightGreen, width: 2),
                        padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 20.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Sačuvaj', style: TextStyle(color: Colors.white, fontSize: 22)),
                    ),
                  ],
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: () { _onResetButton(); },
                  child: const Text('Resetuj podešavanja'),
                ),
              ],
            ),
          ),
        )
      ),
    );
  }

  void _navigateToHomePage() {
    if (mounted) {
      FocusScope.of(context).unfocus();
      Navigator.pushReplacementNamed(context, '/home_page');
    }
  }

  Future<void> _loadPageData() async {
    String backendIpAddress = await AppSettings.getBackendApiAddress();
    String deviceId = await AppSettings.getDeviceId();
    String deviceLocation = await AppSettings.getDeviceLocation();
    bool isCertificateCheckActive = await AppSettings.isCertificateCheckActive();
    setState(() {
      _backendApiAddress.setText(backendIpAddress);
      _deviceId.setText(deviceId);
      _deviceLocation.setText(deviceLocation);
      _isCertificateCheckActive = isCertificateCheckActive;
    });
  }

  Future<void> _saveForm() async {
    if (_formKey.currentState!.validate()) {
      await AppSettings.saveNewBackendApiAddress(_backendApiAddress.text);
      await AppSettings.saveNewDeviceId(_deviceId.text);
      await AppSettings.saveNewDeviceLocation(_deviceLocation.text);
      await AppSettings.saveCertificateCheckActive(_isCertificateCheckActive);
      await _loadPageData();
      showSuccessMessage('Sačuvano');
    }
  }

  void _onResetButton() async {
    await AppSettings.resetToDefaultValues();
    await _loadPageData();
    showSuccessMessage('Uspešno');
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
}
