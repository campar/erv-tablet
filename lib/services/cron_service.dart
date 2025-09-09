import 'package:cron/cron.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive/hive.dart';
import 'package:logging/logging.dart';
import 'package:erv/services/user_action_service.dart';

class CronService {
  static final _log = Logger('CronService');

  static void scheduleUserActionsJob() {
    final cron = Cron();
    cron.schedule(Schedule.parse(dotenv.env['ACTION_SERVICE_JOB_CRON_EXP']!), () async {
      _log.info('ScheduleUserActionsJob: Cron task start!');
      await UserActionService.sendAllUserActions();
      // stale actions cleanup
      Hive.box('user_action').values.where((action) => action.actionTime.isBefore(DateTime.now().subtract(const Duration(days: 60)))).forEach((item) {
        _log.info('ScheduleUserActionsJob: Deleting stale action - $item.');
        item.delete;
      });
      _log.info('ScheduleUserActionsJob: Cron task end!');
    });
  }
}