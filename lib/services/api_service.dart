import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:android_id/android_id.dart';
import 'package:erv/services/user_action_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:logging/logging.dart';
import 'package:erv/utils/application_settings.dart';

import '../model/action_type.dart';
import '../model/exceptions.dart';
import '../utils/blocking_dialog.dart';
import '../utils/blocking_dialog_widget.dart';

class ApiService {
  static final _log = Logger('ApiService');
  static String? _androidId;
  static String? _authorizationHeaderData;
  static bool? _available;
  static int? _cachedTimestamp;
  static const Duration _cacheDuration = Duration(seconds: 60);
  static bool? _offloadingCachedData;

  static Future<Response> postAction(String tagId, ActionType actionType, {DateTime? actionTime}) async {
    Map<String, dynamic> data = {
      'rfid' : tagId,
      'actionType' : actionType.code,
      'deviceId' : await androidId,
      if (actionTime != null) 'dateTime' : actionTime.toIso8601String()
    };

    _log.fine('PostAction: Request body: ${jsonEncode(data)}.');
    _log.fine('PostAction: AuthorizationHeaderData: $authorizationHeaderData');
    try {
      final Response response =  await http.post(
          Uri.parse('https://${await AppSettings.getBackendApiAddress()}/api/external/device/action'),
          headers: {
            HttpHeaders.contentTypeHeader: "application/json",
            HttpHeaders.acceptHeader: "*/*",
            HttpHeaders.authorizationHeader: authorizationHeaderData
          },
          body: jsonEncode(data)).timeout(const Duration(seconds: 3));
      _log.fine('PostAction: Response header: ${response.headers.toString()}');
      _log.fine('PostAction: Status code: ${response.statusCode.toString()}');
      _log.fine('PostAction: Response body: ${response.body.toString()}');

      return response;
    } on SocketException catch (e, stackTrace) {
      _log.severe('PostAction: Backend unavailable!', e, stackTrace);
      throw const ServiceUnavailableException('Service not reachable.');
    } on TimeoutException catch (e, stackTrace) {
      _log.severe('PostAction: Backend unavailable!', e, stackTrace);
      throw const ServiceUnavailableException('Service timed out.');
    }
  }

  static Future<bool> _isReachable() async {
    try {
      final Response response =  await http.get(
          Uri.parse('https://${await AppSettings.getBackendApiAddress()}/api/external/ping/${await androidId}'),
          headers: {
            HttpHeaders.contentTypeHeader: "application/json",
            HttpHeaders.acceptHeader: "*/*",
            HttpHeaders.authorizationHeader: authorizationHeaderData
          }).timeout(const Duration(seconds: 3));
      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (e, stackTrace) {
      _log.severe('IsReachable: Error!', e, stackTrace);
      return false;
    }
  }

  static Future<String> get androidId async {
    _androidId ??= await getAndroidID();
    return _androidId!;
  }

  static bool get offloadingCachedData {
    if (_offloadingCachedData == null) return false;
    return _offloadingCachedData!;
  }

  static String get authorizationHeaderData {
    _authorizationHeaderData ??= 'Basic ${base64Encode(utf8.encode('${utf8.decode(base64Decode(dotenv.env['USER_NAME']!))}:${utf8.decode(base64Decode(dotenv.env['PASSWORD']!))}'))}';
    return _authorizationHeaderData!;
  }

  static Future<String> getAndroidID() async {
    final String? androidId = await const AndroidId().getId();
    return androidId ?? 'Unknown';
  }

  static Future<bool> isBackendAvailable({bool useCache = true}) async {
    _log.fine('IsBackendAvailable: available:$_available, cahcedTimestamp:$_cachedTimestamp, useCache:$useCache');
    if (_available != null && _cachedTimestamp != null && useCache) {
      final cacheAge = DateTime.now().millisecondsSinceEpoch - _cachedTimestamp!;

      if (cacheAge < _cacheDuration.inMilliseconds) {
        // Return the cached status if it's still valid
        return _available!;
      }
    }
    _log.fine('IsBackendAvailable: cache refresh.');
    _available = await _isReachable();
    if (_available!) {
      await offloadDataWhenAvailable();
    }
    _cachedTimestamp = DateTime.now().millisecondsSinceEpoch;
    return _available!;
  }

  static Future<void> offloadDataWhenAvailable() async {
    _log.info('ApiService.offloadDataWhenAvailable: Started!');
    if (UserActionService.isUserActionCacheEmpty()) return;
    showBlockingDialog(const BlockingDialog(message: "Sinhronizujem podatke..."));

    try {
      _offloadingCachedData = true;
      await UserActionService.sendAllUserActions();
    } finally {
      _offloadingCachedData = false;
      closeBlockingDialog();
    }
  }
}