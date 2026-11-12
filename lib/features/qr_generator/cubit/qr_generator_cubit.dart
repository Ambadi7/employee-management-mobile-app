import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/qr_repository.dart';
import '../../../data/models/qr_session_model.dart';
import 'qr_generator_state.dart';

class QrGeneratorCubit extends Cubit<QrGeneratorState> {
  final QrRepository _qrRepository;
  Timer? _countdownTimer;

  QrGeneratorCubit({QrRepository? qrRepository})
      : _qrRepository = qrRepository ?? QrRepository(),
        super(QrGeneratorInitial());

  void generateQr() {
    _countdownTimer?.cancel();
    emit(QrGeneratorLoading());

    final session = _qrRepository.generateSession();
    emit(QrGeneratorActive(session: session, remainingTime: session.remainingTime));
    startExpiryCountdown(session);
  }

  void startExpiryCountdown(QrSessionModel session) {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (isClosed) {
        timer.cancel();
        return;
      }
      final remaining = session.remainingTime;
      if (remaining == Duration.zero) {
        timer.cancel();
        expireQr(session.sessionId);
      } else {
        emit(QrGeneratorActive(session: session, remainingTime: remaining));
      }
    });
  }

  void expireQr(String sessionId) {
    _countdownTimer?.cancel();
    if (!isClosed) {
      emit(QrGeneratorExpired(sessionId));
    }
  }

  @override
  Future<void> close() {
    _countdownTimer?.cancel();
    return super.close();
  }
}
