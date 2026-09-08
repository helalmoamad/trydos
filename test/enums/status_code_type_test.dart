import 'package:flutter_test/flutter_test.dart';
import 'package:trydos/enums/status_code_type.dart';

/// Test ledger · wave 01 Core runtime · unit "Status codes".
///
/// `getException` reads this table and nothing else, so a wrong number here
/// silently remaps every error in the app. Asserted directly rather than
/// through a request, so a break points at the cause instead of a symptom.
void main() {
  test('every status code maps to its own number', () {
    expect(StatusCode.operationSucceeded.code, 200);
    expect(StatusCode.createdSucceeded.code, 201);
    expect(StatusCode.operationFailed.code, 400);
    expect(StatusCode.unauth.code, 401);
    expect(StatusCode.serverError.code, 500);

    // Every value is covered above, and no two share a number — otherwise the
    // exception mapper could not tell them apart.
    final List<int> codes =
        StatusCode.values.map((StatusCode s) => s.code).toList();
    expect(codes, hasLength(StatusCode.values.length));
    expect(codes.toSet(), hasLength(codes.length),
        reason: 'two status codes share a number');
  });
}
