import 'package:flutter_test/flutter_test.dart';
import 'package:trydos/core/utils/validator.dart';

/// Test ledger · wave 01 Core runtime · unit "Form validators".
///
/// Every form in the app is gated by these. A validator returns `null` when the
/// input is acceptable and the error text when it is not.
///
/// One behaviour below is surprising enough to be pinned deliberately:
/// `RequiredValidator` passes `null`. That is how the code behaves today, so the
/// test says so out loud rather than pretending otherwise.
void main() {
  group('required', () {
    test('rejects empty, and whitespace-only once trimming is on', () {
      expect(requiredValidator()(''), isNotNull);

      // `trim` defaults to true, so spaces alone are not an answer.
      expect(requiredValidator()('   '), isNotNull);
      expect(requiredValidator(trim: false)('   '), isNull,
          reason: 'without trimming, spaces count as input');

      expect(requiredValidator()('ahmed'), isNull);
    });

    test('lets null through — a gap worth knowing about', () {
      // `(trim ? value?.trim() : value)?.isNotEmpty ?? true` falls back to
      // `true` when the value is null, so a field that was never touched is
      // treated as filled in. Pinned so a fix is a deliberate change.
      expect(requiredValidator()(null), isNull);
    });
  });

  test('email accepts a real address and rejects a broken one', () {
    expect(emailValidator()('user@example.com'), isNull);
    expect(emailValidator()('user.name+tag@sub.example.co'), isNull);

    expect(emailValidator()('example.com'), isNotNull, reason: 'no @');
    expect(emailValidator()('user@example'), isNotNull, reason: 'no domain dot');
    expect(emailValidator()('@example.com'), isNotNull, reason: 'no local part');
    expect(emailValidator()(''), isNotNull, reason: 'required runs first');
  });

  test('username must start with a letter and run 4 to 33 characters', () {
    expect(userNameValidator()('ahmed'), isNull);
    expect(userNameValidator()('a_b1'), isNull, reason: 'four is the minimum');
    expect(userNameValidator()('a${'x' * 32}'), isNull, reason: '33 is the max');

    expect(userNameValidator()('abc'), isNotNull, reason: 'three is too short');
    expect(userNameValidator()('a${'x' * 33}'), isNotNull, reason: '34 is too long');
    expect(userNameValidator()('1ahmed'), isNotNull, reason: 'leading digit');
    expect(userNameValidator()('_ahmed'), isNotNull, reason: 'leading underscore');
    expect(userNameValidator()(''), isNotNull, reason: 'required runs first');
  });

  test('password runs 8 to 20 characters', () {
    expect(passwordValidator()('x' * 8), isNull);
    expect(passwordValidator()('x' * 20), isNull);

    expect(passwordValidator()('x' * 7), isNotNull);
    expect(passwordValidator()('x' * 21), isNotNull);

    // `LengthRangeValidator` turns off the "ignore empty values" default, so an
    // empty password is rejected here rather than slipping through to a
    // required validator that may not be there.
    expect(passwordValidator()(''), isNotNull);
  });

  test('phone accepts exactly the allowed range', () {
    final String? Function(String?) phone = phoneValidator(9, 10);

    expect(phone('1' * 9), isNull, reason: 'the minimum is allowed');
    expect(phone('1' * 10), isNull, reason: 'the maximum is allowed');
    expect(phone('1' * 8), isNotNull, reason: 'one below the minimum');
    expect(phone('1' * 11), isNotNull, reason: 'one above the maximum');
  });

  test('cvv accepts three or four characters', () {
    expect(cvvNumberValidator()('123'), isNull);
    expect(cvvNumberValidator()('1234'), isNull);
    expect(cvvNumberValidator()('12'), isNotNull);
    expect(cvvNumberValidator()('12345'), isNotNull);
    expect(cvvNumberValidator()(''), isNotNull, reason: 'required runs first');
  });

  test('username-or-email passes when either side does', () {
    expect(userNameOrEmailValidator()('ahmed_99'), isNull, reason: 'a username');
    expect(userNameOrEmailValidator()('user@example.com'), isNull,
        reason: 'an email');
    expect(userNameOrEmailValidator()('1@'), isNotNull,
        reason: 'neither a username nor an email');
  });
}
