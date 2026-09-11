import 'dart:math';

/// Utility to generate random and unique invitation codes for TaskFlow projects.
/// Generates codes formatted as: TFMA-XXXX-XXXX (e.g., TFMA-7X3K-QP2L).
class InvitationCodeGenerator {
  InvitationCodeGenerator._();

  static const String _charset = '23456789ABCDEFGHJKLMNPQRSTUVWXYZ';
  static final Random _random = Random.secure();

  /// Generates a structured invitation code.
  /// Format: TFMA-XXXX-XXXX
  static String generateInvitationCode({String prefix = 'TFMA', int blockCount = 2, int blockSize = 4}) {
    final List<String> blocks = [prefix];
    for (int i = 0; i < blockCount; i++) {
      final buffer = StringBuffer();
      for (int j = 0; j < blockSize; j++) {
        final randomIndex = _random.nextInt(_charset.length);
        buffer.write(_charset[randomIndex]);
      }
      blocks.add(buffer.toString());
    }
    return blocks.join('-');
  }

  /// Validates whether a given code matches the expected invitation code format.
  static bool isValidCode(String code) {
    final regex = RegExp(r'^[A-Z0-9]{4}-[A-Z0-9]{4}-[A-Z0-9]{4}$');
    return regex.hasMatch(code.trim().toUpperCase());
  }
}
