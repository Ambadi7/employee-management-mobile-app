import 'package:flutter_test/flutter_test.dart';
import 'package:emp_management/data/models/qr_session_model.dart';
import 'package:emp_management/data/repositories/qr_repository.dart';

void main() {
  group('QR Session & Repository Tests', () {
    test('QR session generates valid JSON and parses accurately', () {
      final now = DateTime.now().toUtc();
      final expires = now.add(const Duration(minutes: 2));
      final session = QrSessionModel(
        sessionId: 'SESSION_TEST_123',
        generatedAt: now,
        expiresAt: expires,
      );

      final jsonString = session.toJsonString();
      expect(jsonString.contains('SESSION_TEST_123'), isTrue);

      final parsed = QrSessionModel.fromJsonString(jsonString);
      expect(parsed.sessionId, equals('SESSION_TEST_123'));
      expect(parsed.isExpired, isFalse);
    });

    test('Expired QR code is correctly marked as expired', () {
      final past = DateTime.now().toUtc().subtract(const Duration(minutes: 5));
      final expiredSession = QrSessionModel(
        sessionId: 'SESSION_EXPIRED',
        generatedAt: past.subtract(const Duration(minutes: 2)),
        expiresAt: past,
      );

      expect(expiredSession.isExpired, isTrue);
      expect(expiredSession.remainingTime, equals(Duration.zero));

      final repo = QrRepository();
      expect(repo.validateSession(expiredSession), isFalse);
    });

    test('Freshly generated session is valid and active', () {
      final repo = QrRepository();
      final session = repo.generateSession();

      expect(session.sessionId.startsWith('SESSION_'), isTrue);
      expect(session.isExpired, isFalse);
      expect(repo.validateSession(session), isTrue);
    });
  });
}
