import 'package:erv/model/localization_error_msgs.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LocalizationErrorMsg.getLocalizationErrorMsg', () {
    test('maps a backend error code to a localized message', () {
      final msg = LocalizationErrorMsg.getLocalizationErrorMsg('INVALID_CARD');

      expect(msg, LocalizationErrorMsg.invalidCard);
      expect(msg!.message, 'Neispravna kartica.');
    });

    test('ignores letter case', () {
      expect(
        LocalizationErrorMsg.getLocalizationErrorMsg('already_checked_in'),
        LocalizationErrorMsg.alreadyCheckedIn,
      );
    });

    test('returns null for an unknown code', () {
      expect(LocalizationErrorMsg.getLocalizationErrorMsg('SOMETHING_ELSE'), isNull);
    });
  });

  test('every error has a unique code', () {
    final codes = LocalizationErrorMsg.values.map((e) => e.code).toSet();
    expect(codes.length, LocalizationErrorMsg.values.length);
  });
}
