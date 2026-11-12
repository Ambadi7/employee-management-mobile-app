import 'package:equatable/equatable.dart';
import '../../../data/models/qr_session_model.dart';

abstract class QrGeneratorState extends Equatable {
  @override
  List<Object?> get props => [];
}

class QrGeneratorInitial extends QrGeneratorState {}

class QrGeneratorLoading extends QrGeneratorState {}

class QrGeneratorActive extends QrGeneratorState {
  final QrSessionModel session;
  final Duration remainingTime;

  QrGeneratorActive({required this.session, required this.remainingTime});

  @override
  List<Object?> get props => [session, remainingTime];
}

class QrGeneratorExpired extends QrGeneratorState {
  final String sessionId;

  QrGeneratorExpired(this.sessionId);

  @override
  List<Object?> get props => [sessionId];
}
