import 'dart:math' as math;

class InvitationCodeGenerator {
  InvitationCodeGenerator._();

  static String generateInvitationCode({int length = 8}) {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final random = math.Random();
    final buffer = StringBuffer();

    for (var i = 0; i < length; i++) {
      buffer.write(chars[random.nextInt(chars.length)]);
    }

    return buffer.toString();
  }
}
