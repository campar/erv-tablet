import 'package:hive/hive.dart';
part 'user_action.g.dart';

@HiveType(typeId: 1)
class UserAction extends HiveObject {

  UserAction({required this.rfid, required this.actionType, required this.actionTime});

  @HiveField(0)
  String rfid;
  @HiveField(1)
  String actionType;
  @HiveField(2)
  DateTime actionTime;

  @override
  String toString() {
    return 'UserAction (rfid: $rfid, actionType: $actionType, actionTime: $actionTime)';
  }
}