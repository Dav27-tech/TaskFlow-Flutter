import 'package:flutter_test/flutter_test.dart';
import 'package:taskflow/core/utils/invitation_code_generator.dart';

void main() {
  group('InvitationCodeGenerator Tests', () {
    test('1. generateInvitationCode should generate formatted code TFMA-XXXX-XXXX', () {
      final code = InvitationCodeGenerator.generateInvitationCode();

      expect(code, isNotEmpty);
      expect(code.startsWith('TFMA-'), isTrue);

      final parts = code.split('-');
      expect(parts.length, equals(3));
      expect(parts[0], equals('TFMA'));
      expect(parts[1].length, equals(4));
      expect(parts[2].length, equals(4));

      expect(InvitationCodeGenerator.isValidCode(code), isTrue);
    });

    test('generateInvitationCode should generate distinct unique codes', () {
      final code1 = InvitationCodeGenerator.generateInvitationCode();
      final code2 = InvitationCodeGenerator.generateInvitationCode();

      expect(code1, isNot(equals(code2)));
    });

    test('isValidCode should correctly validate formatted strings', () {
      expect(InvitationCodeGenerator.isValidCode('TFMA-7X3K-QP2L'), isTrue);
      expect(InvitationCodeGenerator.isValidCode('ABCD-1234-EF56'), isTrue);
      expect(InvitationCodeGenerator.isValidCode('INVALID_CODE'), isFalse);
      expect(InvitationCodeGenerator.isValidCode('TFMA-123'), isFalse);
      expect(InvitationCodeGenerator.isValidCode(''), isFalse);
    });
  });
}
