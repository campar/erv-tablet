import 'package:erv/model/action_type.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ActionType.getActionType', () {
    test('finds an action by its backend code', () {
      expect(ActionType.getActionType('CHECK_IN'), ActionType.checkIn);
      expect(ActionType.getActionType('BUSINESS_END'), ActionType.businessOutEnd);
    });

    test('ignores letter case', () {
      expect(ActionType.getActionType('pause_start'), ActionType.pauseStart);
    });

    test('returns null for an unknown code', () {
      expect(ActionType.getActionType('LUNCH'), isNull);
    });
  });

  test('every action has a unique code', () {
    final codes = ActionType.values.map((a) => a.code).toSet();
    expect(codes.length, ActionType.values.length);
  });
}
