import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/models/qr_session_model.dart';
import '../../../data/repositories/attendance_repository.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/qr_repository.dart';
import '../../../core/services/location_service.dart';
import 'qr_scanner_state.dart';

class QrScannerCubit extends Cubit<QrScannerState> {
  final AttendanceRepository _attendanceRepository;
  final AuthRepository _authRepository;
  final QrRepository _qrRepository;
  bool _isProcessing = false;

  QrScannerCubit({
    AttendanceRepository? attendanceRepository,
    AuthRepository? authRepository,
    QrRepository? qrRepository,
  })  : _attendanceRepository = attendanceRepository ?? AttendanceRepository(),
        _authRepository = authRepository ?? AuthRepository(),
        _qrRepository = qrRepository ?? QrRepository(),
        super(const QrScannerInitial());

  void toggleTorch() {
    final nextTorch = !state.isTorchOn;
    if (state is QrScannerScanning) {
      emit(QrScannerScanning(isTorchOn: nextTorch));
    } else if (state is QrScannerProcessing) {
      emit(QrScannerProcessing(
        statusMessage: (state as QrScannerProcessing).statusMessage,
        isTorchOn: nextTorch,
      ));
    } else if (state is QrScannerInitial) {
      emit(QrScannerInitial(isTorchOn: nextTorch));
    }
  }

  void startScanning() {
    _isProcessing = false;
    emit(QrScannerScanning(isTorchOn: state.isTorchOn));
  }

  Future<void> scanQr(String qrData) async {
    // Prevent repeated processing of the same or multiple triggers
    if (_isProcessing) return;
    _isProcessing = true;

    emit(QrScannerProcessing(
      statusMessage: 'Verifying QR code data...',
      isTorchOn: state.isTorchOn,
    ));

    try {
      // 1. Parse QR data
      final QrSessionModel session;
      try {
        session = QrSessionModel.fromJsonString(qrData.trim());
      } catch (_) {
        emit(QrScannerError(
          'Invalid QR format. Please scan an authentic attendance QR code.',
          isTorchOn: state.isTorchOn,
        ));
        _isProcessing = false;
        return;
      }

      // 2. Validate session and expiry
      if (!validateQr(session)) {
        if (session.isExpired) {
          emit(QrScannerError(
            'This QR code has expired (valid for 2 mins). Please ask the admin to generate a new QR.',
            isTorchOn: state.isTorchOn,
          ));
        } else {
          emit(QrScannerError(
            'Invalid attendance QR session. Please scan the current active QR code.',
            isTorchOn: state.isTorchOn,
          ));
        }
        _isProcessing = false;
        return;
      }

      // 3. Check current logged-in employee
      final employee = await _authRepository.getLoggedInEmployee();
      if (employee == null) {
        emit(QrScannerError(
          'User session expired. Please log in again to mark attendance.',
          isTorchOn: state.isTorchOn,
        ));
        _isProcessing = false;
        return;
      }

      // 4. Update status to capturing GPS
      emit(QrScannerProcessing(
        statusMessage: 'Capturing GPS location coordinates...',
        isTorchOn: state.isTorchOn,
      ));

      // 5. Capture GPS coordinates with full error handling
      final position = await LocationService.getCurrentPosition();
      if (position == null) {
        emit(QrScannerError(
          'Could not retrieve GPS coordinates. Please ensure GPS is enabled.',
          isTorchOn: state.isTorchOn,
        ));
        _isProcessing = false;
        return;
      }

      // 6. Mark check-in or check-out in SQLite database
      emit(QrScannerProcessing(
        statusMessage: 'Saving attendance record to database...',
        isTorchOn: state.isTorchOn,
      ));

      await markAttendance(
        employeeId: employee.employeeId,
        employeeName: employee.name,
        latitude: position.latitude,
        longitude: position.longitude,
      );
    } catch (e) {
      final cleanMessage = e.toString().replaceFirst('Exception: ', '');
      emit(QrScannerError(cleanMessage, isTorchOn: state.isTorchOn));
      _isProcessing = false;
    }
  }

  bool validateQr(QrSessionModel session) {
    if (session.isExpired) return false;
    return _qrRepository.validateSession(session);
  }

  Future<void> markAttendance({
    required String employeeId,
    required String employeeName,
    required double latitude,
    required double longitude,
  }) async {
    try {
      final todayAttendance =
          await _attendanceRepository.getTodayAttendance(employeeId);
      final nowIso = DateTime.now().toIso8601String();

      if (todayAttendance == null) {
        // First successful scan -> Check-in
        final newRecord = await _attendanceRepository.checkIn(
          employeeId: employeeId,
          employeeName: employeeName,
          checkInTime: nowIso,
          latitude: latitude,
          longitude: longitude,
        );
        emit(QrScannerSuccess(
          attendance: newRecord,
          message: 'Check-in recorded successfully! Welcome.',
          isCheckIn: true,
          isTorchOn: state.isTorchOn,
        ));
      } else if (todayAttendance.status == 'checked_in') {
        // Second successful scan -> Check-out
        final updatedRecord = await _attendanceRepository.checkOut(
          employeeId: employeeId,
          checkOutTime: nowIso,
          latitude: latitude,
          longitude: longitude,
        );
        emit(QrScannerSuccess(
          attendance: updatedRecord,
          message: 'Check-out recorded successfully! Goodbye.',
          isCheckIn: false,
          isTorchOn: state.isTorchOn,
        ));
      } else if (todayAttendance.status == 'checked_out') {
        // Already checked out -> Prevent duplicate
        emit(QrScannerError(
          'You have already completed attendance (check-in and check-out) for today.',
          isTorchOn: state.isTorchOn,
        ));
        _isProcessing = false;
      } else {
        emit(QrScannerError(
          'Invalid attendance state for today.',
          isTorchOn: state.isTorchOn,
        ));
        _isProcessing = false;
      }
    } catch (e) {
      final cleanMessage = e.toString().replaceFirst('Exception: ', '');
      emit(QrScannerError(cleanMessage, isTorchOn: state.isTorchOn));
      _isProcessing = false;
    }
  }

  void reset() {
    _isProcessing = false;
    emit(QrScannerInitial(isTorchOn: state.isTorchOn));
  }
}
