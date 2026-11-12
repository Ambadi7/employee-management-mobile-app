import 'package:equatable/equatable.dart';
import '../../../data/models/attendance_model.dart';

abstract class QrScannerState extends Equatable {
  final bool isTorchOn;
  const QrScannerState({this.isTorchOn = false});

  @override
  List<Object?> get props => [isTorchOn];
}

class QrScannerInitial extends QrScannerState {
  const QrScannerInitial({super.isTorchOn});
}

class QrScannerScanning extends QrScannerState {
  const QrScannerScanning({super.isTorchOn});
}

class QrScannerProcessing extends QrScannerState {
  final String statusMessage;
  const QrScannerProcessing({
    this.statusMessage = 'Validating QR code and capturing GPS...',
    super.isTorchOn,
  });

  @override
  List<Object?> get props => [statusMessage, isTorchOn];
}

class QrScannerSuccess extends QrScannerState {
  final AttendanceModel attendance;
  final String message;
  final bool isCheckIn;

  const QrScannerSuccess({
    required this.attendance,
    required this.message,
    required this.isCheckIn,
    super.isTorchOn,
  });

  @override
  List<Object?> get props => [attendance, message, isCheckIn, isTorchOn];
}

class QrScannerError extends QrScannerState {
  final String message;

  const QrScannerError(this.message, {super.isTorchOn});

  @override
  List<Object?> get props => [message, isTorchOn];
}
