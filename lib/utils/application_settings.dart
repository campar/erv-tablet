import 'dart:io';

import 'package:android_id/android_id.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:logging/logging.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'http_overrides.dart';

class AppSettings {
  static final _log = Logger('AppSettings');
  static String? _deviceId;
  static String? _backendApiAddress;
  static String? _deviceLocation;
  static final SharedPreferencesAsync _asyncPrefs = SharedPreferencesAsync();
  static bool? _certificateCheckActive;

  static Future<bool> isCertificateCheckActive() async {
    if (_certificateCheckActive == null ) await _loadCertificateCheckActive();
    return _certificateCheckActive!;
  }

  static Future<String> getBackendApiAddress() async {
    if (_backendApiAddress == null ) await _loadBackendApiAddress();
    return _backendApiAddress!;
  }

  static Future<String> getDeviceId() async {
    if (_deviceId == null) await _loadDeviceId();
    return _deviceId!;
  }

  static Future<String> getDeviceLocation() async {
    if (_deviceLocation == null) await _loadDeviceLocation();
    return _deviceLocation!;
  }

  static Future<void> saveCertificateCheckActive(bool value) async {
    _log.fine('SaveCertificateCheckActive: value - $value');
    await _asyncPrefs.setBool('certificate_check_active', value);
    await _loadCertificateCheckActive();
  }

  static Future<void> saveNewBackendApiAddress(String value) async {
    await _asyncPrefs.setString('backend_api_address', value);
    await _loadBackendApiAddress();
  }

  static Future<void> saveNewDeviceId(String value) async {
    await _asyncPrefs.setString('device_id', value);
    await _loadDeviceId();
  }

  static Future<void> saveNewDeviceLocation(String value) async {
    _log.fine('SaveNewDeviceLocation: value - $value');
    await _asyncPrefs.setString('device_location', value);
    await _loadDeviceLocation();
  }

  static Future<void> _loadBackendApiAddress() async {
    // these are app default values
    _backendApiAddress = dotenv.env['BACKEND_API_ADDRESS']!;

    // if value is present in shared preferences use that instead of default
    if (await _asyncPrefs.containsKey('backend_api_address')) {
      String? spAddressValue = await _asyncPrefs.getString('backend_api_address');
      if (spAddressValue != null && spAddressValue != '') {
        _backendApiAddress = spAddressValue;
      }
    }
  }

  static Future<void> _loadDeviceId() async {
    // default device id is Android Id
    _deviceId = await const AndroidId().getId();

    // if value is present in shared preferences use that instead of default
    if (await _asyncPrefs.containsKey('device_id')) {
      String? spDeviceId = await _asyncPrefs.getString('device_id');
      if (spDeviceId != null && spDeviceId != '') {
        _deviceId = spDeviceId;
      }
    }
  }

  static Future<void> _loadDeviceLocation() async {
    // default value is empty string
    _deviceLocation = '';

    if (await _asyncPrefs.containsKey('device_location')) {
      String? spDeviceLocation = await _asyncPrefs.getString('device_location');
      if (spDeviceLocation != null && spDeviceLocation != '') {
        _deviceLocation = spDeviceLocation;
      }
    }
  }

  static Future<void> _loadCertificateCheckActive() async {
    // default value is false
    _certificateCheckActive = false;

    if (await _asyncPrefs.containsKey('certificate_check_active')) {
      bool? spCertificateCheckActive = await _asyncPrefs.getBool('certificate_check_active');
      if (spCertificateCheckActive != null) {
        _certificateCheckActive = spCertificateCheckActive;
        HttpOverrides.global = CertificateCheckHttpOverrides(spCertificateCheckActive);
      }
    }
  }

  static Future<void> resetToDefaultValues() async {
    await _asyncPrefs.remove('device_id');
    await _asyncPrefs.remove('backend_api_address');
    await _asyncPrefs.remove('device_location');
    await _asyncPrefs.remove('certificate_check_active');
    await _loadBackendApiAddress();
    await _loadDeviceId();
    await _loadDeviceLocation();
    await _loadCertificateCheckActive();
  }
}