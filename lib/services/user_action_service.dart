import 'dart:convert';

import 'package:hive/hive.dart';
import 'package:http/http.dart';
import 'package:logging/logging.dart';
import 'package:erv/model/api_error.dart';
import 'package:erv/model/action_type.dart';

import '../model/exceptions.dart';
import '../model/localization_error_msgs.dart';
import '../model/user_action.dart';
import 'api_service.dart';

class UserActionService {
  static final _log = Logger('UserActionService');
  static Box<UserAction>? _box;
  static const String defaultErrorMessage = 'Greška';

  static Future<void> processAction(String tagId, ActionType actionType) async {
    if (UserActionService.isUserActionCacheEmpty()) {
      try {
        Response response = await ApiService.postAction(tagId, actionType);
        // Throws exception if response is not valid
        validateResponse(response);
      } on ServiceUnavailableException {
        UserActionService.saveUserAction(UserAction(rfid: tagId, actionType: actionType.code, actionTime: DateTime.now()));
      }
    } else {
      UserActionService.saveUserAction(UserAction(rfid: tagId, actionType: actionType.code, actionTime: DateTime.now()));
    }
  }

  static void saveUserAction(UserAction userAction) {
    _log.info('SaveUserAction: Saving user action for later sending! Action: $userAction');
    userActionBox.add(userAction);
    _log.info('SaveUserAction: Number of cached actions: ${userActionBox.length}');
  }

  static bool isUserActionCacheEmpty() {
    return userActionBox.isEmpty;
  }

  static Future<void> sendAllUserActions() async {
    _log.info('SendAllUserActions: Start.');
    _log.info('SendAllUserActions: userActionBox keys: ${userActionBox.keys.toString()}.');
    for (var userAction in userActionBox.values) {
      try {
        _log.info('SendAllUserActions: Sending userAction with id: ${userAction.key}.');
        _log.fine('SendAllUserActions: userAction: ${userAction.toString()}.');
        Response response = await ApiService.postAction(userAction.rfid, ActionType.getActionType(userAction.actionType)!, actionTime: userAction.actionTime);
        if (response.statusCode >= 200 && response.statusCode < 300)  userAction.delete().then((x) => _log.info('Success. Deleted.'));
        if (response.statusCode == 400 || response.statusCode == 404)  userAction.delete().then((x) => _log.info('User error. Deleted.'));
      } catch (e, stackTrace) {
        _log.severe('SendAllUserActions: Error.', e, stackTrace);
      }
    }
    _log.info('SendAllUserActions: userActionBox keys after iterations: ${userActionBox.keys.toString()}.');
    _log.info('SendAllUserActions: End.');
  }

  static Box<UserAction> get userActionBox {
    _box ??= Hive.box('user_action');
    return _box!;
  }

  static void validateResponse(Response response) {
    _log.info('ValidateResponse: Status code: ${response.statusCode}.');
    switch (response.statusCode) {
      case int statusCode when statusCode == 400:
        throw ServiceUserError(getApiErrorMessage(response));
      case int statusCode when statusCode > 400 && statusCode < 500:
        throw const ServiceClientError(defaultErrorMessage);
      case int statusCode when statusCode >= 500 && statusCode < 600:
        throw const ServiceServerError(defaultErrorMessage);
      case int statusCode when statusCode >= 200 && statusCode < 300:
        break;
      default:
        _log.severe('ValidateResponse: Unexpected status code: ${response.statusCode}.');
        throw const ServiceUnexpectedResponseError(defaultErrorMessage);
    }
  }

  static String getApiErrorMessage(Response response) {
    try {
      ApiError apiError = ApiError.fromJson(json.decode(response.body));
      _log.fine('GetApiErrorMessage: localization key: ${apiError.localizationKey}, map: ${apiError.details}.');
      LocalizationErrorMsg? localErrorMsg = LocalizationErrorMsg.getLocalizationErrorMsg(apiError.localizationKey);
      _log.fine('GetApiErrorMessage: localErrorMsg: $localErrorMsg.');
      return localErrorMsg == null ? defaultErrorMessage : localErrorMsg.message;
    } catch (e, stackTrace) {
      _log.severe('GetApiErrorMessage: Error!', e, stackTrace);
      return defaultErrorMessage;
    }
  }
}