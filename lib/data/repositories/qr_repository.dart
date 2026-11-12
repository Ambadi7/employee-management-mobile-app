import 'package:uuid/uuid.dart';
import '../models/qr_session_model.dart';
import '../../core/constants/app_constants.dart';

class QrRepository {
  static const _uuid = Uuid();
  static QrSessionModel? _currentSession;

  QrSessionModel generateSession() {
    final now = DateTime.now().toUtc();
    final session = QrSessionModel(
      sessionId: 'SESSION_${_uuid.v4().substring(0, 8).toUpperCase()}',
      generatedAt: now,
      expiresAt: now.add(const Duration(minutes: AppConstants.qrExpiryMinutes)),
    );
    _currentSession = session;
    return session;
  }

  QrSessionModel? get currentSession => _currentSession;

  bool validateSession(QrSessionModel scannedSession) {
    if (scannedSession.isExpired) {
      return false;
    }
    // If a session is active in this admin/generator instance, ensure it matches
    if (_currentSession != null) {
      return _currentSession!.sessionId == scannedSession.sessionId &&
          !_currentSession!.isExpired;
    }
    // If scanning in standalone/separate session, validate based on timestamp expiry
    return !scannedSession.isExpired;
  }
}
