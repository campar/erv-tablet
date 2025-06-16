import 'package:erv/model/api_error.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('ApiError.fromJson reads the backend error payload', () {
    final error = ApiError.fromJson({
      'code': '400',
      'message': 'Invalid action',
      'details': {'remainingSeconds': 30},
      'localizationKey': 'NO_CHECK_IN',
    });

    expect(error.code, '400');
    expect(error.message, 'Invalid action');
    expect(error.details, {'remainingSeconds': 30});
    expect(error.localizationKey, 'NO_CHECK_IN');
  });
}
